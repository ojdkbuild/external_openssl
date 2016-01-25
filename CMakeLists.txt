# Copyright 2015, alex at staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required ( VERSION 2.8.12 )

# project
project ( external_openssl CXX )
set ( ${PROJECT_NAME}_STATICLIB_VERSION 1.0.2.5 )
set ( ${PROJECT_NAME}_DESCRIPTION "OpenSSL library build for Staticlibs" )
set ( ${PROJECT_NAME}_URL https://github.com/staticlibs/external_openssl.git )
include ( ${CMAKE_CURRENT_LIST_DIR}/resources/macros.cmake )

# options, use SET ( OPTNAME ON CACHE BOOL "") to override
option ( STATICLIB_OPENSSL_SHARED "Use 'shared' or 'no-shared' OpenSSL flag" OFF )

# standalone build
if ( NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY )
    set ( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} )
endif ( )
if ( NOT DEFINED STATICLIB_TOOLCHAIN )
    if ( NOT DEFINED ${PROJECT_NAME}_TOOLCHAIN )
        if ( WIN32 )
            if ( CMAKE_SIZEOF_VOID_P EQUAL 8 )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_amd64_msvc" )
            else ( )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_i386_msvc" )
            endif ( )
        elseif ( APPLE )
            set ( ${PROJECT_NAME}_TOOLCHAIN "macosx_amd64_clang" )
        elseif ( UNIX )
            set ( ${PROJECT_NAME}_TOOLCHAIN "linux_amd64_gcc" )
        else ( )
            message ( FATAL_ERROR "Cannot determine toolchain to use, please specify [${PROJECT_NAME}_TOOLCHAIN]" )
        endif ( )
    endif ( )
else ( )
    set ( ${PROJECT_NAME}_TOOLCHAIN ${STATICLIB_TOOLCHAIN} )
endif ( )

# variables for makefiles
if ( CMAKE_BUILD_TYPE MATCHES "Release" )
    set ( ${PROJECT_NAME}_CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}" )
else ( )
    set ( ${PROJECT_NAME}_CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}" )
endif ( )
if ( ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-empty-translation-unit -Wno-gnu-statement-expression -Wno-shadow" )
elseif ( ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-maybe-uninitialized" )
endif ( )
if ( STATICLIB_OPENSSL_SHARED )
    set ( ${PROJECT_NAME}_SHARED "shared" )
else ( )
    set ( ${PROJECT_NAME}_SHARED "no-dso" )
endif ( )

# patch OpenSSL if musl is used
# https://patchwork.ozlabs.org/patch/388010/
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "alpine_[^_]+_[^_]+" AND ( NOT DEFINED ${PROJECT_NAME}_OPENSSL_MUSL_APPLIED ) )
    message ( STATUS "Applying patch to OpenSSL to support musl" )
    external_openssl_apply_git_patch ( ${CMAKE_CURRENT_LIST_DIR}/openssl
            ${STATICLIB_CMAKE}/resources/musl/openssl102_musl.patch )
    set ( ${PROJECT_NAME}_OPENSSL_MUSL_APPLIED "" CACHE INTERNAL "" )
endif ( )
# patch OpenSSL if windows x86 is used
# http://rt.openssl.org/Ticket/Display.html?id=3650&user=guest&pass=guest
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_[^_]+" AND ( NOT DEFINED ${PROJECT_NAME}_OPENSSL_WIN32_APPLIED ) )
    message ( STATUS "Applying patch to OpenSSL to fix asm support" )
    external_openssl_apply_git_patch ( ${CMAKE_CURRENT_LIST_DIR}/openssl
            ${CMAKE_CURRENT_LIST_DIR}/resources/windows/masm_102_3650.patch )
    set ( ${PROJECT_NAME}_OPENSSL_WIN32_APPLIED "" CACHE INTERNAL "" )
endif ( )

# copy files
file ( COPY ${CMAKE_CURRENT_LIST_DIR}/openssl
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
file ( COPY ${CMAKE_CURRENT_LIST_DIR}/resources/preconfigured/opensslconf-${${PROJECT_NAME}_TOOLCHAIN}.h
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/openssl/crypto/ )
file ( RENAME ${CMAKE_CURRENT_BINARY_DIR}/openssl/crypto/opensslconf-${${PROJECT_NAME}_TOOLCHAIN}.h
        ${CMAKE_CURRENT_BINARY_DIR}/openssl/crypto/opensslconf.h )

# copy makefile
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/Makefile-${${PROJECT_NAME}_TOOLCHAIN}
        ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${${PROJECT_NAME}_TOOLCHAIN})
if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_[^_]+_[^_]+" )
    set ( ${PROJECT_NAME}_MAKE_PROGRAM nmake )
else ( )
    set ( ${PROJECT_NAME}_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM} )
endif ( )
# run configure
execute_process ( COMMAND ${${PROJECT_NAME}_MAKE_PROGRAM}
        -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${${PROJECT_NAME}_TOOLCHAIN} configure
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )

# check deplibs cache
if ( STATICLIB_USE_DEPLIBS_CACHE )
    set ( ${PROJECT_NAME}_CACHED_LIB_PATH_CRYPTO ${STATICLIB_DEPLIBS_CACHE_DIR}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} )
    set ( ${PROJECT_NAME}_CACHED_LIB_PATH_SSL ${STATICLIB_DEPLIBS_CACHE_DIR}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} )
    if ( ( EXISTS ${${PROJECT_NAME}_CACHED_LIB_PATH_CRYPTO} ) 
            AND ( EXISTS ${${PROJECT_NAME}_CACHED_LIB_PATH_SSL} ) )
        add_library( crypto STATIC IMPORTED GLOBAL )
        set_target_properties( crypto PROPERTIES IMPORTED_LOCATION ${${PROJECT_NAME}_CACHED_LIB_PATH_CRYPTO} )
        add_library( ssl STATIC IMPORTED GLOBAL )
        set_target_properties( ssl PROPERTIES IMPORTED_LOCATION ${${PROJECT_NAME}_CACHED_LIB_PATH_SSL} )
        add_custom_target( ${PROJECT_NAME} )
        message ( STATUS "Using cached library: [${${PROJECT_NAME}_CACHED_LIB_PATH_CRYPTO}]" )
        message ( STATUS "Using cached library: [${${PROJECT_NAME}_CACHED_LIB_PATH_SSL}]" )
        return ( )
    endif ( )
endif ( )

# add build target
add_custom_target ( ${PROJECT_NAME} ALL COMMAND ${${PROJECT_NAME}_MAKE_PROGRAM}
        -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${${PROJECT_NAME}_TOOLCHAIN} build
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
add_library( crypto STATIC IMPORTED GLOBAL )
add_dependencies( crypto ${PROJECT_NAME} )
set_target_properties( crypto PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} )
add_library( ssl STATIC IMPORTED GLOBAL )
add_dependencies( ssl ${PROJECT_NAME} )
set_target_properties( ssl PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} )

# pkg-config
set ( ${PROJECT_NAME}_MODULE openssl )
set ( ${PROJECT_NAME}_PC_CFLAGS "-I${CMAKE_CURRENT_BINARY_DIR}/openssl/include" )
set ( ${PROJECT_NAME}_PC_LIBS "-L${CMAKE_LIBRARY_OUTPUT_DIRECTORY} -lssl -lcrypto" )
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/pkg-config.in 
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/openssl.pc )
