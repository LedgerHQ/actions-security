# GitHub Action: `wiz-cli`

<!-- action-docs-description source="action.yml" -->
## Description

The `wiz-cli` GitHub Action enables seamless integration with Wiz Cloud Security Platform via CLI. This action automates the installation and authentication of the Wiz CLI, allowing developers to perform various security operations such as scanning container images, infrastructure as code, and more.

Designed for seamless integration within Ledger's CI/CD pipeline, the `wiz-cli` action helps identify security issues early in the development lifecycle, ensuring compliance with security policies and best practices.
<!-- action-docs-description source="action.yml" -->
<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `iac_path` | <p>Path to the artifact, directory, or glob pattern to match files for IaC scan</p> | `true` | `""` |
| `policy_iac` | <p>Policy to use for the IaC scan</p> | `true` | `""` |
| `docker_tags` | <p>List of tags to scan (based on the output of the docker/metadata-action)</p> | `true` | `""` |
| `policy_docker` | <p>Policy to use for the Docker scan</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->