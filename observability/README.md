# Observability runbook

Azure Monitor Container Insights is enabled by Terraform with a 30-day
retention period and a 1 GB/day ingestion cap. The Azure Portal dashboard covers
node CPU, node memory, and pod readiness.

Useful Log Analytics queries:

```kusto
// Pod restarts in the last 24 hours
KubePodInventory
| where TimeGenerated > ago(24h)
| where Namespace == "portfolio"
| summarize Restarts=max(ContainerRestartCount) by Name, bin(TimeGenerated, 15m)
| render timechart
```

```kusto
// NGINX access lines and request duration, if ingress access logs are enabled
ContainerLogV2
| where TimeGenerated > ago(1h)
| where PodNamespace == "ingress-nginx"
| where LogMessage has "request_time"
| project TimeGenerated, LogMessage
```

```kusto
// Unhealthy or repeatedly recreated portfolio pods
KubePodInventory
| where TimeGenerated > ago(1h) and Namespace == "portfolio"
| summarize LastSeen=max(TimeGenerated), Restarts=max(ContainerRestartCount)
  by Name, PodStatus, ContainerStatus
| order by Restarts desc
```

Suggested alerts:

- Pod readiness below 1 for five minutes: critical.
- Restart count increase above 3 in 15 minutes: warning.
- Node CPU or memory above 85% for 15 minutes: warning.
- External availability test fails from two regions: critical.

Application Insights is provisioned as the workspace-based telemetry resource.
Because the site is static and intentionally ships no client-side monitoring
JavaScript, request latency comes from NGINX ingress logs. This protects
performance and visitor privacy. Add a frontend SDK only when real-user
monitoring has a defined purpose and privacy notice.

## Optional Prometheus/Grafana layer

For a portfolio demonstration, install `kube-prometheus-stack` only
temporarily. Running it continuously on a B2s node consumes a meaningful share
of the cluster and increases Log Analytics overlap. The Azure-native baseline
is therefore the production default.
