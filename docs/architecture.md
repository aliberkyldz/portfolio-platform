# Architecture decisions

## ADR-001 — Astro static generation

- **Status:** Accepted
- **Context:** The portfolio is content-heavy and has no justified dynamic
  backend requirement.
- **Decision:** Generate static HTML with Astro and Tailwind CSS.
- **Consequences:** Minimal browser JavaScript, small attack surface and strong
  performance. Content changes require a new build, which is acceptable.

## ADR-002 — AKS as a learning-oriented runtime

- **Status:** Accepted with caveat
- **Context:** The site must demonstrate Kubernetes operations, although its
  traffic does not technically require Kubernetes.
- **Decision:** Use AKS Free tier, one small system node and an optional Spot
  user pool.
- **Consequences:** The platform exposes Kubernetes, Helm, policy, probes,
  autoscaling and identity skills. It costs materially more than static
  hosting. A single system node is not highly available; two pods on that node
  only protect against process failure, not node failure.

## ADR-003 — Spot is optional capacity, not the availability baseline

- **Status:** Accepted
- **Context:** Spot VMs can be evicted at any time, and AKS system pools cannot
  use Spot priority.
- **Decision:** Keep one regular system pool and isolate Spot to a tainted user
  pool. The production chart defaults to the regular pool.
- **Consequences:** The cluster survives Spot eviction. Enabling the Spot pool
  adds a second VM/disk and may increase rather than reduce total cost unless
  workloads actually move off regular capacity.

## ADR-004 — Docker Hub instead of ACR

- **Status:** Accepted
- **Context:** The project explicitly excludes Azure Container Registry.
- **Decision:** Publish immutable SemVer images to Docker Hub using a
  least-privilege token.
- **Consequences:** Avoids an ACR resource but introduces external registry
  availability and pull-rate considerations. Production must never deploy
  `latest`; it deploys an immutable release tag.

## ADR-005 — Azure DNS without Cloudflare

- **Status:** Accepted
- **Context:** Authoritative DNS is needed; CDN/WAF features are not currently
  justified.
- **Decision:** Delegate the domain to Azure DNS and route directly to NGINX
  Ingress.
- **Consequences:** Simpler ownership and fewer moving parts. Azure DNS is not a
  CDN or WAF. Add Azure Front Door or Cloudflare only after a measured need.

## ADR-006 — Let's Encrypt through cert-manager

- **Status:** Accepted
- **Context:** AKS does not provide Container Apps managed certificates.
- **Decision:** Use cert-manager HTTP-01 with Let's Encrypt and NGINX Ingress.
- **Consequences:** Automated issuance and renewal without storing certificate
  files in Git. DNS must resolve and port 80 must remain reachable for HTTP-01.

## ADR-007 — Secretless Azure access

- **Status:** Accepted
- **Context:** Long-lived Azure credentials in GitHub or Kubernetes create
  avoidable risk.
- **Decision:** GitHub Actions uses OIDC federation and pods use AKS Workload
  Identity. Key Vault uses RBAC.
- **Consequences:** More initial federation configuration, but no client-secret
  rotation burden.

## ADR-008 — Bounded Azure-native observability

- **Status:** Accepted
- **Context:** Logs are useful but ingestion can dominate a small project's
  bill.
- **Decision:** Use Container Insights, 30-day retention and a 1 GB/day cap.
  Keep Prometheus/Grafana optional.
- **Consequences:** Useful operational evidence with a spend guardrail.
  Application Insights is provisioned, while request telemetry comes from
  ingress logs to avoid shipping a browser SDK without a privacy need.
