#!/bin/bash -eu
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

set -euo pipefail

# Function to process one package and output an attestation JSON object
process_package() {
    local pkg_json="$1"
    
    local PACKAGE_NAME=$(echo "$pkg_json" | jq -r '.name')
    local PACKAGE_VERSION=$(echo "$pkg_json" | jq -r '.version')
    local PACKAGE_FILENAME=$(echo "$pkg_json" | jq -r '.filename')
    local PACKAGE_INTEGRITY=$(echo "$pkg_json" | jq -r '.integrity')

    # We will encode the subject name as an npm package url (purl).
    # https://github.com/package-url/purl-spec/blob/master/PURL-SPECIFICATION.rst
    
    # Get the raw package name and scope
    local raw_package_scope=$(echo "${PACKAGE_NAME:-}" | cut -s -d'/' -f1)
    local raw_package_name=$(echo "${PACKAGE_NAME:-}" | cut -s -d'/' -f2)
    if [ "${raw_package_name}" == "" ]; then
      # This is a non-scoped package.
      raw_package_name="${PACKAGE_NAME:-}"
      raw_package_scope=""
    fi
    
    # URL encode
    local package_scope=$(echo "\"${raw_package_scope}\"" | jq -r '. | @uri')
    local package_name=$(echo "\"${raw_package_name}\"" | jq -r '. | @uri')
    local package_version=$(echo "\"${PACKAGE_VERSION:-}\"" | jq -r '. | @uri')
    
    local package_id="${package_name}@${package_version}"
    if [ "${package_scope}" != "" ]; then
      package_id="${package_scope}/${package_id}"
    fi
    local subject_name="pkg:npm/${package_id}"
    
    # The integrity digest
    local integrity_digest="${PACKAGE_INTEGRITY:-}"
    
    # Parse alg and digest
    local alg=$(echo "${integrity_digest}" | cut -d'-' -f1 | tr '[:upper:]' '[:lower:]')
    local digest=$(echo "${integrity_digest}" | cut -d'-' -f2- | base64 -d | od -A n -v -t x1 | tr -d ' \n')
    
    local attestation_name="${PACKAGE_FILENAME%.*}"
    
    # Construct JSON for this attestation
    # Note: keys in digest object must be dynamic, so we use parens ($alg)
    jq -n \
      --arg name "$attestation_name" \
      --arg subject_name "$subject_name" \
      --arg alg "$alg" \
      --arg digest "$digest" \
      '{
        name: $name,
        subjects: [
          {
            name: $subject_name,
            digest: {
              ($alg): $digest
            }
          }
        ]
      }'
}

# Collect all attestations
ATTESTATIONS_FILE=$(mktemp)

# Iterate over packages in PACKAGES_LIST_FILE
if [ ! -f "${PACKAGES_LIST_FILE}" ]; then
  echo "Error: PACKAGES_LIST_FILE (${PACKAGES_LIST_FILE}) not found"
  exit 1
fi

# Use process substitution to avoid subshell issues with while loop
while read -r pkg; do
    process_package "$pkg"
done < <(jq -c '.[]' "${PACKAGES_LIST_FILE}") > "$ATTESTATIONS_FILE"

# Combine into final layout
# -s reads all inputs into an array
jq -s '{ version: 1, attestations: . }' "$ATTESTATIONS_FILE" | tee "${SLSA_OUTPUTS_ARTIFACTS_FILE}"

rm "$ATTESTATIONS_FILE"
