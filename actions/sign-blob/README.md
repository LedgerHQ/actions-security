# Action: sign-blob

<!-- action-docs-description source="action.yml" -->
## Description

This action is used to sign a blob in keyless mode based on Github OIDC token
<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions
```yaml
permissions:
    id-token: write
```

### Example Workflow
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
| `path` | <p>Path to the artifact to sign</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


<!-- action-docs-runs source="action.yml" -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs source="action.yml" -->