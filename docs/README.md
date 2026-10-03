# Babylon Deploy Documentation Harness

Welcome to the root documentation harness for [`babylon_deploy`](../README.md). This directory serves as the unified entrypoint for architectural specifications, operational runbooks, infrastructure designs, and agent operational standards governing local Docker Compose environments and cloud infrastructure deployments.

Autonomous and collaborative AI agents (such as Gemini, Claude, OpenAI, and Antigravity) as well as human software architects should use this harness as the single navigation hub for understanding and evolving the platform.

---

## Harness Directory Map

```
docs/
├── README.md                                  # [Root] Documentation harness entrypoint (this file)
└── specs/                                     # Architectural Decision Records (ADRs) & Technical Specifications
    ├── README.md                              # Spec authoring standards & directory guidelines
    └── data-loader-serverless-pipeline.md     # ADR: Serverless Ingestion Pipeline (Lambda, Atlas, Secrets Manager)
```

### Core Documentation Links

| Document | Description | Target Audience |
| :--- | :--- | :--- |
| **[`../AGENTS.md`](../AGENTS.md)** | **Source-of-truth system prompt** conforming to the AAIF open standard. Defines agent personas, architecture context, verification loops, and safety constraints. | LLM Agents & Developers |
| **[`specs/README.md`](./specs/README.md)** | Guidelines and standard ADR structure (Context, Decision Drivers, Trade-Off Matrix, Mermaid Diagrams, Roadmap) for authoring specifications. | Architects & Agents |
| **[`specs/data-loader-serverless-pipeline.md`](./specs/data-loader-serverless-pipeline.md)** | Technical specification for the Go Data Loader AWS Lambda container, S3 landing bucket, and MongoDB Atlas M0 cluster. | Architects & DevOps |
| **[`../README.md`](../README.md)** | Repository-level overview, local Docker Compose quickstart, service inventory, and automation scripts. | All Engineers |
| **[`../terraform/README.md`](../terraform/README.md)** | Infrastructure as Code overview for AWS and MongoDB Atlas cloud provisioning. | DevOps & SREs |
| **[`../BABYLON-APP-FIXES.md`](../BABYLON-APP-FIXES.md)** | Operational troubleshooting log for the local `babylon-app` container setup. | Developers |

---

## Guidelines for LLM Agents Exploring and Contributing

When working in `babylon_deploy`, agents must follow the conventions established in this harness:

1. **Consult Existing Specifications First**: Before modifying Terraform modules or Docker infrastructure, explore [`docs/specs/`](./specs/) to ensure changes comply with accepted architectural decisions and cost boundaries (e.g. $0.00/mo baseline).
2. **Authoring Specifications (ADRs)**: If introducing new infrastructure patterns, services, or significant dependency changes, draft an ADR in [`docs/specs/`](./specs/) following the conventions outlined in [`docs/specs/README.md`](./specs/README.md).
3. **Execute the Verification Loop**: All changes must be verified through the mandatory loop documented in [`AGENTS.md`](../AGENTS.md):
   - **Secret Scanning**: Execute `./local/tools/scan-secrets.sh` to ensure no credentials, tokens, or private keys are present in modified, staged, or untracked files.
   - **Terraform Validation (Mandatory Offline)**: Run `terraform -chdir=terraform validate` to ensure configuration syntax and provider schemas are valid without requiring cloud credentials.
   - **Terraform Plan Generation (Online)**: Run `terraform -chdir=terraform plan -var-file=terraform.tfvars.example` to confirm speculative plan generation succeeds when authenticated with AWS.
4. **Human Review Gate**: **Never execute `git commit` directly**. Leave all changes for the user to review.
