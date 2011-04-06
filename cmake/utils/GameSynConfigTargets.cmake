# Configure settings and install targets

if (WIN32)
  set(GameSyn_RELEASE_PATH "/Release")
  set(GameSyn_RELWDBG_PATH "/RelWithDebInfo")
  set(GameSyn_MINSIZE_PATH "/MinSizeRel")
  set(GameSyn_DEBUG_PATH "/Debug")
  set(GameSyn_PLUGIN_PATH "/opt")
elseif (UNIX)
  set(GameSyn_RELEASE_PATH "")
  set(GameSyn_RELWDBG_PATH "")
  set(GameSyn_MINSIZE_PATH "")
  set(GameSyn_DEBUG_PATH "/debug")
  set(GameSyn_PLUGIN_PATH "/GameSyn")
endif ()


# create vcproj.user file for Visual Studio to set debug working directory
function(gamesyn_create_vcproj_userfile TARGETNAME)
  if (MSVC)
    configure_file(
	  ${GameSyn_TEMPLATES_DIR}/VisualStudioUserFile.vcproj.user.in
	  ${CMAKE_CURRENT_BINARY_DIR}/${TARGETNAME}.vcproj.user
	  @ONLY
	)
  endif ()
endfunction(gamesyn_create_vcproj_userfile)

