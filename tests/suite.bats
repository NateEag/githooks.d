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
    run git commit -a -m 'Test commit'
    cd "$cwd"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Could not find pre-commit.d!" ]
}
