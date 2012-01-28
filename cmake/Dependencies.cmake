# CANNIBAL_DEPENDENCIES_DIR can be used to specify a single base
# folder where the required dependencies may be found.
set(SYNAPI_DEPENDENCIES_DIR "${SYNAPI_SOURCE_DIR}/deps" CACHE PATH "Path to SYNAPI dependencies")
set(DEP_PREFIX_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}")

# Set hardcoded path guesses for various platforms
if(WIN32)
  set(DEP_INCLUDE_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/include")
  set(DEP_LIB_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/lib/win32")
  set(DEP_LIBD_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/lib/win32")
endif (WIN32)

if (APPLE)
  set(DEP_INCLUDE_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/include" "/usr/include" "/usr/X11/include" "/usr/X11R6/include" "/usr/local/include")
  set(DEP_LIB_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/lib/mac" "/usr/lib" "/usr/X11/lib" "/usr/X11R6/lib" "/usr/local/lib")
endif ()

if (UNIX AND NOT APPLE)
  set(DEP_INCLUDE_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/include" "/usr/include" "/usr/local/include")
  set(DEP_LIB_SEARCH_DIR "${SYNAPI_DEPENDENCIES_DIR}/lib/nix" "/usr/lib" "/usr/local/lib" "/usr/lib32")
endif ()

# give guesses as hints to the find_package calls
set(CMAKE_INCLUDE_PATH ${DEP_INCLUDE_SEARCH_DIR})
set(CMAKE_LIBRARY_PATH ${DEP_LIB_SEARCH_DIR} ${DEP_LIBD_SEARCH_DIR})
set(CMAKE_PREFIX_PATH ${DEP_PREFIX_SEARCH_DIR})
set(CMAKE_FRAMEWORK_PATH ${CANNIBAL_DEPENDENCIES_DIR} ${DEP_LIB_SEARCH_DIR} ${DEP_LIBD_SEARCH_DIR})

#######################################################################
# Core dependencies
#######################################################################

# Find X11
if (UNIX)
	find_package(X11)
	macro_log_feature(X11_FOUND "X11" "X Window system" "http://www.x.org" TRUE "" "")
	macro_log_feature(X11_Xt_FOUND "Xt" "X Toolkit" "http://www.x.org" TRUE "" "")
	find_library(XAW_LIBRARY NAMES Xaw Xaw7 PATHS ${DEP_LIB_SEARCH_DIR} ${X11_LIB_SEARCH_PATH})
	macro_log_feature(XAW_LIBRARY "Xaw" "X11 Athena widget set" "http://www.x.org" TRUE "" "")
  mark_as_advanced(XAW_LIBRARY)
endif ()

#######################################################################
# Apple-specific
#######################################################################
if (APPLE)
  find_package(Carbon)
  macro_log_feature(Carbon_FOUND "Carbon" "Carbon" "http://www.apple.com" TRUE "" "")

  find_package(Cocoa)
  macro_log_feature(Cocoa_FOUND "Cocoa" "Cocoa" "http://www.apple.com" TRUE "" "")

  find_package(IOKit)
  macro_log_feature(IOKit_FOUND "IOKit" "IOKit HID framework needed by the samples" "http://www.apple.com" FALSE "" "")
endif(APPLE)

find_package(Curl)

# Display results, terminate if anything required is missing
MACRO_DISPLAY_FEATURE_LOG()

# Add library and include paths from the dependencies
include_directories(
  ${X11_INCLUDE_DIR}
  ${Carbon_INCLUDE_DIR}
  ${Cocoa_INCLUDE_DIR}
  ${Curl_INCLUDE_DIR}
)
link_directories(
  ${DEP_LIB_SEARCH_DIR}
  ${X11_LIBRARY_DIRS}
  ${Curl_LIBRARY_DIR}
)


