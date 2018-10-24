#!/bin/bash
#
# `docker images` returns data sorted by time, no need to sort
# we check if container running, if not, starting previous image and log to `1` to failed.conter
#
docker pull localhost:5000/nginx:test

latest=""
second=""
counter=0
while read line
do
	id=$(echo ${line} | awk '{ print $1 }')
	if [ -z ${latest} ]; then
		latest=${id}
	fi
	if [ -z ${second} ]; then
	    if [ ${counter} -eq "1" ]; then
	    	second=${id}
	    fi
	fi
	if [ "$counter" -gt 1 ]; then
		docker rmi ${id}
	fi
	let counter=counter+1

done <<EOT
$(docker images localhost:5000/nginx --all --format "{{.ID}} {{.CreatedAt}}")
EOT

nginxcontid=$(docker ps -a -q --filter="name=nginx_test_cont")
nginxcontstate=$(docker inspect -f {{.State.Running}} ${nginxcontid})
status_code=$(curl --write-out %{http_code} --silent --output /dev/null 127.0.0.1:7072)
if [ ${status_code} -eq 200 -a ${nginxcontstate} = "true" ]
then
    echo "Ok"
else
	docker stop $(docker ps --filter "name=nginx_test_cont" -q)
	docker rm $(docker ps --filter "status=exited" --filter "name=nginx_test_cont" -q)
	docker run --name nginx_test_cont -d -p 7072:80 ${second}
	echo 1 > /tmp/failed.counter
fi
