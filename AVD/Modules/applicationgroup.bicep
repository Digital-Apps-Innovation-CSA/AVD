// Parameters used for the Application Groups

@description( 'Name of the application group')
param name string

@description('Friendly Name of Application Group')
param friendlyNameApg string

@description('Tags for the Application Groups')
param tags object

@description('Region the Application Group')
param location string = resourceGroup().location

@description('Hostpool ID: Needed for applying to the right hostpool')
param hostPoolId string

resource applicationgroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-01-16-preview' = {
  name: 'apg-${name}'
  location: location
  tags: tags
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPoolId
    friendlyName: friendlyNameApg
  }
}

output id string = applicationgroup.id
