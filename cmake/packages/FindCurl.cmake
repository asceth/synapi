include(FindPkgMacros)
findpkg_begin(Curl)

set(Curl_INCLUDE_TEST_FILE curl/curl.h)
set(Curl_INCLUDE_PATH_SUFFIX curl)

set(Curl_LIBRARY_NAMES curl)

set(Curl_INCLUDE_SEARCH_DIRS
  ${DEP_INCLUDE_SEARCH_DIR}
  ${SYNAPI_SOURCE}/deps
  $ENV{SYNAPI_SOURCE}/deps)

set(Curl_LIB_SEARCH_DIRS
  ${DEP_LIB_SEARCH_DIR})

pkg_showsearch(Curl)

find_path(Curl_INCLUDE_DIR NAMES ${Curl_INCLUDE_TEST_FILE} HINTS ${Curl_INCLUDE_SEARCH_DIRS} PATH_SUFFIXES ${Curl_INCLUDE_PATH_SUFFIX})

# curl
find_library(Curl_LIBRARY_REL NAMES ${Curl_LIBRARY_NAMES} HINTS ${Curl_LIB_SEARCH_DIRS} PATH_SUFFIXES release NO_DEFAULT_PATH)
find_library(Curl_LIBRARY_DBG NAMES ${Curl_LIBRARY_NAMES} HINTS ${Curl_LIB_SEARCH_DIRS} PATH_SUFFIXES debug NO_DEFAULT_PATH)

make_library_set(Curl_LIBRARY)

set(Curl_LIBRARY_CUR ${Curl_LIBRARY_REL})

if(Curl_LIBRARY_CUR)
  set(Curl_FOUND TRUE)
endif()

findpkg_finish(Curl)
pkg_showresults(Curl)


