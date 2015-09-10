OpenSSL library build for Staticlibs
====================================

This project is a part of [Staticlibs](http://staticlibs.net/).

This project contains a CMake wrapper for the [openssl library](https://github.com/openssl/openssl). 
Wrapper uses `Makefile`s for each supported platform, supports toolchain specification
with `STATICLIB_TOOLCHAIN` option and exports openssl headers to be used from dependent projects.

OpenSSL unofficial GitHub repository is used as a git submodule of this project.
OpenSSL pinned to version 1.0.2 but you are encouraged to update it to newer releases of 1.0.2 branch.

Link to [documentation](https://www.openssl.org/docs/).

How to build
------------

[CMake](http://cmake.org/) is required for building.

[TODO]

Perl is required for Windows builds.

License information
-------------------

This project is released under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Changelog
---------

**2015-07-08**

 * version 1.0.2.2 - toolchains update

**2015-07-01**

 * version 1.0.2.1 - toolchains update, minor cmake fixes

**2015-05-22**

 * 1.0.2a, initial public version
