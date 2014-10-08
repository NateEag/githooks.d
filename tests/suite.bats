#! /usr/bin/env bats

load test_helper

setup() {
    make_test_repo
}

teardown() {
    rm_test_repo
    rm_test_homedir
}

@test "Sets up repo for running githooks on install." {
    skip "Not yet implemented."
}

@test "Refuses to attempt install if not being run in a git repo." {
    skip "Not yet implemented."
}

@test "Aborts if target hook dir missing" {
    install_hook pre-commit
    rmdir $test_repo_path/.git/hooks/pre-commit.d

    cwd=$(pwd)
    cd "$test_repo_path"
    echo 'Try to commit this.' >> readme.txt
    git add readme.txt
    run git commit -a -m 'Test commit'
    cd "$cwd"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Could not find .git/hooks/pre-commit.d!" ]
}

@test "Exits with last executable hook's non-zero status." {
    install_hook pre-commit

    # GRIPE This is more like installing a hook than the previous step, and
    # should be generalized into such a method.
    cp $test_repo_path/.git/hooks/pre-commit.sample \
       $test_repo_path/.git/hooks/pre-commit.d/sample
    chmod 755 $test_repo_path/.git/hooks/pre-commit.d/sample

    cwd=$(pwd)
    cd "$test_repo_path"
    echo "This line has trailing whitespace    " >> readme.txt
    git add readme.txt
    run git commit -m 'Test commit'
    [ "$status" -eq 1 ]
    cd "$cwd"
}

@test "Runs user hook package." {
    # Forge the HOME variable so we don't have to rely on the current user's
    # home directory for testing.
    HOME="$BATS_TMPDIR/githooks.d-test-homedir"
    export HOME
    hook_package="$HOME/.githooks.d"

    install_hook "pre-commit"
    install_precommit_blocker "$hook_package"

    cwd=$(pwd)

    cd "$test_repo_path"
    echo "This line is fine." >> readme.txt
    git add readme.txt
    run git commit -m 'Test commit'
    echo "$output"

    [ $status -eq 1 ]

    cd "$cwd"
}

@test "Runs successfully if no user hook package exists." {
    # Forge the HOME variable so we don't have to rely on the current user's
    # home directory for testing.
    HOME="$BATS_TMPDIR/githooks.d-test-homedir"
    export HOME
    hook_package="$HOME/.githooks.d"

    install_hook "pre-commit"

    cwd=$(pwd)

    cd "$test_repo_path"
    echo "This line is fine." >> readme.txt
    git add readme.txt
    run git commit -m 'Test commit'
    echo "$output"

    [ $status -eq 0 ]

    cd "$cwd"
}

@test "Runs configured hook packages." {
    skip "Not yet implemented"
}

@test "Complains if configured hook packages are missing." {
    skip "Not yet implemented"
}
