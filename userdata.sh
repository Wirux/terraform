#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker docker.io docker-compose -y
# Start Docker service
sudo service docker start
#mkdir /home/ubuntu/docker-compose
#sudo docker pull adminer
#sudo docker run --link some_database:db -p 8080:8080 adminer
sudo docker-compose -f /home/ubuntu/docker-compose.yaml up -d
