#!/bin/bash

set -eux

helm delete --purge tekton-triggers
kubectl -n tekton-pipelines get crd | grep triggers | awk '{print $1}' | xargs kubectl -n tekton-pipelines delete crd
