#######################################################################
# This file takes care of configuring GameSyn to build with the settings
# given in CMake. It creates the necessary config.h file and will
# also prepare package files for pkg-config and CMake.
#######################################################################

# should we build static libs?
if (GameSyn_STATIC)
  set(GameSyn_LIB_TYPE STATIC)
else ()
  set(GameSyn_LIB_TYPE SHARED)
endif ()

# determine config values depending on build options
set(GameSyn_STATIC_LIB 0)
if (GameSyn_STATIC)
  set(GameSyn_STATIC_LIB 1)
endif()
add_definitions(-DHAVE_GameSyn_BUILDSETTINGS_H)

if (GameSyn_TEST_BIG_ENDIAN)
  set(GameSyn_CONFIG_BIG_ENDIAN 1)
else ()
  set(GameSyn_CONFIG_LITTLE_ENDIAN 1)
endif ()

if (GameSyn_STANDALONE_BUILD)
  set(CMAKE_USE_RELATIVE_PATHS true)
  set(CMAKE_SUPPRESS_REGENERATION true)
endif()
