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

# toolchain setup
set ( STATICLIB_TOOLCHAIN linux_amd64_gcc CACHE STRING "toolchain triplet" )
set ( CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/toolchains/${STATICLIB_TOOLCHAIN}.cmake CACHE INTERNAL "" )

# project setup
project ( external_openssl CXX C )
set ( ${PROJECT_NAME}_STATICLIB_VERSION 1.0.2.1 )
# common include
include ( ${CMAKE_CURRENT_LIST_DIR}/cmake/staticlibs_common.cmake )
# options, use SET ( OPTNAME ON CACHE BOOL "") to override
option ( STATICLIB_OPENSSL_SHARED "Use 'shared' or 'no-shared' OpenSSL flag" OFF )

# compile definitions
set ( ${PROJECT_NAME}_CFLAGS ${CMAKE_C_FLAGS} )
if ( STATICLIB_TOOLCHAIN MATCHES "[^_]+_[^_]+_clang" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-empty-translation-unit -Wno-gnu-statement-expression -Wno-shadow" )
elseif ( STATICLIB_TOOLCHAIN MATCHES "[^_]+_[^_]+_gcc" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-maybe-uninitialized" )
endif ( )

# variables for makefiles
if ( CMAKE_BUILD_TYPE MATCHES "Debug" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} ${CMAKE_C_FLAGS_DEBUG}" )
endif ( )
if ( CMAKE_BUILD_TYPE MATCHES "Release" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} ${CMAKE_C_FLAGS_RELEASE}" )
endif ( )
if ( STATICLIB_OPENSSL_SHARED )
    set ( ${PROJECT_NAME}_SHARED "shared" )
else ( )
    set ( ${PROJECT_NAME}_SHARED "no-dso" )
endif ( )
# library config
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/Makefile-${STATICLIB_TOOLCHAIN}
        ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})
add_custom_target( ${PROJECT_NAME}_build
        COMMAND ${CMAKE_MAKE_PROGRAM} -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})

add_library( ${PROJECT_NAME} STATIC IMPORTED GLOBAL )
add_dependencies( ${PROJECT_NAME} ${PROJECT_NAME}_build )
add_library( ${PROJECT_NAME}_ssl STATIC IMPORTED GLOBAL )
add_dependencies( ${PROJECT_NAME}_ssl ${PROJECT_NAME}_build )
set_target_properties( ${PROJECT_NAME}_ssl PROPERTIES IMPORTED_LOCATION ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} )
set_target_properties( ${PROJECT_NAME} PROPERTIES IMPORTED_LOCATION ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} )
set ( ${PROJECT_NAME}_INCLUDES ${CMAKE_CURRENT_BINARY_DIR}/openssl/include )

# tests
set ( ${PROJECT_NAME}_TEST_INCLUDES ${${PROJECT_NAME}_INCLUDES} )
set ( ${PROJECT_NAME}_TEST_LIBS ${PROJECT_NAME} ${PROJECT_NAME}_ssl )
set ( ${PROJECT_NAME}_TEST_OPTS "" )
staticlib_enable_testing ( ${PROJECT_NAME}_TEST_INCLUDES ${PROJECT_NAME}_TEST_LIBS ${PROJECT_NAME}_TEST_OPTS )

# headers export
set ( ${PROJECT_NAME}_INCLUDES ${${PROJECT_NAME}_INCLUDES} CACHE INTERNAL "" )
