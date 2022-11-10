#!/bin/bash
export AZURE_DEVOPS_EXT_PAT='$(System.AccessToken)'
echo AZURE_DEVOPS_EXT_PAT | az devops login

az devops user list --org https://dev.azure.com/guigsgbm