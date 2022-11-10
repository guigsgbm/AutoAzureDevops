#!/bin/bash
export AZURE_DEVOPS_EXT_PAT=$(System.AccessToken)
az devops login

az devops user list --org https://dev.azure.com/guigsgbm