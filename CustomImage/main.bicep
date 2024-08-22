// Define parameters for the Bicep template
param location string = resourceGroup().location
param imagetemplatename string
param azComputeGalleryName string = 'myGallery'
// Define the parameter for the Storage account name
@description('The name of the Storage account.')
param stgaccountname string

param azUserAssignedManagedIdentity string = 'useri'

// Define the details for the VM offer
var vmOfferDetails = {
  offer: 'WindowsServer'
  publisher: 'MicrosoftWindowsServer'
  sku: '2022-datacenter-azure-edition'
}

// Include the customizations module
module customizationsModule 'customizations.bicep' = {
  name: 'customizationsModule'
  params: {
    stgaccountname: stgaccountname
  }
}
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'  existing ={
  name: azUserAssignedManagedIdentity
}

// Create an image in the Compute Gallery
resource azImage 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: '${azComputeGalleryName}/myImage'
  location: location
  properties: {
    description: 'myImage'
    osType: 'Windows'
    osState: 'Generalized'
    hyperVGeneration: 'V2'
    identifier: {
      publisher: vmOfferDetails.publisher
      offer: vmOfferDetails.offer
      sku: vmOfferDetails.sku
    }
  }
  dependsOn: [
    uami
  ]
}

// Create an image template
resource azImageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: imagetemplatename
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 360
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: azImage.id
        runOutputName: 'myImageTemplateRunOutput'
        replicationRegions: [
          'North US'
        ]
      }
    ]
    source: {
      type: 'PlatformImage'
      publisher: vmOfferDetails.publisher
      offer: vmOfferDetails.offer
      sku: vmOfferDetails.sku
      version: 'latest'
    }
    customize: customizationsModule.outputs.customizationsOutput
    vmProfile: {
      vmSize: 'Standard_D4ds_v5'
      osDiskSizeGB: 0 // Leave size as source image size.
    
    }
    
    optimize: {
      vmBoot: {
        state: 'Enabled'
      }
    }
  }
}
