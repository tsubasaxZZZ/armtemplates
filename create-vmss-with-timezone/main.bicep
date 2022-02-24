param subnetId string
param imageReferenceId string
@secure()
param adminPassword string
param adminUsername string
param vmssName string = 'vmssarm'
param location string = resourceGroup().location

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-11-01' = {
  name: vmssName
  location: location
  sku: {
    capacity: 2
    name: 'Standard_B2ms'
    tier: 'Standard'
  }
  properties: {
    doNotRunExtensionsOnOverprovisionedVMs: false
    orchestrationMode: 'Uniform'
    overprovision: true
    platformFaultDomainCount: 2
    scaleInPolicy: {
      rules: [
        'Default'
      ]
    }
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      extensionProfile: {
        extensions: []
      }
      licenseType: 'Windows_Server'
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vnet-vmsss0224-nic-1'
            properties: {
              dnsSettings: {
                dnsServers: []
              }
              enableAcceleratedNetworking: false
              ipConfigurations: [
                {
                  name: 'vnet-vmsss0224-ip-1-ipconfig'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        adminPassword: adminPassword
        adminUsername: adminUsername
        computerNamePrefix: 'vmssarm'
        secrets: [
        ]
        windowsConfiguration: {
          enableAutomaticUpdates: true
          provisionVMAgent: true
          timeZone: 'Tokyo Standard Time'
        }
      }
      storageProfile: {
        imageReference: {
          id: imageReferenceId
        }
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          caching: 'ReadWrite'
        }
      }
    }
  }
}
