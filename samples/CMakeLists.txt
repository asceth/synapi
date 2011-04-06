# Configure Samples build
if (APPLE AND GameSyn_BUILD_SAMPLES AND NOT IOKit_FOUND)
  message(STATUS "Could not find dependency: IOKit")
  message(STATUS "Skipping samples build")
  set(GameSyn_BUILD_SAMPLES 0)
endif()

if (GameSyn_BUILD_SAMPLES)
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/common/include)

  if (APPLE)
  	set(GameSyn_LIBRARIES ${GameSyn_LIBRARIES} IOKit)
  endif ()

  if (GameSyn_STATIC)
  	# Static linking means we need to directly use plugins
    #include_directories(${CMAKE_SOURCE_DIR}/plugins/controllers/include)
  endif()

	# Link to all enabled plugins
	set(GameSyn_LIBRARIES ${GameSyn_LIBRARIES} ${SAMPLE_DEPENDENCIES})

	# Need to include resource files so that icons are linked
	if (WIN32)
	  # set(RESOURCE_FILES
    # 		${CMAKE_SOURCE_DIR}/OgreMain/src/WIN32/resource.h
	  #   	${CMAKE_SOURCE_DIR}/OgreMain/src/WIN32/OgreWin32Resources.rc
    # 		${CMAKE_SOURCE_DIR}/OgreMain/src/WIN32/winres.h
	  # )
	  # source_group(Resources FILES ${RESOURCE_FILES})
	endif ()

  add_subdirectory(hello)
endif ()


# Install sample sources
if (GameSyn_INSTALL_SAMPLES_SOURCE)
  if (WIN32 OR APPLE)
    set(GameSyn_SAMPLES_DIR samples)
  elseif (UNIX)
    set(GameSyn_SAMPLES_DIR share/GameSyn/samples)
  endif ()
  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/ DESTINATION ${GameSyn_SAMPLES_DIR}
    REGEX "^CMakeLists.txt$" EXCLUDE
    PATTERN "Makefile.am" EXCLUDE
    PATTERN "Media" EXCLUDE
    PATTERN "bin" EXCLUDE
    PATTERN "CEGUIRenderer" EXCLUDE
    PATTERN "misc" EXCLUDE
    PATTERN "setup" EXCLUDE
    PATTERN ".svn" EXCLUDE
	  PATTERN "obj" EXCLUDE
	  PATTERN "scripts" EXCLUDE
  )
  # install a new CMakeLists.txt file to allow building of samples
  configure_file(${GameSyn_TEMPLATES_DIR}/SampleLists.cmake ${CMAKE_CURRENT_BINARY_DIR}/CMakeLists.txt @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CMakeLists.txt DESTINATION ${GameSyn_SAMPLES_DIR})
endif ()
