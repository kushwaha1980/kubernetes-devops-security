#!/bin/bash

sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
kubectl -n default get deployment ${deploymentName} > /dev/null

if [[ $? -ne 0 ]]; then
    echo "deployment ${deploymentName} doesn't exists"
    kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "deployment ${deploymentName} exists"
    echo "image name - ${imageName}"
    kubectl -n default set image deployment.v1.apps/${deploymentName} ${containerName}=${imageName} --record=true
fi
