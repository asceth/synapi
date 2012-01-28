# Configure settings and install targets

if (WIN32)
  set(SYNAPI_RELEASE_PATH "/Release")
  set(SYNAPI_RELWDBG_PATH "/RelWithDebInfo")
  set(SYNAPI_MINSIZE_PATH "/MinSizeRel")
  set(SYNAPI_DEBUG_PATH "/Debug")
  set(SYNAPI_PLUGIN_PATH "/opt")
elseif (UNIX)
  set(SYNAPI_RELEASE_PATH "")
  set(SYNAPI_RELWDBG_PATH "")
  set(SYNAPI_MINSIZE_PATH "")
  set(SYNAPI_DEBUG_PATH "/debug")
  set(SYNAPI_PLUGIN_PATH "/SYNAPI")
endif ()


# create vcproj.user file for Visual Studio to set debug working directory
function(synapi_create_vcproj_userfile TARGETNAME)
  if (MSVC)
    configure_file(
	  ${SYNAPI_TEMPLATES_DIR}/VisualStudioUserFile.vcproj.user.in
	  ${CMAKE_CURRENT_BINARY_DIR}/${TARGETNAME}.vcproj.user
	  @ONLY
	)
  endif ()
endfunction(synapi_create_vcproj_userfile)

# setup common target settings
function(synapi_config_common TARGETNAME)
  set_target_properties(${TARGETNAME} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${SYNAPI_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${SYNAPI_BINARY_DIR}/lib
    RUNTIME_OUTPUT_DIRECTORY ${SYNAPI_BINARY_DIR}/bin
  )
  synapi_create_vcproj_userfile(${TARGETNAME})
endfunction(synapi_config_common)


# setup library build
function(synapi_config_lib LIBNAME)
  synapi_config_common(${LIBNAME})

  set_target_properties(${LIBNAME} PROPERTIES LINK_INTERFACE_LIBRARIES libcurl)

  if (SYNAPI_STATIC)
    # add static prefix, if compiling static version
    set_target_properties(${LIBNAME} PROPERTIES OUTPUT_NAME ${LIBNAME})
  else (SYNAPI_STATIC)
    if (CMAKE_COMPILER_IS_GNUCXX)
      # add GCC visibility flags to shared library build
      set_target_properties(${LIBNAME} PROPERTIES COMPILE_FLAGS "${SYNAPI_GCC_VISIBILITY_FLAGS}")
	endif (CMAKE_COMPILER_IS_GNUCXX)
  endif (SYNAPI_STATIC)
  install(TARGETS ${LIBNAME}
    RUNTIME DESTINATION "bin${SYNAPI_RELEASE_PATH}"
      CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    LIBRARY DESTINATION "lib" CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    ARCHIVE DESTINATION "lib" CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
    FRAMEWORK DESTINATION "bin${SYNAPI_RELEASE_PATH}"
      CONFIGURATIONS Release MinSizeRel RelWithDebInfo None ""
  )
  install(TARGETS ${LIBNAME}
    RUNTIME DESTINATION "bin${SYNAPI_DEBUG_PATH}" CONFIGURATIONS DEBUG
    LIBRARY DESTINATION "lib" CONFIGURATIONS DEBUG
    ARCHIVE DESTINATION "lib" CONFIGURATIONS DEBUG
    FRAMEWORK DESTINATION "bin${SYNAPI_DEBUG_PATH}" CONFIGURATIONS DEBUG
  )

  if (SYNAPI_INSTALL_PDB)
    # install debug pdb files
    if (SYNAPI_STATIC)
	  install(FILES ${SYNAPI_BINARY_DIR}/lib${SYNAPI_DEBUG_PATH}/${LIBNAME}Static_d.pdb
	    DESTINATION lib
		CONFIGURATIONS Debug
	  )
	else ()
	  install(FILES ${SYNAPI_BINARY_DIR}/bin${SYNAPI_DEBUG_PATH}/${LIBNAME}_d.pdb
	    DESTINATION bin${SYNAPI_DEBUG_PATH}
		CONFIGURATIONS Debug
	  )
	endif ()
  endif ()
endfunction(synapi_config_lib)

# setup Gamesyn demo build
function(synapi_config_sample SAMPLENAME)
  synapi_config_common(${SAMPLENAME})

  # set install RPATH for Unix systems
  if (UNIX AND SYNAPI_FULL_RPATH)
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
    set (SYNAPI_SAMPLE_CONTENTS_PATH
      ${CMAKE_BINARY_DIR}/bin/$(CONFIGURATION)/${SAMPLENAME}.app/Contents)

    # now cfg files
    add_custom_command(TARGET ${SAMPLENAME} POST_BUILD
      COMMAND mkdir ARGS -p ${SYNAPI_SAMPLE_CONTENTS_PATH}/Resources
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/plugins.cfg
        ${SYNAPI_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/resources.cfg
        ${SYNAPI_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/media.cfg
        ${SYNAPI_SAMPLE_CONTENTS_PATH}/Resources/
      COMMAND ln ARGS -s -f ${CMAKE_BINARY_DIR}/bin/quake3settings.cfg
        ${SYNAPI_SAMPLE_CONTENTS_PATH}/Resources/
    )
  endif (APPLE)

  if (SYNAPI_INSTALL_SAMPLES)
    install(TARGETS ${SAMPLENAME}
      RUNTIME DESTINATION "bin${SYNAPI_RELEASE_PATH}"
        CONFIGURATIONS Release MinSizeRel RelWithDebInfo None OPTIONAL
    )
    install(TARGETS ${SAMPLENAME}
      RUNTIME DESTINATION "bin${SYNAPI_DEBUG_PATH}" CONFIGURATIONS Debug OPTIONAL
    )
  endif ()

  if (SYNAPI_INSTALL_PDB)
    # install debug pdb files
	  install(FILES ${SYNAPI_BINARY_DIR}/bin${SYNAPI_DEBUG_PATH}/${SAMPLENAME}.pdb
	    DESTINATION bin${SYNAPI_DEBUG_PATH}
	    CONFIGURATIONS Debug
	    )
  endif ()
endfunction(synapi_config_sample)


