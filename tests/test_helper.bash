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

# Add a precommit hook that prevents all commits to package at $1.
install_precommit_blocker () {
    # TODO Probably should have a general routine for making an empty hook
    # package.
    mkdir -p "$1/pre-commit.d"
    commit_blocker_path="$1/pre-commit.d/commit-blocker"

    echo "#! /bin/bash" > "$commit_blocker_path"
    echo "exit 1" >> "$commit_blocker_path"

    chmod 755 "$commit_blocker_path"
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
