# GitHub Action: `sign-container`

<!-- action-docs-description source="action.yml" -->
## Description

The `sign-container` GitHub Action provides secure, keyless signing of container images with multiple tags using OIDC authentication based on GitHub's OIDC token. This action allows developers to sign container images without manually managing sensitive signing keys, enhancing the trust and integrity of containerized applications.

Designed for seamless integration within Ledger's CI/CD pipeline, the `sign-container` action automates the container signing process, ensuring that container images are securely signed and verifiable. By incorporating secure signing into your container deployment workflow, it helps protect against unauthorized modifications and ensures compliance with container security policies.
<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    id-token: write
```

### Example Workflow

Here's how you can use the `sign-container` action within your workflow:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Sign a container
        id: sign-container
        uses: LedgerHQ/actions-security/actions/sign-container@actions/sign-container-1
        with:
          tags: ""
          disgest: ""
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `tags` | <p>List of tags to sign (based on the output of the docker/metadata-action)</p> | `true` | `""` |
| `digest` | <p>Digest of the container image to sign (based on the output of the docker/build-push-action)</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.