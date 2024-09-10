@description('Name of the Hostpool to add the session hosts')
param name string

@description('Tags for the Session Hosts')
param tags object

@description('Prefix for the Session Hosts')
param vmPrefix string

@description('Region of the Session Hosts')
param location string = resourceGroup().location

@description('Number of session hosts to enroll')
param sessionhostscount int

@description('Adding the VNET to the Session Hosts with an ID')
param vnetId string

@description('Adding the Subnet name to the Session Hosts')
param subnetName string

@description('Sizing of the VM for the Session Hosts')
param VMsize string

@description('Local Admin name for creating the Session Hosts')
param localAdminUserName string

@description('Password users for the Local admin account')
@secure()
param localAdminUserPassword string

@description('Licensing type for the Session Hosts')
param licenseType string = 'Windows_Client'

@description('Active Directory Domain to join the Session Hosts')
param domain string

@description('Domin Join account for joining Session Hosts')
param domainjoinaccount string

@description('Password for the Domain Join account')
@secure()
param domainjoinaccountpassword string

@description('Domain join options, this field is needed to determine the options to join the Session Hosts. The default is 3')
param domainJoinOptions int = 3

@description('The OU path of the Session Hosts in Active Directory. Make sure you use the DN')
param ouPath string

@description('Managed Identity Name')
param managedIdentityName string

@description('Resource Group Name for identity scope')
param miResourceGroupName string

var avSetSKU = 'Aligned'

@description('Resource Group Name for identity scope')
param hostToken string


// Connecting the Session Hosts to the right Hostpool with following information. Needed for the AVD agent.

resource hostPoolToken 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' existing = {
  name: 'hp-${name}'
}

resource sessionhostnic 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, sessionhostscount): {
  name: 'nic-${take(name, 10)}-${i +1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetId}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
      
    ]
  }

}]

resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-09-01' = {
  name: '${vmPrefix}-avs'
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
  sku: {
    name: avSetSKU
  }
}

resource sessionHosts 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in range(0, sessionhostscount): {
  name: 'sh${take(name, 10)}-${i +1}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: VMsize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', '${vmPrefix}-avs')
    }
    osProfile: {
      computerName: 'sh${take(name, 10)}-${i + 1}'
      adminUsername: localAdminUserName
      adminPassword: localAdminUserPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-23h2-avd'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: sessionhostnic[i].id
        }
     ]
  }
}

  dependsOn: [
    sessionhostnic[i]
    availabilitySet
  ]
}]

resource domainjoinsessionhosts 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [for i in range(0, sessionhostscount): {
  name: '${sessionHosts[i].name}/JoinDomain'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
  dependsOn: [
    sessionHosts[i]
  ]
}]

resource avdagentsessionhosts 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [for i in range(0, sessionhostscount): {
  name: '${sessionHosts[i].name}/AddSessionHost'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolToken.name
        registrationInfoToken: hostToken
      }
    }
  }

  dependsOn: [
    domainjoinsessionhosts[i]
  ]
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = { 
  name: managedIdentityName
  scope: resourceGroup(miResourceGroupName)
}


resource azuremonitoringagent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, sessionhostscount): {
  name: '${sessionHosts[i].name}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': managedIdentity.id
        }
      }
    }
  }
}]
