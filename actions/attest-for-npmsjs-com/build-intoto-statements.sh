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

# Expands the SLSA outputs layout into one unsigned in-toto Statement per
# attestation entry, ready for the SLSA `sign-attestations` action.
#
# This is a drop-in replacement for the SLSA `generate-attestations` action.
# That action does exactly this transformation (layout + predicate -> in-toto
# statements) but caps a single layout at 50 attestations
# (MAX_ATTESTATION_COUNT), which is too low for large monorepos.
# `sign-attestations` has no such cap, so we build the statements here and sign
# the whole folder, keeping each statement single-subject (the shape npmjs.com
# expects) while supporting an arbitrary number of packages.
#
# Inputs (environment variables):
#   SLSA_LAYOUT_FILE  Path to the SLSA outputs layout (artifacts-layout.json).
#   PREDICATE_FILE    Path to the shared SLSA predicate JSON.
#   PREDICATE_TYPE    Predicate type URI (e.g. https://slsa.dev/provenance/v0.2).
#   OUTPUT_FOLDER     Folder to write the unsigned statements into.

set -euo pipefail

: "${SLSA_LAYOUT_FILE:?SLSA_LAYOUT_FILE is required}"
: "${PREDICATE_FILE:?PREDICATE_FILE is required}"
: "${PREDICATE_TYPE:?PREDICATE_TYPE is required}"
: "${OUTPUT_FOLDER:?OUTPUT_FOLDER is required}"

# The in-toto Statement wrapper produced here is byte-compatible with what the
# SLSA `generate-attestations` action emits (same _type and key ordering).
INTOTO_TYPE="https://in-toto.io/Statement/v0.1"

if [ ! -f "$SLSA_LAYOUT_FILE" ]; then
  echo "::error::SLSA layout file not found: $SLSA_LAYOUT_FILE"
  exit 1
fi
if [ ! -f "$PREDICATE_FILE" ]; then
  echo "::error::Predicate file not found: $PREDICATE_FILE"
  exit 1
fi

count=$(jq '.attestations | length' "$SLSA_LAYOUT_FILE")
if [ "$count" -eq 0 ]; then
  echo "::error::No attestations found in layout: $SLSA_LAYOUT_FILE"
  exit 1
fi

# Start from a clean output folder so `sign-attestations` only signs the
# statements we generated here.
rm -rf "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

for i in $(seq 0 "$((count - 1))"); do
  name=$(jq -r ".attestations[$i].name" "$SLSA_LAYOUT_FILE")
  if [ -z "$name" ] || [ "$name" = "null" ]; then
    echo "::error::Attestation at index $i in $SLSA_LAYOUT_FILE has no name."
    exit 1
  fi

  output_file="${OUTPUT_FOLDER}/${name}"
  if [ -e "$output_file" ]; then
    echo "::error::Duplicate attestation name '${name}' in layout. Attestation names must be unique."
    exit 1
  fi

  # Wrap the layout's subjects (already single-subject) with the shared
  # predicate to form the in-toto statement.
  jq -c \
    --arg type "$INTOTO_TYPE" \
    --arg ptype "$PREDICATE_TYPE" \
    --slurpfile predicate "$PREDICATE_FILE" \
    ".attestations[$i] | {
      _type: \$type,
      subject: .subjects,
      predicateType: \$ptype,
      predicate: \$predicate[0]
    }" "$SLSA_LAYOUT_FILE" >"$output_file"

  echo "Wrote statement '${name}' -> ${output_file}"
done

echo "Generated ${count} in-toto statement(s) in ${OUTPUT_FOLDER}."
