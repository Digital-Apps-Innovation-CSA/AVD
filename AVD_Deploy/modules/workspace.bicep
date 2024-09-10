@description('Name of AVD Workspace')
param name string

@description('Location of the AVD workspace')
param location string = resourceGroup().location

@description('Description of the AVD workspace')
param descriptionws string

@description('Friend Name of the AVD workspace')
param friendlyNameWs string

@description('Application Group assignment of the AVD workspace')
param applicationgroupid string

@description('Tags on the workspace of AVD')
param tags object

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-01-16-preview' = {
  name: 'ws-${name}'
  location: location
  tags: tags
  properties: {
    description: descriptionws
    friendlyName: friendlyNameWs
    applicationGroupReferences: [
      applicationgroupid
    ]

  }
}
