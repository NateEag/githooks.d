githooks.d
==========

Git's
[hook system](https://www.kernel.org/pub/software/scm/git/docs/githooks.html)
is well-design and has a wide range of uses.

That wide range of uses is slightly hampered by the absence of hook
multiplexing in core git.

Since the feature is trivial to implement, it is a wheel that has been made
many times over.

This is my re-invention.

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
