#!/bin/sh

rg=aaampoc
deployName=$(date '+%Y%m%d%H%M%S')
az group create -g $rg -l southeastasia
az group deployment create -g $rg --template-file azuredeploy.json --parameters '@azuredeploy.parameters.json' --name $deployName --mode Complete
# Deploy Domain Controller
az group deployment create -g $rg --template-file aaampoc-extensions-deploy.json  --parameters '@azuredeploy.parameters.json' --name ${deployName}-extensions
az vm restart -g $rg --name vm1
# Join AD
az group deployment create -g $rg --template-file aaampoc-extensions-deploy2.json  --parameters '@azuredeploy.parameters.json' --name ${deployName}-extensions2
