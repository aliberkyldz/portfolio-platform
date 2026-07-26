# Architecture decisions

## ADR-001 — Astro static generation

- **Status:** Accepted
- **Context:** The portfolio has no justified dynamic backend requirement.
- **Decision:** Generate static HTML with Astro and Tailwind CSS.
- **Consequences:** Minimal browser JavaScript, small attack surface and strong
  performance. Content changes require a new immutable build.

## ADR-002 — Container Apps Consumption for production

- **Status:** Accepted, superseding the original AKS runtime decision
- **Context:** A personal static portfolio does not justify a permanent
  Kubernetes node and load balancer.
- **Decision:** Run the NGINX image on Azure Container Apps Consumption with
  `min_replicas = 0` and a conservative maximum.
- **Consequences:** The app can scale to zero and Azure manages the runtime.
  Cold starts are acceptable. Helm manifests remain as a portability and
  Kubernetes skills reference, but are not the production control plane.

## ADR-003 — Docker Hub instead of ACR

- **Status:** Accepted
- **Decision:** Publish immutable SemVer images to Docker Hub using a
  least-privilege token.
- **Consequences:** Avoids an ACR resource but introduces external registry
  availability and public pull-rate considerations.

## ADR-004 — Azure DNS without Cloudflare

- **Status:** Accepted
- **Decision:** Delegate the zone to Azure DNS and route apex directly to the
  Container Apps environment; route `www` with CNAME.
- **Consequences:** Fewer moving parts. Azure DNS is not a CDN or WAF; add Azure
  Front Door or Cloudflare only after a measured requirement.

## ADR-005 — Azure-managed TLS

- **Status:** Accepted
- **Decision:** Bind the apex domain with HTTP validation and `www` with CNAME
  validation, using free Container Apps managed certificates.
- **Consequences:** Azure handles issuance and renewal. Let’s Encrypt,
  cert-manager and an ingress controller are unnecessary in production.

## ADR-006 — Secretless Azure access

- **Status:** Accepted
- **Decision:** GitHub Actions authenticates through OIDC workload identity
  federation. No long-lived Azure client secret is stored in GitHub.

## ADR-007 — Bounded Azure-native observability

- **Status:** Accepted
- **Decision:** Use Log Analytics with 30-day retention and a 1 GB/day cap,
  Application Insights and a Container Apps request dashboard.
- **Consequences:** Useful operational evidence with an explicit spend
  guardrail.
