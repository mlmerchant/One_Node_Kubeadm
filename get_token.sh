#!/bin/bash

# This chain of commands can be used to find the token needed to use the kubernetes dashboard.
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep demo-cluster-admin | awk '{print $1}')
