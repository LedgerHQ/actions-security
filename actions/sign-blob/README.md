# GitHub Action: `sign-blob`

<!-- action-docs-description source="action.yml" -->
## Description

The `sign-blob` GitHub Action enables secure, keyless signing of arbitrary data blobs using OIDC authentication based on GitHub's OIDC token. By eliminating the need to handle sensitive signing keys manually, this action allows developers to sign files, binaries, or other data artifacts securely within the CI/CD pipeline.

This action is designed for seamless integration within Ledger's CI/CD workflow, automating the signing process to enhance the security and integrity of your software artifacts. By providing a secure and automated method for signing data, it helps ensure the authenticity and non-repudiation of artifacts distributed through the software supply chain.
<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    id-token: write
```

### Example Workflow

Here's how you can use the `sign-blob` action within your workflow:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Sign a blob
        id: sign-blob
        uses: LedgerHQ/actions-security/actions/sign-blob@actions/sign-blob-1
        with:
          path: path/to/my/artefact/to/sign
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `path` | <p>Path to the artifact, directory, or glob pattern to match files for signing</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.
