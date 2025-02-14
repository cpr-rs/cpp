#
# newTarget(
#     name
#     source1 [source2 ...]
#
#     [BINARY] (ignores STATIC)
#     [STATIC]
#     [INCLUDE_INSTALL_DIR [/path/to/dir]] (default: '${PREFIX}/include')
#     [INSTALL_DIR [/path/to/dir]] (default: '${PREFIX}/bin' or '${PREFIX}/lib')
#     [LINK_LIBS [lib1 lib2 ...]]
# )
#
# `newTarget` is a function to create a new target
# and initialize it with the given sources and boilerplate
# configurations. It defaults to a shared library but can
# be set as a static library or binary.
#
# name
#   Name of target
#
# sources...
#   Sources for target
#
# LINK_LIBS libs...
#   Libraries to link with
#
function(newTarget targetName)
    cmake_parse_arguments(NT "STATIC;BINARY" "INCLUDE_INSTALL_DIR;INSTALL_DIR" "LINK_LIBS" ${ARGN})

    if(__NT_${targetName}_exists)
        message(FATAL_ERROR "newTarget: Target `${targetName}` already exists")
    endif()

    # get all the sources in the arguments
    set(NT_SOURCES ${NT_UNPARSED_ARGUMENTS})

    get_filename_component(base_dir ${CMAKE_CURRENT_SOURCE_DIR} NAME)

    file(GLOB_RECURSE NT_HEADERS
        ${PROJECT_SOURCE_DIR}/include/${base_dir}/*.h
        ${PROJECT_SOURCE_DIR}/include/${base_dir}/*.hpp
        ${PROJECT_SOURCE_DIR}/include/*.h
        ${PROJECT_SOURCE_DIR}/include/*.hpp)

    set(NT_ALL_SOURCES ${NT_SOURCES} ${NT_HEADERS})

    if(NT_BINARY)
        add_executable(${targetName} ${NT_ALL_SOURCES})
    elseif(NT_STATIC)
        add_library(${targetName} ${NT_ALL_SOURCES})
    else()
        add_library(${targetName} SHARED ${NT_ALL_SOURCES})
    endif()

    target_include_directories(
        ${targetName}
        PUBLIC ${PROJECT_SOURCE_DIR}/include/
        PUBLIC ${PROJECT_SOURCE_DIR}/include/${base_dir}
    )

    # Add vendor libraries
    foreach(lib ${USE_VENDOR_TARGETS})
        target_link_libraries(${targetName} PUBLIC ${lib})
    endforeach()

    if(NT_LINK_LIBS)
        target_link_libraries(${targetName} PUBLIC ${NT_LINK_LIBS})
    endif()

    if(NT_BINARY)
        set_target_properties(${targetName} PROPERTIES OUTPUT_NAME ${targetName})
        set_target_properties(${targetName} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
        set_target_properties(${targetName} PROPERTIES INSTALL_RPATH_USE_LINK_PATH ON)

        install(
            TARGETS ${targetName}
            RUNTIME
                DESTINATION ${FERN_PREFIX_DIR}/bin
                COMPONENT Binaries
            PUBLIC_HEADER
                DESTINATION include/${FT_INCLUDE_INSTALL_DIR}
                COMPONENT Headers
        )
    else()
        set_target_properties(${targetName} PROPERTIES OUTPUT_NAME ${targetName})
        set_target_properties(${targetName} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
        set_target_properties(${targetName} PROPERTIES INSTALL_RPATH_USE_LINK_PATH ON)
        install(
            TARGETS ${targetName}
            LIBRARY
                DESTINATION ${FERN_PREFIX_DIR}/lib
                COMPONENT Libraries
            PUBLIC_HEADER
                DESTINATION include/${FT_INCLUDE_INSTALL_DIR}
                COMPONENT Headers
            )
    endif()

    set(__NT_${targetName}_exists TRUE PARENT_SCOPE)
    set(__NT_${targetName}_base_dir ${base_dir} PARENT_SCOPE)
    set(__NT_${targetName}_link_libs ${NT_LINK_LIBS} PARENT_SCOPE)
    set(__NT_${targetName}_is_binary ${NT_BINARY} PARENT_SCOPE)
endfunction()

#
# newTest(
#     name
#
#     [AGAINST [target]]
#     [SOURCES [source1 source2 ...]]
# )
#
# `newTest` is a function to create a new test
# and initialize it with the given sources and boilerplate
# configurations. It can be set to test against multiple kinds
# of targets.
#
# name
#   Name of target
#
# AGAINST target
#   Target to test against
#
# SOURCES sources...
#   Sources for target
#
function(newTest testName)
    if (NOT ENABLE_TEST_TARGETS)
        message(STATUS "Tests are disabled")
        return()
    endif()

    cmake_parse_arguments(NT "AGAINST" "SOURCES" ${ARGN})

    if(NOT __NT_${NT_AGAINST}_exists)
        message(FATAL_ERROR "newTest: Target `${NT_AGAINST}` does not exist")
    endif()

    if(__NT_TEST_${testName}_exists)
        message(FATAL_ERROR "newTest: Test `${testName}` already exists")
    endif()

    add_executable(${testName} ${NT_SOURCES})

    target_include_directories(
        ${testName}
        PRIVATE ${PROJECT_SOURCE_DIR}/include/
        PRIVATE ${PROJECT_SOURCE_DIR}/include/${__NT_${NT_AGAINST}_base_dir}
    )

    # Add vendor libraries
    foreach(lib ${USE_TEST_VENDOR_TARGETS})
        target_link_libraries(${testName} PRIVATE ${lib})
    endforeach()

    if(NOT __FT_${NT_AGAINST}_is_binary)
        target_link_libraries(${testName} PRIVATE ${NT_AGAINST})
    endif()

    set_target_properties(
        ${testName}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
    )

    include(CTest)
    include(Catch)
    catch_discover_tests(
        ${testName}
        OUTPUT_DIR "${PROJECT_BINARY_DIR}/test"
    )
endfunction()
