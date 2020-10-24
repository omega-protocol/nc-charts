#!/bin/bash

set -eux

helm upgrade --install tekton-triggers ./tekton-triggers \
  --namespace tekton-pipelines
