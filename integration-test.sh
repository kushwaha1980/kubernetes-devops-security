#!/bin/bash

sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo $PORT
echo $applicationURL:$PORT/$applicationURI

if [[ ! -z "$PORT" ]];
then
    response=$(curl -s $applicationURL:$PORT/$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT/$applicationURI)

    if [[ "$response" == 0 ]];
    then
        echo "Increment test passed"
    else
        echo "Increment test failed"
        exit 1;
    fi;

    if [[ "$http_code" == 200 ]];
    then
        echo "HTTP code test passed"
    else
        echo "HTTP code test failed"
        exit 1;
    fi;
else
    echo "service doesn't have nodeport"
    exit 1;
fi;
