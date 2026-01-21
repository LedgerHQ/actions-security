# GitHub Action: `attest-for-pypi`

<!-- action-docs-description source="action.yml" -->
## Description

The `attest-for-pypi` GitHub Action generates PyPI-compatible attestations for Python packages using the Sigstore framework. This action produces attestations that are compatible with PyPI's Trusted Publisher workflow.

Designed for seamless integration within Ledger's CI/CD pipeline, this action creates cryptographic attestations using PyPI's publish attestation marker, enhancing the integrity and authenticity of your Python packages.
<!-- action-docs-description source="action.yml" -->

## How It Works

This action uses GitHub's `actions/attest@v2` with PyPI's specific predicate type (`https://docs.pypi.org/attestations/publish/v1`) to generate Sigstore-compatible attestation bundles. These attestations can be verified by PyPI and other systems that support Sigstore verification.

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
  id-token: write
  attestations: write
```

### Example Workflow

Here's how you can use the `attest-for-pypi` action within your workflow:

```yaml
jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      attestations: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'
      
      - name: Install build dependencies
        run: pip install build
      
      - name: Build package
        run: python -m build
      
      - name: Attest for PyPI
        uses: LedgerHQ/actions-security/actions/attest-for-pypi@actions/attest-for-pypi-1
        with:
          subject-path: dist/*
```

### Publishing to PyPI with Attestations

When publishing to PyPI using Trusted Publishers, the attestations are automatically picked up:

```yaml
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          attestations: true
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `subject-path` | <p>Path to the Python distribution files to attest (wheels, sdists). Supports glob patterns like "dist/*".</p> | `true` | `""` |
| `predicate-type` | <p>The predicate type URI for the attestation.</p> | `false` | `https://docs.pypi.org/attestations/publish/v1` |
| `predicate` | <p>The predicate content as a JSON string.</p> | `false` | `{}` |
| `github_token` | <p>GitHub Token (to be able to upload the attestation to the GitHub Attestation API).</p> | `false` | `${{ github.token }}` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->
## Outputs

| name | description |
| --- | --- |
| `bundle-path` | <p>Path to the generated attestation bundle.</p> |
<!-- action-docs-outputs source="action.yml" -->

## Security Considerations

- This action only runs on **public repositories** to prevent leaking private information through Sigstore's transparency log
- Uses OIDC-based keyless signing via Sigstore
- Attestations are automatically uploaded to GitHub's attestation API

## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.

## Related Resources

- [PyPI Attestations Documentation](https://docs.pypi.org/attestations/)
- [PyPI Trusted Publishers](https://docs.pypi.org/trusted-publishers/)
- [Sigstore](https://www.sigstore.dev/)
