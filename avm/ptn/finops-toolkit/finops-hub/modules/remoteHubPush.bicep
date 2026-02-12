// ============================================================================
// FinOps Hub - Remote Hub Push Module
// ============================================================================
// Implements the "push" mode for remote hub federation.
// This hub acts as a SATELLITE — it processes local cost data and pushes
// the results to a remote PRIMARY hub's storage account.
//
// Resources created:
//   1. Key Vault secret storing the remote storage account key
//   2. ADF linked service to the remote storage (using KV secret)
//   3. ADF datasets pointing to the remote ingestion container
//   4. ADF pipeline to copy processed data from local -> remote ingestion
//
// This matches the upstream FinOps Toolkit RemoteHub/app.bicep pattern.
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Required. Name of the Data Factory.')
param dataFactoryName string

@description('Required. Name of the Key Vault.')
param keyVaultName string

@description('Required. DFS endpoint URI of the primary (remote) hub storage account.')
param remoteHubStorageUri string

@description('Required. Access key for the primary (remote) hub storage account.')
@secure()
param remoteHubStorageKey string

@description('Optional. Name of the ingestion container on the remote hub. Default: ingestion.')
param ingestionContainerName string = 'ingestion'

@description('Optional. Name of the integration runtime to use. If using managed VNet, this should reference the managed IR.')
param integrationRuntimeName string = ''

// ============================================================================
// VARIABLES
// ============================================================================

var secretName = 'remote-hub-storage-key'
var linkedServiceName = 'remoteHubStorage'
var useIntegrationRuntime = !empty(integrationRuntimeName)
var connectViaProperty = useIntegrationRuntime ? {
  referenceName: integrationRuntimeName
  type: 'IntegrationRuntimeReference'
} : null

// ============================================================================
// EXISTING RESOURCES
// ============================================================================

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// ============================================================================
// RESOURCES
// ============================================================================

// --- Key Vault Secret ---
// Store the remote storage account key securely in Key Vault
resource remoteStorageSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: remoteHubStorageKey
    contentType: 'Remote hub storage account key for cross-hub data federation'
    attributes: {
      enabled: true
    }
  }
}

// --- ADF Linked Service to Remote Storage ---
// Connects ADF to the remote (primary) hub's ADLS Gen2 storage via KV secret
resource linkedService_remoteHubStorage 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: linkedServiceName
  parent: dataFactory
  dependsOn: [remoteStorageSecret]
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: remoteHubStorageUri
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: keyVault.name
          type: 'LinkedServiceReference'
        }
        secretName: secretName
      }
    }
    connectVia: connectViaProperty
    annotations: ['RemoteHub', 'push-mode']
  }
}

// --- Remote Ingestion Dataset ---
// Points to the ingestion container on the REMOTE hub's storage
resource dataset_remoteIngestion 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'remote_${ingestionContainerName}'
  parent: dataFactory
  properties: {
    linkedServiceName: {
      referenceName: linkedService_remoteHubStorage.name
      type: 'LinkedServiceReference'
    }
    type: 'Parquet'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@{dataset().blobPath}'
          type: 'Expression'
        }
        fileSystem: ingestionContainerName
      }
    }
    parameters: {
      blobPath: {
        type: 'String'
      }
    }
    annotations: ['RemoteHub']
  }
}

// --- Remote Ingestion Files Dataset ---
// For listing/copying files from local to remote
resource dataset_remoteIngestion_files 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'remote_${ingestionContainerName}_files'
  parent: dataFactory
  properties: {
    linkedServiceName: {
      referenceName: linkedService_remoteHubStorage.name
      type: 'LinkedServiceReference'
    }
    type: 'Parquet'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileSystem: ingestionContainerName
        folderPath: {
          value: '@dataset().folderPath'
          type: 'Expression'
        }
      }
    }
    parameters: {
      folderPath: {
        type: 'String'
      }
    }
    annotations: ['RemoteHub']
  }
}

// --- Remote Ingestion Manifest Dataset ---
// For copying manifest files to remote hub to trigger ingestion
resource dataset_remoteIngestion_manifest 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'remote_ingestion_manifest'
  parent: dataFactory
  properties: {
    linkedServiceName: {
      referenceName: linkedService_remoteHubStorage.name
      type: 'LinkedServiceReference'
    }
    type: 'Json'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@{dataset().fileName}'
          type: 'Expression'
        }
        folderPath: {
          value: '@{dataset().folderPath}'
          type: 'Expression'
        }
        fileSystem: ingestionContainerName
      }
    }
    parameters: {
      fileName: {
        type: 'String'
        defaultValue: 'manifest.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: ingestionContainerName
      }
    }
    annotations: ['RemoteHub']
  }
}

