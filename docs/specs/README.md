# Specifications & Architectural Decision Records (ADRs)

Welcome to the specifications catalog within the [`babylon_deploy`](../../README.md) documentation harness. For overall harness navigation and agent system prompts, see [`docs/README.md`](../README.md) and [`AGENTS.md`](../../AGENTS.md).

This directory serves as the repository for architectural decision records, technical specifications, and infrastructure designs governing cloud and local deployments. Agents should explore this directory directly to inspect current and historical specifications.

---

## Specifications & ADR Catalog

| Specification / ADR | Status | Description | Target Components |
| :--- | :--- | :--- | :--- |
| **[`data-loader-serverless-pipeline.md`](./data-loader-serverless-pipeline.md)** | Accepted (Phase 1 Implemented) | Serverless Data Loader Ingestion Pipeline with AWS Lambda, MongoDB Atlas M0, and AWS Secrets Manager | `babylon_data_loader`, `terraform/modules/data-loader` |
| **[`data-loader-infrastructure-cicd.md`](./data-loader-infrastructure-cicd.md)** | Accepted (Implemented - PR #4 Pending Merge) | Declarative Serverless Infrastructure, Remote State Backend, and GitHub Actions CI/CD Pipeline for Babylon Data Loader | `terraform/`, `.github/workflows/terraform.yml`, `tools/` |

---

## Guidelines for Agents Authoring Specifications

All specifications in this directory must adhere to the standard Architectural Decision Record (ADR) format:

1. **File Naming**: Use descriptive kebab-case filenames describing the decision or component (e.g., `<component-or-decision-topic>.md`). Do not use numeric prefixes in file names.
2. **Standard ADR Sections**:
   * **Header Metadata**: Status (`Proposed`, `Accepted`, `Implemented`, `Superseded`), Author/Agent Role, Date, Target Components, Related Specs.
   * **Context & Problem Statement**: Clear explanation of current state, limitations, and operational forces.
   * **Decision Drivers**: Key engineering constraints (e.g., cost boundaries, security standards, availability targets).
   * **Considered Options**: Concrete trade-off matrix comparing evaluated alternatives with explicit cost numbers.
   * **Decision Outcome**: Selected option with detailed architectural rationale.
   * **Architecture & Flow Diagrams**: Sequence and system diagrams rendered via Mermaid.
   * **Implementation State & Roadmap**: Work completed vs. downstream phases.
   * **Consequences & Mitigations**: Honest assessment of negative trade-offs, capacity caps, and technical mitigations.
3. **Traceability**: Link to implementation PRs, Terraform modules, and related agent artifacts.
