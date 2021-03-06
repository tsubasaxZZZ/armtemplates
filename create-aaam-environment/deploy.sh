#!/bin/sh

if [ x"$1" = x"" ]; then
    echo "Please provide RG name."
    exit 1
fi

git clone https://github.com/tsubasaxZZZ/armtemplates.git
cd armtemplates/create-aaam-environment
rg=$1
deployName=$(date '+%Y%m%d%H%M%S')
az group create -g $rg -l southeastasia
az group deployment create -g $rg --template-file azuredeploy.json --parameters '@azuredeploy.parameters.json' --name $deployName
# Deploy Domain Controller
az group deployment create -g $rg --template-file aaampoc-extensions-deploy.json  --parameters '@azuredeploy.parameters.json' --name ${deployName}-extensions
az vm restart -g $rg --name vm1
az vm restart -g $rg --name vm3
# Join AD
az group deployment create -g $rg --template-file aaampoc-extensions-deploy2.json  --parameters '@azuredeploy.parameters.json' --name ${deployName}-extensions2
