# Microsoft.Insights/autoscalesettings

The `Microsoft.Insights/autoscalesettings` resource type in Azure is used to configure autoscale settings for various Azure resources. Autoscale settings help ensure that you have the right amount of resources running to handle the fluctuating load of your application. You can configure autoscale settings to be triggered based on metrics that indicate load or performance, or triggered at a scheduled date and time.

## Description

This module deploys an autoscale setting for Azure resources.

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/res/insights/autoscalesettings:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module autoscalesettings 'br/public:avm/res/insights/autoscalesettings:<version>' = {
  name: 'autoscalesettingsDeployment'
  params: {
    // Required parameters
    name: 'asmin001'
    workspaceResourceId: '<workspaceResourceId>'
    location: '<location>'
    properties: {
        enabled: true
        name: 'string'
        predictiveAutoscalePolicy: {
        scaleLookAheadTime: 'string'
        scaleMode: 'string'
        }
        profiles: [
        {
            capacity: {
            default: 'string'
            maximum: 'string'
            minimum: 'string'
            }
            rules: [
            {
                metricTrigger: {
                dimensions: [
                    {
                    DimensionName: 'string'
                    Operator: 'string'
                    Values: ['string']
                    }
                ]
                dividePerInstance: bool
                metricName: 'string'
                metricNamespace: 'string'
                metricResourceLocation: 'string'
                metricResourceUri: 'string'
                operator: 'string'
                statistic: 'string'
                threshold: int
                timeAggregation: 'string'
                timeGrain: 'string'
                timeWindow: 'string'
                }
                scaleAction: {
                cooldown: 'string'
                direction: 'string'
                type: 'string'
                value: 'string'
                }
            }
            ]
        }
        ]
        targetResourceLocation: 'string'
        targetResourceUri: 'string'
    }
            Enabled: true
            profiles
                capacity
                rules
                    metricTrigger
                    scaleAction
    }
    }
```


## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | `string` | Yes | The name of the autoscale setting. |
| `location` | `string` | Yes | The location where the autoscale setting is deployed. |
| `tags` | `object` | No | A list of key-value pairs that describe the resource. |
| `properties` | `object` | Yes | The properties of the autoscale setting. |

### Properties

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `enabled` | `bool` | Yes | A boolean indicating whether the autoscale setting is enabled. |
| `notifications` | `array` | No | An array of notification settings, including email and webhook configurations. |
| `predictiveAutoscalePolicy` | `object` | No | Settings for predictive autoscale, including look-ahead time and scale mode. |
| `profiles` | `array` | Yes | An array of profiles that define the autoscale rules. |

#### Profiles

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `capacity` | `object` | Yes | Defines the minimum, maximum, and default number of instances. |
| `fixedDate` | `object` | No | Specifies the start and end date for the profile. |
| `recurrence` | `object` | No | Defines the recurrence schedule for the profile. |
| `rules` | `array` | Yes | An array of rules that define the conditions for scaling. |

##### Rules

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `metricTrigger` | `object` | Yes | Defines the metric that triggers the scaling action. |
| `scaleAction` | `object` | Yes | Defines the action to take when the metric trigger condition is met. |

## Example Bicep Template

```bicep
resource symbolicname 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: 'string'
  location: 'string'
  properties: {
    enabled: bool
    name: 'string'
    notifications: [
      {
        email: {
          customEmails: ['string']
          sendToSubscriptionAdministrator: bool
          sendToSubscriptionCoAdministrators: bool
        }
        operation: 'Scale'
        webhooks: [
          {
            properties: {
              {customized property}: 'string'
            }
            serviceUri: 'string'
          }
        ]
      }
    ]
    predictiveAutoscalePolicy: {
      scaleLookAheadTime: 'string'
      scaleMode: 'string'
    }
    profiles: [
      {
        capacity: {
          default: 'string'
          maximum: 'string'
          minimum: 'string'
        }
        fixedDate: {
          end: 'string'
          start: 'string'
          timeZone: 'string'
        }
        name: 'string'
        recurrence: {
          frequency: 'string'
          schedule: {
            days: ['string']
            hours: [int]
            minutes: [int]
            timeZone: 'string'
          }
        }
        rules: [
          {
            metricTrigger: {
              dimensions: [
                {
                  DimensionName: 'string'
                  Operator: 'string'
                  Values: ['string']
                }
              ]
              dividePerInstance: bool
              metricName: 'string'
              metricNamespace: 'string'
              metricResourceLocation: 'string'
              metricResourceUri: 'string'
              operator: 'string'
              statistic: 'string'
              threshold: int
              timeAggregation: 'string'
              timeGrain: 'string'
              timeWindow: 'string'
            }
            scaleAction: {
              cooldown: 'string'
              direction: 'string'
              type: 'string'
              value: 'string'
            }
          }
        ]
      }
    ]
    targetResourceLocation: 'string'
    targetResourceUri: 'string'
  }
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
}
```
