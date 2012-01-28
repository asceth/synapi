######################################################################
# SynAPI Build System
# Welcome to the CMake build system for SynAPI
######################################################################

cmake_minimum_required(VERSION 2.8)
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE)
#cmake_policy(SET CMP0003 NEW)

project(SYNAPI)

# Include necessary submodules
set(CMAKE_MODULE_PATH
  "${SYNAPI_SOURCE_DIR}/cmake"
  "${SYNAPI_SOURCE_DIR}/cmake/utils"
  "${SYNAPI_SOURCE_DIR}/cmake/packages"
)
include(CMakeDependentOption)
include(MacroLogFeature)
include(SynAPIConfigTargets)
include(PreprocessorUtils)
set(SYNAPI_WORK_DIR ${SYNAPI_BINARY_DIR})


#####################################################################
# Set up the basic build environment
#####################################################################

if (CMAKE_BUILD_TYPE STREQUAL "")
  # CMake defaults to leaving CMAKE_BUILD_TYPE empty. This screws up
  # differentiation between debug and release builds.
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None (CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif ()
set(CONFIGURATION ${CMAKE_BUILD_TYPE})

if (NOT APPLE)
  # Create debug libraries with no postfix
  set(CMAKE_DEBUG_POSTFIX "")
endif ()

if (CMAKE_COMPILER_IS_GNUCXX)
  # Test for GCC visibility
  include(CheckCXXCompilerFlag)
  check_cxx_compiler_flag(-fvisibility=hidden SYNAPI_GCC_VISIBILITY)
  if (SYNAPI_GCC_VISIBILITY)
    # determine gcc version
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
      OUTPUT_VARIABLE SYNAPI_GCC_VERSION)
    message(STATUS "Detected g++ ${SYNAPI_GCC_VERSION}")
    message(STATUS "Enabling GCC visibility flags")
    set(SYNAPI_GCC_VISIBILITY_FLAGS "-DSYNAPI_GCC_VISIBILITY -fvisibility=hidden")

    # check if we can safely add -fvisibility-inlines-hidden
    string(TOLOWER "${CMAKE_BUILD_TYPE}" SYNAPI_BUILD_TYPE)
    if (SYNAPI_BUILD_TYPE STREQUAL "debug" AND SYNAPI_GCC_VERSION VERSION_LESS "4.2")
      message(STATUS "Skipping -fvisibility-inlines-hidden due to possible bug in g++ < 4.2")
    else ()
      set(SYNAPI_GCC_VISIBILITY_FLAGS "${SYNAPI_GCC_VISIBILITY_FLAGS} -fvisibility-inlines-hidden")
    endif ()
  endif (SYNAPI_GCC_VISIBILITY)
endif (CMAKE_COMPILER_IS_GNUCXX)

# determine system endianess
include(TestBigEndian)
test_big_endian(SYNAPI_TEST_BIG_ENDIAN)

# 32 bit
set(CMAKE_C_FLAGS "-m32")

include_directories("${SYNAPI_SOURCE_DIR}/deps/curl")
include_directories("${SYNAPI_SOURCE_DIR}/api")

include(Dependencies)

# Specify build paths
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${SYNAPI_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${SYNAPI_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${SYNAPI_BINARY_DIR}/bin")



######################################################################
# Provide user options to customise the build process
######################################################################

# Customise what to build
option(SYNAPI_STATIC "Static build" TRUE)
option(SYNAPI_BUILD_SAMPLES "Build SYNAPI Samples" TRUE)


###################################################################
# configure global build settings based on selected build options
###################################################################
include(ConfigureBuild)


##################################################################
# Now setup targets
##################################################################

# Setup SYNAPI api project
add_subdirectory(api)

if(SYNAPI_BUILD_SAMPLES)
  # Setup samples
  add_subdirectory(samples)
endif()


