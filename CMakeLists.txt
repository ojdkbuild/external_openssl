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
set ( ${PROJECT_NAME}_STATICLIB_VERSION 1.0.2.3 )
set ( ${PROJECT_NAME}_DESCRIPTION "OpenSSL library build for Staticlibs" )
set ( ${PROJECT_NAME}_URL https://github.com/staticlibs/external_openssl.git )

# options, use SET ( OPTNAME ON CACHE BOOL "") to override
option ( STATICLIB_OPENSSL_SHARED "Use 'shared' or 'no-shared' OpenSSL flag" OFF )

# variables for makefiles
set ( ${PROJECT_NAME}_CFLAGS ${CMAKE_C_FLAGS} )
if ( ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-empty-translation-unit -Wno-gnu-statement-expression -Wno-shadow" )
elseif ( ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU" )
    set ( ${PROJECT_NAME}_CFLAGS "${${PROJECT_NAME}_CFLAGS} -Wno-maybe-uninitialized" )
endif ( )
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

# library
if ( DEFINED STATICLIB_TOOLCHAIN )
    configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/Makefile-${STATICLIB_TOOLCHAIN}
            ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})
    add_custom_target ( ${PROJECT_NAME}
            COMMAND ${CMAKE_MAKE_PROGRAM} -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})
    add_library( crypto STATIC IMPORTED GLOBAL )
    add_dependencies( crypto ${PROJECT_NAME} )
    set_target_properties( crypto PROPERTIES IMPORTED_LOCATION
            ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} )
    add_library( ssl STATIC IMPORTED GLOBAL )
    add_dependencies( ssl ${PROJECT_NAME} )
    set_target_properties( ssl PROPERTIES IMPORTED_LOCATION
            ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} )
endif ( )

# pkg-config
if ( NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY )
    set ( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
endif ( )
set ( ${PROJECT_NAME}_MODULE openssl )
set ( ${PROJECT_NAME}_PC_CFLAGS "-I${CMAKE_CURRENT_BINARY_DIR}/openssl/include" )
set ( ${PROJECT_NAME}_PC_LIBS "-L${CMAKE_LIBRARY_OUTPUT_DIRECTORY} -lssl -lcrypto" )
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/pkg-config.in 
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/openssl.pc )
