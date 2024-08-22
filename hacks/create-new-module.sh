#!/bin/bash

# Get module name
if [ $# -ne 1 ]; then
  echo "Usage: $0 <module-name>"
  exit 1
fi

MODULE_NAME="$1"

# Validate module name
if ! [[ $MODULE_NAME =~ ^[a-zA-Z0-9-]+$ ]]; then
  echo "Error: Module name can only contain lower case alphanumeric characters and dashes."
  exit 1
fi

# Get the git repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
if [ $? -ne 0 ]; then
  echo "Error: Not in a git repository."
  exit 1
fi

# Check if the module directory already exists
MODULE_PATH="$REPO_ROOT/modules/$MODULE_NAME"
if [ -d "$MODULE_PATH" ]; then
  echo "Error: Module directory already exists: $MODULE_PATH"
  exit 1
fi

# Create the directory
mkdir -p "$MODULE_PATH"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create directory $MODULE_PATH"
  exit 1
fi

# Create versions.tf
cat <<EOF >"$MODULE_PATH/versions.tf"
terraform {
  required_version = ">= 1.0.0"
}

# TODO: add your providers
EOF
if [ $? -ne 0 ]; then
  echo "Error: Failed to create file versions.tf"
  exit 1
fi

# Create .tflint.hcl
cat <<EOF >"$MODULE_PATH/.tflint.hcl"
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# TODO: setup tflint rulesets for your providers
# for example: https://github.com/terraform-linters/tflint-ruleset-aws
EOF
if [ $? -ne 0 ]; then
  echo "Error: Failed to create file .tflint.hcl"
  exit 1
fi

# Update release-please-config.json
CONFIG_FILE="$REPO_ROOT/release-please-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: release-please-config.json not found at $CONFIG_FILE"
  exit 1
fi

# Use jq to add the new module to the config file
jq --arg module "$MODULE_NAME" \
  '.packages += {
    "modules/\($module)": {
      "component": $module,
      "release-type": "terraform-module",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": false,
      "bump-patch-for-minor-pre-major": false,
      "draft": false,
      "prerelease": false
    }
  }' \
  "$CONFIG_FILE" >"$CONFIG_FILE.tmp" &&
  mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to update release-please-config.json"
  exit 1
fi

echo "Module $MODULE_NAME created, you should create a new branch with these changes and open a pull request"
echo "\
From the repo root:

git switch -c new-module/$MODULE_NAME
git add modules/$MODULE_NAME
git add release-please-config.json
git commit -m \"feat: add new module $MODULE_NAME\"
git push -u origin new-module/$MODULE_NAME
"
