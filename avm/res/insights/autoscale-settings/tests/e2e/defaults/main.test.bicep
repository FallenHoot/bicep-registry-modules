targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-insights.components-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'icmin'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = 'test'

@description('Required. The resource name.')
param autoscaleSettingResourceName string = 'autoscaleSetting'

@description('Required. The name of the autoscale setting. The value should be a valid Azure region, such as "eastus" or "swedencentral".')
param location string = 'eastus'

@description('Required. The profiles to use for autoscaling. The values provided are examples.')
param profiles array = [
  {
    name: 'profileName'
    capacity: {
      default: '1'
      maximum: '10'
      minimum: '1'
    }
    rules: [
      {
        metricTrigger: {
          dimensions: [
            {
              DimensionName: 'dimensionName'
              Operator: 'Equals'
              Values: ['value1']
            }
          ]
          dividePerInstance: true
          metricName: 'Percentage CPU'
          metricResourceLocation: 'eastus'
          operator: 'GreaterThan'
          statistic: 'Average'
          threshold: 75
          timeAggregation: 'Average'
          timeGrain: 'PT1M'
          timeWindow: 'PT5M'
        }
        scaleAction: {
          cooldown: 'PT5M'
          direction: 'Increase'
          type: 'ChangeCount'
          value: '1'
        }
      }
    ]
  }
]

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============== //
// Test Execution //
// ============== //

module vmss_dependencies '../dependencies/vmss/dependencies.vmss.bicep' = {
  scope: resourceGroup
  params: {
    location: resourceLocation
    adminUsername: 'adminUser'
    adminPassword: 'Password123!'
  }
  name: 'vmss_dependencies'
}

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    autoscaleSettingResourceName: autoscaleSettingResourceName
    location: location
    profiles: profiles
    metricNamespace: 'Microsoft.Compute/virtualMachineScaleSets'
    metricResourceUri: vmss_dependencies.outputs.vmssId
    targetResourceUri: vmss_dependencies.outputs.vmssId
  }
}
