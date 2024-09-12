# actions-security
Github Action - Security actions and reusable workflow used at Ledger

> [!TIP]
> To benefit from the patch and minor upgrade, please use the major tag of the action that you are using

> [!IMPORTANT]
> Theses actions can require to define custom permission inside the Github Action Workflow where they are use. Like, `id-token: write`or `attestations: write`, please refer to the documenation of each action to have more informations.

## Actions

| Path | Last major version | Usage |
| ------------- | ------------- | ------------- |
| actions/jfrog-login | `actions/jfrog-login-1` | This action is used to login to the JFrog Plateform of Ledger (Artifactory, Xray, etc.). |
| actions/attest | `actions/attest-1` | This action is used to generate a provenance file and to sign it (attestation in-toto format). |
| actions/sign-blob | `actions/sign-blob-1` | This action is used to sign a blob in keyless mode based on Github OIDC token. |
| actions/sign-container | `actions/sign-container-1` | This action is used to sign a container image with a list of tags in keyless mode based on Github OIDC token. |


