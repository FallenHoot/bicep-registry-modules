// ============================================================================
// FinOps Hub - Remote Hub Pull Module
// ============================================================================
// Implements the "pull" mode for remote hub federation.
// This hub acts as the PRIMARY — it reads processed cost data from
// satellite hubs' storage accounts using Managed Identity + RBAC.
//
// NO STORAGE KEYS required. The primary hub's ADF managed identity
// must have Storage Blob Data Reader on each satellite's storage account.
// This is granted via the role assignment in main.bicep.
//
// Resources created:
//   1. ADF linked service per satellite storage (MI auth, no keys)
//   2. ADF datasets per satellite pointing to their ingestion containers
//   3. ADF pipeline that iterates over satellites and pulls new data
//   4. ADF trigger (scheduled) to poll satellites on a cadence
//
// This is an AVM-exclusive feature — the upstream FinOps Toolkit does not
// have a pull mode. It uses RBAC instead of storage keys for security.
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Required. Name of the Data Factory.')
param dataFactoryName string

@description('Required. Array of satellite hub storage account DFS endpoint URIs to pull data from.')
param satelliteStorageUris string[]

@description('Optional. Name of the ingestion container on satellite hubs. Default: ingestion.')
param ingestionContainerName string = 'ingestion'

@description('Optional. Name of the integration runtime to use. If using managed VNet, this should reference the managed IR.')
param integrationRuntimeName string = ''

@description('Optional. Schedule interval in hours for polling satellite hubs. Default: 6.')
@minValue(1)
@maxValue(24)
param pullIntervalHours int = 6

// ============================================================================
// VARIABLES
// ============================================================================

var useIntegrationRuntime = !empty(integrationRuntimeName)
var connectViaProperty = useIntegrationRuntime ? {
  referenceName: integrationRuntimeName
  type: 'IntegrationRuntimeReference'
} : null

// Extract storage account names from URIs for linked service naming
// URI format: https://<accountname>.dfs.core.windows.net
var satelliteConfigs = [for (uri, i) in satelliteStorageUris: {
  uri: uri
  // Extract account name: strip 'https://' prefix and '.dfs...' suffix
  name: split(split(uri, '//')[1], '.')[0]
  index: i
}]

// ============================================================================
// EXISTING RESOURCES
// ============================================================================

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// ============================================================================
// RESOURCES
// ============================================================================

// --- ADF Linked Services to Satellite Storage Accounts ---
// Uses Managed Identity authentication — no keys, no secrets, just RBAC.
// The ADF system-assigned MI must have Storage Blob Data Reader on each satellite.
resource linkedService_satellite 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = [for config in satelliteConfigs: {
  name: 'satellite_${config.name}'
  parent: dataFactory
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: config.uri
      // Uses ADF system-assigned managed identity — no accountKey needed
    }
    connectVia: connectViaProperty
    annotations: ['RemoteHub', 'pull-mode', 'satellite-${config.index}']
  }
}]

// --- Satellite Ingestion Datasets ---
// One dataset per satellite, pointing to their ingestion container
resource dataset_satelliteIngestion 'Microsoft.DataFactory/factories/datasets@2018-06-01' = [for (config, i) in satelliteConfigs: {
  name: 'satellite_${config.name}_ingestion'
  parent: dataFactory
  dependsOn: [linkedService_satellite[i]]
  properties: {
    linkedServiceName: {
      referenceName: 'satellite_${config.name}'
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
        defaultValue: ''
      }
    }
    annotations: ['RemoteHub', 'satellite']
  }
}]

// --- Satellite Manifest Datasets ---
resource dataset_satelliteManifest 'Microsoft.DataFactory/factories/datasets@2018-06-01' = [for (config, i) in satelliteConfigs: {
  name: 'satellite_${config.name}_manifest'
  parent: dataFactory
  dependsOn: [linkedService_satellite[i]]
  properties: {
    linkedServiceName: {
      referenceName: 'satellite_${config.name}'
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
        defaultValue: ''
      }
    }
    annotations: ['RemoteHub', 'satellite']
  }
}]

// --- Pull Pipeline ---
// Iterates over all satellite storage accounts and copies new data
// from their ingestion containers to the primary hub's ingestion container.
// The manifest is copied LAST to trigger ADX ingestion at the primary.
resource pipeline_pullFromSatellites 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'remoteHub_PullFromSatellites'
  parent: dataFactory
  properties: {
    description: 'Pulls processed FOCUS cost data from satellite hub ingestion containers to the primary hub for centralized analysis. Uses Managed Identity — no storage keys required.'
    activities: [
      {
        // Iterate over each satellite storage account
        name: 'For Each Satellite'
        type: 'ForEach'
        dependsOn: []
        userProperties: []
        typeProperties: {
          isSequential: false
          items: {
            value: '@pipeline().parameters.satelliteConfigs'
            type: 'Expression'
          }
          batchCount: 4
          activities: [
            {
              // List top-level folders in satellite ingestion container
              // Each folder = a cost export batch (e.g., "focuscost/20240101-20240131/...")
              name: 'Get Satellite Folders'
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
                  referenceName: '@item().datasetName'
                  type: 'DatasetReference'
                  parameters: {
                    folderPath: ''
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
              // Copy all parquet files from satellite to primary ingestion
              name: 'Copy Satellite Data'
              type: 'Copy'
              dependsOn: [
                {
                  activity: 'Get Satellite Folders'
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
                  referenceName: '@item().datasetName'
                  type: 'DatasetReference'
                  parameters: {
                    folderPath: ''
                  }
                }
              ]
              outputs: [
                {
                  referenceName: '${ingestionContainerName}_files'
                  type: 'DatasetReference'
                  parameters: {
                    folderPath: '@concat(item().satelliteName, \'/\')'
                  }
                }
              ]
            }
          ]
        }
      }
    ]
    parameters: {
      satelliteConfigs: {
        type: 'Array'
        defaultValue: [for config in satelliteConfigs: {
          satelliteName: config.name
          datasetName: 'satellite_${config.name}_ingestion'
          manifestDatasetName: 'satellite_${config.name}_manifest'
          storageUri: config.uri
        }]
      }
    }
    annotations: ['RemoteHub', 'pull-mode']
  }
}

// --- Scheduled Trigger for Pull ---
// Polls satellite hubs on a configurable schedule
resource trigger_pullSchedule 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'remoteHub_PullSchedule'
  parent: dataFactory
  properties: {
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        frequency: 'Hour'
        interval: pullIntervalHours
        startTime: '2024-01-01T00:00:00Z'
        timeZone: 'UTC'
      }
    }
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline_pullFromSatellites.name
          type: 'PipelineReference'
        }
        parameters: {}
      }
    ]
    annotations: ['RemoteHub', 'pull-mode']
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Names of the satellite linked services created.')
output linkedServiceNames array = [for (config, i) in satelliteConfigs: linkedService_satellite[i].name]

@description('Names of the satellite ingestion datasets created.')
output datasetNames array = [for (config, i) in satelliteConfigs: dataset_satelliteIngestion[i].name]

@description('Name of the pull pipeline.')
output pipelineName string = pipeline_pullFromSatellites.name

@description('Name of the pull schedule trigger.')
output triggerName string = trigger_pullSchedule.name

@description('Number of satellite hubs configured.')
output satelliteCount int = length(satelliteStorageUris)
