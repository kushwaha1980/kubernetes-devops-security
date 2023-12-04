#!/bin/bash

sleep 60

if [[ $(kubectl -n devsecops-istio rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]
then
    echo "Deployment ${deploymentName} has failed"
    kubectl -n devsecops-istio rollout undo deploy ${deploymentName}
    exit 1
else
    echo "Deployment ${deploymentName} is Success"
fi
