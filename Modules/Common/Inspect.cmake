include_guard(GLOBAL)

#[[ Prints the current value of the given variables ]]
function (inspect)
  get_property(prefix GLOBAL PROPERTY ixm::inspect::prefix)
  foreach (var IN LISTS ARGN)
    set(CMAKE_MESSAGE_INDENT "${prefix}${var}: ")
    if (DEFINED ${var})
      list(LENGTH ${var} length)
      if (length GREATER 1)
        string(JOIN " " ${var} ${${var}})
      endif()
      message("${${var}}")
    else()
      message("$<UNDEFINED>")
    endif()
  endforeach()
endfunction()