# setup common target settings
function(gamesyn_config_common TARGETNAME)
  set_target_properties(${TARGETNAME} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${GameSyn_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${GameSyn_BINARY_DIR}/lib
    RUNTIME_OUTPUT_DIRECTORY ${GameSyn_BINARY_DIR}/bin
  )
  gamesyn_create_vcproj_userfile(${TARGETNAME})
endfunction(gamesyn_config_common)


# setup library build
function(gamesyn_config_lib LIBNAME)
  gamesyn_config_common(${LIBNAME})

  if (APPLE)
    set_target_properties(${PLUGINNAME}
      PROPERTIES BUILD_WITH_INSTALL_RPATH 1
      INSTALL_NAME_DIR "@executable_path/../Plugins"
      )
  endif ()

  set_target_properties(${LIBNAME} PROPERTIES LINK_INTERFACE_LIBRARIES LibStrophe)

  if (GameSyn_STATIC)
    # add static prefix, if compiling static version
    set_target_properties(${LIBNAME} PROPERTIES OUTPUT_NAME ${LIBNAME}Static)
  else (GameSyn_STATIC)
    if (CMAKE_COMPILER_IS_GNUCXX)
      # add GCC visibility flags to shared library build
      set_target_properties(${LIBNAME} PROPERTIES COMPILE_FLAGS "${GameSyn_GCC_VISIBILITY_FLAGS}")
	endif (CMAKE_COMPILER_IS_GNUCXX)
  endif (GameSyn_STATIC)
  install(TARGETS ${LIBNAME}
    RUNTIME DESTINATION "bin${GameSyn_RELEASE_PATH}"
      CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    LIBRARY DESTINATION "lib" CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    ARCHIVE DESTINATION "lib" CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    FRAMEWORK DESTINATION "bin${GameSyn_RELEASE_PATH}"
      CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
  )
  install(TARGETS ${LIBNAME}
    RUNTIME DESTINATION "bin${GameSyn_DEBUG_PATH}" CONFIGURATIONS DEBUG
    LIBRARY DESTINATION "lib" CONFIGURATIONS DEBUG
    ARCHIVE DESTINATION "lib" CONFIGURATIONS DEBUG
    FRAMEWORK DESTINATION "bin${GameSyn_DEBUG_PATH}" CONFIGURATIONS DEBUG
  )

  if (GameSyn_INSTALL_PDB)
    # install debug pdb files
    if (GameSyn_STATIC)
	  install(FILES ${GameSyn_BINARY_DIR}/lib${GameSyn_DEBUG_PATH}/${LIBNAME}Static_d.pdb
	    DESTINATION lib
		CONFIGURATIONS Debug
	  )
	else ()
	  install(FILES ${GameSyn_BINARY_DIR}/bin${GameSyn_DEBUG_PATH}/${LIBNAME}_d.pdb
	    DESTINATION bin${GameSyn_DEBUG_PATH}
		CONFIGURATIONS Debug
	  )
	endif ()
  endif ()
endfunction(gamesyn_config_lib)

# setup plugin build
function(gamesyn_config_plugin PLUGINNAME)
  gamesyn_config_common(${PLUGINNAME})

  if (APPLE)
    set_target_properties(${PLUGINNAME}
      PROPERTIES BUILD_WITH_INSTALL_RPATH 1
      INSTALL_NAME_DIR "@executable_path/../Plugins"
      )
  endif ()

  set_property(TARGET ${PLUGINNAME} PROPERTY LINK_INTERFACE_LIBRARIES "")

  if (GameSyn_STATIC)
    # add static prefix, if compiling static version
    set_target_properties(${PLUGINNAME} PROPERTIES OUTPUT_NAME ${PLUGINNAME}Static)
  else (GameSyn_STATIC)
    if (CMAKE_COMPILER_IS_GNUCXX)
      # add GCC visibility flags to shared library build
      set_target_properties(${PLUGINNAME} PROPERTIES COMPILE_FLAGS "${GameSyn_GCC_VISIBILITY_FLAGS}")
      # disable "lib" prefix on Unix
      set_target_properties(${PLUGINNAME} PROPERTIES PREFIX "")
	  endif (CMAKE_COMPILER_IS_GNUCXX)
  endif (GameSyn_STATIC)
  install(TARGETS ${PLUGINNAME}
    RUNTIME DESTINATION "bin${GameSyn_RELEASE_PATH}"
    CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    LIBRARY DESTINATION "lib${GameSyn_PLUGIN_PATH}"
    CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    ARCHIVE DESTINATION "lib${GameSyn_PLUGIN_PATH}"
    CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    )
  install(TARGETS ${PLUGINNAME}
    RUNTIME DESTINATION "bin${GameSyn_DEBUG_PATH}" CONFIGURATIONS DEBUG
    LIBRARY DESTINATION "lib${GameSyn_PLUGIN_PATH}" CONFIGURATIONS DEBUG
    ARCHIVE DESTINATION "lib${GameSyn_PLUGIN_PATH}" CONFIGURATIONS DEBUG
    )

  if (GameSyn_INSTALL_PDB)
    # install debug pdb files
    if (GameSyn_STATIC)
	    install(FILES ${GameSyn_BINARY_DIR}/lib${GameSyn_DEBUG_PATH}/${PLUGINNAME}Static_d.pdb
	      DESTINATION lib/opt
		    CONFIGURATIONS Debug
	      )
	  else ()
	    install(FILES ${GameSyn_BINARY_DIR}/bin${GameSyn_DEBUG_PATH}/${PLUGINNAME}_d.pdb
	      DESTINATION bin${GameSyn_DEBUG_PATH}
		    CONFIGURATIONS Debug
	      )
	  endif ()
  endif ()
endfunction(gamesyn_config_plugin)

# setup Gamesyn demo build
function(gamesyn_config_sample SAMPLENAME)
  gamesyn_config_common(${SAMPLENAME})

  # set install RPATH for Unix systems
  if (UNIX AND GameSyn_FULL_RPATH)
    set_property(TARGET ${SAMPLENAME} APPEND PROPERTY
      INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/lib)
    set_property(TARGET ${SAMPLENAME} PROPERTY INSTALL_RPATH_USE_LINK_PATH TRUE)
  endif ()

  set_property(TARGET ${SAMPLENAME} PROPERTY LINK_INTERFACE_LIBRARIES "")

  if (APPLE)
    # On OS X, create .app bundle
    set_property(TARGET ${SAMPLENAME} PROPERTY MACOSX_BUNDLE TRUE)
    # also, symlink frameworks so .app is standalone
    # NOTE: $(CONFIGURATION) is not resolvable at CMake run time, it's only
    # valid at build time (hence parenthesis rather than braces)
    set (GameSyn_SAMPLE_CONTENTS_PATH
      ${CMAKE_BINARY_DIR}/bin/$(CONFIGURATION)/${SAMPLENAME}.app/Contents)

    # now cfg files
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND mkdir ARGS -p ${GameSyn_SAMPLE_CONTENTS_PATH}/Resources
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/plugins.cfg
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/resources.cfg
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/media.cfg
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/quake3settings.cfg
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Resources/
    )
    # now plugins
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND mkdir ARGS -p ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins)

    # gamesyn
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND mkdir ARGS -p ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libGamesynEngine.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
    )

    ## OIS and MyGui and OpenAL and ALUT
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libOIS.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libMyGui.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libopenal.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libalut.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )

    ## ogre plugins
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/libOgreMain.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/RenderSystem_GL.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_BSPSceneManager.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_CgProgramManager.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_OctreeSceneManager.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_PCZSceneManager.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_OctreeZone.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_ParticleFX.dylib
      ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
      )

    ## gamesyn plugins
	  if (GameSyn_BUILD_PLUGIN_ADVANCEDOBJECTS)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_AdvancedObjects.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
	  if (GameSyn_BUILD_PLUGIN_CONTROLLERS)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_Controllers.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
	  if (GameSyn_BUILD_PLUGIN_MINIGAMES)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_MiniGames.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
	  if (GameSyn_BUILD_PLUGIN_OPENAL)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_OpenAL.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
	  if (GameSyn_BUILD_PLUGIN_SIMPLEOBJECTS)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_SimpleObjects.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
    if (GameSyn_BUILD_PLUGIN_SLINGSHOT)
      add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
        COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/lib/$(CONFIGURATION)/Plugin_Slingshot.dylib
        ${GameSyn_SAMPLE_CONTENTS_PATH}/Plugins/
        )
    endif()
  endif (APPLE)

  if (GameSyn_INSTALL_SAMPLES)
    install(TARGETS ${SAMPLENAME}
      RUNTIME DESTINATION "bin${GameSyn_RELEASE_PATH}"
        CONFIGURATIONS Release MinSizeRel RelWithDebInfo None OPTIONAL
    )
    install(TARGETS ${SAMPLENAME}
      RUNTIME DESTINATION "bin${GameSyn_DEBUG_PATH}" CONFIGURATIONS Debug OPTIONAL
    )
  endif ()

  if (GameSyn_INSTALL_PDB)
    # install debug pdb files
	  install(FILES ${GameSyn_BINARY_DIR}/bin${GameSyn_DEBUG_PATH}/${SAMPLENAME}.pdb
	    DESTINATION bin${GameSyn_DEBUG_PATH}
	    CONFIGURATIONS Debug
	    )
  endif ()
