OpenSSL library build for Staticlibs
====================================

This project is a part of [Staticlibs](http://staticlibs.net/).

This project contains a CMake wrapper for the [openssl library](https://github.com/openssl/openssl). 
Wrapper uses `Makefile`s for each supported platform, supports toolchain specification
with `STATICLIB_TOOLCHAIN` option and exports openssl headers to be used from dependent projects.

OpenSSL unofficial GitHub repository is used as a git submodule of this project.
OpenSSL pinned to version 1.0.2 but you are encouraged to update it to newer releases of the 1.0.2 branch.

Link to the [documentation](https://www.openssl.org/docs/).

How to build
------------

[CMake](http://cmake.org/) is required for building.

[Perl](https://www.perl.org/) is also required for building, Windows users can obtain ready-to-use
Perl distribution from [tools_windows_perl](https://github.com/staticlibs/tools_windows_perl) repository.

To build the library on Windows using Visual Studio 2013 Express run the following commands using
Visual Studio development command prompt 
(`C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts\VS2013 x86 Native Tools Command Prompt`):

    git clone --recursive https://github.com/staticlibs/external_openssl.git
    cd external_openssl
    mkdir build
    cd build
    cmake ..
    msbuild external_openssl.sln

See [StaticlibsToolchains](https://github.com/staticlibs/wiki/wiki/StaticlibsToolchains) for 
more information about the toolchain setup and cross-compilation.

License information
-------------------

This project is released under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Changelog
---------

**2016-01-17**

 * version 1.0.2.5
 * minor CMake changes

**2015-11-10**

 * version 1.0.2.4
 * separate `configure` and `build` stages for `Makefile` builds

**2015-10-20**

 * version 1.0.2.3 - `pkg-config` integration

**2015-07-08**

 * version 1.0.2.2 - toolchains update

**2015-07-01**

 * version 1.0.2.1 - toolchains update, minor cmake fixes

**2015-05-22**

 * 1.0.2a, initial public version
