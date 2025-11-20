#!/bin/bash

# Compute some variables
extract_entry_point() {
  local workflow_ref="$1"
  local entry_point="${workflow_ref#*/*/}"
  entry_point="${entry_point%@*}"
  echo "$entry_point"
}

ENTRY_POINT=$(extract_entry_point "$GITHUB_WORKFLOW_REF")

# Generate JSON
cat <<EOF > predicate.json
{
    "builder": {
        "id": "$BUILDER_ID"
    },
    "buildType": "https://slsa-framework.github.io/github-actions-buildtypes/workflow/v1",
    "invocation": {
        "configSource": {
            "uri": "$CONFIG_SOURCE_URI",
            "digest": {
                "sha1": "$CONFIG_SOURCE_DIGEST"
            },
            "entryPoint": "$ENTRY_POINT"
        },
        "environment": {
            "GITHUB_ACTOR_ID": "$GITHUB_ACTOR_ID",
            "GITHUB_EVENT_NAME": "$GITHUB_EVENT_NAME",
            "GITHUB_BASE_REF": "$GITHUB_BASE_REF",
            "GITHUB_REF": "$GITHUB_REF",
            "GITHUB_REF_TYPE": "$GITHUB_REF_TYPE",
            "GITHUB_REPOSITORY": "$GITHUB_REPOSITORY",
            "GITHUB_REPOSITORY_ID": "$GITHUB_REPOSITORY_ID",
            "GITHUB_REPOSITORY_OWNER": "$GITHUB_REPOSITORY_OWNER",
            "GITHUB_REPOSITORY_OWNER_ID": "$GITHUB_REPOSITORY_OWNER_ID",
            "GITHUB_RUN_ATTEMPT": "$GITHUB_RUN_ATTEMPT",
            "GITHUB_RUN_ID": "$GITHUB_RUN_ID",
            "GITHUB_RUN_NUMBER": "$GITHUB_RUN_NUMBER",
            "GITHUB_SHA": "$GITHUB_SHA",
            "GITHUB_TRIGGERING_ACTOR_ID": "$GITHUB_TRIGGERING_ACTOR_ID",
            "GITHUB_WORKFLOW_REF": "$GITHUB_WORKFLOW_REF",
            "GITHUB_WORKFLOW_SHA": "$GITHUB_WORKFLOW_SHA",
            "NPM_DIST_TAG": "${NPM_DIST_TAG}"
        }
    },
    "metadata": {
        "buildInvocationId": "$BUILD_INVOCATION_ID"
    },
    "materials": [
      {
            "uri": "$CONFIG_SOURCE_URI",
            "digest": {
                "sha1": "$CONFIG_SOURCE_DIGEST"
            }
        }
    ]
}
EOF

echo "Predicate file generated: predicate.json"