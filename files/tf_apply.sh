#!/bin/bash

pushd $1
terraform apply -no-color -auto-approve