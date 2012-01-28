#ifndef _SYNAPI_API_H_
#define _SYNAPI_API_H_

#define SYNAPIAPI_VERSION_MAJOR 0
#define SYNAPIAPI_VERSION_MINOR 1
#define SYNAPIAPI_VERSION_PATCH 0
#define SYNAPIAPI_VERSION_NAME "One Byte To Go!"

#define SYNAPIAPI_VERSION ((SYNAPIAPI_VERSION_MAJOR << 16) | (SYNAPIAPI_VERSION_MINOR << 8) | SYNAPIAPI_VERSION_PATCH)

#include <stdarg.h>
#include <curl/curl.h>

// Detect platform
#if defined( WINCE )
#   if !defined( PLATFORM_WIN_CE )
#       define PLATFORM_WIN_CE
#   endif
#elif defined( WIN32 ) || defined( _WINDOWS )
#   if !defined( PLATFORM_WIN )
#       define PLATFORM_WIN
#   endif
#elif defined( __APPLE__ ) || defined( __APPLE_CC__ )
#   if !defined( PLATFORM_MAC )
#      define PLATFORM_MAC
#   endif
#else
#   if !defined( PLATFORM_LINUX )
#       define PLATFORM_LINUX
#   endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Pre-declare classes
// Allows use of pointers in header files without including individual .h
// so decreases dependencies between files

typedef enum synapi_option
  {
    SYNAPI_SERVER_SLOTS = 0,
    SYNAPI_SERVER_GAME,
    SYNAPI_SERVER_IP,
    SYNAPI_SERVER_PORT,
    SYNAPI_SERVER_NAME,
    SYNAPI_SERVER_LEVEL,
    SYNAPI_PLAYER_NAME,
    SYNAPI_PLAYER_SCORE,
    SYNAPI_PLAYER_INTERNAL_ID,
    SYNAPI_PLAYER_NETWORK_ID,
    SYNAPI_END
  } synapi_option;

typedef enum synapi_method
  {
    SYN_GET = 0,
    SYN_POST = 1,
    SYN_PUT = 2,
    SYN_DELETE = 3
  } synapi_method;

typedef enum synapi_action
  {
    SYN_SERVERS_NEW = 0,
    SYN_SERVERS_UPDATE,
    SYN_PLAYERS_NEW,
    SYN_PLAYERS_UPDATE,
    SYN_PLAYERS_DELETE,
    SYN_HEARTBEAT
  } synapi_action;

typedef struct synapi_curl_handle_t {
  int free;
  CURL* handle;
} synapi_curl_handle_t;

typedef struct synapi_request_t
{
  char* query;
  char url[255];
  synapi_method method;
  synapi_action action;
  int api_key_request;
  int user_data;
} synapi_request_t;

typedef struct synapi_t
{
  int pool_size;
  int handles_running;
  int queued_messages;
  int api_key_set;
  CURLM* multi_handle;
  char api_key[256]; // SYN:S:<id>:<hash>
  char base_url[256];
  synapi_curl_handle_t** pool;
  synapi_request_t** requests;
} synapi_t;


// public
synapi_t* synapi_init(const char* api_key, int pool_size);
void synapi_url(synapi_t* handle, char* url);
void synapi_free(synapi_t* handle);

int synapi_queued(synapi_t* handle);
void synapi_perform(synapi_t* handle);


// ACTIONS
void synapi_new_server(synapi_t* handle);
void synapi_update_server(synapi_t* handle, ...);
void synapi_new_player(synapi_t* handle, ...);
void synapi_update_player(synapi_t* handle, int internal_id, ...);
void synapi_delete_player(synapi_t* handle, int internal_id);
void synapi_heartbeat(synapi_t* handle);


// semi private
int synapi_queue(synapi_t* handle, synapi_action action, synapi_method method, int api_key_request, int user_data, va_list options);


// private
void synapi_send(synapi_t* handle, synapi_request_t* request);
void synapi_free_curl_handle(synapi_t* handle, synapi_curl_handle_t* curl);
void synapi_free_request(synapi_t* handle, synapi_request_t* request);
synapi_curl_handle_t* synapi_get_curl_handle(synapi_t* handle);
void synapi_build_url(synapi_t* handle, synapi_request_t* request);
void synapi_add_parameter(int* buffer_size, int buffer_max, char* buffer, char* attr, char* value);
void synapi_build_query_string(synapi_t* handle, synapi_request_t* request, va_list options);


// CALLBACKS
size_t synapi_api_key_write(void* ptr, size_t size, size_t nmemb, void* stream);

#ifdef __cplusplus
}
#endif

#endif
