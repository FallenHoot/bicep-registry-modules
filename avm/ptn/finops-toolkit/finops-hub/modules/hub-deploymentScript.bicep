// ============================================================================
// FinOps Hub - Config Deployment Script
// ============================================================================
// Deploys/updates settings.json in the config container using a deployment script.
// This is a critical component that writes hub configuration (version, scopes,
// retention settings) to blob storage where ADF pipelines read it at runtime.
//
// Direct port from upstream FinOps toolkit:
// https://github.com/microsoft/finops-toolkit/blob/dev/src/templates/finops-hub/modules/Microsoft.FinOpsHubs/Core/app.bicep
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Required. Name of the storage account.')
param storageAccountName string

@description('Required. Name of the config container.')
param configContainerName string = 'config'

@description('Required. FinOps toolkit version string.')
param ftkVersion string

@description('Required. Pipe-delimited list of scope IDs to monitor.')
param scopesPipeDelimited string = ''

@description('Optional. Number of days to retain data in the msexports container. Default: 0.')
param msexportRetentionInDays int = 0

@description('Optional. Number of months to retain data in the ingestion container. Default: 13.')
param ingestionRetentionInMonths int = 13

@description('Optional. Number of days to retain data in the Data Explorer *_raw tables. Default: 0.')
param rawRetentionInDays int = 0

@description('Optional. Number of months to retain data in the Data Explorer *_final_v* tables. Default: 13.')
param finalRetentionInMonths int = 13

@description('Required. Resource ID of the user-assigned managed identity for the deployment script.')
param managedIdentityResourceId string

@description('Required. Azure region for the deployment script.')
param location string

@description('Optional. Tags for the deployment script resource.')
param tags object = {}

@description('Optional. Force script re-execution on every deployment. Default: current UTC time.')
param forceUpdateTag string = utcNow()

// ============================================================================
// RESOURCES
// ============================================================================

resource uploadSettings 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${storageAccountName}_uploadSettings'
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '12.3'
    retentionInterval: 'PT1H'
    forceUpdateTag: forceUpdateTag
    environmentVariables: [
      {
        name: 'ftkVersion'
        value: ftkVersion
      }
      {
        name: 'scopes'
        value: scopesPipeDelimited
      }
      {
        name: 'msexportRetentionInDays'
        value: string(msexportRetentionInDays)
      }
      {
        name: 'ingestionRetentionInMonths'
        value: string(ingestionRetentionInMonths)
      }
      {
        name: 'rawRetentionInDays'
        value: string(rawRetentionInDays)
      }
      {
        name: 'finalRetentionInMonths'
        value: string(finalRetentionInMonths)
      }
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: configContainerName
      }
    ]
    scriptContent: loadTextContent('scripts/Copy-FileToAzureBlob.ps1')
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Deployment script name.')
output scriptName string = uploadSettings.name

@description('Deployment script provisioning state.')
output provisioningState string = uploadSettings.properties.provisioningState
