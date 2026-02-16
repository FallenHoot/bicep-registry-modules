# FinOps Hub Upstream Sync Workflows

Two GitHub Action workflows automate keeping the AVM FinOps Hub module in sync with the upstream [microsoft/finops-toolkit](https://github.com/microsoft/finops-toolkit) repository.

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Phase 1: Upstream Sync                         │
│                     (daily @ 06:00 UTC)                            │
│                                                                    │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────────────────┐ │
│  │ Check        │    │ Compare with │    │ Create sync branch    │ │
│  │ upstream dev │───▶│ local tracker│───▶│ + open DRAFT PR       │ │
│  │ ftkver.txt   │    │ .upstream-   │    │ labelled              │ │
│  │              │    │  version     │    │ "upstream-sync"       │ │
│  └──────────────┘    └──────────────┘    └───────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Phase 2: Release Gate                          │
│                     (daily @ 08:00 UTC)                            │
│                                                                    │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────────────────┐ │
│  │ Find draft   │    │ Check        │    │ Mark PR ready for     │ │
│  │ PRs with     │───▶│ upstream     │───▶│ review + notify       │ │
│  │ upstream-    │    │ main         │    │ maintainer            │ │
│  │ sync label   │    │ ftkver.txt   │    │                       │ │
│  └──────────────┘    └──────────────┘    └───────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## Workflow Files

| File | Schedule | Purpose |
|------|----------|---------|
| `finops-hub-upstream-sync.yml` | Daily 06:00 UTC | Detect new version on `dev`, create sync branch + draft PR |
| `finops-hub-release-gate.yml` | Daily 08:00 UTC | Check if version is on `main`, mark PR ready |

## Version Tracking

- **Upstream source**: `microsoft/finops-toolkit` → `src/templates/finops-hub/modules/fx/ftkver.txt`
- **Local tracker**: `avm/ptn/finops-toolkit/finops-hub/.upstream-version`
- **Comparison**: If upstream `dev` version ≠ local tracker → sync needed

## Manual Trigger

Both workflows support `workflow_dispatch` for manual runs:

```bash
# Force a sync even if versions match
gh workflow run "FinOps Hub – Upstream Sync" -f force=true

# Check release gate manually
gh workflow run "FinOps Hub – Release Gate"
```

## What Gets Synced

The sync workflow copies from upstream:
- KQL scripts from `Microsoft.FinOpsHubs/Analytics/scripts/`
- Shared KQL from `fx/`
- Version tracking files

## After a Sync PR is Merged

The maintainer must complete these manual steps:

1. **Adapt Bicep changes** — Upstream Bicep structure differs from AVM. Translate any new parameters, resources, or modules.
2. **Normalize line endings** — Run CRLF→LF on `.kql` files (Windows)
3. **Rebuild** — `bicep build main.bicep --outfile main.json`
4. **Regenerate README** — `Set-ModuleReadMe -TemplateFilePath main.bicep`
5. **Update CHANGELOG** — Add version entry with changes
6. **Validate CI** — Push and confirm all checks pass

## Label

The workflows use the `upstream-sync` label. Create it in your fork if it doesn't exist:

```bash
gh label create upstream-sync --color "0E8A16" --description "Automated upstream sync from microsoft/finops-toolkit"
```
