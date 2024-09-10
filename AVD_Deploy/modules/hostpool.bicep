@description('Name of AVD Hostpool')
param name string

@description('Tags on the AVD Hostpool')
param tags object

@description('Region of AVD Hostpool')
param location string = resourceGroup().location

@description('Type of AVD Hostpool')
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string

@description('Type of load balancing')
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param loadBalancerType string

@description('Maximum users for the session hosts')
param maxSessionLimit int

@description('Type of Application Group')
@allowed([
  'Desktop'
  'RailApplictions'
  'None'
])
param preferredAppGroupType string

@description('Sets the base time value in specified format')
param baseTime string = utcNow('u')

var tokenExpirationTime = dateTimeAdd(baseTime, 'PT48H')

resource hostpool 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' = {
  name: 'hp-${name}'
  location: location
  tags: tags
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
    maxSessionLimit: maxSessionLimit
    startVMOnConnect: true
    validationEnvironment: false
    customRdpProperty: 'redirectprinters:i:0;redirectsmartcards:i:1;enablecredsspsupport:i:1;use multimon:i:1;autoreconnection enabled:i:1;dynamic resolution:i:1;smart sizing:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;camerastoredirect:s:*;redirected video capture encoding quality:i:0;audiomode:i:0'
    registrationInfo: {
      expirationTime: tokenExpirationTime
      token: null
      registrationTokenOperation: 'Update'
  }
}

}


output id string = hostpool.id

