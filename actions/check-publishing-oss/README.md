# Check OSS publishing status

Verify that a package was successfully published to a public registry (npmjs.com, PyPI, crates.io) through the Ledger supply chain pipeline.

After publishing a package to JFrog, the supply chain API automatically picks it up and publishes it to the target registry. This action polls the API until publishing is confirmed or fails.

## Prerequisites

- The workflow must have `permissions: id-token: write`
- The repository must belong to the **LedgerHQ** GitHub organization

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `package-type` | Yes | - | `npm`, `pypi`, or `crate` |
| `package-name` | No* | - | Package name (e.g. `@scope/pkg`, `my-python-pkg`, `my-crate`) |
| `package-version` | No* | - | Package version |
| `tarball-path` | No* | - | Path to npm tarball (`.tgz`). Extracts name/version automatically. npm only. |
| `timeout` | No | `300` | Maximum seconds to wait (max 600) |
| `poll-interval` | No | `15` | Seconds between status checks |

\* Either `tarball-path` (npm only) **or** both `package-name` + `package-version` are required.

## Outputs

| Name | Description |
|------|-------------|
| `status` | `success`, `failed`, or `timed_out` |
| `error-message` | Error details on failure, empty on success |

## Usage

### npm (from tarball)

```yaml
- uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: npm
    tarball-path: ${{ steps.tarball.outputs.path }}
```

### npm (explicit name/version)

```yaml
- uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: npm
    package-name: "@ledger/my-package"
    package-version: "1.2.3"
```

### PyPI

```yaml
- uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: pypi
    package-name: my-python-package
    package-version: "1.0.0"
```

### Crates.io (Rust)

```yaml
- uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: crate
    package-name: my-rust-crate
    package-version: "0.1.0"
```

### With custom timeout

```yaml
- uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: npm
    tarball-path: ${{ steps.tarball.outputs.path }}
    timeout: "600"
    poll-interval: "20"
```

### Using the output

```yaml
- name: Check OSS publishing
  id: deploy
  uses: LedgerHQ/actions-security/actions/check-publishing-oss@actions/check-publishing-oss-1
  with:
    package-type: pypi
    package-name: my-package
    package-version: "1.0.0"

- name: Next step
  if: steps.deploy.outputs.status == 'success'
  run: echo "Package is live!"
```

## Status values

| Status | Meaning | Action outcome |
|--------|---------|----------------|
| `success` | Package published to registry | Step passes |
| `failed` | Publishing failed | Step fails with error message |
| `timed_out` | No result within timeout | Step fails |

## Troubleshooting

| Error | Solution |
|-------|----------|
| `Authentication failed (HTTP 401/403)` | Ensure `permissions: id-token: write` is set and the repo is in the LedgerHQ org |
| `Invalid package-type` | Must be `npm`, `pypi`, or `crate` |
| `tarball-path is only supported for npm` | Use `package-name` + `package-version` for pypi/crate |
| `Tarball not found` | Check the `tarball-path` points to an existing `.tgz` file |
| `Timed out` | Increase `timeout` or check if the JFrog webhook fired |
