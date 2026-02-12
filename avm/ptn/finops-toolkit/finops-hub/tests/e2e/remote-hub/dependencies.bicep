// ============================================================================
// Dependencies for Remote Hub E2E Test
// ============================================================================
// Creates a secondary storage account to simulate the remote hub target.
// In production, this would be an existing storage account in another subscription.

@description('Required. Azure region for the remote storage account.')
param location string

@description('Required. Name prefix for resource naming.')
param namePrefix string

@description('Required. Deployment suffix for unique naming.')
param deploymentSuffix string

// Resource naming — simulate a "remote" storage account
var remoteStorageAccountName = take(toLower('strmt${replace(namePrefix, '-', '')}${deploymentSuffix}'), 24)

// ============================================================================
// Resources
// ============================================================================

// Remote storage account — represents the target hub's storage in a multi-hub setup
resource remoteStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: remoteStorageAccountName
  location: location
  tags: {
    SecurityControl: 'Ignore'
    Purpose: 'RemoteHubTarget'
    'hidden-title': 'Remote Hub Storage (Test)'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: true // ADLS Gen2 required for FinOps Hub
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true // Required for remote hub key-based access
  }

  resource blobService 'blobServices' = {
    name: 'default'

    // Create the ingestion container (where remote data would land)
    resource ingestionContainer 'containers' = {
      name: 'ingestion'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Name of the remote storage account.')
output storageAccountName string = remoteStorageAccount.name

@description('Resource ID of the remote storage account.')
output storageAccountId string = remoteStorageAccount.id

@description('DFS endpoint of the remote storage account (used as remoteHubStorageUri).')
output storageAccountDfsEndpoint string = 'https://${remoteStorageAccount.name}.dfs.${environment().suffixes.storage}'

@description('Primary key of the remote storage account (used as remoteHubStorageKey).')
#disable-next-line outputs-should-not-contain-secrets // Test-only: key needed to validate remoteHubStorageKey parameter acceptance
output storageAccountKey string = remoteStorageAccount.listKeys().keys[0].value
