targetScope = 'subscription'

metadata name = 'Remote Hub Configuration'
metadata description = 'This instance deploys the module with remote hub federation in push mode. Tests cross-hub data federation where this hub acts as a satellite pushing data to a remote primary hub.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-finops-hub-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'fhrmt'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// Stable suffix for idempotent deployments — must NOT depend on deployment().name
// which changes every CI run, causing orphan resources instead of in-place updates.
// Uses subscription + namePrefix + serviceShort so the name is identical across runs.
var deploymentSuffix = take(uniqueString(subscription().subscriptionId, namePrefix, serviceShort), 4)

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// Deploy a secondary "remote" storage account to simulate the remote primary hub target.
// In production, this would be an existing storage account in a different subscription/region/tenant.
module remoteStorage 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-remote-deps'
  params: {
    location: resourceLocation
    namePrefix: '${namePrefix}${serviceShort}'
    deploymentSuffix: deploymentSuffix
  }
}

// ============== //
// Test Execution //
// ============== //

// Test: Storage-only hub with remote hub push mode enabled.
// This hub acts as a SATELLITE — it pushes processed data to the remote primary hub.
// Resources created: KV secret, ADF linked service, datasets, copy pipeline.
@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      // Required parameters - include deployment suffix to avoid Key Vault naming conflicts
      hubName: '${namePrefix}${serviceShort}${deploymentSuffix}'

      // Non-required parameters
      location: resourceLocation
      deploymentConfiguration: 'minimal'
      deploymentType: 'storage-only'

      // =====================================================
      // KEY SETTING: Remote Hub Push Mode
      // =====================================================
      // This hub is a satellite that pushes processed cost data
      // to a remote primary hub's ingestion container.
      //
      // Push mode (upstream-compatible):
      //   - Stores remote storage key in Key Vault
      //   - Creates ADF linked service to remote storage
      //   - Creates ADF datasets pointing to remote ingestion
      //   - Creates ADF pipeline to copy local -> remote
      //   - Works cross-cloud and cross-tenant
      //
      // Pull mode (AVM-exclusive, not tested here):
      //   - Uses Managed Identity + RBAC (no keys)
      //   - Primary hub pulls from satellite storage
      //   - More secure, but same-cloud/same-tenant only
      remoteHubMode: 'push'
      remoteHubStorageUri: remoteStorage.outputs.storageAccountDfsEndpoint
      remoteHubStorageKey: remoteStorage.outputs.storageAccountKey

      enableTelemetry: true
      tags: {
        SecurityControl: 'Ignore'
        Environment: 'Development'
        'hidden-title': 'FinOps Hub - Remote Hub Push Test'
        TestScenario: 'RemoteHub-Push'
      }
    }
  }
]

// ============== //
// Outputs        //
// ============== //

@description('Name of the primary hub.')
output hubName string = testDeployment[0].outputs.hubName

@description('Storage account name of the primary hub.')
output primaryStorageAccountName string = testDeployment[0].outputs.storageAccountName

@description('Storage account name of the remote hub target.')
output remoteStorageAccountName string = remoteStorage.outputs.storageAccountName

@description('Remote hub storage URI that was passed to the module.')
output remoteHubStorageUri string = remoteStorage.outputs.storageAccountDfsEndpoint

@description('Remote hub mode configured.')
output remoteHubMode string = testDeployment[0].outputs.remoteHubMode

@description('Remote hub push pipeline name.')
output remoteHubPushPipeline string = testDeployment[0].outputs.remoteHubPushPipeline

@description('Deployment mode (should be demo since no scopes configured).')
output deploymentMode string = testDeployment[0].outputs.deploymentMode
