// General parameters for multiple resources

@description('Naming the resource in the deployment')
param name string

@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object

@description('Managed Identity Name')
param managedIdentityName string

@description('Type of AVD Hostpool')
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string

//Parameter for deploying resources
@description('Parameter for the deploymentname time window, this will be visible in the Azure portal on the resource group')
param time string = replace(utcNow(), ':', '-')

// VNET parameters

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('subnet address prefix')
param SubnetPrefix string

@description('DNS Settings for the VNET')
param dnsServer string


// VNET Peering parameters

@description('VNET peering needs to be deployed')
param vnetpeeringdeploy bool

@description('Hub VNET name to connect the peering')
param hubVnetName string

@description('Hub resource group name for VNET peering')
param hubVnetRgName string

// Network Security Group parameters (information available in general parameters)


// Hostpool parameters

@description('Maximum users for the session hosts')
param maxSessionLimit int

// Applicationgroup parameters

@description('Friendly Name of Application Group')
param friendlyNameApg string

// Scalingplan parameters

@description('Scalingplan needs to be deployed')
param scalingplandeploy bool

@description('Exclusion Tag for exclusing session hosts from the scalingplan')
param exclusionTag string

@description('Friendly name of the scalingplan')
param friendlyNameSC string

@description('Name of scedule')
param nameSchedule string

@description('ScalingPlan Enabled or not')
param scalingPlanEnabled bool

@description('Rampdown Notification for users to log off')
param rampDownNotificationMessage string

// Workspace parameters

@description('Description of the AVD workspace')
param descriptionws string

@description('Friend Name of the AVD workspace')
param friendlyNameWs string

// Storage account parameters (FSLogix)

@description('Storage account needs to be deployed')
param storagedeploy bool

@description('Specifies the name of the Azure Storage account.')
param storageAccountName string = 'fslogix${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the File Share. File share names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only.')
@minLength(3)
@maxLength(63)
param fileShareName string

@description('Sizing of the fileshare in GB')
param shareQuota int

// Identity parameters for User Managed Assigned Identity

@description('The IDs of the role definitions to assign to the managed identity. Each role assignment is created at the resource group scope. Role definition IDs are GUIDs. To find the GUID for built-in Azure role definitions, see https://docs.microsoft.com/azure/role-based-access-control/built-in-roles. You can also use IDs of custom role definitions.')
param roleDefinitionIds array

// Monitoring parameters for Insights on AVD (All parameters are already configured in the bicep file)


module networksecuritygroup 'modules/networksecuritygroup.bicep' = {
  name: 'networksecuritygroup-${time}'
  params: {
    name: name
    tags: tags
    location: location
  }
}

module virtualnetwork 'modules/virtualnetwork.bicep' = {
  name: 'virtualnetwork-${time}'
  params: {
    name: name
    tags: tags
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    SubnetPrefix: SubnetPrefix
    dnsServer: dnsServer
    networkSecurityGroupId: networksecuritygroup.outputs.id
  }
}

// Mainly needed when there is no domain connectivity in the created VNET
module vnetpeering01 'modules/vnetpeering.bicep' = if (vnetpeeringdeploy) {
  name: 'vnetpeering01-${time}'
  scope: resourceGroup()
  params: {
    remoteVnetName: virtualnetwork.outputs.name
    remoteVnetRsourceGroupName: resourceGroup().name
    remoteVnetSubscriptionId: subscription().id
    vnetName: hubVnetName
    vnetResourceGroupName: hubVnetRgName
  }
}

// Mainly needed when there is no domain connectivity in the created VNET
module vnetpeering02 'modules/vnetpeering.bicep' = if (vnetpeeringdeploy) {
  name: 'vnetpeering02-${time}'
  scope: resourceGroup(hubVnetRgName)
  params: {
    remoteVnetName: hubVnetName
    remoteVnetRsourceGroupName: hubVnetRgName
    remoteVnetSubscriptionId: subscription().id
    vnetName: virtualnetwork.outputs.name
    vnetResourceGroupName: resourceGroup().name
  }
}

module hostpool 'modules/hostpool.bicep' = {
  name: 'hostpool-${time}'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolType: 'Pooled'
    maxSessionLimit: maxSessionLimit
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

module applicationgroup 'modules/applicationgroup.bicep' = {
  name: 'applicationgroup-${time}'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolId: hostpool.outputs.id
    friendlyNameApg: friendlyNameApg
  }
}

module scalingplan 'modules/scalingplan.bicep' = if (scalingplandeploy) {
  name: 'scalingplan-${time}'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolType: hostPoolType
    exclusionTag: exclusionTag
    friendlyNameSC: friendlyNameSC
    scalingPlanEnabled: scalingPlanEnabled
    nameSchedule: nameSchedule
    hostPoolId: hostpool.outputs.id
    rampDownNotificationMessage: rampDownNotificationMessage
  }
}

module workspace 'modules/workspace.bicep' = {
  name: 'workspace-${time}'
  params: {
    name: name
    tags: tags
    location: location
    applicationgroupid: applicationgroup.outputs.id
    descriptionws: descriptionws
    friendlyNameWs: friendlyNameWs
  }
}

module storageaccount 'modules/storageaccount.bicep' = if (storagedeploy) {
  name: 'storageaccount-${time}'
  params: { 
    storageAccountName: storageAccountName
    fileShareName: fileShareName
    tags: tags
    location: location
    shareQuota: shareQuota
  }
}

module identity 'modules/identity.bicep' = {
  name: 'identity-${time}'
  params: {
    location: location
    managedIdentityName: managedIdentityName
    roleDefinitionIds: roleDefinitionIds
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-${time}'
  params: {
    location:location
  }
}
