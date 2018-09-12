
include(CMakeParseArguments)

macro(add_polly_library name)
  cmake_parse_arguments(ARG "" "" "" ${ARGN})
  set(srcs ${ARG_UNPARSED_ARGUMENTS})
  if(MSVC_IDE OR XCODE)
    file( GLOB_RECURSE headers *.h *.td *.def)
    set(srcs ${srcs} ${headers})
    string( REGEX MATCHALL "/[^/]+" split_path ${CMAKE_CURRENT_SOURCE_DIR})
    list( GET split_path -1 dir)
    file( GLOB_RECURSE headers
      ../../include/polly${dir}/*.h)
    set(srcs ${srcs} ${headers})
  endif(MSVC_IDE OR XCODE)
  if (MODULE)
    set(libkind MODULE)
  elseif (SHARED_LIBRARY)
    set(libkind SHARED)
  else()
    set(libkind STATIC)
  endif()
  add_llvm_library( ${name}
    ${srcs}

    ${libkind}

    LINK_LIBS ${POLLY_LINK_LIBS}
    )
  set_target_properties(${name} PROPERTIES FOLDER "Polly")
endmacro(add_polly_library)

macro(add_polly_loadable_module name)
  set(srcs ${ARGN})
  # klduge: pass different values for MODULE with multiple targets in same dir
  # this allows building shared-lib and module in same dir
  # there must be a cleaner way to achieve this....
  if (MODULE)
  else()
    set(GLOBAL_NOT_MODULE TRUE)
  endif()
  set(MODULE TRUE)
  add_polly_library(${name} ${srcs})
  if (GLOBAL_NOT_MODULE)
    unset (MODULE)
  endif()
  if (APPLE)
    # Darwin-specific linker flags for loadable modules.
    set_target_properties(${name} PROPERTIES
      LINK_FLAGS "-Wl,-flat_namespace -Wl,-undefined -Wl,suppress")
  endif()
endmacro(add_polly_loadable_module)

# Use C99-compatible compile mode for all C source files of a target.
function(target_enable_c99 _target)
  if(CMAKE_VERSION VERSION_GREATER "3.1")
    set_target_properties("${_target}" PROPERTIES C_STANDARD 99)
  elseif(CMAKE_COMPILER_IS_GNUCC)
    get_target_property(_sources "${_target}" SOURCES)
    foreach(_file IN LISTS _sources)
      get_source_file_property(_lang "${_file}" LANGUAGE)
      if(_lang STREQUAL "C")
        set_source_files_properties(${_file} COMPILE_FLAGS "-std=gnu99")
      endif()
    endforeach()
  endif()
endfunction()
