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


// Session Hosts parameters

@description('Prefix for the Session Hosts')
param vmPrefix string

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

@description('Active Directory Domain to join the Session Hosts')
param domain string

@description('Domin Join account for joining Session Hosts')
param domainjoinaccount string

@description('Password for the Domain Join account')
@secure()
param domainjoinaccountpassword string

@description('The OU path of the Session Hosts in Active Directory. Make sure you use the DN')
param ouPath string

@description('Resource Group Name for identity scope')
param miResourceGroupName string

@description('hostToken for the Session Hosts')
param hostToken string


module sessionhosts './modules/sessionhost.bicep' = {
  name: 'sessionhosts-${time}'
  params: {
    location: location
    domain: domain
    domainjoinaccount: domainjoinaccount
    domainjoinaccountpassword: domainjoinaccountpassword
    localAdminUserName: localAdminUserName
    localAdminUserPassword: localAdminUserPassword
    managedIdentityName:  managedIdentityName
    miResourceGroupName: miResourceGroupName
    name: name
    ouPath: ouPath
    sessionhostscount: sessionhostscount
    subnetName: subnetName
    tags:tags
    vmPrefix: vmPrefix
    VMsize: VMsize
    vnetId: vnetId
    hostToken: hostToken
  }
}
