# Action: jfrog-login

This action is used to login to the JFrog Plateform of Ledger (Artifactory, Xray, etc.).

## Usage

```yaml
permissions:
    id-token: write
```


```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Login to JFrog Ledger
        id: jfrog-login
        uses: LedgerHQ/actions-security/actions/jfrog-login@actions/jfrog-login-1
```