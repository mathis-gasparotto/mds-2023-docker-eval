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

mysql_root_password="secret"
mysql_db="eval"



# Build images
if [ ! $(docker images -q $sqlite_image_name) ]; then
  docker build -t $sqlite_image_name -f ./sqlite.Dockerfile .
fi
if [ ! $(docker images -q $app_mysql_image_name) ]; then
  docker build -t $app_mysql_image_name -f ./app.Dockerfile .
fi
if [ ! $(docker images -q $mysql_image_name) ]; then
  docker build -t $mysql_image_name -f ./mysql.Dockerfile .
fi



# Create network
if [ ! $(docker network ls --format true --filter name=$mysql_network_name) ]; then
  docker network create $mysql_network_name
fi



## Run containers
# If container does not exist
if [ ! $(docker ps -a -q -f name=$sqlite_container_name) ]; then
  docker run -dp 8001:3001 --name $sqlite_container_name -v $sqlite_volume_name:/etc/todos -w /app $sqlite_image_name sh -c "yarn install && yarn run dev"
# Else if container does not running
elif [ ! $(docker ps -q -f name=$sqlite_container_name) ]; then
  docker start $sqlite_container_name
fi

mysql_container_not_already_started=false
if [ ! $(docker ps -a -q -f name=$mysql_container_name) ]; then
  mysql_container_not_already_started=true
  docker run -d --network $mysql_network_name --network-alias mysql --name $mysql_container_name -v $mysql_volume_name:/var/lib/mysql -e MYSQL_HOST=mysql -e MYSQL_ROOT_PASSWORD=$mysql_root_password -e MYSQL_DATABASE=$mysql_db $mysql_image_name
elif [ ! $(docker ps -q -f name=$mysql_container_name) ]; then
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

# Run mysql app container
if [ ! $(docker ps -a -q -f name=$app_mysql_container_name) ]; then
  docker run -dp 8002:3001 --network $mysql_network_name --network-alias app --name $app_mysql_container_name -e MYSQL_HOST=mysql -e MYSQL_USER=root -e MYSQL_PASSWORD=$mysql_root_password -e MYSQL_DB=$mysql_db -w /app $app_mysql_image_name sh -c "yarn install && yarn run dev"
elif [ ! $(docker ps -q -f name=$app_mysql_container_name) ]; then
  docker start $app_mysql_container_name
fi



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



exit 0
