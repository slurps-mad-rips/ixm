include_guard(GLOBAL)

#[[ SYNOPSIS

This module holds functions and macros related to augmenting CMake. Most, if
not all of the other modules include this one.

]]

include(PushState)

push_module_path(IXM)
include(SourceDepends)
include(ParentScope)
include(Standalone)
include(AddPackage)
include(Algorithm)
include(ArgParse)
include(Override)
include(Print)
include(Dump)
include(Fetch)
pop_module_path()
