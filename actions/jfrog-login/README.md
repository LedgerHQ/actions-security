# GitHub Action: `jfrog-login`

<!-- action-docs-description source="action.yml" -->
## Description

The `jfrog-login` GitHub Action facilitates a secure login to Ledger's JFrog platform, which includes services such as **Artifactory** and **Xray**. By using OIDC authentication, this action ensures secure access to manage artifacts, perform security scans, and interact with the JFrog APIs and CLI without handling sensitive credentials manually.

This action is designed for seamless integration within Ledger's CI/CD pipeline, allowing developers to securely interact with JFrog services while automating critical parts of the software supply chain.
<!-- action-docs-description source="action.yml" -->

## Usage

### Required Permissions

To enable this action to work properly, ensure the following permissions are set in your workflow:

```yaml
permissions:
  id-token: write
```

This grants the action permission to generate the OIDC token required for authentication with JFrog.

### Example Workflow

Here's how you can use the `jfrog-login` action within your workflow:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Login to JFrog Ledger
        id: jfrog-login
        uses: LedgerHQ/actions-security/actions/jfrog-login@actions/jfrog-login-1
```
<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description |
| --- | --- |
| `jfrog-url` | <p>Base URL of Ledger's JFrog platform to be used for subsequent API/CLI operations. Default `https://jfrog.ledgerlabs.net`</p> |
<!-- action-docs-inputs source="action.yml" -->

<!-- action-docs-outputs source="action.yml" -->
## Outputs

| name | description |
| --- | --- |
| `oidc-token` | <p>OIDC token generated by JFrog CLI for secure API/CLI interactions, using the Setup JFrog CLI step with the configured oidc-provider-name.</p> |
| `oidc-user` | <p>Username extracted from the OIDC token during authentication.</p> |
| `jfrog-url` | <p>Base URL of Ledger's JFrog platform to be used for subsequent API/CLI operations.</p> |
| `jfrog-domain` | <p>Base domain of Ledger's JFrog platform to be used for subsequent API/CLI operations.</p> |
<!-- action-docs-outputs source="action.yml" -->

Those are also exposed as environment variables:

| name | description |
| --- | --- |
| `JFROG_TOKEN` | <p>OIDC token generated by JFrog CLI for secure API/CLI interactions, using the Setup JFrog CLI step with the configured oidc-provider-name.</p> |
| `JFROG_USER` | <p>Username extracted from the OIDC token during authentication.</p> |
| `JFROG_URL` | <p>Base URL of Ledger's JFrog platform to be used for subsequent API/CLI operations.</p> |
| `JFROG_DOMAIN` | <p>Base domain of Ledger's JFrog platform to be used for subsequent API/CLI operations.</p> |

## Runs

This action is a **composite action**, which allows us to combine multiple workflow steps into a single, reusable action. This promotes modularity and simplifies our workflows.

## Additional Information

- This action securely manages the OIDC-based login for Ledger's JFrog platform, removing the need for manual credential handling.
- Ensure your GitHub repository and workflows are configured to use OIDC for maximum security and efficiency.
