# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-src")
  file(MAKE_DIRECTORY "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-src")
endif()
file(MAKE_DIRECTORY
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-build"
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix"
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/tmp"
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/src/better_enums-populate-stamp"
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/src"
  "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/src/better_enums-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/src/better_enums-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/nick/rdkit-ocaml/build/rdkit/_deps/better_enums-subbuild/better_enums-populate-prefix/src/better_enums-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
