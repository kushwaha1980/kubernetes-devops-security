#!/bin/bash
total_fail=$(kube-bench run --targets etcd --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]]; then
  echo "CIS Benchmark Failed etcd"
  exit 1
else
  echo "CIS Benchmark Passed etcd"
fi

