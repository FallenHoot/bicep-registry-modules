# FinOps Hub - Internal Bicep Modules

This folder contains internal helper modules used by the main `main.bicep` template. These are **not** standalone AVMs - they are implementation details that should not be used directly.

Module names follow the upstream FinOps Toolkit `fx/*` naming convention where an equivalent exists (prefixed with `hub-`). AVM-level naming (`main.bicep`, module path) follows AVM conventions and cannot be changed.

## Module Architecture

```
main.bicep (the AVM entry point)
    │
    ├── AVM resource modules (inline)      → br/public:avm/res/* (Storage, KV, ADF, ADX, MI)
    │
    ├── modules/hub-types.bicep             → Shared type definitions (upstream: fx/hub-types.bicep)
    ├── modules/hub-database.bicep          → Generic KQL script runner (upstream: fx/hub-database.bicep)
    ├── modules/hub-deploymentScript.bicep  → Config deployment script (upstream: fx/hub-deploymentScript.bicep)
    ├── modules/hub-initialize.bicep        → Trigger stop/start for idempotent redeploy (upstream: fx/hub-initialize.bicep)
    │
    ├── modules/dataFactoryResources.bicep  → ADF child resources (pipelines, datasets, triggers)
    ├── modules/managedExportsPipelines.bicep → Managed export ADF pipelines
    ├── modules/network.bicep               → Managed VNet, subnets, NSG, Private DNS zones
    ├── modules/remoteHubPush.bicep         → Remote hub push mode (satellite → primary)
    ├── modules/remoteHubPull.bicep         → Remote hub pull mode (primary ← satellites)
    │
    ├── modules/adxSchemaSetup.bicep        → Orchestrates KQL script deployment order
    ├── modules/adxManagedIdentityPolicy.bicep   → ADX MI policy configuration
    ├── modules/adxManagedPrivateEndpoint.bicep   → ADF managed PE to ADX
    ├── modules/adxPrivateEndpointApproval.bicep  → PE approval logic
    │
    └── modules/scripts/                    → KQL scripts (see scripts/README.md)
```

## Naming Convention

Modules that have a direct upstream equivalent in `microsoft/finops-toolkit/src/templates/finops-hub/modules/fx/` use the same `hub-` prefix naming:

| AVM Module | Upstream fx/* Equivalent | Notes |
|-----------|------------------------|-------|
| `hub-types.bicep` | `fx/hub-types.bicep` | Shared types and constants |
| `hub-database.bicep` | `fx/hub-database.bicep` | ADX database script runner |
| `hub-deploymentScript.bicep` | `fx/hub-deploymentScript.bicep` | PowerShell deployment script wrapper |
| `hub-initialize.bicep` | `fx/hub-initialize.bicep` | Trigger management and post-deploy init |

Modules without an upstream equivalent keep descriptive names (`dataFactoryResources.bicep`, `network.bicep`, etc.).

Upstream `fx/*` modules that have **no AVM equivalent** (functionality handled differently):

| Upstream fx/* Module | AVM Approach |
|---------------------|-------------|
| `hub-app.bicep` | Not needed — AVM uses `br/public:avm/res/*` directly, no publisher/app framework |
| `hub-storage.bicep` | Handled by `br/public:avm/res/storage/storage-account` |
| `hub-vault.bicep` | Handled by `br/public:avm/res/key-vault/vault` |
| `hub-identity.bicep` | Handled by `br/public:avm/res/managed-identity/user-assigned-identity` |
| `hub-eventTrigger.bicep` | Triggers defined inline in `dataFactoryResources.bicep` |
| `keyVaultEndpoints.bicep` | Private endpoints handled by `network.bicep` |
| `storageEndpoints.bicep` | Private endpoints handled by `network.bicep` |

## How Modules Work

### 1. Hub Foundation Modules (hub-*)
These follow upstream `fx/*` naming and provide shared utilities:

| Module | Upstream | Purpose |
|--------|----------|---------|
| `hub-types.bicep` | `fx/hub-types.bicep` | Type definitions and shared constants |
| `hub-database.bicep` | `fx/hub-database.bicep` | Generic wrapper for `Microsoft.Kusto/clusters/databases/scripts` |
| `hub-deploymentScript.bicep` | `fx/hub-deploymentScript.bicep` | Writes settings.json to config container |
| `hub-initialize.bicep` | `fx/hub-initialize.bicep` | Stops/starts ADF triggers for idempotent redeployments |

### 2. Custom Resource Modules
These modules create resources not available as AVMs:

| Module | Purpose |
|--------|---------|
| `dataFactoryResources.bicep` | All ADF pipelines, datasets, linked services, triggers |
| `managedExportsPipelines.bicep` | ADF pipelines for managed Cost Management exports |
| `network.bicep` | Self-contained VNet for "Managed" network isolation |
| `remoteHubPush.bicep` | Push-mode remote hub federation |
| `remoteHubPull.bicep` | Pull-mode remote hub federation |

### 3. ADX Schema Modules
These modules deploy the FinOps Hub schema to Azure Data Explorer:

| Module | Purpose |
|--------|---------|
| `adxSchemaSetup.bicep` | Orchestrates KQL script deployment in correct order |
| `hub-database.bicep` | Generic wrapper that creates `Microsoft.Kusto/clusters/databases/scripts` resources |
| `adxManagedIdentityPolicy.bicep` | Sets cluster-level MI policy via deployment script |

## Key Concepts

### Script Deployment Mechanism

KQL scripts are deployed using native ADX `scripts` resources:

```bicep
// 1. adxSchemaSetup.bicep loads KQL at compile time
var rawTablesScript = loadTextContent('scripts/IngestionSetup_RawTables.kql')

// 2. Passes to hub-database.bicep module
module ingestionScripts 'hub-database.bicep' = {
  params: {
    scripts: {
      RawTables: rawTablesScript
    }
  }
}

// 3. hub-database.bicep creates ADX script resources
resource script 'scripts' = [for scr in items(scripts): {
  name: scr.key
  properties: {
    scriptContent: scr.value
    continueOnErrors: true
    forceUpdateTag: utcNow()  // Forces re-execution each deployment
  }
}]
```

### Network Isolation Modes

The `network.bicep` module supports the "Managed" mode:

| Mode | What Module Creates | Who Manages Upgrades |
|------|--------------------|--------------------|
| `None` | Nothing (public access) | Just redeploy |
| `Managed` | VNet, subnet, NSG, DNS zones, PEs | Just redeploy |
| `BringYourOwn` | Nothing (customer provides) | Customer tests before upgrade |

## Adding New Modules

When adding new functionality:

1. **Prefer AVMs**: If an AVM exists for the resource, use the registry module directly
2. **Follow naming**: Use `hub-` prefix for modules that have upstream `fx/*` equivalents; use descriptive names for AVM-specific modules
3. **Keep types separate**: Use `hub-types.bicep` for shared type definitions
4. **Document dependencies**: Add comments explaining module dependencies

## See Also

- [scripts/README.md](./scripts/README.md) - KQL script documentation
- [main.bicep](../main.bicep) - Main module entry point
- [FinOps Toolkit](https://aka.ms/finops/toolkit) - Official documentation
