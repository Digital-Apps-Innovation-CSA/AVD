
@description('Location of the Log Analytics Workspace')
param location string = resourceGroup().location

@description('Mame of log Analytics Workspace')
param logAnalyticsWorkspaceName string = 'la-${uniqueString(resourceGroup().id)}'

var vmInsights = {
  name: 'VMInsights(${logAnalyticsWorkspaceName})'
  galleryName: 'VMInsights'
}

var environmentName = 'Production'
var costCenterName = 'AVD'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: {
    Environment: environmentName
    CostCenter: costCenterName
  }
  properties: any({
    retentionInDays: 90
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}


resource solutionsVMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: vmInsights.name
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: vmInsights.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}