// --- Push Pipeline ---
// Copies processed data from local ingestion container to remote hub's ingestion container.
// This pipeline is triggered after the local msexports_ETL_ingestion pipeline completes,
// ensuring data is only pushed after successful local processing.
resource pipeline_pushToRemoteHub 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'remoteHub_PushToRemote'
  parent: dataFactory
  properties: {
    description: 'Copies processed FOCUS cost data from the local hub ingestion container to the remote (primary) hub ingestion container for centralized analysis.'
    activities: [
      {
        // Get list of folders in local ingestion (each folder = one export batch)
        name: 'Get Ingestion Folders'
        type: 'GetMetadata'
        dependsOn: []
        policy: {
          timeout: '0.00:10:00'
          retry: 2
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          dataset: {
            referenceName: '${ingestionContainerName}_files'
            type: 'DatasetReference'
            parameters: {
              folderPath: '@pipeline().parameters.folderPath'
            }
          }
          fieldList: ['childItems']
          storeSettings: {
            type: 'AzureBlobFSReadSettings'
            recursive: false
            enablePartitionDiscovery: false
          }
        }
      }
      {
        // Copy each file from local ingestion to remote ingestion
        name: 'Copy Data To Remote Hub'
        type: 'Copy'
        dependsOn: [
          {
            activity: 'Get Ingestion Folders'
            dependencyConditions: ['Succeeded']
          }
        ]
        policy: {
          timeout: '0.12:00:00'
          retry: 2
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'ParquetSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: true
              wildcardFolderPath: '@pipeline().parameters.folderPath'
              wildcardFileName: '*.parquet'
              enablePartitionDiscovery: false
            }
          }
          sink: {
            type: 'ParquetSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
            }
            formatSettings: {
              type: 'ParquetWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: '${ingestionContainerName}_files'
            type: 'DatasetReference'
            parameters: {
              folderPath: '@pipeline().parameters.folderPath'
            }
          }
        ]
        outputs: [
          {
            referenceName: dataset_remoteIngestion_files.name
            type: 'DatasetReference'
            parameters: {
              folderPath: '@pipeline().parameters.folderPath'
            }
          }
        ]
      }
      {
        // Copy the manifest file last — this triggers ingestion at the remote hub
        name: 'Copy Manifest To Remote Hub'
        type: 'Copy'
        dependsOn: [
          {
            activity: 'Copy Data To Remote Hub'
            dependencyConditions: ['Succeeded']
          }
        ]
        policy: {
          timeout: '0.00:10:00'
          retry: 2
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'JsonSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: false
              enablePartitionDiscovery: false
            }
            formatSettings: {
              type: 'JsonReadSettings'
            }
          }
          sink: {
            type: 'JsonSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
            }
            formatSettings: {
              type: 'JsonWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: 'ingestion_manifest'
            type: 'DatasetReference'
            parameters: {
              fileName: '@pipeline().parameters.manifestFileName'
              folderPath: '@pipeline().parameters.folderPath'
            }
          }
        ]
        outputs: [
          {
            referenceName: dataset_remoteIngestion_manifest.name
            type: 'DatasetReference'
            parameters: {
              fileName: '@pipeline().parameters.manifestFileName'
              folderPath: '@pipeline().parameters.folderPath'
            }
          }
        ]
      }
    ]
    parameters: {
      folderPath: {
        type: 'String'
        defaultValue: ''
      }
      manifestFileName: {
        type: 'String'
        defaultValue: 'manifest.json'
      }
    }
    annotations: ['RemoteHub', 'push-mode']
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Name of the remote hub linked service.')
output linkedServiceName string = linkedService_remoteHubStorage.name

@description('Name of the Key Vault secret storing the remote storage key.')
output secretName string = remoteStorageSecret.name

@description('Name of the push pipeline.')
output pipelineName string = pipeline_pushToRemoteHub.name

@description('Names of the remote datasets created.')
output datasetNames array = [
  dataset_remoteIngestion.name
  dataset_remoteIngestion_files.name
  dataset_remoteIngestion_manifest.name
]
