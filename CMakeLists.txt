######################################################################
# GameSyn Build System
# Welcome to the CMake build system for GameSyn.
######################################################################

cmake_minimum_required(VERSION 2.6)
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE)
cmake_policy(SET CMP0003 NEW)

project(GameSyn)

# Include necessary submodules
set(CMAKE_MODULE_PATH
  "${GameSyn_SOURCE_DIR}/cmake"
  "${GameSyn_SOURCE_DIR}/cmake/utils"
  "${GameSyn_SOURCE_DIR}/cmake/packages"
)
include(CMakeDependentOption)
include(MacroLogFeature)
include(GameSynConfigTargets)
include(PreprocessorUtils)
set(GameSyn_WORK_DIR ${GameSyn_BINARY_DIR})


#####################################################################
# Set up the basic build environment
#####################################################################

if (CMAKE_BUILD_TYPE STREQUAL "")
  # CMake defaults to leaving CMAKE_BUILD_TYPE empty. This screws up
  # differentiation between debug and release builds.
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Choose the type of build, options are: None (CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif ()
set(CONFIGURATION ${CMAKE_BUILD_TYPE})

if (NOT APPLE)
  # Create debug libraries with _d postfix
  set(CMAKE_DEBUG_POSTFIX "_d")
endif ()

# Set compiler specific build flags
if (CMAKE_COMPILER_IS_GNUCXX)
  add_definitions(-msse)
endif ()
if (MSVC)
  add_definitions(/fp:fast)
endif ()

if (CMAKE_COMPILER_IS_GNUCXX)
  # Test for GCC visibility
  include(CheckCXXCompilerFlag)
  check_cxx_compiler_flag(-fvisibility=hidden GameSyn_GCC_VISIBILITY)
  if (GameSyn_GCC_VISIBILITY)
    # determine gcc version
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
      OUTPUT_VARIABLE GameSyn_GCC_VERSION)
    message(STATUS "Detected g++ ${GameSyn_GCC_VERSION}")
    message(STATUS "Enabling GCC visibility flags")
    set(GameSyn_GCC_VISIBILITY_FLAGS "-DGameSyn_GCC_VISIBILITY -fvisibility=hidden")

    # check if we can safely add -fvisibility-inlines-hidden
    string(TOLOWER "${CMAKE_BUILD_TYPE}" GameSyn_BUILD_TYPE)
    if (GameSyn_BUILD_TYPE STREQUAL "debug" AND GameSyn_GCC_VERSION VERSION_LESS "4.2")
      message(STATUS "Skipping -fvisibility-inlines-hidden due to possible bug in g++ < 4.2")
    else ()
      set(GameSyn_GCC_VISIBILITY_FLAGS "${GameSyn_GCC_VISIBILITY_FLAGS} -fvisibility-inlines-hidden")
    endif ()
  endif (GameSyn_GCC_VISIBILITY)
endif (CMAKE_COMPILER_IS_GNUCXX)

# determine system endianess
include(TestBigEndian)
test_big_endian(GameSyn_TEST_BIG_ENDIAN)

# Add GameSyn engine include path
include_directories("${GameSyn_SOURCE_DIR}/deps/curl")
include_directories("${GameSyn_SOURCE_DIR}/api")

include(Dependencies)
# definitions for samples
set(GameSyn_LIBRARIES LibGameSyn)

# Specify build paths
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${GameSyn_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${GameSyn_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${GameSyn_BINARY_DIR}/bin")
if (WIN32 OR APPLE)
  if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # We don't want to install in default system location, install is really for the SDK, so call it that
    SET(CMAKE_INSTALL_PREFIX
	  "${GameSyn_BINARY_DIR}/sdk" CACHE PATH "GameSyn install prefix" FORCE
    )
  endif (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
endif(WIN32 OR APPLE)



######################################################################
# Provide user options to customise the build process
######################################################################

# Customise what to build
option(GameSyn_STATIC "Static build" TRUE)
option(GameSyn_FULL_RPATH "Build executables with the full required RPATH to run from their install location." FALSE)
option(GameSyn_STANDALONE_BUILD "Generate build files that do not reference CMake (e.g. source distro)" FALSE)
option(GameSyn_BUILD_SAMPLES "Build GameSyn Samples" TRUE)


###################################################################
# configure global build settings based on selected build options
###################################################################
include(ConfigureBuild)


##################################################################
# Now setup targets
##################################################################

# Setup GameSyn api project
add_subdirectory(api)

# Setup samples
add_subdirectory(samples)

# Install CMake modules
add_subdirectory(cmake)
