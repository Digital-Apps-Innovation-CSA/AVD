
param location string = resourceGroup().location
param imagetemplatename string
param azComputeGalleryName string = 'myGallery'
param azUserAssignedManagedIdentity string = 'useri'
param imagaName string = 'myImage'
param imageDescription string = 'My custom image'
// Define the details for the VM offer
param vmOfferDetails object
param vmProfile object
param customizations array

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'  existing ={
  name: azUserAssignedManagedIdentity
}

// Create an image in the Compute Gallery
resource azImage 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: '${azComputeGalleryName}/${imagaName}'
  location: location
  properties: {
    description: imageDescription
    osType: vmOfferDetails.osType
    osState: vmOfferDetails.osState
    hyperVGeneration: vmOfferDetails.hyperVGeneration
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
      }
    ]
    source: {
      type: 'PlatformImage'
      publisher: vmOfferDetails.publisher
      offer: vmOfferDetails.offer
      sku: vmOfferDetails.sku
      version: vmOfferDetails.version
    }
    customize: customizations
    vmProfile: {
      vmSize: vmProfile.vmSize
      osDiskSizeGB: vmProfile.osDiskSizeGB
    }
    optimize: {
      vmBoot: {
        state: 'Enabled'
      }
    }
  }
}
