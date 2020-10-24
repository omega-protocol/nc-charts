#!/bin/bash

set -eux

helm upgrade --install tekton-dashboard ./tekton-dashboard \
  --namespace tekton-pipelines
