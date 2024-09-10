@description('Resource Groupname of exiwting VNET for the peering')
param vnetResourceGroupName string

@description('Existing VNET Name for the VNET peering')
param vnetName string

@description('Remote Subscription ID for the VNET peering')
param remoteVnetSubscriptionId string

@description('Remote resource group name for the VNET peering')
param remoteVnetRsourceGroupName string

@description('Remote VNET Name from an existing VNET')
param remoteVnetName string

resource remoteVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: remoteVnetName
  scope: resourceGroup(remoteVnetSubscriptionId, remoteVnetRsourceGroupName)
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${remoteVnetName}/${remoteVnetName}_to_${virtualNetwork.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
  }

  dependsOn: [
    remoteVirtualNetwork
  ]
}
