#!/bin/bash
for test in 1.2.21 1.2.23 1.2.24; do 
  result=$(kube-bench run --targets master --check $test --json | jq .[].tests[].results[].status | tr -d '"')
  if [[ "$result" == "FAIL" ]]; then
    echo "CIS Benchmark Failed Kubelet while testing for $test"
    exit_code=1
  else
    echo "CIS Benchmark Passed Kubelet for $test"
  fi
done

if [[ "$exit_code" -ne 0 ]]; then
  exit 1
fi

