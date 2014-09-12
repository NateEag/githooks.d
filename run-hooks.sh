#! /bin/bash

# Simple script for multiplexing git hooks.

# Disallow unset variables
set -o nounset

# Run the hooks identified by $1 in the hook package at $2.
#
# Echoes exit status for the package as a return value. It is 0 if all hooks
# succeeded, and the exit status of the last failed hook otherwise.
run_hooks_in_package () {
     hook_name="$1"
     package_path="$2"
     input="$3"

     hooks_dir="$package_path/$hook_name.d"

     exit_status=0
     for hook in $hooks_dir/*; do
         if [[ ! -x $hook ]]; then
             continue
         fi

         "$input" | "$hook" "$@"
         hook_status=$?
         if [[ $hook_status -ne 0 ]]; then
             # DEBUG Is it better to quit now, or keep running more hooks?
             # Probably depends on the hook type - pre-receive should die fast,
             # but for post-receive you'd want to fire everything you can and log
             # the ones that fail.
             exit_status=$hook_status
         fi
     done

     echo "$exit_status"
}

hook_name=$(basename "$0")

# Capture stdin for passing to hooks, as some make use of it.
input=$(cat)

# Run user hooks if available.
user_hooks_dir="$HOME/.githooks.d"
if [[ -d "$user_hooks_dir" ]]; then
    exit_status=$(run_hooks_in_package "$hook_name" "$user_hooks_dir" "$input")
    if [[ "$exit_status" -ne "0" ]]; then
        exit "$exit_status"
    fi
fi

# Run this repo's hooks, bailing out if they are not found.
hooks_dir=".git/hooks/$hook_name".d
if [[ ! -d "$hooks_dir" ]]; then
    # Warn the user and bail out. Since we have a borked install, use a
    # non-zero exit code to prevent any git operations from taking place.
    echo "Could not find $hooks_dir!" >&2
    exit 1
fi

exit_status=$(run_hooks_in_package "$hook_name" ./.git/hooks "$input")

exit "$exit_status"
