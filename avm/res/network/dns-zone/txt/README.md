# Public DNS Zone TXT record `[Microsoft.Network/dnsZones/TXT]`

This module deploys a Public DNS Zone TXT record.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.Network/dnsZones/TXT` | [2018-05-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2018-05-01/dnsZones/TXT) |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the TXT record. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dnsZoneName`](#parameter-dnszonename) | string | The name of the parent DNS zone. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`metadata`](#parameter-metadata) | object | The metadata attached to the record set. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`ttl`](#parameter-ttl) | int | The TTL (time-to-live) of the records in the record set. |
| [`txtRecords`](#parameter-txtrecords) | array | The list of TXT records in the record set. |

### Parameter: `dnsZoneName`

The name of the parent DNS zone. Required if the template is used in a standalone deployment.
- Required: Yes
- Type: string

### Parameter: `metadata`

The metadata attached to the record set.
- Required: No
- Type: object

### Parameter: `name`

The name of the TXT record.
- Required: Yes
- Type: string

### Parameter: `roleAssignments`

Array of role assignments to create.
- Required: No
- Type: array


| Name | Required | Type | Description |
| :-- | :-- | :--| :-- |
| [`condition`](#parameter-roleassignmentscondition) | No | string | Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container" |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | No | string | Optional. Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | No | string | Optional. The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | No | string | Optional. The description of the role assignment. |
| [`principalId`](#parameter-roleassignmentsprincipalid) | Yes | string | Required. The principal ID of the principal (user/group/identity) to assign the role to. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | No | string | Optional. The principal type of the assigned principal ID. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | Yes | string | Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

### Parameter: `roleAssignments.condition`

Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Optional. Version of the condition.

- Required: No
- Type: string
- Allowed: `[2.0]`

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

Optional. The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

Optional. The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalId`

Required. The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.principalType`

Optional. The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed: `[Device, ForeignGroup, Group, ServicePrincipal, User]`

### Parameter: `roleAssignments.roleDefinitionIdOrName`

Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `ttl`

The TTL (time-to-live) of the records in the record set.
- Required: No
- Type: int
- Default: `3600`

### Parameter: `txtRecords`

The list of TXT records in the record set.
- Required: No
- Type: array


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed TXT record. |
| `resourceGroupName` | string | The resource group of the deployed TXT record. |
| `resourceId` | string | The resource ID of the deployed TXT record. |

## Cross-referenced modules

_None_