endfunction(gamesyn_config_sample)

# setup Gamesyn tool build
function(gamesyn_config_tool TOOLNAME)
  gamesyn_config_common(${TOOLNAME})

  # set install RPATH for Unix systems
  if (UNIX AND GameSyn_FULL_RPATH)
    set_property(TARGET ${TOOLNAME} APPEND PROPERTY
      INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/lib)
    set_property(TARGET ${TOOLNAME} PROPERTY INSTALL_RPATH_USE_LINK_PATH TRUE)
  endif ()

  if (GameSyn_INSTALL_TOOLS)
    install(TARGETS ${TOOLNAME}
      RUNTIME DESTINATION "bin${GameSyn_RELEASE_PATH}"
        CONFIGURATIONS Release MinSizeRel RelWithDebInfo None OPTIONAL
    )
    install(TARGETS ${TOOLNAME}
      RUNTIME DESTINATION "bin${GameSyn_DEBUG_PATH}" CONFIGURATIONS Debug OPTIONAL
    )
  endif ()

  if (GameSyn_INSTALL_PDB)
    # install debug pdb files
	install(FILES ${GameSyn_BINARY_DIR}/bin${GameSyn_DEBUG_PATH}/${TOOLNAME}.pdb
	  DESTINATION bin${GameSyn_DEBUG_PATH}
	  CONFIGURATIONS Debug
	)
  endif ()
endfunction(gamesyn_config_tool)

#########################################################
# Install Gamesyn dependencies
#########################################################

macro(gamesyn_install_dep DEP)
  message(STATUS "Looking for ${DEP}..")
  # On Unix, the plugins might have no prefix
  if (CMAKE_FIND_LIBRARY_PREFIXES)
    set(TMP_CMAKE_LIB_PREFIX ${CMAKE_FIND_LIBRARY_PREFIXES})
    set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "")
  endif()

  # header files for plugins are optional
  set(GameSyn_DEP_PATH_SUFFIXES
    plugins plugins/${DEP} ${DEP} ${ARGN})

  # find link libraries for plugins
  set(GameSyn_${DEP}_LIBRARY_NAMES "${DEP}${GameSyn_LIB_SUFFIX}")
  get_debug_names(GameSyn_${DEP}_LIBRARY_NAMES)

  find_library(GameSyn_${DEP}_LIBRARY_REL NAMES ${GameSyn_${DEP}_LIBRARY_NAMES}
    HINTS ${GameSyn_LIBRARY_DIRS} ${DEP_LIB_SEARCH_DIR} PATH_SUFFIXES GameSyn release NO_DEFAULT_PATH)
  find_library(GameSyn_${DEP}_LIBRARY_DBG NAMES ${GameSyn_${DEP}_LIBRARY_NAMES}
    HINTS ${GameSyn_LIBRARY_DIRS} ${DEP_LIBD_SEARCH_DIR} PATH_SUFFIXES GameSyn debug NO_DEFAULT_PATH)
  make_library_set(GameSyn_${DEP}_LIBRARY)

  if (GameSyn_${DEP}_LIBRARY)
    message(STATUS "  Found ${DEP}: ${GameSyn_${DEP}_LIBRARY}")
    set(GameSyn_${DEP}_FOUND TRUE)
    set(GameSyn_${DEP}_LIBRARIES ${GameSyn_${DEP}_LIBRARY})

    # copy to release
    get_filename_component(GameSyn_${DEP}_FILENAME ${GameSyn_${DEP}_LIBRARY_REL} NAME)
    configure_file(${GameSyn_${DEP}_LIBRARY_REL} ${GameSyn_BINARY_DIR}/lib/Release/${GameSyn_${DEP}_FILENAME} COPYONLY)

    # copy to debug
    get_filename_component(GameSyn_${DEP}_FILENAME ${GameSyn_${DEP}_LIBRARY_DBG} NAME)
    configure_file(${GameSyn_${DEP}_LIBRARY_DBG} ${GameSyn_BINARY_DIR}/lib/Debug/${GameSyn_${DEP}_FILENAME} COPYONLY)
  else ()
    message(STATUS "  dependency ${DEP} not found..")
  endif ()

  mark_as_advanced(GameSyn_${DEP}_LIBRARY_REL GameSyn_${DEP}_LIBRARY_DBG GameSyn_${DEP}_LIBRARY_FWK)
endmacro(gamesyn_install_dep)

