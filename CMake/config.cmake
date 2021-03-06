####################################################################################
#                                                                                  #
#  Copyright (c) 2014, 2015 - 2017 Axel Menzel <info@rttr.org>                     #
#                                                                                  #
#  This file is part of RTTR (Run Time Type Reflection)                            #
#  License: MIT License                                                            #
#                                                                                  #
#  Permission is hereby granted, free of charge, to any person obtaining           #
#  a copy of this software and associated documentation files (the "Software"),    #
#  to deal in the Software without restriction, including without limitation       #
#  the rights to use, copy, modify, merge, publish, distribute, sublicense,        #
#  and/or sell copies of the Software, and to permit persons to whom the           #
#  Software is furnished to do so, subject to the following conditions:            #
#                                                                                  #
#  The above copyright notice and this permission notice shall be included in      #
#  all copies or substantial portions of the Software.                             #
#                                                                                  #
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      #
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        #
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     #
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          #
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   #
#  SOFTWARE.                                                                       #
#                                                                                  #
####################################################################################

# setup version numbers
set(RTTR_VERSION_MAJOR 0)
set(RTTR_VERSION_MINOR 9)
set(RTTR_VERSION_PATCH 6)
set(RTTR_VERSION ${RTTR_VERSION_MAJOR}.${RTTR_VERSION_MINOR}.${RTTR_VERSION_PATCH})
set(RTTR_VERSION_STR "${RTTR_VERSION_MAJOR}.${RTTR_VERSION_MINOR}.${RTTR_VERSION_PATCH}")
math(EXPR RTTR_VERSION_CALC "${RTTR_VERSION_MAJOR}*1000 + ${RTTR_VERSION_MINOR}*100 + ${RTTR_VERSION_PATCH}")
set(RTTR_PRODUCT_NAME "RTTR")
message("Project version: ${RTTR_VERSION_STR}")

# files
set(README_FILE "${CMAKE_SOURCE_DIR}/README.md")
set(LICENSE_FILE "${CMAKE_SOURCE_DIR}/LICENSE.txt")

# dirs where the binaries should be placed, installed
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")
set(CMAKE_EXECUTABLE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")

# here we specify the installation directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/install" CACHE PATH  "RTTR install prefix" FORCE)
endif()

# in order to group in visual studio the targets into solution filters
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#3rd part dependencies dirs
set(RTTR_3RD_PARTY_DIR "${CMAKE_SOURCE_DIR}/3rd_party")

getNameOfDir(CMAKE_LIBRARY_OUTPUT_DIRECTORY RTTR_TARGET_BIN_DIR)
is_vs_based_build(VS_BUILD)

# set all install directories for the targets
if(UNIX)
  include(GNUInstallDirs)
  set(RTTR_RUNTIME_INSTALL_DIR "${CMAKE_INSTALL_BINDIR}") 
  set(RTTR_LIBRARY_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}")
  set(RTTR_ARCHIVE_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}")
  set(RTTR_FRAMEWORK_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}")

  set(RTTR_INSTALL_FULL_LIBDIR "${CMAKE_INSTALL_FULL_LIBDIR}")

  set(RTTR_CMAKE_CONFIG_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/rttr/cmake")
  set(RTTR_ADDITIONAL_FILES_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/rttr")

else(WINDOWS)
  set(RTTR_RUNTIME_INSTALL_DIR "bin") 
  set(RTTR_LIBRARY_INSTALL_DIR "bin")
  set(RTTR_ARCHIVE_INSTALL_DIR "lib")
  set(RTTR_FRAMEWORK_INSTALL_DIR "bin")

  set(RTTR_CMAKE_CONFIG_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/cmake")
  set(RTTR_ADDITIONAL_FILES_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}")
endif()

set(CMAKE_DEBUG_POSTFIX "_d")

# set the rpath for executables
set(CMAKE_SKIP_BUILD_RPATH OFF)            # use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)    # when building, don't use the install RPATH already (but later on when installing)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF) # NO automatic rpath for INSTALL
if(APPLE)
  set(MACOSX_RPATH ON CACHE STRING "Set this to off if you dont want @rpath in install names") # uses a install name @rpath/... for libraries
  set(RTTR_EXECUTABLE_INSTALL_RPATH "${RTTR_INSTALL_FULL_LIBDIR};@executable_path")
  # the executable is relocatable, since the library builds with and install name "@rpath/librttr_core.0.9.6.dylib"
  # the executable links 
elseif(UNIX)
  set(RTTR_EXECUTABLE_INSTALL_RPATH "${RTTR_INSTALL_FULL_LIBDIR};$ORIGIN")
elseif(WINDOWS)
  # no such thin as rpath exists,
  set(RTTR_EXECUTABLE_INSTALL_RPATH ${RTTR_INSTALL_BINDIR}) # default, has no effect
endif()



# detect architecture
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(RTTR_NATIVE_ARCH 64)
    message(STATUS "Architecture: x64")
else()
    set(RTTR_NATIVE_ARCH 32)
    message(STATUS "Architecture: x86")
endif()

enable_rtti(BUILD_WITH_RTTI)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -Wall -Werror")
    message(STATUS "added flag -std=c++0x, -Wall, -Werror to g++")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror")
    message(STATUS "added flag -std=c++11, -Wall, -Werror to g++")
  endif()
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.0.0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden")
  endif()

  if(MINGW)
    set(GNU_STATIC_LINKER_FLAGS "-static-libgcc -static-libstdc++ -static")
  else()
    set(GNU_STATIC_LINKER_FLAGS "-static-libgcc -static-libstdc++")
  endif()
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror")
  message(STATUS "added flag -std=c++11, -Wall, -Werror to g++")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden")
  message(WARNING "clang support is currently experimental")
  
  set(CLANG_STATIC_LINKER_FLAGS "-stdlib=libc++ -static-libstdc++")
endif()

if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj /WX")
    replaceCompilerOption("/W3" "/W4")
    message(STATUS "added flag /bigobj, /W4 to MSVC compiler")
    message(STATUS "Treats all compiler warnings as errors.")
endif()

# RelWithDepInfo should have the same option like the Release build
# but of course with Debug informations
if(MSVC)
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELEASE}")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /Zi /DEBUG")
elseif(CMAKE_COMPILER_IS_GNUCXX )
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELEASE}")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELEASE}")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g")
else()
  message(WARNING "Please adjust CMAKE_CXX_FLAGS_RELWITHDEBINFO flags for this compiler!")
endif()

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/CMake/rttr-config-version.cmake"
  VERSION ${RTTR_VERSION_STR}
  COMPATIBILITY AnyNewerVersion
)

if (BUILD_INSTALLER)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/CMake/rttr-config-version.cmake"
             DESTINATION ${RTTR_CMAKE_CONFIG_INSTALL_DIR}
             COMPONENT Devel)

    install(FILES "${LICENSE_FILE}" "${README_FILE}"
             DESTINATION ${RTTR_ADDITIONAL_FILES_INSTALL_DIR}
             PERMISSIONS OWNER_READ)
endif()
