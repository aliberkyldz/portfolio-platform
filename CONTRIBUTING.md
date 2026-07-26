# Contributing

1. Create `feature/<name>`, `fix/<name>`, or `infra/<name>` from `main`.
2. Use Conventional Commits such as `feat: add project case study`.
3. Run format, lint, tests and build locally.
4. Open a pull request using the template and describe security, cost and
   rollback impact.
5. Obtain at least one approval and pass all required checks.

Never commit credentials, Terraform state, private CV data or `.env` files.
Infrastructure changes must include a reviewed Terraform plan.
