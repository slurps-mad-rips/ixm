include_guard(GLOBAL)

include(ParentScope)
include(AddPackage)
include(Fetch)
include(Print)

include(AcquireDependencies/Args)
include(AcquireDependencies/Git)

# Settings specific to this module
# These can be overridden as cache variables
set(IXM_EXTERN_DIR extern)
set(IXM_HEADER_DIR header)

#[[ Acquire a package from github. This is a macro around githttps ]]
macro (github pkg)
  githttps(${pkg} DOMAIN "https://github.com" ${ARGN})
endmacro()

#[[ Acquire a package from gitlab. This is a macro around githttps ]]
macro (gitlab pkg)
  githttps(${pkg} DOMAIN "https://gitlab.com" ${ARGN})
endmacro()

#[[ Acquire a package from bitbucket. This is a macro around githttps ]]
macro (bitbucket pkg)
  githttps(${pkg} DOMAIN "https://bitbucket.com" ${ARGN})
endmacro ()

#[[ Use the https:// protocol to acquire a package via git ]]
function (githttps pkg)
  __git_args(${ARGN})
  __argparse(${ARGN})
  __verify_args()

  __git_name(${pkg})
  __set_alias(${name})
  __set_options()
  __set_install()
  __push_quiet()
  # This is the one line that differs between githttps and gitssh
  info("Acquiring - ${pkg}")
  __git_acquire(${alias} ${ARG_DOMAIN}/${repository} ${tag})
  # TODO: Don't *always* add_package. Only if there's a CMakeLists.txt in the
  # ${alias}_SOURCE_DIR directory. Otherwise, additional steps are needed.
  if (EXISTS "${${alias}_SOURCE_DIR}/CMakeLists.txt")
    info("Adding - ${alias} from ${pkg}")
    add_package(${${alias}_SOURCE_DIR} ${${alias}_SOURCE_DIR} ${ADD_PACKAGE_ARGS})
  else()
    error("Not Yet Implemented")
  endif()
  __pop_quiet()
  # XXX: We still do not support multiple targets at this time...
  __set_target(${name})
  if (NOT TARGET ${alias}::${alias})
    add_library(${alias}::${alias} ALIAS ${target})
  endif()
  parent_scope(${alias}_SOURCE_DIR ${alias}_BINARY_DIR)
endfunction()

#[[ Use the ssh:// protocol to acquire a package via git ]]
function (gitssh pkg)
  __git_args(${ARGN})
  __argparse(${ARGN})
endfunction()

# Useful for libraries like nlohmann::json
function (archive pkg)
  __common_args()
  __argparse(${ARGN})
  __verify_args()
  get_filename_component(name ${pkg} NAME_WE)
  __set_alias(${name})
  __set_options()
  __set_install()
  __push_quiet()
  info("Acquiring - ${pkg}")
  fetch(URL ${pkg})
  if (EXISTS "${${alias}_SOURCE_DIR}/CMakeLists.txt")
    info("Adding - ${alias} from ${pkg}")
    add_package(${${alias_SOURCE_DIR} ${${alias_SOURCE_DIR} ${ADD_PACKAGE_ARGS})
  else()
    error("Not Yet Implemented")
  endif()
  __pop_quiet()
  __set_target(${name})
  if (NOT TARGET ${alias}::${alias})
    add_library(${alias}::${alias} ALIAS ${target})
  endif()
  parent_scope(${alias}_SOURCE_DIR ${alias}_BINARY_DIR)
endfunction()

# Useful for libraries like Catch2
function (header url)
  __minimal_args()
  __argparse(${ARGN})
  #TODO: Investigate if we need a different approach for getting the filename
  #      and the URL
  get_filename_component(name ${url} NAME_WE)
  get_filename_component(file ${url} NAME)
  set(source_dir ${PROJECT_BINARY_DIR}/${IXM_HEADER_DIR}/${name}-src)
  set(binary_dir ${PROJECT_BINARY_DIR}/${IXM_HEADER_DIR}/${name}-build)

  if (NOT EXISTS ${source_dir}/${file})
    file(DOWNLOAD ${url} ${source_dir}/${file})
  endif()

  __set_alias(${name})
  add_library(${name} INTERFACE)
  add_library(${alias}::${alias} ALIAS ${name})
  target_include_directories(${name} INTERFACE ${source_dir})

  set(${alias}_SOURCE_DIR ${source_dir})
  set(${alias}_BINARY_DIR ${binary_dir})
  parent_scope(${alias}_SOURCE_DIR ${alias}_BINARY_DIR)
endfunction()

function (extern name)
  __minimal_args()
  __common_args()
  __argparse(${ARGN})
  __verify_args()

  set(source_dir ${PROJECT_SOURCE_DIR}/${IXM_EXTERN_DIR}/${name})
  set(binary_dir ${PROJECT_BINARY_DIR}/${IXM_EXTERN_DIR}/${name})

  __set_alias(${name})
  __set_options()
  __set_install()
  __push_quiet()

  add_package(${source_dir} ${binary_dir} ${ADD_PACKAGE_ARGS})

  __pop_quiet()
  __set_target(${name})
  
  add_library(${alias}::${alias} ALIAS ${target})

  set(${alias}_SOURCE_DIR ${source_dir})
  set(${alias}_BINARY_DIR ${binary_dir})
  parent_scope(${alias}_SOURCE_DIR ${alias}_BINARY_DIR})
endfunction()