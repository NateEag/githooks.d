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

Tests
-----

Install [Bats](https://github.com/sstephenson/bats), then:

    cd tests
    bats suite.bats
