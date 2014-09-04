#! /usr/bin/env bats

load test_helper

setup() {
    make_test_repo
}

teardown() {
    rm_test_repo
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
    skip "Not yet implemented"
}

@test "Runs configured hook packages." {
    skip "Not yet implemented"
}
