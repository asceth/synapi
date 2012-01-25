#ifndef _SYNAPI_API_H_
#define _SYNAPI_API_H_

#define SYNAPIAPI_VERSION_MAJOR 0
#define SYNAPIAPI_VERSION_MINOR 1
#define SYNAPIAPI_VERSION_PATCH 0
#define SYNAPIAPI_VERSION_NAME "One Byte To Go!"

#define SYNAPIAPI_VERSION ((SYNAPIAPI_VERSION_MAJOR << 16) | (SYNAPIAPI_VERSION_MINOR << 8) | SYNAPIAPI_VERSION_PATCH)


// Pre-declare classes
// Allows use of pointers in header files without including individual .h
// so decreases dependencies between files

struct synapi_curl_handle_t {
  int free;
  int api_key_request;
  CURL* handle;
};

struct synapi_t
{
  int pool_size;
  int handles_running;
  int queued_messages;
  CURLM* multi_handle;
  char api_key[96]; // SYN:S:<id>:<hash>
  struct synapi_curl_handle_t* pool[];
};

enum synapi_option
  {
    SYNAPI_SLOTS = 0,   // 0
    SYNAPI_SCORE,       // 1
    SYNAPI_INTERNAL_ID, // 2
    SYNAPI_GAME,        // 3
    SYNAPI_IP,          // 4
    SYNAPI_PORT,        // 5
    SYNAPI_NAME,        // 6
    SYNAPI_LEVEL,       // 7
    SYNAPI_UNIQUE,      // 8
    SYNAPI_END          // 9
  };


// "public"
struct synapi_t* synapi_init(const char* api_key, int pool_size);

void synapi_perform(struct synapi_t* handle);

void synapi_new_server(struct synapi_t* handle, ...);
void synapi_update_server(struct synapi_t* handle, ...);

void synapi_player(struct synapi_t* handle, ...);
void synapi_delete_player(struct synapi_t* handle, int internal_id);

void synapi_send(struct synapi_t* handle, const char* url, int method, int api_key_request, ...);
void synapi_heartbeat(struct synapi_t* handle);

void synapi_free(struct synapi_t* handle);

// "private"
size_t synapi_api_key_write(void* ptr, size_t size, size_t nmemb, void* stream);
CURL* synapi_get_curl_handle();
char* synapi_build_query_string(struct synapi_t* handle, ...);

#endif
