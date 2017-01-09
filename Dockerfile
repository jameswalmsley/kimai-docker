FROM pliguori/lamp
MAINTAINER James Walmsley <james@fullfat-fs.co.uk>

# INstall Prereqs
RUN apt-get update
RUN apt-get install -y wget unzip git zip

RUN wget -O /tmp/kimai.zip https://github.com/kimai/kimai/releases/download/1.1.0/kimai_1.1.0.zip
RUN rm -fr /var/www/html/*
RUN unzip /tmp/kimai.zip  -d /var/www/html/
RUN mkdir -p /var/www/html/mobile/
RUN git clone https://github.com/kimai/kimai-mobile.git /var/www/html/mobile/
COPY autoconf.php /var/www/html/includes/autoconf.php

RUN chown -R www-data:www-data /var/www/html/*

ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

COPY kimai.sql /kimai.sql

EXPOSE 80

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]

