# FinOps Hub Dashboards

This folder contains Azure Data Explorer (ADX) dashboards for visualizing FinOps data ingested by FinOps Hub.

## Overview

**Version**: 13.4 (February 2026)

ADX dashboards provide interactive visualizations for analyzing cloud cost and usage data based on the [FinOps Open Cost and Usage Specification (FOCUS)](https://aka.ms/finops/focus). These dashboards are designed for central FinOps teams and finance stakeholders who need comprehensive visibility into cloud spending.

### What's New in v13.4

#### 🐛 Bug Fixes

| Fix | Description |
|-----|-------------|
| **All parameters wired to queries** | Fixed all dashboard parameters (`numberOfMonths`, `numberOfDays`, `maxGroupCount`) — previously every query had hardcoded time ranges and `usedVariables: []`, meaning the filter bar had no effect. Now 31 queries use `numberOfMonths`, 13 use `numberOfDays`, and 22 use `maxGroupCount`. |
| **Orphaned resources `x_ResourceType`** | Fixed orphaned resource queries using `ResourceType` (display name like "Disk") instead of `x_ResourceType` (ARM format like `Microsoft.Compute/disks`). Hub ingestion maps `ResourceType` to `SingularDisplayName`. |
| **Multistat tile minimum height** | Fixed "Current tile size (22, 4) is smaller than the minimum supported tile size (3, 6)" error on orphaned resources summary by increasing tile height from 4 to 6. |

#### 🔄 Improvements

| Improvement | Description |
|-------------|-------------|
| **Parameter descriptions** | Updated `numberOfMonths`, `numberOfDays`, and `maxGroupCount` with helpful examples (e.g., "Enter 7 for last week, 28 for last 4 weeks, 90 for last quarter") |
| **Freetext parameter inputs** | All three numeric parameters use freetext input so users can type any custom value |
| **Removed invalid parameter queries** | Removed 3 `datatable` + `strcat()` queries that caused "Expected ] Token: strcat" syntax errors (`datatable` only supports literal values) |

---

### What's New in v13.1

#### ✨ New Pages

| Page | Domain | Description |
|------|--------|-------------|
| **Forecasting** | QUANTIFY | 90-day cost forecast via `series_decompose_forecast`, current month projection, monthly forecast vs actual, per-subscription projections |
| **Unit Economics** | QUANTIFY | Cost-per-resource, cost-per-subscription, cost-per-RG efficiency ratios, monthly efficiency trend, unit cost by resource type |

#### ✨ New Features

| Enhancement | Description |
|-------------|-------------|
| **Monthly Budget Parameter** | New 💰 Monthly Budget freetext parameter — enables budget vs actual comparisons on Budgeting and Forecasting pages |
| **Tag Key Parameter** | New 🏷️ Tag Key filter with query-driven dropdown — filter chargeback data by any tag key |
| **Budget Tracking** | 3 new tiles on Budgeting page: Budget vs Actual KPIs (with 🟢/🟡/🔴 status), Budget Burn Rate chart, Budget Variance by Subscription |
| **Chargeback & Showback** | 2 new tiles on Invoicing page: Chargeback by Tag Value (bar), Showback by Department (table) |
| **CPU Architecture** | Cost breakdown by CPU architecture (AMD/Intel/Arm64 Cobalt) on Summary page — community request [#1594](https://github.com/microsoft/finops-toolkit/issues/1594) |
| **Data Quality Warnings** | Flags EffectiveCost > ListCost anomalies on Data Ingestion page — addresses [#1424](https://github.com/microsoft/finops-toolkit/issues/1424) |
| **6 New Cross-Filters** | ServiceName, ServiceCategory, and ResourceGroupName cross-filters on Summary page charts/tables |
| **4 New Drillthroughs** | Anomaly subscription chart → Resource Drilldown, Rate Optimization chargeback → Resource Drilldown, Budgeting subscription table → Resource Drilldown |
| **Experimental: Community Items** | Cloud Sustainability placeholder, Workload Optimization placeholder ([#1602](https://github.com/microsoft/finops-toolkit/issues/1602)), FinOps Maturity Scorecard placeholder, Community Feature Requests links |

#### 🔄 Improvements

| Improvement | Description |
|-------------|-------------|
| **Legend Optimization** | 22 wide stacked charts moved to bottom legend placement for better readability |
| **Experimental Header** | Updated with 6-feature table including 3 new community-requested items |
| **FinOps Coverage** | Dashboard now covers 10+ FinOps Framework capabilities (was 5) |

---

### What's New in v13.0

#### 🐛 Bug Fixes

| Fix | Description |
|-----|-------------|
| **BillingPeriodStart Queries** | Fixed 3 Summary page queries that incorrectly used `ChargePeriodStart` instead of `BillingPeriodStart` for month-over-month calculations |
| **Tag KQL Queries** | Fixed 5 Tag Allocation queries with proper `bag_keys()` + `mv-apply` patterns for reliable tag parsing |
| **SaaS Query Fix** | Fixed `x_PublisherCategory` filter value from `'Vendor'` to `'Marketplace'` (FOCUS schema compliance) |
| **Typo Fixes** | Fixed "Understand uage" → "Understand usage", "aligment" → "alignment" |
| **Dead Color Rule** | Re-enabled a disabled color rule on the "Counts (last n days)" multistat tile |
| **Decimal Type Fixes** | Applied decimal→real type fixes from [#1881](https://github.com/microsoft/finops-toolkit/issues/1881) |

#### ✨ New Features

| Enhancement | Description |
|-------------|-------------|
| **Subscription Filter** | New 🏢 Subscription parameter with "Select All" support — filter all cost tiles by subscription |
| **Region Filter** | New 🌍 Region parameter with "Select All" support — filter all cost tiles by region |
| **Cross-Filter Mappings** | 11 tiles wired with column→parameter mappings: click a subscription or region chart to filter the dashboard |
| **Drillthrough Navigation** | 2 Summary page subscription tiles drill through to Resource Drilldown page with subscription context |
| **Conditional Formatting** | Color rules on 10 tiles: MoM Change (🔴↑/🟢↓), Savings Rate (🟢≥50%/🟠<10%), Cost Spikes (🔴>$1K), Utilization (🟢≥90%/🔴<70%) |
| **Amortized vs Actual Docs** | About page comparison table explaining BilledCost (Actual) vs EffectiveCost (Amortized) with ACM mapping guidance |
| **Summary Page Info** | Added ℹ️ callout on Summary page clarifying it shows effective (amortized) cost |
| **Experimental Section** | New EXPERIMENTAL page group with MACC Tracking, Tag Allocation, and Resource Drilldown |
| **Tag Allocation** | Tag coverage analysis, cost by tag key/value, tag detail table, monthly coverage trend |
| **Resource Drilldown** | Subscription-to-resource drill-down with cost by service, resource group, and resource |

#### 🔄 Improvements

| Improvement | Description |
|-------------|-------------|
| **Page Renames** | "Licensing + SaaS" → "Azure Hybrid Benefit", "Marketplace" → "SaaS" for clarity |
| **Improved Descriptions** | Updated headers with clearer explanations for end users |
| **Schema v67 Compliance** | All IDs use valid UUIDs, removed invalid properties |
| **Survey Tracking** | Updated to FTK13.0 for telemetry |

> 💎 **Enterprise-Ready**: This dashboard is optimized for executive presentations and leadership reviews with professional styling, interactive cross-filtering, and auto-refresh capabilities.

> ⚠️ **Security Note**: ADX dashboards do not include row-level security (RLS) by default. All users with database reader access can see ALL data in the dashboard. These dashboards are best suited for:
> - Central FinOps teams with full organizational visibility
> - Finance leadership reviewing company-wide spend
> - Cloud Center of Excellence (CCoE) teams
>
> For scenarios requiring data isolation by subscription or business unit, consider Power BI reports with RLS enabled instead.

---

## ✨ Enterprise Features

This dashboard incorporates Azure Data Explorer best practices for executive-grade presentations:

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Auto-Refresh** | 15m default, 5m minimum | Always up-to-date for live presentations |
| **Cross-Filters** | 17 tiles with column→parameter mappings | Click subscription, region, service, or resource group charts to filter the dashboard |
| **Drillthrough** | 6 tiles with page navigation | Click a subscription to jump to Resource Drilldown with context |
| **Conditional Formatting** | 13 tiles with color rules + icons | Red/green/orange highlights for KPIs, budget status, trends, and thresholds |
| **Budget & Tag Filters** | 7 interactive parameters | Budget target, tag key, subscription, region, date ranges, and grouping |
| **Large KPI Cards** | Multi-stat tiles with large text | Visible from any meeting room position |
| **Optimized Legends** | Bottom-aligned on wide charts, right on narrow | Clear data series identification without compressing chart area |
| **Performance Tuned** | 10 series limit on load, 5-point tooltips | Fast rendering for large datasets |
| **Human-Readable JSON** | 6,000+ lines, properly indented | Easy to version control and customize |

### Visual Types Used

| Visual Type | Count | Use Case |
|-------------|-------|----------|
| Markdown Cards | 81 | Section headers, explanatory text, inline documentation |
| Tables | 50 | Detailed drill-down data with conditional formatting |
| Stacked Column | 22 | Time series comparisons |
| Multi-Stat | 22 | Executive KPI summaries with color rules |
| Bar/Column | 27 | Category comparisons with cross-filter support |
| Pie | 5 | Distribution breakdowns |
| Area/Stacked Area | 5 | Trend visualizations |
| Time Chart | 3 | Time series and forecast analysis |

---

## Available Dashboards

### finops-hub-dashboard.json

**Title**: FinOps Hub - Cloud Cost Intelligence Dashboard

**Purpose**: Comprehensive FinOps dashboard aligned with the FinOps Framework capabilities.

**Prerequisites**:
- FinOps Hub deployed with ADX (Azure Data Explorer) enabled
- ADX cluster with cost data ingested
- `Viewer` access to the ADX database (minimum)

---

## Dashboard Pages

The dashboard is organized into sections aligned with the [FinOps Framework](https://www.finops.org/framework/):

### 📊 About
Introduction page with dashboard overview, navigation guidance, and a comparison table explaining the difference between Amortized (EffectiveCost) and Actual (BilledCost) cost types with guidance on how to compare with Azure Cost Management.

---

### 🔍 UNDERSTAND Domain

#### Summary
- **Purpose**: High-level cost overview and trends
- **Key Visuals**: Monthly cost trends, month-over-month changes, cost by subscription, **CPU architecture breakdown** (AMD/Intel/Arm64)
- **Interactive Features**: Cross-filter on subscription/region/service/resource group charts, drillthrough to Resource Drilldown
- **Use Cases**: Quick health check on overall cloud spend, architecture cost comparison
- **Note**: Shows effective (amortized) cost — see About page for details on cost types

#### Anomaly Management
- **Purpose**: Detect unexpected cost changes and spending patterns
- **Key Visuals**: Daily cost with rolling averages, top cost spikes, deviation analysis
- **Use Cases**: Identify runaway resources, misconfigurations, or unexpected charges
- **FinOps Capability**: [Anomaly Management](http://aka.ms/ftk/fx/anomalies)

#### Data Ingestion
- **Purpose**: Monitor the health of data pipelines and ingestion status
- **Key Visuals**: Ingested months, row counts by dataset, data quality checks, **data quality warnings** (EffectiveCost > ListCost detection)
- **Use Cases**: Ensure data freshness, troubleshoot ingestion issues, identify billing data anomalies ([#1424](https://github.com/microsoft/finops-toolkit/issues/1424))

---

### 💡 OPTIMIZE Domain

#### Rate Optimization
- **Purpose**: Analyze commitment discount utilization and savings opportunities
- **Key Visuals**: 
  - Effective Savings Rate (ESR) calculations
  - Commitment utilization (Reservations, Savings Plans)
  - Savings breakdown by type (negotiated vs commitment)
  - Underutilized commitments
- **Use Cases**: Maximize ROI on commitment discounts, identify waste
- **Key Metrics**:
  - **List Cost**: On-demand pricing without any discounts
  - **Contracted Cost**: After negotiated discounts (EA/MCA pricing)
  - **Effective Cost**: Final cost after all discounts (amortized)
  - **ESR**: Total Savings ÷ List Cost

#### Azure Hybrid Benefit
- **Purpose**: Analyze hybrid benefit licensing for Windows Server, SQL Server, and Linux
- **Key Visuals**: License coverage, underutilized vCPU capacity, eligible resources
- **Use Cases**: Optimize Azure Hybrid Benefit (AHUB) utilization, identify licensing opportunities
- **FinOps Capability**: [Licensing & SaaS](http://aka.ms/ftk/fx/licensing)

#### SaaS
- **Purpose**: Track spending on Azure Marketplace, third-party SaaS, and vendor products
- **Key Visuals**:
  - SaaS summary stats (total spend, publishers, products)
  - Monthly SaaS spend trend
  - Top publishers and products by spend
  - Spend by subscription
- **Use Cases**: Vendor management, SaaS sprawl identification, procurement planning, contract renewals
- **FOCUS Fields**: `PublisherCategory = 'Vendor'`, `PublisherName`, `ServiceName`
- **FinOps Capability**: [Licensing & SaaS](http://aka.ms/ftk/fx/licensing)

#### Spot Analysis
- **Purpose**: Track spot/preemptible instance usage and savings
- **Key Visuals**:
  - Spot summary stats (spend, resources, savings)
  - Pricing category breakdown (On-Demand vs Spot vs Committed)
  - Spot vs On-Demand trend
  - Top spot resources with savings percentage
- **Use Cases**: Identify spot savings opportunities, track spot adoption
- **FOCUS Fields**: `PricingCategory = 'Dynamic'`

---

### 📈 QUANTIFY Domain

#### Budgeting
- **Purpose**: Support budget planning and fiscal accountability
- **Key Visuals**: Monthly spend trends, running total comparison, budget vs actual KPIs, budget burn rate, budget variance by subscription
- **Interactive Features**: Budget vs Actual multistat with 🟢/🟡/🔴 status indicators, cumulative burn rate chart with budget line overlay
- **Parameters**: Set `monthlyBudget` to enable budget tracking — variance thresholds at 5% (at risk) and 15% (over budget)
- **Use Cases**: Fiscal year planning, monthly budget compliance, subscription-level budget allocation
- **FinOps Capability**: [Budgeting](http://aka.ms/ftk/fx/budgeting)

#### Forecasting
- **Purpose**: Predict future cloud spending using time-series decomposition and trend analysis
- **Key Visuals**:
  - **90-day cost forecast**: `series_decompose_forecast` with 6 months of training data, overlapping actual + forecast lines
  - **Current month projection**: Daily run rate × days in month, with month-over-month change %
  - **Monthly forecast vs actual**: Historical actuals + 3-month forward projection
  - **Projected cost by subscription**: Top 10 subscriptions by projected monthly spend
  - **Monthly cost trend table**: MoM change % with 📈/📉 trend indicators
- **Parameters**: Uses `monthlyBudget` for projection comparisons, `numberOfMonths` for history depth
- **Use Cases**: Budget planning, executive cost briefings, identifying spending trajectory changes
- **FinOps Capability**: [Forecasting](https://www.finops.org/framework/capabilities/forecasting/)

#### Unit Economics
- **Purpose**: Measure cost efficiency using per-unit metrics (cost/resource, cost/subscription, cost/RG)
- **Key Visuals**:
  - **Cost efficiency KPIs**: Cost per resource, per subscription, per resource group (multistat)
  - **Cost efficiency by subscription**: Ranked bar chart showing total cost, resources, and cost-per-resource
  - **Monthly efficiency trend**: Time series of cost-per-resource over time
  - **Cost efficiency by resource group**: Top RGs ranked by cost-per-resource
  - **Unit cost by resource type**: Detailed table with resource counts and per-unit costs
- **Use Cases**: Identify over-provisioned subscriptions, track resource efficiency trends, capacity planning
- **FinOps Capability**: [Unit Economics](https://www.finops.org/framework/capabilities/unit-economics/)

---

### 🛠️ MANAGE Domain

#### Invoicing + Chargeback
- **Purpose**: Support internal billing, cost allocation, and department-level chargeback
- **Key Visuals**: Cost by period, change over time, monthly counts, chargeback by tag value, showback by department
- **Interactive Features**: Tag Key parameter filters chargeback tile by any tag key; drillthrough to Resource Drilldown from subscription tiles
- **Parameters**: Use `tagKeyFilter` to select a tag key (e.g., Department, CostCenter, BusinessUnit) for tag-based chargeback
- **Use Cases**: Internal invoicing, showback/chargeback reports, department allocation, tag-based cost attribution
- **FinOps Capability**: [Invoicing & Chargeback](https://www.finops.org/framework/capabilities/invoicing-chargeback/)

---

### 🧪 EXPERIMENTAL

Preview capabilities, community-requested features, and items needing community feedback. Some require manual setup or external data sources.

#### MACC Tracking
- **Purpose**: Track Microsoft Azure Consumption Commitment (MACC) burn-down
- **Status**: ⏳ Requires manual entry of MACC contract details via KQL script
- **Key Visuals**: MACC status table, monthly consumption trend, forecast KPIs
- **Data Requirements**: Run `ManualEntry_MACC.kql` against your ADX cluster to enter contract details
- **Use Cases**: Contract compliance, procurement planning, finance reporting, renewal negotiations
- **FinOps Capability**: [Managing commitment discounts](https://learn.microsoft.com/azure/cost-management-billing/manage/track-consumption-commitment)

#### Tag Allocation
- **Purpose**: Analyze cost allocation using resource tags
- **Status**: ✅ Uses FOCUS `Tags` column — works with standard FinOps Hub ingestion
- **Key Visuals**:
  - **Tag coverage stats**: Tagged vs untagged cost and resource counts
  - **Cost by tag key**: Top tag keys by total effective cost (bar chart)
  - **Cost by tag value**: Top key=value pairs by cost (bar chart)
  - **Tag detail table**: All tag key-value pairs with cost and resource count
  - **Monthly tag coverage trend**: Tagged vs untagged cost over time (stacked column)
- **FOCUS Fields**: `Tags` (JSON key-value pairs), `EffectiveCost`, `BilledCost`, `ResourceId`
- **Use Cases**: Tagging compliance, cost allocation reporting, identifying untagged resources, showback by team/project/environment
- **FinOps Capability**: [Allocation](http://aka.ms/ftk/fx/allocation)

#### Resource Drilldown
- **Purpose**: Drill into resource-level cost under each subscription
- **Status**: ✅ Uses FOCUS cost data — works with standard FinOps Hub ingestion
- **Key Visuals**:
  - **Subscription summary stats**: Subscription count, resource group count, resource count, total cost
  - **Cost by subscription**: Monthly trend with top-N grouping (stacked column)
  - **Top resources by subscription**: Nested table showing Subscription → Resource Group → Resource with cost
  - **Cost by service**: Top services by effective cost (bar chart)
  - **Cost by resource group**: Top resource groups by effective cost (bar chart)
- **FOCUS Fields**: `SubAccountId`, `SubAccountName`, `ResourceId`, `ResourceName`, `x_ResourceGroupName`, `ServiceName`, `x_ResourceType`
- **Use Cases**: Identifying top cost drivers per subscription, resource-level cost accountability, capacity planning
- **FinOps Capability**: [Reporting & analytics](http://aka.ms/ftk/fx/reporting)

#### Orphaned Resources
- **Purpose**: Identify likely orphaned/idle resources and their associated costs using heuristic detection from cost data patterns
- **Status**: 🧪 Heuristic-based — uses cost data patterns to flag likely orphaned resources (no Advisor API dependency)
- **Approach**: The Hub `Recommendations()` table only contains reservation purchase recommendations, NOT Azure Advisor orphaned resource alerts. This experimental feature uses **cost-based heuristics** to detect likely orphans:
  - **Unattached managed disks**: `ResourceType =~ 'Microsoft.Compute/disks'` with cost but no corresponding VM compute charges in the same resource group
  - **Unused public IPs**: `ResourceType =~ 'Microsoft.Network/publicIPAddresses'` with charges but no associated VM/LB
  - **Stopped VMs**: VMs with only disk/storage charges but zero compute charges over the lookback period
  - **Idle load balancers**: `ResourceType =~ 'Microsoft.Network/loadBalancers'` with no backend pool traffic
  - **Empty App Service plans**: `ResourceType =~ 'Microsoft.Web/serverFarms'` with cost but no associated web apps
- **Key Visuals**:
  - **Orphaned resource summary**: Total waste estimate, resource count, top resource types (multistat)
  - **Waste by resource type**: Orphaned cost breakdown by type (pie chart)
  - **Orphaned resources detail table**: ResourceName, ResourceType, SubAccountName, MonthlyCost, DetectionRule, x_ResourceGroupName
  - **Projected annual waste**: Monthly orphaned cost × 12 for budget impact
  - **Waste trend**: Monthly orphaned resource cost over time (stacked column)
- **FOCUS Fields**: `ResourceId`, `ResourceName`, `ResourceType`, `SubAccountName`, `EffectiveCost`, `ChargeCategory`, `x_ResourceGroupName`
- **Limitations**:
  - Heuristic detection may produce false positives — resources flagged as "orphaned" may still be in use for DR, staging, or compliance
  - Does not replace Azure Advisor — Advisor has access to utilization metrics that cost data alone cannot provide
  - Detection accuracy depends on cost export granularity and resource tagging
- **Use Cases**: Cost optimization reviews, identifying waste before budget cycles, subscription cleanup, governance reporting
- **FinOps Capability**: [Workload Optimization](https://www.finops.org/framework/capabilities/workload-optimization/)

#### Cloud Sustainability (Blocked)
- **Purpose**: Track carbon emissions and environmental impact of cloud resources
- **Status**: 🚧 Blocked — waiting for FOCUS carbon columns (`CarbonEmissions`, `CarbonIntensity`) in Azure cost exports
- **FinOps Capability**: [Cloud Sustainability](https://www.finops.org/framework/capabilities/sustainability/)

#### Workload Optimization (Community Input)
- **Purpose**: Right-sizing recommendations, idle resource detection, and resource efficiency scoring
- **Status**: 🚧 Needs community input — requires Azure Advisor API data integration ([#1602](https://github.com/microsoft/finops-toolkit/issues/1602))
- **FinOps Capability**: [Workload Optimization](https://www.finops.org/framework/capabilities/workload-optimization/)

#### FinOps Maturity Scorecard (Community Input)
- **Purpose**: Crawl/Walk/Run maturity assessment based on tag compliance, commitment coverage, budget variance
- **Status**: 🚧 Needs community consensus on scoring methodology and thresholds
- **FinOps Capability**: [FinOps Assessment](https://www.finops.org/framework/capabilities/finops-assessment/)

#### Community Feature Requests
- Links to top-voted community issues from [microsoft/finops-toolkit](https://github.com/microsoft/finops-toolkit/issues)
- Includes: CPU architecture cost breakdown (#1594 ✅ implemented), Workload Optimization (#1602), Predictive commitment models (#1060), Cross-provider sub-allocation (#1970)

---

### 📋 FOCUS (Executive Summary)

- **Purpose**: CFO and Finance team executive summary
- **Key Visuals**:
  - **Executive Summary**: This month cost, last month comparison, 30-day trend
  - **Anomaly Detection**: Daily costs with rolling averages, top spikes
  - **Rate Optimization**: Commitment utilization, savings by type
  - **Multi-Cloud Analysis**: Cost by cloud provider (Azure, AWS, GCP)
  - **Cost Allocation**: Tag coverage, cost by subscription
  - **Budgeting & Forecasting**: Monthly trends, month-over-month changes
- **Use Cases**: Board presentations, finance reviews, executive briefings

---

## How to Import

1. Navigate to your ADX cluster in the Azure portal
2. Select **Dashboards** from the left menu
3. Click **Import dashboard**
4. Select the `finops-hub-dashboard.json` file
5. Update the **data source** connection:
   - Cluster URI: `https://<your-cluster>.kusto.windows.net`
   - Database: `Hub` (default FinOps Hub database name)
6. Click **Save**

---

## Customization

### Dashboard Parameters

The dashboard includes configurable parameters (displayed in the filter bar):

| Parameter | Label | Default | Description |
|-----------|-------|---------|-------------|
| `numberOfMonths` | 📅 Monthly trend | 1 | Number of months to look back in monthly trend charts. Enter 0 for current month only, 1 for this + last month, 6 for half a year, 12 for a full year. |
| `numberOfDays` | 📊 Daily trend | 28 | Number of days to look back in daily trend charts. Enter 7 for last week, 28 for last 4 weeks, 90 for last quarter. |
| `maxGroupCount` | 📋 Max groups | 9 | Max items to show in grouped charts. Remaining items are combined into an "(N others)" group. Try 5 for clean charts or 25 for more detail. |
| `subscriptionFilter` | 🏢 Subscription | All | Filter all cost tiles by subscription name |
| `regionFilter` | 🌍 Region | All | Filter all cost tiles by Azure region |
| `monthlyBudget` | 💰 Monthly budget | 0 | Monthly cloud budget target for variance tracking (Budgeting + Forecasting pages) |
| `tagKeyFilter` | 🏷️ Tag key | All | Filter chargeback/allocation data by a specific tag key (Invoicing + Tag Allocation pages) |

> 💡 **Tip**: Parameters use icons for visual clarity. Use the filter bar at the top of the dashboard to adjust these values. `numberOfMonths`, `numberOfDays`, and `maxGroupCount` accept any number — type a custom value to fine-tune your view. Set `monthlyBudget` to your monthly cloud budget to enable budget vs actual tracking with 🟢/🟡/🔴 status indicators. The `tagKeyFilter` parameter drives the chargeback-by-tag tile on the Invoicing page.

### Cross-Filter Interactivity

The dashboard enables **cross-filtering** with column-to-parameter mappings on 17 key tiles:

| Interaction | Tiles | Behavior |
|-------------|-------|----------|
| **Subscription cross-filter** | 11 subscription charts & tables | Click a subscription bar/row → sets 🏢 Subscription filter |
| **Region cross-filter** | Region charts & tables | Click a region bar/row → sets 🌍 Region filter |
| **ServiceName cross-filter** | 2 Summary service name tiles | Click a service name → filters other service name tiles |
| **ServiceCategory cross-filter** | 2 Summary service category tiles | Click a service category → filters other service category tiles |
| **ResourceGroup cross-filter** | 2 Summary resource group tiles | Click a resource group → filters other resource group tiles |
| **Drillthrough** | 6 subscription tiles (Summary, Anomaly, Rate Opt, Budgeting) | Click a subscription → navigates to Resource Drilldown page |

Executives can:
1. Click any subscription or region chart segment to filter all cost tiles on the page
2. Drill through from Summary subscription tiles directly to Resource Drilldown with subscription context
3. Reset filters using the "Reset" button in the top bar or selecting "All" in the parameter dropdown

### Conditional Formatting

Color rules and icons highlight important thresholds at a glance:

| Tile | Rule | Visual |
|------|------|--------|
| **Month-over-Month Change** | Cost increase > 0 | 🔴 Red cell + ↑ up arrow |
| **Month-over-Month Change** | Cost decrease < 0 | 🟢 Green cell + ↓ down arrow |
| **Effective Savings Rate** | ESR ≥ 50% | 🟢 Green cell (healthy) |
| **Effective Savings Rate** | ESR < 10% | 🟠 Orange cell (needs attention) |
| **Top Cost Spikes** | EffectiveCost > $1,000 | 🔴 Red row highlight |
| **Commitment Utilization** | Utilization ≥ 90% | 🟢 Green cell (on target) |
| **Commitment Utilization** | Utilization < 70% | 🔴 Red cell (underutilized) |
| **Budget vs Actual** | Status = On track | 🟢 Green (within budget) |
| **Budget vs Actual** | Status = At risk | 🟡 Yellow (5-15% over) |
| **Budget vs Actual** | Status = Over budget | 🔴 Red (>15% over) |

### Adding Custom Pages

1. Open the dashboard in ADX
2. Click **+ Add page**
3. Add tiles using KQL queries against the `Hub` database
4. Key tables available:
   - `Costs` - FOCUS-aligned cost data
   - `Prices` - Price sheet data
   - `Recommendations` - Azure Advisor recommendations
   - `Transactions` - Reservation/savings plan transactions

### Customizing for Your Brand

To customize the dashboard appearance:

1. **Title**: Edit the dashboard title in the settings menu
2. **Color Palette**: Each tile can use different color schemes (blues, greens, categorical)
3. **Conditional Formatting**: Add color rules to highlight thresholds (red/yellow/green)
4. **Legend Position**: Adjust legend placement per tile for optimal readability

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No data visible | Verify data ingestion completed in Data Ingestion page |
| Permission denied | Request `Viewer` role on ADX database |
| Wrong cluster | Update data source connection in dashboard settings |
| Stale data | Check ADF pipeline triggers are running |
| Slow performance | Reduce `numberOfMonths` or `numberOfDays` parameters |
| Too many series | Reduce `maxGroupCount` parameter |

---

## Related Resources

- [FinOps Framework Capabilities](https://www.finops.org/framework/capabilities/)
- [FOCUS Specification](https://focus.finops.org/)
- [Azure Data Explorer Dashboards](https://learn.microsoft.com/azure/data-explorer/azure-data-explorer-dashboards)
- [FinOps Toolkit Documentation](https://aka.ms/finops/toolkit)

---

## FOCUS Compatibility

This dashboard is designed to work with the [FinOps Open Cost and Usage Specification (FOCUS)](https://focus.finops.org/) schema. The table below shows compatibility with different FOCUS versions:

### Version Support Matrix

| FOCUS Version | Release Date | Status | Notes |
|---------------|--------------|--------|-------|
| 1.0-preview(v1) | Nov 2023 | ✅ Fully compatible | Initial preview spec |
| 1.0 | June 2024 | ✅ Fully compatible | **Microsoft exports this version** |
| 1.1 | Nov 2024 | ✅ Compatible | New: `CapacityReservationId`, `CommitmentDiscountQuantity` |
| 1.2 | June 2025 | ✅ Compatible | New: `InvoiceId`, `PricingCurrency`, `SubAccountType` |
| 1.3 | Dec 2025 | ⚠️ Works with deprecations | Deprecated: `ProviderName`, `PublisherName` |

### Column Usage Notes

This dashboard uses the following FOCUS columns that have deprecation notices in v1.3:

| Column | Dashboard Usage | FOCUS 1.3 Replacement | Migration Status |
|--------|----------------|----------------------|------------------|
| `ProviderName` | Commitment discount calculations, FOCUS page provider breakdown | `ServiceProviderName` | Defer until Microsoft exports 1.3 |
| `PublisherName` | SaaS page publisher counts and grouping | *(deprecated, no replacement)* | Defer until Microsoft exports 1.3 |

### Microsoft Extended Columns

The dashboard also uses Microsoft-specific extended columns (prefixed with `x_`). Note that the Hub `Costs` function abstracts some of these into shorter aliases (e.g., `x_SkuMeterName` → `SkuMeter`). Dashboard queries reference the function output columns:

| Column | Function Output | Purpose | Stability |
|--------|----------------|---------|-----------|
| `x_PublisherCategory` | `PublisherCategory` | Filter Marketplace/Vendor vs Microsoft charges | ✅ Stable |
| `x_SkuMeterName` | `SkuMeter` | CPU architecture detection (AMD/Intel/Cobalt) | ✅ Stable |
| `x_SkuMeterCategory` | `SkuMeterCategory` | Azure Hybrid Benefit license type detection | ✅ Stable |
| `x_SkuMeterSubcategory` | `SkuMeterSubcategory` | Azure Hybrid Benefit license type detection | ✅ Stable |
| `x_ResourceGroupName` | `ResourceGroupName` | Resource group grouping for unit economics | ✅ Stable |

### Forward Compatibility Strategy

1. **Current State**: Microsoft Cost Management exports FOCUS 1.0 schema
2. **Dashboard Approach**: Queries reference the Hub `Costs` function output columns (e.g., `SkuMeter`, `ResourceType`) rather than raw `x_` prefixed export columns, ensuring abstraction from schema changes
3. **Future Migration**: When Microsoft upgrades to FOCUS 1.2/1.3:
   - The FinOps Hub `Costs` function abstracts schema changes
   - Dashboard queries already use function output aliases — only the function internals need updating
   - Backward compatibility will be maintained where possible

> 💡 **Best Practice**: Monitor the [FOCUS changelog](https://github.com/FinOps-Open-Cost-and-Usage-Spec/FOCUS_Spec/blob/working_draft/CHANGELOG.md) and [Microsoft FOCUS documentation](https://learn.microsoft.com/azure/cost-management-billing/automate/focus-dataset-columns) for schema updates.

---

## Roadmap / TODO

The following dashboard enhancements are planned for future releases:

### Promote Experimental Features to Production

The following experimental features are candidates for promotion to the main dashboard once they mature:

| Feature | Current Status | Promotion Criteria |
|---------|---------------|-------------------|
| **MACC Tracking** | 🧪 Experimental (manual setup) | Awaiting MACC data in Cost Management exports |
| **Tag Allocation** | 🧪 Experimental | Community feedback on tag-based cost analysis queries |
| **Resource Drilldown** | 🧪 Experimental | Community feedback on resource-level drill-down UX |
| **Provider Comparison** | 🧪 Experimental (v13.2) | Needs multi-cloud data ingestion to validate queries |
| **Orphaned Resources** | 🧪 Experimental (v13.3) | Validate heuristic accuracy with real customer data; consider Advisor API integration ([#1602](https://github.com/microsoft/finops-toolkit/issues/1602)) |

### Completed Enhancements (v13.0)

- ~~**Cross-filter integration**: Enable cross-filtering between subscription chart and resource drilldown table~~ → ✅ Done: 11 tiles with subscription/region cross-filters + drillthrough to Resource Drilldown
- ~~**Subscription/Region filtering**: Add parameters to filter by subscription and region~~ → ✅ Done: 2 new interactive parameters with "Select All" support
- ~~**Conditional formatting**: Add color rules to highlight KPIs and thresholds~~ → ✅ Done: 10 tiles with color rules and trend icons
- ~~**Amortized vs Actual documentation**: Help users understand cost type differences~~ → ✅ Done: About page comparison table + Summary page callout

### Completed Enhancements (v13.2)

- ~~**Cloud provider filter**: Add ☁️ Provider parameter dropdown from FOCUS ProviderName~~ → ✅ Done: Query-driven parameter showing on all pages with "Select All" support
- ~~**Provider cross-filter**: Enable cross-filtering on Cost by Provider and Provider Trend tiles~~ → ✅ Done: Click provider to filter all FOCUS page tiles
- ~~**Provider breakdown on Summary**: Add multi-cloud distribution section~~ → ✅ Done: Provider pie (with cross-filter) + monthly provider trend on Summary page
- ~~**Provider on key tables**: Show ProviderName on Ingestion, Invoicing, and Resource Drilldown tables~~ → ✅ Done: Provider column on alignment table, data quality warnings, new resource drilldown table
- ~~**Billing account hierarchy**: Add BillingAccountName tiles to FOCUS page~~ → ✅ Done: Account Hierarchy section with bar chart + detail table
- ~~**Invoice issuer tracking**: Add InvoiceIssuerName to Invoicing page~~ → ✅ Done: New "Cost by provider and invoice issuer" table with monthly breakdown
- ~~**FOCUS-neutral labels**: Replace Azure-centric "Subscriptions" with FOCUS "Sub Accounts"~~ → ✅ Done: Updated FOCUS page tile titles and markdown headers
- ~~**Provider-aware markdown**: Update section headers with multi-cloud context~~ → ✅ Done: Executive Summary, Multi-Cloud Analysis, Cost Allocation, Budgeting headers updated
- ~~**Provider Comparison page**: Add experimental side-by-side cloud comparison~~ → ✅ Done: New page with monthly/daily trends, service table, sub-account table, savings by provider
- ~~**Cumulative cost chart**: Add running total this month vs last month~~ → ✅ Done: Cumulative area chart on FOCUS page after Executive Summary

### Completed Enhancements (v13.1)

- ~~**Cost forecasting**: Add dedicated Forecasting page with 90-day projections~~ → ✅ Done: Forecasting page with series_decompose_forecast, month projection, trend table
- ~~**Unit economics**: Add cost-per-unit efficiency metrics~~ → ✅ Done: Unit Economics page with cost/resource, cost/sub, cost/RG ratios
- ~~**Budget tracking**: Add budget vs actual with variance thresholds~~ → ✅ Done: Budget parameter + 3 new tiles with 🟢/🟡/🔴 status
- ~~**Chargeback & showback**: Add tag-based chargeback and department summaries~~ → ✅ Done: Tag Key parameter + 2 new tiles on Invoicing page
- ~~**CPU architecture**: Cost breakdown by AMD/Intel/Arm64~~ → ✅ Done: Pie chart on Summary page using `SkuMeter` column with `ResourceType =~ 'Virtual machine'` filter (community request #1594)
- ~~**Data quality warnings**: Flag EffectiveCost > ListCost anomalies~~ → ✅ Done: Warning table on Data Ingestion page
- ~~**Service cross-filters**: Extend cross-filter mappings to ServiceName and ResourceGroup dimensions~~ → ✅ Done: 6 new cross-filters (ServiceName, ServiceCategory, ResourceGroupName)
- ~~**Tag parameter filtering**: Add a dashboard parameter to filter all tiles by a specific tag key/value~~ → ✅ Done: Tag Key parameter on Invoicing + Tag Allocation pages
- ~~**Legend optimization**: Move legends to bottom on wide stacked charts~~ → ✅ Done: 22 wide stacked charts moved to bottom legends
- ~~**Experimental community items**: Add Sustainability, Workload Optimization, Maturity Scorecard~~ → ✅ Done: 3 new placeholders + Community Feature Requests card

### Future Enhancements

- **SKU-level breakdown**: Resource SKU and pricing tier analysis per provider — requires FOCUS `SkuId` / `SkuPriceId` columns (comparable to AWS Cost Explorer "Usage type" grouping and GCP "SKU" column)
- **Carbon & sustainability**: Carbon emission tracking per provider — blocked on FOCUS carbon columns in Azure export (comparable to GCP Carbon Footprint reports)
- **Multi-select parameters**: Upgrade subscription/region filters from single-select to multi-select with `in()` operator
- **Built-in time range picker**: Add ADX native `_startTime`/`_endTime` for ad-hoc date range selection
- **Multi-cloud tags**: Normalize tag formats across Azure, AWS, and GCP providers
- **Workload optimization**: Right-sizing and idle resource detection from Azure Advisor data ([#1602](https://github.com/microsoft/finops-toolkit/issues/1602)) — see 🧪 Orphaned Resources for cost-based heuristic approach available now
- **Predictive commitment models**: Forward-looking RI/SP savings projections ([#1060](https://github.com/microsoft/finops-toolkit/issues/1060))
- **FinOps maturity scorecard**: Crawl/Walk/Run assessment with automated scoring
- **Cross-provider sub-allocation**: FOCUS 1.3 external usage driver attribution ([#1970](https://github.com/microsoft/finops-toolkit/issues/1970))

---

## Dashboard Features

### Built-in ADX Best Practices

This dashboard follows Azure Data Explorer dashboard best practices:

| Feature | Value | Description |
|---------|-------|-------------|
| **Auto-Refresh** | Enabled (15m default, 5m min) | Keeps data up-to-date automatically |
| **Base Queries** | 8 reusable queries | Consistent filtering with subscription/region awareness |
| **Parameters** | 8 configurable filters | Budget, tag key, date ranges, grouping, subscription, region, and provider filters |
| **Cross-Filters** | 19 tiles with column mappings | Click subscription, region, service, resource group, or provider to filter |
| **Drillthroughs** | 6 tiles with page navigation | Click to navigate from Summary/Anomaly/Rate Opt/Budgeting to Resource Drilldown |
| **Conditional Formatting** | 16 tiles with color rules | Budget status, KPIs, trends, and threshold highlights |
| **Human-Readable JSON** | Formatted with indentation | Easy to version control and diff |

### Batteries Included

All analytics capabilities are built directly into the dashboard:
- ✅ **Subscription & Region filters** - Interactive parameters to slice all cost data by subscription or region
- ✅ **Cloud provider filter** - ☁️ Provider dropdown to filter by Azure, AWS, GCP, or any FOCUS ProviderName
- ✅ **Cross-filter interactivity** - Click subscription, region, service, resource group, or provider charts to filter the dashboard
- ✅ **Drillthrough navigation** - Click through from Summary/Anomaly/Rate Opt/Budgeting to Resource Drilldown
- ✅ **Conditional formatting** - Color-coded KPIs, budget status, trend arrows, and threshold highlights
- ✅ **Multi-cloud analysis** - Provider breakdown, billing account hierarchy, and invoice issuer tracking using FOCUS columns
- ✅ **Cumulative cost tracking** - Running total comparison (this month vs last) for pacing analysis
- ✅ **Amortized vs Actual docs** - Built-in guidance on BilledCost vs EffectiveCost with ACM comparison tips
- ✅ **Cost forecasting** - 90-day projections via series_decompose_forecast with current month run rate
- ✅ **Unit economics** - Cost-per-resource, cost-per-subscription, cost-per-RG efficiency metrics
- ✅ **Budget tracking** - Budget vs actual with variance thresholds and 🟢/🟡/🔴 status
- ✅ **Chargeback & showback** - Tag-based chargeback and department-level showback summaries
- ✅ **CPU architecture** - AMD/Intel/Arm64 cost breakdown from `SkuMeter` column (VM resources filtered by `ResourceType =~ 'Virtual machine'`)
- ✅ **Data quality warnings** - Flags EffectiveCost > ListCost anomalies
- ✅ **SaaS tracking** - Full vendor/publisher/marketplace analysis
- ✅ **Spot analysis** - Preemptible instance usage and savings
- ✅ **Anomaly detection** - Rolling averages and spike detection
- ✅ **Rate optimization** - ESR, commitment utilization, savings breakdown
- ✅ **Azure Hybrid Benefit** - License coverage and optimization
- 🧪 **Tag allocation** - Tag coverage analysis and cost by tag key/value (experimental)
- 🧪 **Resource drilldown** - Resource-level cost under each subscription (experimental)
- 🧪 **MACC tracking** - Consumption commitment burn-down (experimental, manual setup)
- 🧪 **Provider comparison** - Side-by-side cost trends, service breakdown, and savings rate across cloud providers (experimental)
- 🧪 **Orphaned resources** - Heuristic detection of likely orphaned disks, IPs, stopped VMs, idle LBs with cost impact (experimental)

**Roadmap (not yet implemented):**
- 🔮 **SKU-level breakdown** - Resource SKU and pricing tier analysis per provider (requires FOCUS `SkuId` / `SkuPriceId` columns)
- 🔮 **Carbon & sustainability** - Carbon emission tracking per provider (blocked: waiting for FOCUS carbon columns in Azure export)

No separate query files needed - import the dashboard and everything works immediately.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 13.4.0 | Feb 2026 | **Parameter wiring & UX fix:** All dashboard parameters (`numberOfMonths`, `numberOfDays`, `maxGroupCount`) now actually control query results — previously all 146 queries had hardcoded time ranges. Fixed orphaned resources `x_ResourceType` filter and multistat tile height. Updated parameter descriptions with helpful examples. Removed 3 invalid `datatable`+`strcat` parameter queries. |
| 13.3.0 | Feb 2026 | **Orphaned Resources page:** 🧪 Experimental page with heuristic detection of likely orphaned disks, unused public IPs, and idle load balancers from FOCUS cost data patterns. Waste summary KPIs (multistat), waste by detection rule (pie), projected annual waste table with 🔴 color rules, orphaned resources detail table with cost highlighting, monthly waste trend (stacked column). No Advisor API dependency — works with standard Hub data. Adds 1 page, 5 queries, 6 tiles, 3 color rules. |
| 13.2.0 | Feb 2026 | **Multi-cloud enhancements:** ☁️ Provider parameter filter (all pages), cross-filter on Provider tiles, provider breakdown on Summary page (pie + trend), billing account section on FOCUS page (bar + table), InvoiceIssuerName on Invoicing, FOCUS-neutral labels (sub accounts), provider-aware markdown headers, cumulative cost chart (this month vs last), Provider Comparison experimental page (monthly/daily trends, service breakdown, savings by provider). Adds 1 page, 13 queries, 17 tiles, 1 parameter. |
| 13.1.0 | Feb 2026 | New Forecasting page (90-day projections), Unit Economics page (cost-per-unit ratios), Budget tracking (3 tiles + budget parameter), Chargeback/Showback (tag key param + 2 tiles), CPU Architecture breakdown, Data Quality warnings, 6 new cross-filters, 4 new drillthroughs, 22 legend optimizations, 3 experimental community items |
| 13.0.1 | Feb 2026 | Fixed BillingPeriodStart queries, tag KQL, dead color rules. Added subscription/region filters, cross-filter mappings (11 tiles), drillthrough navigation (2 tiles), conditional formatting (10 tiles), Amortized vs Actual documentation |
| 13.0.0 | Feb 2026 | Experimental section (MACC, Tag Allocation, Resource Drilldown), page renames, SaaS query fix, schema v67, decimal type fixes |
| 1.0.0 | 2025 | Initial dashboard aligned with FinOps Hub v1.0.0 |
