#!/bin/sh

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start docker and try again."
  exit 1
fi



# Set variables
sqlite_container_name="eval-app-sqlite"
app_mysql_container_name="eval-app-mysql"
mysql_container_name="eval-mysql"



# Stop containers
docker stop $sqlite_container_name
docker stop $app_mysql_container_name
docker stop $mysql_container_name



echo "Containers stopped"
exit 0
