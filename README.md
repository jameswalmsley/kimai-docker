# Kimai-Docker

Dockerised time-management system.

# Start/Stop

    docker pull jameswalmsley/kimai-docker:v1.1.0-r1

The use the supplied docker-compose.yml file from github.

    docker-compose up
    docker-compose down

# Backups

    docker-compose run --rm kimai app:backup

The backup creates a folder called kimai-backup in the mounted path (/srv/docker/kimai).


