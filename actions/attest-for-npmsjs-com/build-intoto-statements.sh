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

# Builds one unsigned in-toto Statement per npm package described in the
# manifest, ready to be signed by the SLSA `sign-attestations` action.
#
# We intentionally build the statements ourselves rather than calling the SLSA
# `generate-attestations` action: that action caps a single layout at 50
# attestations (MAX_ATTESTATION_COUNT), which is too low for large monorepos.
# `sign-attestations` has no such cap, so emitting the statements directly and
# signing the whole folder lets us attest an arbitrary number of packages while
# keeping each attestation single-subject (the shape npmjs.com expects).
#
# Inputs (environment variables):
#   MANIFEST_FILE  Path to the packages manifest (JSON array of
#                  {name, version, integrity, filename, tarball}).
#   PREDICATE_FILE Path to the shared SLSA predicate JSON.
#   PREDICATE_TYPE Predicate type URI (e.g. https://slsa.dev/provenance/v0.2).
#   OUTPUT_FOLDER  Folder to write the unsigned statements into.

set -euo pipefail

: "${MANIFEST_FILE:?MANIFEST_FILE is required}"
: "${PREDICATE_FILE:?PREDICATE_FILE is required}"
: "${PREDICATE_TYPE:?PREDICATE_TYPE is required}"
: "${OUTPUT_FOLDER:?OUTPUT_FOLDER is required}"

# The in-toto Statement wrapper produced here is byte-compatible with what the
# SLSA `generate-attestations` action emits (same _type and key ordering).
INTOTO_TYPE="https://in-toto.io/Statement/v0.1"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "::error::Manifest file not found: $MANIFEST_FILE"
  exit 1
fi
if [ ! -f "$PREDICATE_FILE" ]; then
  echo "::error::Predicate file not found: $PREDICATE_FILE"
  exit 1
fi

count=$(jq 'length' "$MANIFEST_FILE")
if [ "$count" -eq 0 ]; then
  echo "::error::No packages found in manifest: $MANIFEST_FILE"
  exit 1
fi

# Start from a clean output folder so `sign-attestations` only signs the
# statements we generated here.
rm -rf "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

# Track attestation filenames to detect collisions (two tarballs producing the
# same basename would silently overwrite each other otherwise).
declare -A seen_names=()

for i in $(seq 0 "$((count - 1))"); do
  pkg=$(jq -c ".[$i]" "$MANIFEST_FILE")
  package_name=$(jq -r '.name' <<<"$pkg")
  package_version=$(jq -r '.version' <<<"$pkg")
  package_integrity=$(jq -r '.integrity' <<<"$pkg")
  package_filename=$(jq -r '.filename' <<<"$pkg")

  # Encode the subject name as an npm package url (purl):
  #   With scope:    pkg:npm/<scope>/<name>@<version>
  #   Without scope: pkg:npm/<name>@<version>
  # `cut -s` suppresses output when the '/' delimiter is absent (non-scoped).
  raw_package_scope=$(printf '%s' "$package_name" | cut -s -d'/' -f1)
  raw_package_name=$(printf '%s' "$package_name" | cut -s -d'/' -f2)
  if [ "${raw_package_name}" == "" ]; then
    raw_package_name="${package_name}"
    raw_package_scope=""
  fi
  package_scope=$(jq -rn --arg v "$raw_package_scope" '$v | @uri')
  package_name_enc=$(jq -rn --arg v "$raw_package_name" '$v | @uri')
  package_version_enc=$(jq -rn --arg v "$package_version" '$v | @uri')

  package_id="${package_name_enc}@${package_version_enc}"
  if [ "${package_scope}" != "" ]; then
    package_id="${package_scope}/${package_id}"
  fi
  subject_name="pkg:npm/${package_id}"

  # The integrity digest is "<hash alg>-<base64 checksum>". Parse the algorithm
  # (lowercased) and convert the checksum from base64 to hex for the subject.
  alg=$(printf '%s' "$package_integrity" | cut -d'-' -f1 | tr '[:upper:]' '[:lower:]')
  digest=$(printf '%s' "$package_integrity" | cut -d'-' -f2- | base64 -d | od -A n -v -t x1 | tr -d ' \n')
  if [ -z "$alg" ] || [ -z "$digest" ]; then
    echo "::error::Failed to derive digest from integrity '${package_integrity}' for ${package_name}."
    exit 1
  fi

  attestation_name="${package_filename%.*}"
  if [ -n "${seen_names[$attestation_name]:-}" ]; then
    echo "::error::Duplicate attestation name '${attestation_name}' derived from tarball '${package_filename}'. Tarball basenames must be unique."
    exit 1
  fi
  seen_names[$attestation_name]=1

  output_file="${OUTPUT_FOLDER}/${attestation_name}"
  jq -cn \
    --arg type "$INTOTO_TYPE" \
    --arg sname "$subject_name" \
    --arg alg "$alg" \
    --arg digest "$digest" \
    --arg ptype "$PREDICATE_TYPE" \
    --slurpfile predicate "$PREDICATE_FILE" \
    '{
      _type: $type,
      subject: [ { name: $sname, digest: { ($alg): $digest } } ],
      predicateType: $ptype,
      predicate: $predicate[0]
    }' >"$output_file"

  echo "Wrote statement for ${subject_name} -> ${output_file}"
done

echo "Generated ${count} in-toto statement(s) in ${OUTPUT_FOLDER}."
