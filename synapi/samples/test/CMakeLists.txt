set(HEADER_FILES )

set(SOURCE_FILES
	./main.c
)

add_executable(SynTest WIN32 ${HEADER_FILES} ${SOURCE_FILES} ${RESOURCE_FILES})

target_link_libraries(SynTest synapi)
synapi_config_sample(SynTest)


