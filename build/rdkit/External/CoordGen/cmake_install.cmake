# Install script for directory: /home/nick/rdkit-ocaml/vendor/rdkit/External/CoordGen

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/nick/rdkit-ocaml/install/rdkit")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/nix/store/hb2bs5fg5wkm04x565737qd5nh2hy5nk-gcc-wrapper-15.2.0/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "")
    endif()
  endforeach()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre;/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so.1"
    )
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/nix/store/hb2bs5fg5wkm04x565737qd5nh2hy5nk-gcc-wrapper-15.2.0/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/maeparser.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser_static.a")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE STATIC_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/libRDKitmaeparser_static.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/maeparser_static.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "")
    endif()
  endforeach()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre;/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so.1"
    )
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/nix/store/hb2bs5fg5wkm04x565737qd5nh2hy5nk-gcc-wrapper-15.2.0/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitmaeparser.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitmaeparser.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/maeparser.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "")
    endif()
  endforeach()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre;/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so.1"
    )
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/nix/store/hb2bs5fg5wkm04x565737qd5nh2hy5nk-gcc-wrapper-15.2.0/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/coordgen.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen_static.a")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE STATIC_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/libRDKitcoordgen_static.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/coordgen_static.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "")
    endif()
  endforeach()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre;/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
    "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so.1"
    )
  foreach(file
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1.2026.09.1pre"
      "$ENV{DESTDIR}/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so.1"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/nix/store/hb2bs5fg5wkm04x565737qd5nh2hy5nk-gcc-wrapper-15.2.0/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/nick/rdkit-ocaml/vendor/rdkit/lib/libRDKitcoordgen.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/nick/rdkit-ocaml/vendor/rdkit/lib" TYPE SHARED_LIBRARY FILES "/home/nick/rdkit-ocaml/build/rdkit/lib/libRDKitcoordgen.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/CMakeFiles/coordgen.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/nick/rdkit-ocaml/build/rdkit/External/CoordGen/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
