#######################################################################
# This file takes care of configuring SYNAPI to build with the settings
# given in CMake. It creates the necessary config.h file and will
# also prepare package files for pkg-config and CMake.
#######################################################################

# should we build static libs?
if (SYNAPI_STATIC)
  set(SYNAPI_LIB_TYPE STATIC)
else ()
  set(SYNAPI_LIB_TYPE SHARED)
endif ()

# determine config values depending on build options
set(SYNAPI_STATIC_LIB 0)
if (SYNAPI_STATIC)
  set(SYNAPI_STATIC_LIB 1)
endif()
add_definitions(-DHAVE_SYNAPI_BUILDSETTINGS_H)

if (SYNAPI_TEST_BIG_ENDIAN)
  set(SYNAPI_CONFIG_BIG_ENDIAN 1)
else ()
  set(SYNAPI_CONFIG_LITTLE_ENDIAN 1)
endif ()

if (SYNAPI_STANDALONE_BUILD)
  set(CMAKE_USE_RELATIVE_PATHS true)
  set(CMAKE_SUPPRESS_REGENERATION true)
endif()
