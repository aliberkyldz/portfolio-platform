# Cost optimization case study

## Executive conclusion

The least expensive sensible host for this static site is not AKS. Static Web
Apps, Storage Static Website, or Container Apps can remove the always-on node
and load-balancer cost. AKS is retained because the portfolio's learning and
demonstration value is an explicit product requirement.

This is a **cost-controlled AKS design**, not a claim that Kubernetes is the
cheapest host.

## Main cost drivers

| Component                        | Cost behavior                      | Control                                                    |
| -------------------------------- | ---------------------------------- | ---------------------------------------------------------- |
| AKS control plane                | Free tier selected                 | No uptime SLA; acceptable for portfolio                    |
| System VM                        | Largest fixed compute cost         | One small B-series node; validate regional availability    |
| Spot VM                          | Discounted but optional extra node | Disabled for app scheduling by default; delete when unused |
| Managed disks                    | Per node, fixed allocation         | 30 GiB OS disks; no persistent app volumes                 |
| Standard Load Balancer/public IP | Recurring + rule/data charges      | One ingress controller shares one load balancer            |
| Log Analytics                    | Ingestion and retention            | 30 days, 1 GB/day cap, avoid duplicate telemetry           |
| Key Vault                        | Per operation                      | No polling-heavy application behavior                      |
| Azure DNS                        | Zone + query volume                | Direct authoritative DNS, no extra CDN layer               |
| Storage state                    | Capacity/operations                | LRS and tiny state files                                   |

Prices are intentionally not hard-coded because Azure rates vary by region,
currency and date. Before each apply, use Azure Pricing Calculator for the
chosen region and review the Terraform plan.

## Why “all Spot” was rejected

AKS requires a regular system node pool. A Spot user pool cannot replace it and
can be evicted without notice. Keeping both a regular node and a Spot node for a
tiny static site can cost more than running only the regular node. Spot is kept
as an optional demonstration layer, not a misleading savings claim.

## Scaling choices

- System pool is fixed at one node. A `1 → 2` cluster autoscaler offers little
  benefit for a static site and risks surprise cost.
- HPA ranges from two to four tiny pods. It demonstrates application scaling but
  cannot create capacity when the one node is full.
- Two replicas improve rollout/process resilience, not node-level availability.
- For real availability, use at least two regular nodes across zones; this is a
  conscious cost increase.

## Cost guardrails

1. Set an Azure Cost Management monthly budget and 50/80/100% alerts manually
   after confirming the desired currency and amount.
2. Keep Log Analytics quota and retention bounded.
3. Require a reviewed Terraform plan before apply.
4. Tag all resources by project, owner and environment.
5. Delete the optional Spot pool when it is not part of a demonstration.
6. Review idle public IP, disk and Log Analytics resources monthly.

## Exit strategy

If the project's goal changes from “Kubernetes case study” to “lowest-cost
portfolio,” preserve the same Astro build and Dockerfile but move runtime to
Azure Static Web Apps or Container Apps. DNS and repository workflows can be
adapted without rewriting the frontend.
