# Action: attest

<!-- action-docs-description source="action.yml" -->
## Description

This action is used to generate a provenance file and to sign it (attestation in-toto format).
<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions
```yaml
permissions:
    id-token: write
    attestations: write
```

### Example Workflow
```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Attest
        id: attest
        uses: LedgerHQ/actions-security/actions/attest@actions/attest-1
        with:
          subject-path: path/to/my/artefact/to/attest
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `subject-path` | <p>Path to the artefact to attest</p> | `true` | `./` |
| `push-to-registry` | <p>Push the attestation to the registry</p> | `false` | `false` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


<!-- action-docs-runs source="action.yml" -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs source="action.yml" -->