# Changelog

## 0.2.0

### Features

* **attest-npmjs-com:** attest every tarball in a directory instead of only the newest one, with one single-subject attestation per package
* **attest-npmjs-com:** support large monorepos by building the in-toto statements directly and signing them in a single pass, removing the SLSA `generate-attestations` 50-attestation-per-layout limit
* **attest-npmjs-com:** add `tarball-paths` and `package-count` outputs

## [0.1.2](https://github.com/LedgerHQ/actions-security/compare/actions/attest-for-npmsjs-com-0.1.1...actions/attest-for-npmsjs-com-0.1.2) (2026-03-17)


### Bug Fixes

* **attest-npmjs-com:** validate repository.url before generating attestation ([#80](https://github.com/LedgerHQ/actions-security/issues/80)) ([9fc9d84](https://github.com/LedgerHQ/actions-security/commit/9fc9d84f6372413a3189d4ded0505bc7af7b0084))

## [0.1.1](https://github.com/LedgerHQ/actions-security/compare/actions/attest-for-npmsjs-com-0.1.0...actions/attest-for-npmsjs-com-0.1.1) (2026-03-11)


### Bug Fixes

* **attest-npmjs-com:** compute integrity from actual tarball bytes ([#78](https://github.com/LedgerHQ/actions-security/issues/78)) ([4ecc46c](https://github.com/LedgerHQ/actions-security/commit/4ecc46c5f4393631b1582371f61edc724a22d3ef))

## 0.1.0 (2025-11-20)


### Features

* **action-attest-npmjs-com:** init the action ([#52](https://github.com/LedgerHQ/actions-security/issues/52)) ([f9bea89](https://github.com/LedgerHQ/actions-security/commit/f9bea89b5dd2e060840d763d1cd99150dc74d8c2))
