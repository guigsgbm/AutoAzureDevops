#!/bin/bash
export AZURE_DEVOPS_EXT_PAT=$__PAT__
az devops login
env | grep '^__.*__'

az devops user list --org https://dev.azure.com/guigsgbm/
az devops logout