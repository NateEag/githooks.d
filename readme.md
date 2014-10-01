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

Hook Packages
-------------

Hook packages let you share git hooks between multiple projects. Why do that?

* A company's repositories could share a commit message checker, to ensure
  every commit has a ticket ID in it.
* A team's style guide could be written as pre-commit and pre-receive hooks, then
  used to enforce adherence across their projects.
* Dependency managers like [npm](https://www.npmjs.org/) and
  [pip](https://pypi.python.org/pypi/pip) are used by a lot of different
  projects. All those projects could share a generic set of git hooks
  for updating installed dependencies after pulls, checkouts, and rebases.

Tests
-----

Install [Bats](https://github.com/sstephenson/bats), then:

    cd tests
    bats suite.bats
