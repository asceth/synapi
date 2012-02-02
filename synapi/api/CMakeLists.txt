include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set (HEADER_FILES synapi.h)
set (SOURCE_FILES synapi.c)

add_definitions(-D_USRDLL)

if(SYNAPI_STATIC)
  add_library(synapi STATIC ${HEADER_FILES} ${SOURCE_FILES})
  set_target_properties(synapi PROPERTIES
      COMPILE_DEFINITIONS SYNAPI_BUILD_STATIC)
else()
  add_library(synapi SHARED ${HEADER_FILES} ${SOURCE_FILES})
  set_target_properties(synapi PROPERTIES
      COMPILE_DEFINITIONS SYNAPI_BUILD_DYNAMIC)
endif()

target_link_libraries(synapi ${Curl_LIBRARY_CUR} rt)


synapi_config_lib(synapi)



