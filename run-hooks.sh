#! /bin/bash

# Simple script for multiplexing git hooks.

# Disallow unset variables
set -o nounset

# Find the directory containing our hook scripts.
hook_name=$(basename "$0")
hooks_dir=$(dirname "$0")/"$hook_name".d
if [[ ! -d "$hooks_dir" ]]; then
    # Warn the user and bail out. Since we have a borked install, use a
    # non-zero exit code to prevent any git operations from taking place.
    echo "Could not find $hooks_dir!" >&2
    exit 1
fi

echo "$@"

# Capture stdin for passing to hooks, as some make use of it.
input=$(cat)

exit_status=0
for hook in ./$hooks_dir/*; do
    if [[ ! -x $hook ]]; then
        echo "Skipping $hook..."
        continue
    fi

    "$input" | "$hook" "$@"
    hook_status=$?
    if [[ $hook_status -ne 0 ]]; then
        # DEBUG Is it better to quit now, or keep running more hooks?
        exit_status=$hook_status
    fi
done

exit $exit_status
