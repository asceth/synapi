#ifndef _SYNAPI_API_H_
#define _SYNAPI_API_H_

#include <curl/curl.h>

#define SYNAPIAPI_VERSION_MAJOR 0
#define SYNAPIAPI_VERSION_MINOR 4
#define SYNAPIAPI_VERSION_PATCH 0
#define SYNAPIAPI_VERSION_SUFFIX ""
#define SYNAPIAPI_VERSION_NAME "Zulu"

#define SYNAPIAPI_VERSION    ((SYNAPIAPI_VERSION_MAJOR << 16) | (SYNAPIAPI_VERSION_MINOR << 8) | SYNAPIAPI_VERSION_PATCH)


// Pre-declare classes
// Allows use of pointers in header files without including individual .h
// so decreases dependencies between files

struct synapi_player_t
{
  char name[255];
  unsigned int score;
  int internal_id;
  char platform_unique_id[255];
};

struct synapi_server_t
{
  char[255] game;
  char[40] ip;
  char[8] port;
  char[255] name;
  unsigned int slots;
  char[255] level;
};

struct synapi_t
{
  int pool_size;
  synapi_curl_handle_t* pool[];
  CURLM* multi_handle;
  char[96] api_key; // SYN:S:<id>:<hash>
  synapi_server_t server;
};

struct synapi_curl_handle_t
{
  CURL* handle;
  bool free;
};

enum synapi_server_attribute
  {
    SYNAPI_GAME,
    SYNAPI_IP,
    SYNAPI_PORT,
    SYNAPI_NAME,
    SYNAPI_SLOTS,
    SYNAPI_LEVEL,
    SYNAPI_END
  };


synapi_t* synapi_init(const char* api_key);
void synapi_free(synapi_t* handle);

void synapi_change(synapi_t* handle, synapi_server_attribute attribute, const char* value);

void synapi_player_add(synapi_t* handle, const char* name, unsigned int score, int internal_id, const char* platform_unique_id);
void synapi_player_add(synapi_t* handle, synapi_player_t* player);

void synapi_player_delete(synapi_t* handle, int internal_id);
void synapi_player_delete(synapi_t* handle, synapi_player_t* player);

void synapi_heartbeat(synapi_t* handle);

void _synapi_build_server_json(char* payload);

#endif
