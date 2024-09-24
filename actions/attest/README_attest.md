# GitHub Action: `attest`

<!-- action-docs-description source="action.yml" -->
## Description

The `attest` GitHub Action enables the generation and signing of provenance files using the **in-toto** attestation format. Leveraging OIDC authentication for keyless signing, this action securely creates verifiable metadata about your software artifacts without the need to manage sensitive signing keys manually.

Designed for seamless integration within Ledger's CI/CD pipeline, the `attest` action automates the creation of cryptographic attestations, enhancing the integrity, authenticity, and traceability of your software supply chain. By providing a secure method to verify the origin and build process of your artifacts, it helps safeguard against supply chain attacks and meets compliance requirements for software distribution.
<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    id-token: write
    attestations: write
```

### Example Workflow

Here's how you can use the `attest` action within your workflow:

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
| `type-slsa` | <p>Generate an attestations bind some subject (a named artifact along with its digest) to a SLSA build provenance predicate using the in-toto format.</p> | `false` | `true` |
| `subject-path` | <p>Path to the artifact serving as the subject of the attestation. Must specify exactly one of "subject-path" or "subject-digest". May contain a glob pattern or list of paths (total subject count cannot exceed 2500).</p> | `false` | `""` |
| `subject-digest` | <p>SHA256 digest of the subject for the attestation. Must be in the form "sha256:hex_digest" (e.g. "sha256:abc123…"). Must specify exactly one of "subject-path" or "subject-digest".</p> | `false` | `""` |
| `subject-name` | <p>Subject name as it should appear in the attestation. Required unless "subject-path" is specified, in which case it will be inferred from the path.</p> | `false` | `""` |
| `push-to-registry` | <p>Whether to push the attestation to the image registry. Requires that the "subject-name" parameter specify the fully-qualified image name and that the "subject-digest" parameter be specified. Defaults to false.</p> | `false` | `false` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->


## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.