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



## Start containers
# Start SQLite container
docker start $sqlite_container_name

# Start MySQL container
mysql_container_not_already_started=false
if [ $(docker ps -a -q -f name=$mysql_container_name) ] && [ ! $(docker ps -q -f name=$mysql_container_name) ]; then
  mysql_container_not_already_started=true
  docker start $mysql_container_name
fi

if $mysql_container_not_already_started; then
  # Wait for MySQL to be ready
  echo "Lauching MySQL..."
  while MYSQL_STATUS=$(docker inspect --format "{{.State.Health.Status}}" $mysql_container_name); [ $MYSQL_STATUS != "healthy" ]; do
    if [ $MYSQL_STATUS = "unhealthy" ]; then
      echo "MySQL Failed!"
      exit 1
    fi
    printf .
    sleep 1
  done
  printf "\n"
  echo "MySQL is ready!"
fi

# Start mysql app container
docker start $app_mysql_container_name



# Wait for SQLite container to be ready
while APP_SQLITE_STATUS=$(docker inspect --format "{{.State.Health.Status}}" $sqlite_container_name); [ "$APP_SQLITE_STATUS" != "healthy" ]; do
  if [ $APP_SQLITE_STATUS = "unhealthy" ]; then
    echo "SQLite app failed!"
    exit 1
  fi
  sleep 1
done
echo "SQLite App running at http://localhost:8001"

# Wait for MySQL container to be ready
while APP_MYSQL_STATUS=$(docker inspect --format "{{.State.Health.Status}}" $mysql_container_name); [ "$APP_MYSQL_STATUS" != "healthy" ]; do
  if [ $APP_MYSQL_STATUS = "unhealthy" ]; then
    echo "MySQL app failed!"
    exit 1
  fi
  sleep 1
done
echo "MySQL App running at http://localhost:8002"



echo "Containers started"
exit 0
