# Release NPM Action

A GitHub Action that creates GitHub Releases for npm packages based on their CHANGELOG.md content. It can also upload release assets (tarballs/zips).

## Usage

```yaml
steps:
  - name: Create GitHub Releases
    uses: ./actions/release-npm
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      cwd: ./  # Optional: working directory
      artifacts_path: ./dist  # Optional: path to artifacts to upload
```

## How it works

1. Scans the repository for npm packages (supports monorepos).
2. Calculates the expected git tag for the current version (e.g. `v1.0.0` or `@scope/pkg@1.0.0`).
3. Checks if a GitHub Release exists for that tag.
4. If not, creates the release using the corresponding entry from `CHANGELOG.md`.
5. If `artifacts_path` is provided, searches for matching `.tgz` or `.zip` files and uploads them to the release.

## Requirements

- `CHANGELOG.md` files must exist and follow "Keep a Changelog" or "Changesets" format.
- `GITHUB_TOKEN` must have `contents: write` permission.

