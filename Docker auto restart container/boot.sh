#!/bin/bash
docker stop $(docker ps --filter "name=nginx_test_cont" -q)

docker run -d -p 5000:5000 --name registry registry:2
docker pull nginx:latest
docker tag nginx:latest localhost:5000/nginx:test
docker rmi nginx:latest
docker push localhost:5000/nginx:test
docker rmi localhost:5000/nginx:test
docker pull localhost:5000/nginx:test
echo ENV E=$(date +%s) >> Dockerfile
docker build -t localhost:5000/nginx:test .
docker push localhost:5000/nginx:test
docker rmi localhost:5000/nginx:test
docker pull localhost:5000/nginx:test
echo ENV E=$(date +%s) >> Dockerfile 
docker build -t localhost:5000/nginx:test .
docker push localhost:5000/nginx:test
docker rmi localhost:5000/nginx:test
docker pull localhost:5000/nginx:test