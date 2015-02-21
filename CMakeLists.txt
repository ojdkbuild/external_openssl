

cmake_minimum_required ( VERSION 2.8.12 )

# toolchain setup
set ( STATICLIB_TOOLCHAIN linux_amd64_clang CACHE STRING "toolchain triplet" )
set ( CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/toolchains/${STATICLIB_TOOLCHAIN}.cmake CACHE INTERNAL "" )

# project setup
project ( external_openssl CXX C )
# common include
include ( ${CMAKE_CURRENT_LIST_DIR}/cmake/CMakeLists_common.cmake )

# library config
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/Makefile-${STATICLIB_TOOLCHAIN}
        ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})
add_custom_target( ${PROJECT_NAME}_build
        COMMAND ${CMAKE_MAKE_PROGRAM} -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile-${STATICLIB_TOOLCHAIN})
add_library( ssl STATIC IMPORTED GLOBAL )
add_library( crypto STATIC IMPORTED GLOBAL )
if ( STATICLIB_TOOLCHAIN MATCHES "windows_(amd64|i386)_msvc" )
    set_target_properties( ssl PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/openssl/out32/ssleay32${CMAKE_STATIC_LIBRARY_SUFFIX} )
    set_target_properties( crypto PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/openssl/out32/libeay32${CMAKE_STATIC_LIBRARY_SUFFIX} )
    set ( ${PROJECT_NAME}_INCLUDES ${CMAKE_CURRENT_BINARY_DIR}/openssl/inc32 )
else ( )
    set_target_properties( ssl PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/openssl/libssl${CMAKE_STATIC_LIBRARY_SUFFIX} )
    set_target_properties( crypto PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/openssl/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} )
    set ( ${PROJECT_NAME}_INCLUDES ${CMAKE_CURRENT_BINARY_DIR}/openssl/include )
endif ( )

# tests
enable_testing ( )
set ( ${PROJECT_NAME}_TEST_INCLUDES ${${PROJECT_NAME}_INCLUDES} )
add_executable ( openssl_test ${CMAKE_CURRENT_LIST_DIR}/test/openssl_test.cpp )
target_include_directories ( openssl_test BEFORE PRIVATE ${${PROJECT_NAME}_INCLUDES} )
target_link_libraries ( openssl_test ssl crypto )
add_dependencies( openssl_test ${PROJECT_NAME}_build )
add_test ( openssl_test ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/openssl_test )

# headers export
set ( ${PROJECT_NAME}_INCLUDES ${${PROJECT_NAME}_INCLUDES} CACHE INTERNAL "" )
