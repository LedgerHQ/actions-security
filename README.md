<div align="center">

# 🔐 Actions Security

**Security-focused GitHub Actions for Ledger's CI/CD pipelines**

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

</div>

---

## Overview

A collection of reusable GitHub Actions for automating **artifact signing**, **attestation**, **JFrog authentication**, and **security scanning** within Ledger's software supply chain.

> [!TIP]
> Use the major tag of each action (e.g., `uses: LedgerHQ/actions-security/actions/attest@actions/attest-1` in your workflow's `uses:` field) to automatically receive patch and minor updates.

> [!IMPORTANT]
> Some actions require workflow permissions like `id-token: write` or `attestations: write`. See each action's README for details.

---

## Available Actions

| Action | Version | Description |
|--------|---------|-------------|
| **[attest](actions/attest)** | `actions/attest-1` | Generate and sign provenance files using in-toto attestation with OIDC keyless signing |
| **[attest-for-npmsjs-com](actions/attest-for-npmsjs-com)** | `actions/attest-for-npmsjs-com-1` | Generate SLSA provenance attestations for npm packages on npmjs.com |
| **[sign-blob](actions/sign-blob)** | `actions/sign-blob-1` | Sign arbitrary files or binaries with OIDC keyless signing |
| **[sign-container](actions/sign-container)** | `actions/sign-container-1` | Sign container images with multiple tags using OIDC keyless signing |
| **[jfrog-login](actions/jfrog-login)** | `actions/jfrog-login-1` | Secure OIDC-based login to Ledger's JFrog platform (Artifactory & Xray) |
| **[jfrog-npm](actions/jfrog-npm)** | `actions/jfrog-npm-1` | Configure `.npmrc` for npm/pnpm/yarn to authenticate with JFrog |
| **[check-npm-deployment](actions/check-npm-deployment)** | `actions/check-npm-deployment-1` | Verify npm packages were published to npmjs.com through the supply chain pipeline |
| **[wiz-cli](actions/wiz-cli)** | `actions/wiz-cli-1` | Integrate with Wiz Cloud Security for IaC and container image scanning |

---

## Documentation

Each action includes detailed documentation with usage examples in its respective `README.md`.

## License

[MIT License](LICENSE)
