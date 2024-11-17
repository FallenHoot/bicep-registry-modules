metadata name = 'autoscale-settings'
metadata description = ' This resource is used to configure autoscale settings for an Azure resource, such as a Virtual Machine Scale Set or an App Service.'
metadata owner = 'Azure/module-maintainers'

@description('Required. The resource name.')
param autoscaleSettingResourceName string

@description('Required. The name of the autoscale setting. The value should be a valid Azure region, such as "eastus" or "swedencentral".')
param location string = 'eastus'

@description('Required. The metric namespace to use.')
@allowed([
  'Microsoft.Compute/virtualMachineScaleSets'
  'Microsoft.Compute/virtualMachines'
  'Microsoft.Web/sites'
  'Microsoft.Network/loadBalancers'
])
param metricNamespace string = 'Microsoft.Compute/virtualMachineScaleSets'

@description('Required. The resource URI of the metric to be used for autoscaling. This should be a valid Azure resource URI.')
param metricResourceUri string?

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
          metricNamespace: metricNamespace
          metricResourceLocation: 'eastus'
          metricResourceUri: metricResourceUri
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
    // fixedDate: {
    //   end: '2023-12-31T23:59:59Z'
    //   start: '2023-01-01T00:00:00Z'
    //   timeZone: 'UTC'
    // }
    // recurrence: {
    //   frequency: 'Week'
    //   schedule: {
    //     days: ['Monday']
    //     hours: [0]
    //     minutes: [0]
    //     timeZone: 'UTC'
    //   }
    // }
  }
]

@description('Optional. The name of the autoscale setting.')
param autoscaleSettingName string?

@description('Optional. Indicates whether the autoscale setting is enabled. Default is false.')
@allowed([
  true
  false
])
param enabled bool = false

@description('Optional. The notifications to send when the autoscale setting is triggered.')
param notifications array = []

@description('Optional. The predictive autoscale mode to use.')
@allowed([
  'Disabled'
  'Enabled'
  'ForecastOnly'
])
param scaleMode string = 'Disabled'

@description('Optional. The predictive autoscale policy to use. The value should be an ISO 8601 duration format string, such as "PT1H" for 1 hour.')
param scaleLookAheadTime string?

@description('Optional. The target resource location. The value should be a valid Azure region, such as "eastus" or "swedencentral".')
param targetResourceLocation string?

@description('Optional. The target resource URI.')
param targetResourceUri string?

@description('Optional. The tags to assign to the autoscale setting.')
param tags object?

resource autoscaleSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: autoscaleSettingResourceName
  location: location
  properties: {
    name: empty(autoscaleSettingName) ? null : autoscaleSettingName
    profiles: profiles
    enabled: enabled ? true : false
    notifications: empty(notifications) ? null : notifications
    predictiveAutoscalePolicy: {
      scaleMode: empty(scaleLookAheadTime) ? 'Disabled' : scaleMode
      scaleLookAheadTime: empty(scaleLookAheadTime) ? null : scaleLookAheadTime
    }
    targetResourceLocation: empty(targetResourceLocation) ? null : targetResourceLocation
    targetResourceUri: empty(targetResourceUri) ? null : targetResourceUri
  }
  tags: empty(tags) ? null : tags
}
