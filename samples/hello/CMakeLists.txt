set(HEADER_FILES
  include/prereq.h
  include/hello_application.h
)

set(SOURCE_FILES
  src/main.cpp
  src/hello_application.cpp
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
add_executable(Demo_Hello WIN32 ${HEADER_FILES} ${SOURCE_FILES} ${RESOURCE_FILES})

target_link_libraries(Demo_Hello GameSynAPI Strophe)
gamesyn_config_sample(Demo_Hello)

#add_dependencies(Demo_Hello ${SAMPLE_DEPENDENCIES})
