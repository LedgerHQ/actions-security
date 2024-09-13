# GitHub Action: `sign-container`

<!-- action-docs-description source="action.yml" -->
## Description

This action is used to sign a container image with a list of tags in keyless mode based on Github OIDC token.
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
      - name: Sign a blob
        id: sign-blob
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