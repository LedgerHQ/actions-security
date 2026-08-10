#!/usr/bin/env bash
#
# Copyright 2023 SLSA Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Builds the SLSA outputs layout (artifacts-layout.json) from the packages list.
# One attestation entry (single subject) is emitted per package. The layout is
# the same format the SLSA `generate-attestations` action consumes; we build the
# in-toto statements from it ourselves in a later step to avoid that action's
# 50-attestation cap (see build-intoto-statements.sh).
#
# Inputs (environment variables):
#   PACKAGES_LIST_FILE          JSON array of {name, version, integrity, filename}.
#   SLSA_OUTPUTS_ARTIFACTS_FILE Path to write the layout JSON to.

set -euo pipefail

: "${PACKAGES_LIST_FILE:?PACKAGES_LIST_FILE is required}"
: "${SLSA_OUTPUTS_ARTIFACTS_FILE:?SLSA_OUTPUTS_ARTIFACTS_FILE is required}"

if [ ! -f "${PACKAGES_LIST_FILE}" ]; then
  echo "::error::PACKAGES_LIST_FILE (${PACKAGES_LIST_FILE}) not found"
  exit 1
fi

# Emit one attestation object (with a single subject) for one package.
process_package() {
  local pkg_json="$1"

  local package_name package_version package_filename package_integrity
  package_name=$(jq -r '.name' <<<"$pkg_json")
  package_version=$(jq -r '.version' <<<"$pkg_json")
  package_filename=$(jq -r '.filename' <<<"$pkg_json")
  package_integrity=$(jq -r '.integrity' <<<"$pkg_json")

  # Encode the subject name as an npm package url (purl):
  #   With scope:    pkg:npm/<scope>/<name>@<version>
  #   Without scope: pkg:npm/<name>@<version>
  # `cut -s` suppresses output when the '/' delimiter is absent (non-scoped).
  local raw_package_scope raw_package_name
  raw_package_scope=$(printf '%s' "$package_name" | cut -s -d'/' -f1)
  raw_package_name=$(printf '%s' "$package_name" | cut -s -d'/' -f2)
  if [ "${raw_package_name}" == "" ]; then
    raw_package_name="${package_name}"
    raw_package_scope=""
  fi

  local package_scope package_name_enc package_version_enc
  package_scope=$(jq -rn --arg v "$raw_package_scope" '$v | @uri')
  package_name_enc=$(jq -rn --arg v "$raw_package_name" '$v | @uri')
  package_version_enc=$(jq -rn --arg v "$package_version" '$v | @uri')

  local package_id="${package_name_enc}@${package_version_enc}"
  if [ "${package_scope}" != "" ]; then
    package_id="${package_scope}/${package_id}"
  fi
  local subject_name="pkg:npm/${package_id}"

  # Validate integrity format ("<alg>-<base64>") before decoding.
  if ! [[ "${package_integrity}" =~ ^[a-zA-Z0-9]+-[A-Za-z0-9+/=]+$ ]]; then
    echo "::error::Invalid integrity format for package '${package_name}': '${package_integrity}'" >&2
    exit 1
  fi

  # The subject digest is the hex-encoded checksum, keyed by its algorithm.
  local alg base64_digest digest
  alg=$(printf '%s' "${package_integrity}" | cut -d'-' -f1 | tr '[:upper:]' '[:lower:]')
  base64_digest=$(printf '%s' "${package_integrity}" | cut -d'-' -f2-)
  if ! digest=$(printf '%s' "${base64_digest}" | base64 -d 2>/dev/null | od -A n -v -t x1 | tr -d ' \n'); then
    echo "::error::Failed to base64-decode integrity for package '${package_name}': '${base64_digest}'" >&2
    exit 1
  fi
  if [ -z "$alg" ] || [ -z "$digest" ]; then
    echo "::error::Failed to derive digest from integrity '${package_integrity}' for '${package_name}'." >&2
    exit 1
  fi

  # The attestation name is the tarball basename without its extension. It is
  # used as the statement filename, so it must be unique across packages.
  local attestation_name="${package_filename%.*}"

  jq -cn \
    --arg name "$attestation_name" \
    --arg subject_name "$subject_name" \
    --arg alg "$alg" \
    --arg digest "$digest" \
    '{
      name: $name,
      subjects: [
        {
          name: $subject_name,
          digest: { ($alg): $digest }
        }
      ]
    }'
}

ATTESTATIONS_FILE=$(mktemp)
trap 'rm -f "$ATTESTATIONS_FILE"' EXIT

# One layout attestation per package. Process substitution keeps the loop in the
# current shell so a failing package aborts the whole run (set -e).
while read -r pkg; do
  process_package "$pkg"
done < <(jq -c '.[]' "${PACKAGES_LIST_FILE}") >"$ATTESTATIONS_FILE"

# Guard against duplicate attestation names (would collide as statement files).
DUPLICATES=$(jq -r '.name' "$ATTESTATIONS_FILE" | sort | uniq -d)
if [ -n "$DUPLICATES" ]; then
  echo "::error::Duplicate attestation name(s) derived from tarball basenames: ${DUPLICATES}. Tarball basenames must be unique."
  exit 1
fi

# Combine the per-package objects into the final layout.
jq -s '{ version: 1, attestations: . }' "$ATTESTATIONS_FILE" | tee "${SLSA_OUTPUTS_ARTIFACTS_FILE}"
