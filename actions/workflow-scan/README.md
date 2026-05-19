# GitHub Action: `workflow-scan`



## Description

The `workflow-scan` GitHub Action runs two complementary GitHub Actions workflow security scanners:

- **Trajan** ([praetorian-inc/trajan](https://github.com/praetorian-inc/trajan)) — API-backed scan that queries the GitHub API for workflow definitions on the merged ref.
- **octoscan** ([synacktiv/octoscan](https://github.com/synacktiv/octoscan)) — static YAML analysis of `.github/workflows/`.

Both binaries are pinned by version and verified by SHA-256 before installation. Designed for seamless integration within Ledger's CI/CD pipeline, ensuring that GitHub Actions workflows follow security best practices and are free from common misconfigurations.

## Usage

### Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
    contents: read
```

### Example Workflow

Trajan queries the GitHub API for workflows on the merged ref, so it can only run on the default branch. Use it as a **post-merge scan** (e.g. on `push` to `main`):

```yaml
on:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  workflow-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          persist-credentials: false

      - name: Run workflow scan
        uses: LedgerHQ/actions-security/actions/workflow-scan@actions/workflow-scan-1
```

The default `GITHUB_TOKEN` is sufficient for Trajan's GitHub API scan; no extra secrets need to be passed.



## Inputs


| name               | description                                                                  | required | default                                                              |
| ------------------ | ---------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------- |
| `trajan-enabled`   | Enable the Trajan GitHub API scan                                            | `false`  | `"true"`                                                             |
| `trajan-version`   | Trajan release version                                                       | `false`  | `"1.0.1"`                                                            |
| `trajan-sha256`    | Expected SHA-256 digest of the Trajan binary                                 | `false`  | `"133486f9ddc12c7b20ca19c3100a4dbdfb0fba5066e7dc9322db6f67baa16609"` |
| `octoscan-enabled` | Enable the octoscan static analysis scan                                     | `false`  | `"true"`                                                             |
| `octoscan-version` | octoscan release version                                                     | `false`  | `"0.1.7"`                                                            |
| `octoscan-sha256`  | Expected SHA-256 digest of the octoscan binary                               | `false`  | `"6435e9cc0e6346741367cbb1803e5b545d8e7031d188c733a0b30f768ab6ebe2"` |
| `token`            | GitHub token for the Trajan API scan (defaults to the workflow GITHUB_TOKEN) | `false`  | `${{ github.token }}`                                                |








## Pinned versions


| Tool     | Version | SHA-256                                                            |
| -------- | ------- | ------------------------------------------------------------------ |
| Trajan   | `1.0.1` | `133486f9ddc12c7b20ca19c3100a4dbdfb0fba5066e7dc9322db6f67baa16609` |
| octoscan | `0.1.7` | `6435e9cc0e6346741367cbb1803e5b545d8e7031d188c733a0b30f768ab6ebe2` |


## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.

## Notes

- Only Linux x86_64 runners (e.g. `ubuntu-latest`) are supported.
- octoscan is invoked with `--disable-rules shellcheck,local-action --filter-triggers external`.

