# Check npm Deployment Status

Check if an npm package was successfully deployed to npm via the OSS Supply Chain API. Uses GitHub OIDC for zero-secret authentication.

## Prerequisites

- The workflow must have `permissions: id-token: write`
- The repository must belong to the **LedgerHQ** GitHub organization
- The OSS Supply Chain API and AWS API Gateway JWT authorizer must be deployed

## Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `tarball-path` | Yes | - | Path to the npm tarball (typically from `attest-for-npmsjs-com` output) |
| `timeout` | No | `300` | Maximum seconds to wait for deployment result (max 600) |
| `poll-interval` | No | `15` | Seconds between status checks |

## Outputs

| Name | Description |
|------|-------------|
| `status` | Deployment status: `success`, `failed`, or `timed_out` |
| `error-message` | Error message if deployment failed or timed out, empty on success |

## Usage

### Single package

```yaml
permissions:
  id-token: write
  attestations: write

steps:
  - name: Attest package
    id: attest
    uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@v1
    with:
      subject-path: ./dist

  - name: Publish to JFrog
    run: npm publish ${{ steps.attest.outputs.tarball-path }} --registry=https://jfrog.ledgerlabs.net/...

  # JFrog webhook triggers the OSS Supply Chain API to publish to npm

  - name: Check deployment status
    uses: LedgerHQ/actions-security/actions/check-npm-deployment@v1
    with:
      tarball-path: ${{ steps.attest.outputs.tarball-path }}
```

### Multiple packages (matrix)

```yaml
strategy:
  matrix:
    package: [./packages/pkg-a, ./packages/pkg-b, ./packages/pkg-c]
steps:
  - uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@v1
    id: attest
    with:
      subject-path: ${{ matrix.package }}

  - uses: LedgerHQ/actions-security/actions/check-npm-deployment@v1
    with:
      tarball-path: ${{ steps.attest.outputs.tarball-path }}
```

### Custom timeout

For workflows publishing many packages where webhook processing may take longer:

```yaml
  - uses: LedgerHQ/actions-security/actions/check-npm-deployment@v1
    with:
      tarball-path: ${{ steps.attest.outputs.tarball-path }}
      timeout: "600"
```

## How it works

1. Extracts the package name and version from the tarball's `package.json`
2. Requests a short-lived OIDC token from GitHub (audience: `api.security.ledger.com`)
3. Polls `GET /api/deployments/status?type=npm&name=<name>&version=<version>` on the OSS Supply Chain API
4. Handles status transitions: `unknown` / `queued` / `in_progress` (keep polling) -> `success` or `failed`
5. Returns the deployment status once resolved, or fails after timeout

## Security

- **No secrets required**: Authentication uses GitHub OIDC (keyless, short-lived tokens)
- **Organization restricted**: Only LedgerHQ repositories can access the endpoint (validated by Lambda authorizer)
- **Token masking**: OIDC tokens are masked in CI logs via `::add-mask::`
- **Token refresh**: A fresh token is requested before each API call to handle expiration
- **Hardcoded API URL**: The API URL is not configurable to prevent OIDC token exfiltration to attacker-controlled servers
- **Temporary files**: Response files use `mktemp` and are cleaned up via `trap EXIT`
