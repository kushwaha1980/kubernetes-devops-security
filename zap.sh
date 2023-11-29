#!/bin/bash

#echo "$(kubectl -n default get svc ${serviceName})"


PORT=$(sudo kubectl -n default get svc $serviceName -o json | jq .spec.ports[].nodePort)

# first run this
sudo chmod 777 $(pwd)
echo $(id -u):$(id -g)
#docker run -u 0 -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t http://mydevsecops.eastus.cloudapp.azure.com:30372/v3/api-docs -f openapi -r zap_report.html

docker run -u 0 -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -r zap_report.html

exit_code=$?

# HTML Report
sudo mkdir -p owasp-zap-report
sudo chmod 777 owasp-zap-report
sudo mv zap_report.html owasp-zap-report


echo "Exit Code : $exit_code"

 if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1;
   else
    echo "OWASP ZAP did not report any Risk"
 fi;
