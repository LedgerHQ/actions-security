# GitHub Action: `jfrog-npm`

<!-- action-docs-description source="action.yml" -->
## Description

The `jfrog-npm` GitHub Action facilitates the configuration of the `.npmrc`
file that is used to configure package managers like
[npm](https://docs.npmjs.com/cli/v11/configuring-npm/npmrc),
[pnpm](https://pnpm.io/) or [yarn](https://yarnpkg.com/).

This action is designed for seamless integration within Ledger's CI/CD
pipeline, allowing developers to securely interact with JFrog services while
automating critical parts of the software supply chain.
<!-- action-docs-description source="action.yml" -->

## Usage

### Good to know

While not mandatory, this action is designed to receive the token provided by
[jfrog-login](../jfrog-login/).

### Example Workflow

Here's how you can use the `jfrog-login` action within your workflow:

```yaml
jobs:
  release:
    runs-on: ledgerhq-shared-small
    steps:
      - name: Login to JFrog Ledger
        id: jfrog-login
        uses: LedgerHQ/actions-security/actions/jfrog-login@actions/jfrog-login-1

      - name: Configure npmrc
        id: jfrog-npm
        uses: LedgerHQ/actions-security/actions/jfrog-npm@actions/jfrog-npm-1
        with:
          token: ${{ steps.jfrog-login.outputs.oidc-token }}
          registry: jfrog.ledgerlabs.net/artifactory/api/npm/<jfrog-repo>
          ignore-scripts: 'true'
```

**Note**: Replace `<jfrog-repo>` with the chosen repo for your project, as defined in jfrog.

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | default | description |
| --- | --- | --- |
| `token` |  | <p>The authorization token that will be used against the registry</p>  |
| registry | | <p>The registry URL from where packages will be installed</p> |
| provenance | `false` | <p>Enable provenance. This will create an attestation when publishing packages.</p> |
| ignore-scripts | `false` | <p>Disable the automatic run of lifecycle scripts like `install`, `postinstall`, and others.</p> |
| omit | `false` | <p>Disable the installation of certain types of packages. e.g.: `dev` will not install devDependencies.</p> |
| minimum-release-age | `false` | <p>Require packages to be older than the provided value in minutes.</p> |

<!-- action-docs-inputs source="action.yml" -->

## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.
