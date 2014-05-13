#! /bin/bash

# Simple script for multiplexing git hooks.

# Disallow unset variables
set -o nounset

# Find the directory
hook_name=$(basename $0)
hooks_dir="$hook_name".d
if [[ ! -d "hooks_dir" ]]; then
    # Warn the user and bail out. Since we have a borked install, use a
    # non-zero exit code, so no dangerous operations can take place.
    echo "Could not find $hooks_dir!" >&2
    exit 1
fi
