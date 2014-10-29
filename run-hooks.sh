#! /bin/bash

# Simple script for multiplexing git hooks.

# Disallow unset variables
set -o nounset


# Array of all git hook names. I feel like there should be a git command that
# will generate this, but I couldn't find it. Instead, this is ripped from the
# githooks(5) manpage.
hook_names=(applypatch-msg pre-applypatch post-applypatch pre-commit
            prepare-commit-msg commit-msg post-commit pre-rebase post-checkout
            post-merge pre-receive update post-receive post-update pre-auto-gc
            post-rewrite)


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

         echo "$input" | "$hook" "$@"
         hook_status=$?
         if [[ $hook_status -ne 0 ]]; then
             # DEBUG Is it better to quit now, or keep running more hooks?
             # Probably depends on the hook type - pre-receive should die fast,
             # but for post-receive you'd want to fire everything you can and log
             # the ones that fail.
             exit_status=$hook_status
         fi
     done

     # TODO Use return, because I just discovered bash does in fact have this
     # feature I've always thought it should. DUH.
     echo "$exit_status"
}

# Set up a git repository to manage its hooks with this script.
#
# Optional $1 is the path to target git repo. Otherwise, we assume the current
# path is part of the target repo.
install_self () {
    target_repo="${1-}"
    if [ -z "target_repo" ]; then
        target_repo=$(pwd)
    fi

    old_cwd=$(pwd)
    cd "$target_repo"
    git rev-parse --git-dir 2> /dev/null
    in_git_repo=$?

    if [[ $in_git_repo -ne 0 ]]; then
        echo "Can only be installed in git repositories."

        exit 1
    fi

    hook_cmd=$(basename "$0")

    # TODO Handle pre-existing hooks sanely (fail?)
    for hook_name in "${hook_names[@]}"; do
        mkdir .git/hooks/$hook_name.d

        echo '#! /bin/bash' >> .git/hooks/$hook_name
        echo 'input=$(cat)' >> .git/hooks/$hook_name
        echo 'echo "$input" | ' "$hook_cmd" ' $hook_name "$@"' >> .git/hooks/$hook_name
        chmod 755 .git/hooks/$hook_name
    done

    cd "$old_cwd"
}

# Handle requests for installs.
if [[ $# -gt 0 && "$1" == "install" ]]; then
    if [[ $# -gt 1 ]]; then
        install_self "$2"
    else
        install_self
    fi

    exit 0
fi


# Set hook name then drop it from our arg list, so we can pass $@ to hooks.
hook_name=$(basename "$1")
shift

# Make sure this repo's hooks are installed correctly.
hooks_dir=".git/hooks/$hook_name".d
if [[ ! -d "$hooks_dir" ]]; then
    # Warn the user and bail out. Since we have a borked install, use a
    # non-zero exit code to prevent any git operations from taking place.
    echo "Could not find $hooks_dir!" >&2
    exit 1
fi

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

exit_status=$(run_hooks_in_package "$hook_name" ./.git/hooks "$input")

exit "$exit_status"
