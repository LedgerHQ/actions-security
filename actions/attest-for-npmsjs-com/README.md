# GitHub Action: `attest-for-npmsjs-com`

<!-- action-docs-description source="action.yml" -->

Attest a npm package for npmjs.com distribution. Supports pre-packed tarballs or directories with package.json.

<!-- action-docs-description source="action.yml" -->

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    id-token: write
```

### Important: Tarball Identity

The attestation is computed on the **exact bytes** of the tarball. You must publish the **same tarball** to npm that was attested. If you pack twice (even with the same source), the tarballs will differ and the attestation will not match.

Two recommended workflows:

#### Workflow A: Pre-packed tarball (recommended)

Pack once, then pass the tarball to the action. Use the same tarball for all publishing steps.

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4

      # Pack once with your preferred package manager
      - run: pnpm pack --pack-destination .
        working-directory: path/to/my/package

      # Attest the exact tarball
      - name: Attest for npmjs.com
        id: attest
        uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@actions/attest-for-npmsjs-com-1
        with:
          subject-path: path/to/my/package/my-package-1.0.0.tgz

      # Publish the same tarball to JFrog, then to npm
      # Use ${{ steps.attest.outputs.tarball-path }} to reference the attested tarball
```

#### Workflow B: Let the action pack

The action packs from a directory containing `package.json`. Use the `tarball-path` output for subsequent publish steps.

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4

      - name: Attest for npmjs.com
        id: attest
        uses: LedgerHQ/actions-security/actions/attest-for-npmsjs-com@actions/attest-for-npmsjs-com-1
        with:
          subject-path: path/to/my/package
          package-manager: pnpm

      # Publish the tarball that was attested (not a separately packed one)
      - run: npm publish "${{ steps.attest.outputs.tarball-path }}" --attest-file path/to/attestation.json
```

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `subject-path` | Path to the npm package to attest. Can be a `.tgz` file, a directory containing `.tgz` files, or a directory with a `package.json` to pack. | `true` | `""` |
| `package-manager` | Package manager to use for packing when `subject-path` is a directory with `package.json` (`npm` or `pnpm`). | `false` | `npm` |
| `github_token` | GitHub Token (to be able to upload the attestation to the GitHub Attestation API). | `true` | `${{ github.token }}` |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->
## Outputs

| name | description |
| --- | --- |
| `tarball-path` | Absolute path to the tarball that was attested. Use this path for publishing to ensure the checksum matches. |
<!-- action-docs-outputs source="action.yml" -->

## How It Works

1. **Resolves the tarball**: accepts a `.tgz` file directly, a directory containing `.tgz` files, or a directory with `package.json` (packs it with the specified package manager).
2. **Computes integrity**: calculates `sha512` directly from the tarball bytes (no re-packing).
3. **Generates SLSA provenance**: creates an in-toto attestation with build provenance metadata.
4. **Signs and uploads**: signs the attestation with Sigstore (OIDC keyless) and uploads to the GitHub Attestations API.

## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.
