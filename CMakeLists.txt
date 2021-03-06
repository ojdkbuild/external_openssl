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
project ( external_openssl C CXX )
set ( ${PROJECT_NAME}_STATICLIB_VERSION 1.0.2k-6 )
set ( ${PROJECT_NAME}_DESCRIPTION "OpenSSL library build for Staticlibs" )
set ( ${PROJECT_NAME}_URL https://github.com/staticlibs/external_openssl.git )
include ( ${CMAKE_CURRENT_LIST_DIR}/resources/macros.cmake )

# standalone build
if ( NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY )
    set ( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} )
endif ( )

# openssl subproject
add_subdirectory ( ${CMAKE_CURRENT_LIST_DIR}/resources/openssl_cmake ${CMAKE_CURRENT_BINARY_DIR}/openssl )
set_target_properties ( openssl PROPERTIES FOLDER "deps" )
add_custom_target ( ${PROJECT_NAME} DEPENDS openssl )

# pkg-config
set ( ${PROJECT_NAME}_MODULE openssl )
set ( ${PROJECT_NAME}_PC_CFLAGS "-I${CMAKE_CURRENT_BINARY_DIR}/openssl/include" )
# curl requires it
set ( ${PROJECT_NAME}_PC_CFLAGS "${${PROJECT_NAME}_PC_CFLAGS} -I${CMAKE_CURRENT_BINARY_DIR}/openssl/include/openssl" )
set ( ${PROJECT_NAME}_PC_LIBS "-L${CMAKE_LIBRARY_OUTPUT_DIRECTORY} -lopenssl" )
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/pkg-config.in 
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/openssl.pc )
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/pkg-config.in 
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/libssl.pc )
