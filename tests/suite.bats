#! /usr/bin/env bats

load test_helper

# Set up PATH so that the tests can run the script.
app_dir=$(dirname "$BATS_TEST_DIRNAME")

app_name="run-hooks.sh"

setup() {
    PATH=$app_dir:$PATH
    export PATH

    make_test_repo
}

teardown() {
    rm_test_repo
    rm_test_homedir
}

@test "Should not run install outside a git repo." {
    run $app_name install "$BATS_TMPDIR"

    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Can only be installed in git repositories." ]
}

@test "Install sets up repo to use githooks." {
    $app_name install "$test_repo_path"

    # TODO This should all be generalized, since it happens in multiple places.
    cp $test_repo_path/.git/hooks/pre-commit.sample \
       $test_repo_path/.git/hooks/pre-commit.d/sample
    chmod 755 $test_repo_path/.git/hooks/pre-commit.d/sample

    cwd=$(pwd)
    cd "$test_repo_path"
    echo "This line has trailing whitespace    " > readme.txt
    git add readme.txt

    run git commit -m 'Test commit'

    [ "$status" -eq 1 ]
    [[ "${lines[0]}" = *"trailing whitespace"* ]]

    cd "$cwd"
}

@test "Aborts if target hook dir missing" {
    $app_name install "$test_repo_path"

    rmdir $test_repo_path/.git/hooks/pre-commit.d

    cwd=$(pwd)
    cd "$test_repo_path"
    echo 'Try to commit this.' >> readme.txt
    git add readme.txt
    run git commit -a -m 'Test commit'

    [ "$status" -eq 1 ]
    [[ "${lines[0]}" = *"Could not find"* ]]

    cd "$cwd"
}

# TODO Would be a better test if the exit status were unusual.
@test "Exits with last executable hook's non-zero status." {
    $app_name install "$test_repo_path"

    cp $test_repo_path/.git/hooks/pre-commit.sample \
       $test_repo_path/.git/hooks/pre-commit.d/sample
    chmod 755 $test_repo_path/.git/hooks/pre-commit.d/sample

    cwd=$(pwd)
    cd "$test_repo_path"
    echo "This line has trailing whitespace    " >> readme.txt
    git add readme.txt
    run git commit -m 'Test commit'

    [ "$status" -eq 1 ]
    [[ "${lines[0]}" = *"trailing whitespace"* ]]

    cd "$cwd"
}

@test "Runs user hook package." {
    $app_name install "$test_repo_path"

    # Forge the HOME variable so we don't have to rely on the current user's
    # home directory for testing.
    HOME="$BATS_TMPDIR/githooks.d-test-homedir"
    export HOME
    hook_package="$HOME/.githooks.d"

    install_precommit_blocker "$hook_package"

    cwd=$(pwd)

    cd "$test_repo_path"
    echo "This line is fine." >> readme.txt
    git add readme.txt
    run git commit -m 'Test commit'

    [ $status -eq 1 ]
    [[ "${lines[0]}" = *"trailing whitespace"* ]]

    cd "$cwd"
}

@test "Runs successfully if no user hook package exists." {
    $app_name install "$test_repo_path"

    # Forge the HOME variable so we don't have to rely on the current user's
    # home directory for testing.
    HOME="$BATS_TMPDIR/githooks.d-test-homedir"
    export HOME

    cp $test_repo_path/.git/hooks/pre-commit.sample \
       $test_repo_path/.git/hooks/pre-commit.d/sample
    chmod 755 $test_repo_path/.git/hooks/pre-commit.d/sample

    cwd=$(pwd)

    cd "$test_repo_path"
    echo "This line is fine." >> readme.txt
    git add readme.txt

    run git commit -m 'Test commit'

    [ $status -eq 0 ]

    cd "$cwd"
}

@test "Runs configured hook packages." {
    skip "Not yet implemented"
}

@test "Complains if configured hook packages are missing." {
    skip "Not yet implemented"
}
