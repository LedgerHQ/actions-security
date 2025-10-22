# actions-security

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ledgerhq/actions-security/release.yaml)](https://github.com/ledgerhq/actions-security/actions/workflows/release.yaml)
[![GitHub issues](https://img.shields.io/github/issues/ledgerhq/actions-security)](https://github.com/ledgerhq/actions-security/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/ledgerhq/actions-security)](https://github.com/ledgerhq/actions-security/pulls)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)](https://github.com/ledgerhq/actions-security/pulse)

A collection of GitHub Actions and reusable workflows focused on enhancing security in CI/CD pipelines. These actions are developed by Ledger and made available to the community.

## Overview

This repository contains security-focused GitHub Actions that help secure your software supply chain through:
- Secure authentication with artifact repositories
- Attestation generation and verification
- Secure signing of artifacts and containers
- And more

> [!TIP]
> For reliable updates, reference actions by their major version tag (e.g., `actions/attest-1`). This ensures you receive patch and minor updates automatically while avoiding breaking changes.

> [!IMPORTANT]
> Some actions require specific GitHub workflow permissions such as `id-token: write` or `attestations: write`. Please refer to each action's documentation for detailed requirements.

## Available Actions

| Action | Latest Version | Description |
|--------|----------------|-------------|
| [actions/jfrog-login](actions/jfrog-login) | `actions/jfrog-login-1` | Securely authenticate to JFrog services (Artifactory, Xray) using OIDC, eliminating the need for static credentials. Enables artifact management and security scanning within CI/CD pipelines. |
| [actions/attest](actions/attest) | `actions/attest-1` | Generate and sign **in-toto** attestations for your artifacts using keyless signing with OIDC. Create verifiable metadata about your software supply chain to enhance integrity and traceability. |
| [actions/sign-blob](actions/sign-blob) | `actions/sign-blob-1` | Sign arbitrary data using keyless signing with GitHub's OIDC tokens. Secure your files, binaries, and other artifacts without managing sensitive signing keys. |
| [actions/sign-container](actions/sign-container) | `actions/sign-container-1` | Sign container images with multiple tags using keyless signing. Ensure the integrity and authenticity of your containers throughout your deployment pipeline. |

## Getting Started

Each action directory contains:
- Detailed documentation in its README.md
- Usage examples
- Parameter descriptions
- Required permissions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.