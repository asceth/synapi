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

# Display results, terminate if anything required is missing
MACRO_DISPLAY_FEATURE_LOG()

# Add library and include paths from the dependencies
include_directories(
  ${X11_INCLUDE_DIR}
  ${Carbon_INCLUDE_DIRS}
  ${Cocoa_INCLUDE_DIRS}
)
link_directories(
  ${X11_LIBRARY_DIRS}
)

