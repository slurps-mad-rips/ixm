include_guard(GLOBAL)

function (dict action target)
  if (action STREQUAL CREATE)
    ixm_dict_create(${target})
  elseif (action STREQUAL APPEND)
    ixm_dict_append(${target} ${ARGN})
  elseif (action STREQUAL ASSIGN)
    ixm_dict_assign(${target} ${ARGN})
  elseif (action STREQUAL REMOVE)
    ixm_dict_remove(${target} ${ARGN})
  elseif (action STREQUAL COPY)
    ixm_dict_copy(${target} ${ARGN})
  elseif (action STREQUAL GET)
    ixm_dict_get(${target} ${ARGN})
  elseif (action STREQUAL HAS)
    ixm_dict_has(${target} ${ARGN})
  else()
    error("dict(${action}) is an invalid operation")
  endif()
endfunction()

function (ixm_dict_create target)
  if (NOT TARGET ${target})
    add_library(${target} INTERFACE IMPORTED)
  endif()
endfunction()

function (ixm_dict_append target key)
  if (NOT ARGN)
    error("dict(APPEND) requires at least one value to be appended")
  endif()
  ixm_dict_create(${target})
  set_property(TARGET ${target} APPEND PROPERTY INTERFACE_${key} ${ARGN})
endfunction ()

function (ixm_dict_assign target key)
  if (NOT ARGN)
    error("dict(ASSIGN) requires at least one value to be assigned")
  endif()
  ixm_dict_create(${target})
  set_property(TARGET ${target} PROPERTY INTERFACE_${key} ${ARGN})
  debug(target key ARGN)
endfunction()

function (ixm_dict_remove target)
  if (NOT ARGN)
    error("dict(REMVOE) requires at least one key to be removed")
  endif()
  if (NOT TARGET ${target})
    return()
  endif()
  foreach (key IN LISTS ARGN)
    set_property(TARGET ${target} PROPERTY INTERFACE_${key})
  endforeach()
endfunction()

macro (ixm_dict_has target key var)
  get_property(out TARGET ${target} PROPERTY INTERFACE_${key} SET)
  set(${var} ${out} PARENT_SCOPE)
endmacro()

macro (ixm_dict_get target key var)
  if (NOT TARGET ${target})
    return()
  endif()
  get_property(out TARGET ${target} PROPERTY INTERFACE_${key})
  set(${var} ${out} PARENT_SCOPE)
endmacro()