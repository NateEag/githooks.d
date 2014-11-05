#! /bin/bash

# Helper functions for bats test suite.

test_repo_path="$BATS_TMPDIR/githooks.d_test"

# Create the test repository in our temporary directory.
make_test_repo () {
    git init "$test_repo_path"
    git config user.name 'Some Person'
    git config user.email 'test@example.com'
}

rm_test_homedir () {
    rm -rf "$BATS_TMPDIR/githooks.d-test-homedir"
}

# Remove the test repository from our temporary directory.
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
