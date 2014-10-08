githooks.d
==========

Git's
[hook system](https://www.kernel.org/pub/software/scm/git/docs/githooks.html)
is very useful for automating workflow-related tasks.

It would be even better if you could register multiple programs for a hook to
run.

Since such a feature is trivial to implement, it is a wheel that has been
crafted many times over.

This is my re-invention.

Goals
-----

* Do not actively ambush Windows (i.e. don't require symlinks, because
  they're second-class citizens on Windows)
* Allow sharing hook packages between different repositories
* Fit my personal aesthetic

Installing
----------

Not implemented yet, but should look something like:

`run-hooks.sh --install` - set up a repo to use `githooks.d` to run hooks via
run-hooks.sh. It creates one-line stub scripts for each hook that assume
`run-hooks.sh` is on $PATH (maybe uses `githooks.conf.sh` to actually ensure
that?).

This approach differs from the usual "symlink the hook manager" approach so
that it's still easy to update the hook manager globally on Windows.

Hook Packages
-------------

Hook packages let you share git hooks between multiple projects. Why do that?

* A company's repositories could share a commit message checker, to ensure
  every commit has a ticket ID in it.
* A team's style guide could be written as pre-commit and pre-receive hooks, then
  used to check code style in all their projects.
* Dependency managers like [npm](https://www.npmjs.org/) and
  [pip](https://pypi.python.org/pypi/pip) are used by a lot of different
  projects. Projects using the same dependency manager could share a set of git
  hooks for updating dependencies after pulls, checkouts, and rebases.


## What Are Hook Packages?

A hook package is a directory with one or more subdirectories named after git
hooks.

When a repository includes a hook package, at hook run time, it runs each
executable file inside `$package_dir/$hook_name.d/`.

If a file exists at `$package_dir/githooks.conf.sh`, it will be sourced before
running the package's hooks. This allows each hook package to set custom
`$PATH`s and other environment variables.

The `$GITHOOKS_REQUIRED_PACKAGES` variable can be set in `githooks.conf.sh` to
an array of package names, so that packages can require other packages.
If set, `$GITHOOKS_PACKAGE_PATH` provides the search path for packages,
functioning like $PATH does for binaries. It defaults to
`$GIT_DIR/.git/hooks/:$HOME/.githooks.d`.

If you need to run hook packages with the same name from the same repository,
the easiest way is to just change one's name.

If other hook packages use them both as dependencies, that isn't an option.
Instead, keep them in different paths, and use `$GITHOOKS_PACKAGE_PATH` to
control which one is available when.

Tests
-----

Install [Bats](https://github.com/sstephenson/bats), then:

    cd tests
    bats suite.bats
