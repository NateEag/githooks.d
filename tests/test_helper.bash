#! /bin/bash

# Helper functions for bats test suite.

test_repo_path="$BATS_TMPDIR/githooks.d_test"

# Create the test repository in our temporary directory.
make_test_repo () {
    git init "$test_repo_path"
}

# Remote the test repository from our temporary directory.
rm_test_repo () {
    rm -rf "$test_repo_path"
}

# Install run-hooks.sh for the hook named $1 in our test repo.
# GRIPE This is mis-named. It doesn't install a hook, it installs our hook
# driver. Also, it probably belongs in a general-purpose installation module.
install_hook () {
    hook_path="$test_repo_path/.git/hooks/$1"
    cp ../run-hooks.sh "$hook_path"
    chmod 755 "$hook_path"
    mkdir -p "$hook_path".d
}
