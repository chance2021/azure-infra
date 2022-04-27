#!/bin/bash

terraform init -backend-config=config/dev/config.tf -backend-config="access_key=$ACCOUNT_KEY"

terraform plan -var-file=config/dev/dev.tfvars -out deploy.tfplan

terraform apply deploy.tfplan
