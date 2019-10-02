OpenSSL library build for Staticlibs
====================================

[![travis](https://travis-ci.org/staticlibs/external_openssl.svg?branch=master)](https://travis-ci.org/staticlibs/external_openssl)
[![appveyor](https://ci.appveyor.com/api/projects/status/github/staticlibs/external_openssl?svg=true)](https://ci.appveyor.com/project/staticlibs/external-openssl)

This project is a part of [Staticlibs](http://staticlibs.net/).


This project contains a CMake wrapper for [OpenSSL library](https://www.openssl.org/) that
can be used to build sources imported from [CentOS lookaside](https://github.com/staticlibs/lookaside_openssl.git).

Link to the [documentation](https://www.openssl.org/docs/).

How to build
------------

[CMake](http://cmake.org/) is required for building.

[Perl](https://www.perl.org/) is also required for building, Windows users can obtain ready-to-use
Perl distribution from [tools_windows_perl](https://github.com/staticlibs/tools_windows_perl) repository.

[NASM](http://nasm.us/) is also required for building on Windows.
You can obtain ready-to-use NASM distribution from 
[tools_windows_nasm](https://github.com/staticlibs/tools_windows_nasm) repository.

To build the library on Windows using Visual Studio 2013 Express run the following commands using
Visual Studio development command prompt 
(`C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts\VS2013 x86 Native Tools Command Prompt`):

    git clone https://github.com/staticlibs/lookaside_openssl.git
    git clone https://github.com/staticlibs/external_openssl.git
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

**2019-10-02**

 * version 1.0.2k-5
 * 4 patches applied

**2019-06-07**

 * version 1.0.2k-4
 * 2 new patches included

**2019-01-07**

 * version 1.0.2k-3
 * 7 new patches included

**2018-06-13**

 * version 1.0.2k-2
 * April 2018 patches included

**2018-02-27**

 * version 1.0.2k-1
 * linux support
 * macOS support

**2017-12-25**
 * version 1.0.1e-5
 * vs2017 support

**2016-11-08**

 * version 1.0.1e-4
 * update OpenSSL with recent patches
 * Android and Linux builds

**2016-10-30**

 * version 1.0.1e-3
 * update OpenSSL with recent patches

**2016-10-29**

 * version 1.0.1e-2
 * use OpenSSL sources from CentOS

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
