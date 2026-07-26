# Cost optimization case study

## Executive conclusion

Production uses Azure Container Apps Consumption instead of AKS. A static
portfolio does not need a permanent VM, managed Kubernetes control plane or
public load balancer. Scale-to-zero keeps the container architecture while
aligning spend with real traffic.

## Main cost drivers

| Component          | Cost behavior                 | Control                                      |
| ------------------ | ----------------------------- | -------------------------------------------- |
| Container Apps     | Requests and active resources | 0.25 vCPU, 0.5 GiB, scale 0 → 2              |
| Log Analytics      | Ingestion and retention       | 30 days and 1 GB/day cap                     |
| Azure DNS          | Hosted zone and query volume  | Direct authoritative DNS, no unnecessary CDN |
| Terraform state    | Tiny storage/operation usage  | LRS storage                                  |
| Docker Hub         | External image hosting        | Public repository and immutable tags         |
| Managed certificate| No certificate charge         | Azure-managed issuance and renewal           |

Prices are not hard-coded because rates vary by region, currency and date.
Review the Azure pricing calculator and Terraform plan before every apply.

## Guardrails

1. Keep `min_replicas = 0` unless cold-start measurements justify one warm
   replica.
2. Cap replicas at two until real traffic proves otherwise.
3. Require a reviewed Terraform plan and protected production environment.
4. Cap Log Analytics ingestion and retain logs for 30 days.
5. Tag every resource by owner, project and environment.
6. Add Cloudflare or Azure Front Door only for a measured CDN/WAF requirement.
7. Configure Azure Cost Management alerts after choosing a monthly budget.

## Trade-off

Scale-to-zero can introduce a cold start after idle periods. For a portfolio,
that small latency trade-off is preferable to paying for an always-on AKS
node. If availability or latency requirements change, set one minimum replica
before considering a dedicated workload profile.
