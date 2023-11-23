#!/bin/sh

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start docker and try again."
  exit 1
fi



# Set variables
sqlite_image_name="eval-app-sqlite"
app_mysql_image_name="eval-app-mysql"
mysql_image_name="eval-mysql"

sqlite_container_name=$sqlite_image_name
app_mysql_container_name=$app_mysql_image_name
mysql_container_name=$mysql_image_name

sqlite_volume_name="eval-sqlite-data"
mysql_volume_name="eval-mysql-data"

mysql_network_name="eval-mysql"



# Stop and Remove containers
docker rm $sqlite_container_name -f
docker rm $mysql_container_name -f
docker rm $app_mysql_container_name -f



# Remove network
docker network rm $mysql_network_name



for flag in $@; do

  # Remove volumes if -v flag is passed
  if [ $flag = "-v" ]; then
    echo "two is in the list"
    docker volume rm $sqlite_volume_name -f
    docker volume rm $mysql_volume_name -f
  fi

  # Remove images if -i flag is passed
  if [ $flag = "-i" ]; then
    docker image rm $sqlite_image_name -f
    docker image rm $app_mysql_image_name -f
    docker image rm $mysql_image_name -f
  fi

done



exit 0
