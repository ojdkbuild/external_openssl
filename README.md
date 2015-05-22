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

Staticlib toolchain name must be specified as a `STATICLIB_TOOLCHAIN` parameter to `cmake` command
unless you are using GCC on Linux x86_64 (`linux_amd64_gcc` toolchain) that is default.

Example build for Windows x86_64 with Visual Studio 2013 Express, run the following commands 
from the development shell `C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts\VS2013 x64 Cross Tools Command Prompt` :

    git clone https://github.com/staticlibs/external_openssl.git
    cd external_openssl
    git submodule update --init --recursive
    mkdir build
    cd build
    cmake .. -DSTATICLIB_TOOLCHAIN=windows_amd64_msvc -G "NMake Makefiles"
    nmake
    nmake test

License information
-------------------

This project is released under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Changelog
---------

**2015-05-22**

 * 1.0.2a, initial public version
