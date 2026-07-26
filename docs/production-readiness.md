# Production readiness checklist

## Before first apply

- [ ] Confirm Azure subscription, region, quotas and B2s AKS availability.
- [ ] Run an Azure Pricing Calculator estimate and set a monthly budget.
- [ ] Bootstrap state and restrict storage access after runner connectivity is designed.
- [ ] Configure GitHub OIDC federation and environment reviewers.
- [ ] Replace placeholder portfolio content and add a real CV.
- [ ] Confirm Docker Hub repository and pull limits.

## Before DNS cutover

- [ ] Confirm Terraform's static public IP and DNS A records match the ingress values.
- [ ] Install NGINX Ingress and cert-manager.
- [ ] Test Let's Encrypt staging first, then production.
- [ ] Verify HTTP to HTTPS redirection and certificate renewal.
- [ ] Run Lighthouse, container scan, Checkov and smoke tests.
- [ ] Validate backup/restore for Terraform state.

## Operations

- [ ] Add Azure Cost Management alerts.
- [ ] Configure availability, restart, CPU and memory alerts.
- [ ] Test rollback to the previous immutable image.
- [ ] Test node drain and document the single-node availability limitation.
- [ ] Review Kubernetes and base-image updates monthly.
