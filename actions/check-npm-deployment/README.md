# Check npm Deployment Status

Verify that your npm package was successfully published to npmjs.com through the Ledger supply chain pipeline.

After publishing a package to JFrog, the supply chain API automatically picks it up and publishes it to npmjs.com. This action polls the API until the deployment is confirmed or fails.

## Prerequisites

- The workflow must have `permissions: id-token: write`
- The repository must belong to the **LedgerHQ** GitHub organization

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `tarball-path` | Yes | - | Path to the npm tarball (`.tgz` file) |
| `timeout` | No | `300` | Maximum seconds to wait (max 600) |
| `poll-interval` | No | `15` | Seconds between status checks |

## Outputs

| Name | Description |
|------|-------------|
| `status` | `success`, `failed`, or `timed_out` |
| `error-message` | Error details on failure, empty on success |

## Usage

### Basic

```yaml
permissions:
  contents: read
  id-token: write
  attestations: write

jobs:
  publish:
    runs-on: public-ledgerhq-shared-small
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: npm pack

      - name: Login to JFrog
        id: jfrog-login
        uses: LedgerHQ/actions-security/actions/jfrog-login@actions/jfrog-login-1

      - name: Publish to JFrog
        run: npm publish --registry=https://jfrog.ledgerlabs.net/artifactory/api/npm/your-repo/

      - name: Attest
        id: attest
        uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@actions/attest-for-npmsjs-com-1
        with:
          subject-path: "*.tgz"

      - name: Wait for npm deployment
        uses: LedgerHQ/actions-security/actions/check-npm-deployment@actions/check-npm-deployment-1
        with:
          tarball-path: ${{ steps.attest.outputs.tarball-path }}
```

### With custom timeout

For large packages or high-traffic periods:

```yaml
      - name: Wait for npm deployment
        uses: LedgerHQ/actions-security/actions/check-npm-deployment@actions/check-npm-deployment-1
        with:
          tarball-path: "*.tgz"
          timeout: "600"
          poll-interval: "20"
```

### Using the output

```yaml
      - name: Wait for npm deployment
        id: deploy
        uses: LedgerHQ/actions-security/actions/check-npm-deployment@actions/check-npm-deployment-1
        with:
          tarball-path: "*.tgz"

      - name: Next step
        if: steps.deploy.outputs.status == 'success'
        run: echo "Package is live on npmjs.com!"
```

### Matrix (multiple packages)

```yaml
strategy:
  matrix:
    package: [packages/pkg-a, packages/pkg-b]
steps:
  - uses: LedgerHQ/actions-security/actions/check-npm-deployment@actions/check-npm-deployment-1
    with:
      tarball-path: ${{ matrix.package }}/*.tgz
```

## Status values

| Status | Meaning | Action outcome |
|--------|---------|----------------|
| `success` | Package published to npmjs.com | Step passes |
| `failed` | Publishing failed | Step fails with error message |
| `timed_out` | No result within timeout | Step fails |

## Troubleshooting

| Error | Solution |
|-------|----------|
| `Authentication failed (HTTP 401/403)` | Ensure `permissions: id-token: write` is set and the repo is in the LedgerHQ org |
| `Tarball not found` | Check the `tarball-path` points to an existing `.tgz` file |
| `Timed out` | Increase `timeout` or check if the JFrog webhook fired |
| `Failed to parse package name` | Ensure the tarball contains a valid `package/package.json` |
