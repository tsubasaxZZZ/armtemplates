param keyName string
param userAssignedManagedIdentityResourceId string
resource sshkey 'Microsoft.Compute/sshPublicKeys@2022-08-01' = {
  name: keyName
  location: location
}

param utcValue string = utcNow()
param location string = resourceGroup().location

resource runBashWithOutputs 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runBashWithOutputs'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityResourceId}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.40.0'
    timeout: 'PT30M'
    arguments: sshkey.id
    scriptContent: 'az rest --method post --url https://management.azure.com/$1/generateKeyPair?api-version=2022-08-01 > $AZ_SCRIPTS_OUTPUT_PATH'
    retentionInterval: 'PT1H'
  }

}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: runBashWithOutputs
  name: 'default'
}

output log string = logs.properties.log
// This is for testing purposes only. Do not output privateKey in production.
output privateKey string = runBashWithOutputs.properties.outputs['privateKey']
output publicKey string = runBashWithOutputs.properties.outputs['publicKey']
