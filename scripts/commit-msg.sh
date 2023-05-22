#!/bin/bash

# Define variable to use conventional commits hook
COMMIT_MSG_HOOK='#!/bin/bash \nMSG_FILE=$1 \ncz check --allow-abort --commit-msg-file $MSG_FILE'

# Output the contents of the variable to a file
echo -e "${COMMIT_MSG_HOOK}" > .git/hooks/commit-msg

# Make the file executable
chmod +x .git/hooks/commit-msg

echo "Pre-commit hook created!"
