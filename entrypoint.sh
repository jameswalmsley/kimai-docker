#!/bin/bash
set -e

[[ $DEBUG == true ]] && set -x

init_services()
{
        supervisord

        while ! mysqladmin ping; do
                sleep 1
        done
}

init_kimai() {

	VOLUME_HOME="/var/lib/mysql"

	sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    		-e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
	if [[ ! -d $VOLUME_HOME/mysql ]]; then
    		echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    		echo "=> Installing MySQL ..."
    		mysql_install_db
    		echo "=> Done!"
    		/create_mysql_admin_user.sh
	else
    		echo "=> Using an existing volume of MySQL"
	fi

	init_services

	#ISSUE: these rows are ignored ...
	mysqladmin -uadmin -ppass create kimai || true
}

init_database() {
	COUNT=$(mysql -ss -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'kimai';")
	echo "$COUNT"

	if [[ -z ${COUNT} || ${COUNT} -eq 0 ]]; then
	    echo "Setting up Kimai for firstrun. Please be patient, this could take a while..."
	    mysql < /kimai.sql
  	fi
}

case ${1} in
  app:init|app:start|app:backup|app:restore)

    case ${1} in
      app:start)
	init_kimai
	init_database
	while true; do sleep 1000; done
        ;;
      app:init)
        ;;
      app:backup)
	init_services
	echo "USE kimai;" > /var/lib/mysql/kimai.sql
	mkdir -p /var/lib/mysql/kimai-backups/
	mkdir -p /var/lib/mysql/kimai-backup/
        mysqldump --databases kimai >> /var/lib/mysql/kimai-backup/kimai.sql
	cp /var/www/html/includes/autoconf.php /var/lib/mysql/kimai-backup/
	zip -r kimai-backup.zip kimai-backup
	rm -rf /var/lib/mysql/kimai-backup
        ;;
      app:restore)
	init_services
	mysql < /var/lib/mysql/kimai-backup/kimai.sql
	;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:start        - Starts the kimai server (default)"
    echo " app:init         - Initialize the kimai server (e.g. create databases, compile assets), but don't start it."
    echo " app:sanitize     - Fix repository/builds directory permissions."
    echo " app:rake <task>  - Execute a rake task."
    echo " app:help         - Displays the help"
    echo " [command]        - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac

