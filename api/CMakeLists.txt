project(GameSynAPI)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set (HEADER_FILES
  include/gamesyn.h
  include/gamesyn_exception.h
  include/gamesyn_platform.h
  include/gamesyn_prerequisites.h
  include/gamesyn_root.h
  include/gamesyn_singleton.h
  include/gamesyn_std_headers.h
  include/gamesyn_string.h
  include/gamesyn_string_converter.h
  include/gamesyn_string_vector.h
)

set (SOURCE_FILES
  src/gamesyn_exception.cpp
  src/gamesyn_root.cpp
  src/gamesyn_string.cpp
  src/gamesyn_string_converter.cpp
)

add_definitions(-D_USRDLL)
set(ENGINE_LIBS Strophe)
message(STATUS "Engine libs: ${ENGINE_LIBS}")

add_library(GameSynAPI STATIC ${HEADER_FILES} ${SOURCE_FILES})
target_link_libraries(GameSynAPI
  ${ENGINE_LIBS}
)

gamesyn_config_lib(GameSynAPI)
install(FILES ${HEADER_FILES}
  DESTINATION include/GAMESYN
)




