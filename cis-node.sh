#!/bin/bash
total_fail=$(kube-bench run --targets node --check=4.2.6 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]]; then
  echo "CIS Benchmark Failed node"
  exit 1
else
  echo "CIS Benchmark Passed node"
fi

