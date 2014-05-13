githooks.d
==========

Git's
[hook system](https://www.kernel.org/pub/software/scm/git/docs/githooks.html)
is well-thought-out and has a wide range of uses.

Multiplexing hooks is not a stock feature, is trivial to implement, and is
therefore a wheel that has been crafted many time.

This is my version.

Goals
-----

* Do not actively ambush Windows (i.e. don't require symlinks, because
  they're second-class citizens on Windows)
* Make it easy to install multiple hook collections
* Be prettier than other solutions I've found

Tests
-----

Install [Bats](https://github.com/sstephenson/bats), then:

    cd tests
    bats suite.bats
