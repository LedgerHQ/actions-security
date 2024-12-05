# GitHub Action: `attest-for-npmsjs-com`

<!-- action-docs-description source="action.yml" -->

<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    id-token: write
```

### Example Workflow

Here's how you can use the `attest` action within your workflow:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Attest for npmjs.com
        id: attest
        uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@actions/attest-for-npmsjs-com-1
        with:
          subject-path: path/to/my/npm-package/to/attest
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `subject-path` | <p>Path to the npm package to attest.</p> | `true` | `""` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.