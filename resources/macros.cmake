# Copyright 2016, alex at staticlibs.net
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

# applies git patch to the specified project
macro ( ${PROJECT_NAME}_apply_git_patch _gitdir_path _patch_path )
    message ( STATUS "Applying patch: [${_patch_path}] to [${_gitdir_path}]" )
    execute_process ( COMMAND git reset --hard HEAD
            WORKING_DIRECTORY ${_gitdir_path} )
    execute_process ( COMMAND git apply ${_patch_path}
            WORKING_DIRECTORY ${_gitdir_path} )
endmacro ( )

# converts list to space-separated string with a prefix to each element
macro ( ${PROJECT_NAME}_list_to_string _out_var_name _prefix _list_var_name )
    set ( ${_out_var_name} "" )
    foreach ( _el ${${_list_var_name}} )
        set ( ${_out_var_name} "${${_out_var_name}}${_prefix}${_el} " )
    endforeach ( )
endmacro ( )

# asm compilation
macro ( ${PROJECT_NAME}_asm_compile _path )
    string ( REGEX REPLACE "/[^/]*$" "/" _dir ${_path} )
    string ( REGEX REPLACE "^.*/" "" _name ${_path} )
    string ( REGEX REPLACE "\\..*$" "" _name ${_name} )
    if ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_i386_msvc" )
        add_custom_command ( OUTPUT ${_name}.obj
                COMMAND perl ${_dir}/${_name}.pl ${${PROJECT_NAME}_ASM_PERL_OPTIONS} > ${_name}.asm
                COMMAND nasm ${${PROJECT_NAME}_ASM_NASM_OPTIONS} -o ${_name}.obj ${_name}.asm
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.asm PROPERTIES GENERATED 1 )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.obj )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "windows_amd64_msvc" )
        add_custom_command ( OUTPUT ${_name}.obj
                COMMAND set ASM=nasm -f win64 -DNEAR -Ox -g
                COMMAND perl ${_dir}/${_name}.pl ${_name}.asm
                COMMAND nasm ${${PROJECT_NAME}_ASM_NASM_OPTIONS} -o ${_name}.obj ${_name}.asm
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.asm PROPERTIES GENERATED 1 )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.obj )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_gcc" )
        add_custom_command ( OUTPUT ${_name}.s
                COMMAND perl ${_dir}/${_name}.pl elf > ${_name}.s
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES GENERATED 1 )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES LANGUAGE C )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.s )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "android_[^_]+_gcc" )
        add_custom_command ( OUTPUT ${_name}.S
                COMMAND perl ${_dir}/${_name}.pl void ${_name}.S
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.S PROPERTIES GENERATED 1 )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.S PROPERTIES LANGUAGE C )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.S )
    elseif ( ${PROJECT_NAME}_TOOLCHAIN MATCHES "macosx_amd64_clang" )
        add_custom_command ( OUTPUT ${_name}.s
                COMMAND perl ${_dir}/${_name}.pl macosx > ${_name}.s
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR} )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES GENERATED 1 )
        set_source_files_properties ( ${PROJECT_BINARY_DIR}/${_name}.s PROPERTIES LANGUAGE C )
        set ( ${PROJECT_NAME}_ASMOBJ ${${PROJECT_NAME}_ASMOBJ} ${PROJECT_BINARY_DIR}/${_name}.s )
    else ( )
        message ( FATAL_ERROR "Unsupported toolchain for ASM: [${${PROJECT_NAME}_TOOLCHAIN}]" )
    endif ( )

endmacro ( )

