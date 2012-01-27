project(Synapi)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set (HEADER_FILES
  synapi.h
)

set (SOURCE_FILES
  synapi.c
)

add_definitions(-D_USRDLL)
set(ENGINE_LIBS curl)
message(STATUS "Engine libs: ${ENGINE_LIBS}")

add_library(Synapi STATIC ${HEADER_FILES} ${SOURCE_FILES})
target_link_libraries(Synapi
  ${ENGINE_LIBS}
)

gamesyn_config_lib(Synapi)



