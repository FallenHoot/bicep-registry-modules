targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

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
param namePrefix string = '#_namePrefix_#'

@description('Required. The resource name.')
param autoscaleSettingResourceName string

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
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          metricResourceLocation: 'eastus'
          metricResourceUri: 'resourceUri'
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
    fixedDate: {
      end: '2023-12-31T23:59:59Z'
      start: '2023-01-01T00:00:00Z'
      timeZone: 'UTC'
    }
    recurrence: {
      frequency: 'Week'
      schedule: {
        days: ['Monday']
        hours: [0]
        minutes: [0]
        timeZone: 'UTC'
      }
    }
  }
]

@description('Optional. The name of the autoscale setting.')
param autoscaleSettingName string = 'autoscaleSettingName'

@description('Optional. Indicates whether the autoscale setting is enabled. Default is false.')
@allowed([
  true
  false
])
param enabled bool = false

@description('Optional. The notifications to send when the autoscale setting is triggered.')
param notifications array = [
  {
    email: {
      customEmails: ['email1', 'email2']
      sendToSubscriptionAdministrator: true
      sendToSubscriptionCoAdministrators: true
    }
    operation: 'Scale'
    webhook: {
      properties: {
        serviceUri: 'https://serviceUri'
        useCommonAlertSchema: true
      }
      serviceUri: 'https://serviceUri'
    }
  }
]

@description('Optional. The predictive autoscale mode to use.')
@allowed([
  'Disabled'
  'Enabled'
  'ForecastOnly'
])
param scaleMode string = 'Disabled'

@description('Optional. The predictive autoscale policy to use. The value should be an ISO 8601 duration format string, such as "PT1H" for 1 hour.')
param scaleLookAheadTime string = 'PT1H'

@description('Optional. The target resource location. The value should be a valid Azure region, such as "eastus" or "swedencentral".')
param targetResourceLocation string = 'eastus'

@description('Optional. The target resource URI.')
param targetResourceUri string = 'resourceUri'

@description('Optional. The tags to assign to the autoscale setting.')
param tags object = {
  maxTag: 'maxValue'
}

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

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    autoscaleSettingResourceName: autoscaleSettingResourceName
    location: location
    profiles: profiles
    autoscaleSettingName: autoscaleSettingName
    enabled: enabled
    notifications: notifications
    scaleMode: scaleMode
    scaleLookAheadTime: scaleLookAheadTime
    targetResourceLocation: targetResourceLocation
    targetResourceUri: targetResourceUri
    tags: tags
  }
}
