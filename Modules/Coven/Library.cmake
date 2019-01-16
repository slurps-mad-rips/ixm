include_guard(GLOBAL)

function (ixm_coven_add_interface)
  add_library(${PROJECT_NAME} INTERFACE)
  target_include_directories(${PROJECT_NAME}
    INTERFACE
      $<BUILD_INTERFACE:${PROJECT_SOURCE}/include>
      $<INSTALL_INTERFACE:include>)
endfunction()

function (ixm_coven_add_library)
  foreach (ext IN LISTS IXM_SOURCE_EXTENSIONS)
    file(GLOB files
      LIST_DIRECTORIES OFF
      CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/src/*.${ext}")
    list(FILTER files EXCLUDE REGEX ".*/main[.]${ext}")
    list(APPEND sources ${files})
  endforeach()
  #  if (NOT sources AND NOT directories)
  #    return()
  #  endif()
  add_library(${PROJECT_NAME})
  target_include_directories(${PROJECT_NAME}
    PUBLIC
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>
    PRIVATE
      "${PROJECT_SOURCE_DIR}/src")
  target_sources(${PROJECT_NAME} PRIVATE ${sources})
endfunction()

import(IXM::Generators::UnityBuild)

function (ixm_coven_add_legacy_module directory)
  file(RELATIVE_PATH path "${PROJECT_SOURCE_DIR}/src" "${directory}")
  string(REPLACE "/" "-" target "${PROJECT_NAME}/${path}")
  string(REPLACE "/" "::" alias "${PROJECT_NAME}/${path}")
  foreach (ext IN LISTS IXM_SOURCE_EXTENSIONS)
    file(GLOB files
      LIST_DIRECTORIES OFF
      CONFIGURE_DEPENDS "${directory}/*.${ext}")
    list(APPEND sources ${files})
  endforeach()
  if (NOT sources)
    return()
  endif()
  ixm_generate_unity_build_file(${alias})
  add_submodule(${alias} SPLAYED ${sources})
endfunction()

function (ixm_coven_create_primary_modules)
  file(GLOB_RECURSE entries LIST_DIRECTORIES ON "${PROJECT_SOURCE_DIR}/src/*")
  string(JOIN "|" regex ${IXM_SOURCE_EXTENSIONS})
  # Early file removal
  list(FILTER entries EXCLUDE REGEX "${PROJECT_SOURCE_DIR}/src/bin")
  list(FILTER entries EXCLUDE REGEX ".*[.](${regex})")
  foreach (entry IN LISTS entries)
    if (IS_DIRECTORY ${entry})
      list(APPEND directories ${entry})
    endif()
  endforeach()
  foreach (directory IN LISTS directories)
    ixm_coven_add_legacy_module(${directory})
  endforeach()
endfunction()

function (ixm_coven_create_primary_library)
  if (EXISTS "${PROJECT_SOURCE_DIR}/src")
    ixm_coven_add_library()
  endif()
  if (NOT TARGET ${PROJECT_NAME})
    ixm_coven_add_interface()
  endif()
  add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
endfunction()
