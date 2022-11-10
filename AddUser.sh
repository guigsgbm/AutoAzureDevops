#!/bin/bash
env | grep '^__.*__'

echo $__PAT__ | az devops login
az devops user list --org https://dev.azure.com/guigsgbm/
az devops logout