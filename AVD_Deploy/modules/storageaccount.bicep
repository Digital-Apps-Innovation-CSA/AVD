@description('Specifies the name of the Azure Storage account.')
param storageAccountName string = 'fslogix${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the File Share. File share names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only.')
@minLength(3)
@maxLength(63)
param fileShareName string

@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@description('Sizing of the fileshare in GB')
param shareQuota int

@description('Tags on the storage account')
param tags object

resource safslogix 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  tags: tags
  location: location
  kind: 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${safslogix.name}/default/${fileShareName}'
   properties: {
    enabledProtocols: 'SMB'
    shareQuota: shareQuota
   }
}

output storageId string = safslogix.id
