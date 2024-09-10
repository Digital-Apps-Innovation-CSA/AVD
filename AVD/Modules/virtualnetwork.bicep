@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object

@description('Name of the virtual network resource')
param name string

@description('Group ID of the network security group')
param networkSecurityGroupId string

@description('Virtual network address prefix')
param vnetAddressPrefix string 

@description('subnet address prefix')
param SubnetPrefix string 

@description('DNS Settings for the VNET')
param dnsServer string

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vn-${name}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: (!empty(dnsServer) ? {
      dnsServers: [
        dnsServer
      ]
    } : json('null'))
    subnets: [
      { 
        name: 'sn-${name}'
        properties: {
          addressPrefix: SubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
    ]
  }
}

output id string = virtualnetwork.id
output name string = virtualnetwork.name
