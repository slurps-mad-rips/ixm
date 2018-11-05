include_guard(GLOBAL)

function (check_component package component)
  set(found ON)
  foreach (item IN LISTS ${ARGN})
    if (NOT item)
      set(found OFF)
      break()
    endif()
  endforeach ()
  parent_scope(${package}_${component}_FOUND)
endfunction ()

function (check_library_component package component)
  set(combined ${package}_${component})
  set(library ${combined}_LIBRARY)
  check_component(${package} ${component} ${library})
  parent_scope(${combined}_FOUND)
endfunction()

function (check_program_component package component)
  set(combined ${package}_${component})
  set(executable ${combined}_EXECUTABLE)
  check_component(${package} ${component} ${executable})
  parent_scope(${combined}_FOUND)
endfunction()
