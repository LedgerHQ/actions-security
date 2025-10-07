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
| `iac_path` | <p>Path to the artifact, directory, or glob pattern to match files for IaC scan</p> | `false` | `""` |
| `policy_iac` | <p>Policy to use for the IaC scan</p> | `false` | `""` |
| `docker_tags` | <p>List of tags to scan (based on the output of the docker/metadata-action)</p> | `false` | `""` |
| `policy_docker` | <p>Policy to use for the Docker scan</p> | `false` | `""` |
| `wiz_client_id` | <p>Wiz API client ID for authentication</p> | `true` | `""` |
| `wiz_client_secret` | <p>Wiz API client secret for authentication</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

## Usage

### IaC Scanning

```yaml
- name: Wiz IaC Scan
  uses: LedgerHQ/actions-security/feat-wiz-cli-init/actions/wiz-cli@actions/wiz-cli-1
  with:
    iac_path: "terraform/"
    policy_iac: "iac-security-policy"
    wiz_client_id: ${{ secrets.WIZ_CLIENT_ID }}
    wiz_client_secret: ${{ secrets.WIZ_CLIENT_SECRET }}
```

### Docker Image Scanning

```yaml
- name: Wiz Docker Scan
  uses: LedgerHQ/actions-security/feat-wiz-cli-init/actions/wiz-cli@actions/wiz-cli-1
  with:
    docker_tags: "my-image:latest,my-image:v1.0.0"
    policy_docker: "container-security-policy"
    wiz_client_id: ${{ secrets.WIZ_CLIENT_ID }}
    wiz_client_secret: ${{ secrets.WIZ_CLIENT_SECRET }}
```

### Combined Scanning

```yaml
- name: Wiz Security Scan
  uses: LedgerHQ/actions-security/feat-wiz-cli-init/actions/wiz-cli@actions/wiz-cli-1
  with:
    iac_path: "terraform/"
    policy_iac: "iac-security-policy"
    docker_tags: "my-image:latest"
    policy_docker: "container-security-policy"
    wiz_client_id: ${{ secrets.WIZ_CLIENT_ID }}
    wiz_client_secret: ${{ secrets.WIZ_CLIENT_SECRET }}
```

**Note**: At least one scan type (`iac_path` or `docker_tags`) must be specified for the action to run successfully.