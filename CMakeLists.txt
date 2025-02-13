cmake_minimum_required(VERSION 3.19.6)

project({{ project.name }} C CXX)

# Convert relative paths to absolute paths for subdirectory `target_sources`
if(POLICY CMP0076)
    cmake_policy(SET CMP0076 NEW)
endif()

# Don't clobber existing variables when evaluating `option()` declarations
if(POLICY CMP0077)
    cmake_policy(SET CMP0077 NEW)
endif()

# Clobber existing timestamps of extracted files when using `ExternalProject_Add()`
if(POLICY CMP0086)
    cmake_policy(SET CMP0086 NEW)
endif()

# Allow for forced colored output
option(FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." ON)
if(${FORCE_COLORED_OUTPUT})
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        add_compile_options(-fdiagnostics-color=always)
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        add_compile_options(-fcolor-diagnostics)
    endif()
endif()

# Prefix directory
if(DEFINED ENV{PREFIX_DIR} AND NOT "$ENV{PREFIX_DIR}" STREQUAL "")
    set(FERN_PREFIX_DIR "$ENV{PREFIX_DIR}")
else()
    set(FERN_PREFIX_DIR "$ENV{HOME}/.{{ project.dir | lower }}")
endif()
set(CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX};${PROJECT_BINARY_DIR}")
add_definitions(-DINSTALL_PREFIX=${CMAKE_INSTALL_PREFIX})
message(STATUS "Using PREFIX = ${CMAKE_INSTALL_PREFIX}")

# Module path setup
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${PROJECT_SOURCE_DIR}/cmake")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${PROJECT_SOURCE_DIR}")

# macOS `rpath` fix
set(ORIGIN "$ORIGIN")
if(APPLE)
    set(ORIGIN "@loader_path")
endif()
set(CMAKE_INSTALL_RPATH "${ORIGIN}/../lib/{{ project.dir.name }};${ORIGIN}/../lib;${ORIGIN}/.")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR TRUE)
set(CMAKE_MACOSX_RPATH TRUE)

# C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build type
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
    message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}' as none was specified.")
endif()

# Build definitions
if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions(-DDEBUG)
    message(STATUS "Debug build")
endif()

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wcast-align -Wfloat-equal -Wsign-promo")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wcast-align -Wfloat-equal -Wsign-promo")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2")
endif()

option(ADDRESS_SANITIZER "Enable Address Sanitizer" OFF)

if(ADDRESS_SANITIZER)
    message(STATUS "Address Sanitizer enabled")
    add_definitions(-DASAN_ENABLED)
    add_compile_options(-fsanitize=address)
    add_link_options(-fsanitize=address)
endif()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_TYPE_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# ccache support
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    message(STATUS "Using ccache")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK "${CCACHE_PROGRAM}")
    message(STATUS "Using ccache: ${CCACHE_PROGRAM}")
endif()

# Config
include(ProjectConfig)

# Dependencies
include(Dependencies)

# Testing
list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
enable_testing()

# Install includes
install(DIRECTORY "${PROJECT_SOURCE_DIR}/include/"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/include/{{ project.name | lower }}")

# Target creation utilities
include(TargetMacros)

# Add source files
add_subdirectory(src)
