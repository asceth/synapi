#include <curl/curl.h>
#include "stdlib.h"
#include "synapi.h"

struct synapi_t* synapi_init(const char* api_key, int pool_size)
{
  struct synapi_t* handle = malloc(sizeof (* struct synapi_t));
  handle->multi_handle = curl_multi_init();
  handle->pool_size = pool_size;

  handle->pool = new synapi_curl_handle_t[pool_size];
  for (i = 0; i < pool_size; i++)
    {
      handle->pool[i] = new synapi_curl_handle_t;
      handle->pool[i]->handle = curl_easy_init();
      handle->pool[i]->free = true
    }

  if (handle->api_key != NULL)
    {
      strncpy(handle->api_key, api_key, sizeof(handle->api_key) - 1);
      handle->api_key[sizeof(handle->api_key)] = '\0';
    }
  else
    {
      handle->api_key[0] = '\0';
    }

  return handle;
}

void synapi_perform(struct synapi_t* handle)
{
  struct timeval timeout;
  int rc; /* select() return code */

  fd_set fdread;
  fd_set fdwrite;
  fd_set fdexcep;
  int maxfd = -1;

  long curl_timeo = -1;

  FD_ZERO(&fdread);
  FD_ZERO(&fdwrite);
  FD_ZERO(&fdexcep);

  /* set a suitable timeout to play around with */
  timeout.tv_sec = 1;
  timeout.tv_usec = 0;

  curl_multi_timeout(handle->multi_handle, &curl_timeo);
  if(curl_timeo >= 0)
    {
      timeout.tv_sec = curl_timeo / 1000;
      if(timeout.tv_sec > 1)
        {
          timeout.tv_sec = 1;
        }
      else
        {
          timeout.tv_usec = (curl_timeo % 1000) * 1000;
        }
    }

  /* get file descriptors from the transfers */
  curl_multi_fdset(handle->multi_handle, &fdread, &fdwrite, &fdexcep, &maxfd);

  /* In a real-world program you OF COURSE check the return code of the
     function calls.  On success, the value of maxfd is guaranteed to be
     greater or equal than -1.  We call select(maxfd + 1, ...), specially in
     case of (maxfd == -1), we call select(0, ...), which is basically equal
     to sleep. */

  rc = select(maxfd+1, &fdread, &fdwrite, &fdexcep, &timeout);

  switch(rc)
    {
    case -1:
      // select error
      break;
    case 0:
      // timeout
      break;
    default:
      // readable/writable sockets
      curl_multi_perform(handle->multi_handle, &handle->handles_running);
      break;
    }

  CURLMsg* existing_handle = curl_multi_info_read(handle->multi_handle, handle->queued_messages);
  if (existing_handle && existing_handle->msg == CURLMSG_DONE)
    {
      for (int i = 0; i < handle->pool_size; i++)
        {
          if (!handle->pool[i]->free)
            {
              if (existing_handle->easy_handle == handle->pool[i]->handle)
                {
                  if (handle->pool[i]->api_key_request)
                    {
                      handle->api_key_set = true;
                    }
                  handle->pool[i]->free = true;
                  handle->pool[i]->api_key_request = false;
                  curl_multi_remove_handle(handle->multi_handle, handle->pool[i]->handle);
                }
            }
        }
    }
}

void synapi_new_server(struct synapi_t* handle, ...)
{n
  va_list options;
  va_start(options, handle);

  unsigned char url[255];
  snprintf(url, "http://api.serversyn.com/servers", sizeof(url));

  synapi_send(handle, url, 1, true, options);

  va_end(options);
}

void synapi_update_server(struct synapi_t* handle, ...)
{
  va_list options;
  va_start(options, handle);

  unsigned char url[255];
  snprintf(url, "http://api.serversyn.com/servers/%s", sizeof(url), handle->api_key);

  synapi_send(handle, url, 2, false, options);

  va_end(options);
}

void synapi_player(struct synapi_t* handle, ...)
{
  va_list options;
  va_start(options, handle);

  unsigned char url[255];
  snprintf(url, "http://api.serversyn.com/servers/%s/players", sizeof(url), handle->api_key);

  synapi_send(handle, url, 1, false, options);

  va_end(options);
}

void synapi_delete_player(struct synapi_t* handle, int internal_id)
{
  va_list options;
  va_start(options, handle);

  unsigned char url[255];
  snprintf(url, "http://api.serversyn.com/servers/%s/players/%d", sizeof(url), handle->api_key, internal_id);

  synapi_send(handle, url, 0, false, options);

  va_end(options);
}

void synapi_send(struct synapi_t* handle, const char* url, int method, int api_key_request, ...)
{
  va_list options;
  va_start(options, handle);

  char* query = synapi_build_query_string(handle, options);

  // send buffer off to payloadnn
  synapi_curl_handle_t* curl = synapi_get_curl_handle();
  curl_easy_setopt(curl->handle, CURLOPT_URL, url);
  curl_easy_setopt(curl->handle, CURLOPT_COPYPOSTFIELDS, query);
  switch (method)
    {
    case 0:
      curl_easy_setopt(curl->handle, CURLOPT_CUSTOMREQUEST, "DELETE");
      break;
    case 1:
      curl_easy_setopt(curl->handle, CURLOPT_HTTPPOST, 1);
      break;
    case 2:
      curl_easy_setopt(curl->handle, CURLOPT_UPLOAD, 1);
      break;
    }

  if (api_key_request)
    {
      curl->api_key_request = true;
      handle->api_key_set = false;
      handle->api_key[0] = '\0';
      curl_easy_setopt(curl->handle, CURLOPT_WRITEFUNCTION, synapi_api_key_write);
      curl_easy_setopt(curl->handle, CURLOPT_WRITEDATA, handle);
    }
  curl_multi_add_handle(handle->multi_handle, curl->handle);

  delete[] query;

  va_end(options);
}

void synapi_heartbeat(struct synapi_t* handle)
{
  unsigned char url[255];
  snprintf(url, "http://api.serversyn.com/servers/%s/heartbeat", sizeof(url), handle->api_key);

  synapi_send(handle, url, 1, SYNAPI_END);
}

void synapi_free(struct synapi_t* handle)
{
  curl_multi_cleanup(handle->multi_handle);

  for (i = 0; i < pool-size; i++)
    {
      curl_easy_cleanup(handle->pool[i]->handle);
      delete handle->pool[i];
    }

  delete handle;
}

size_t synapi_api_key_write(void* ptr, size_t size, size_t nmemb, void* stream)
{
  strncat(((struct synapi_t*)stream)->api_key, (char*) ptr, nmemb);
  return size * nmemb;
}

CURL* synapi_get_curl_handle()
{
  for (int i = 0; i < handle->pool_size; i++)
    {
      if (handle->pool[i]->free)
        {
          handle->pool[i]->free = false;
          return handle->pool[i]->handle;
        }
    }
}

char* synapi_build_query_string(struct synapi_t* handle, ...)
{
  va_list options;
  va_start(options, handle);

  unsigned char buffer[2048];
  buffer[sizeof(buffer) - 1] = '\0';
  int buffer_size = 1;

  synapi_option option;

  char* value = NULL;
  char* name = NULL;
  char numeric_value[8];

  while(true)
    {
      attribute = va_arg(options, synapi_option);
      if (option == SYNAPI_END)
        {
          break;
        }
      else
        {
          if (buffer_size != 1)
            {
              buffer_size += 1;
              strncat(buffer, "&", sizeof(buffer) - buffer_size);
            }

          switch(option)
            {
            case SYNAPI_SLOTS:
              int slots = va_arg(options, int);
              snprintf(numeric_value, sizeof(numeric_value) - 1, "%d", slots);
              attr = "slots=";
              break;
            case SYNAPI_SCORE:
              int score = va_arg(options, int);
              snprintf(numeric_value, sizeof(numeric_value) - 1, "%d", score);
              attr = "score=";
              break;
            case SYNAPI_INTERNAL_ID:
              int internal_id = va_arg(options, int);
              snprintf(numeric_value, sizeof(numeric_value) - 1, "%d", internal_id);
              attr = "internal_id=";
              break;
            case SYNAPI_GAME:
              value = va_arg(args, char*);
              attr = "game=";
              break;
            case SYNAPI_IP:
              value = va_arg(args, char*);
              attr = "ip=";
              break;
            case SYNAPI_PORT:
              value = va_arg(args, char*);
              attr = "port=";
              break;
            case SYNAPI_NAME:
              value = va_arg(args, char*);
              attr = "name=";
              break;
            case SYNAPI_LEVEL:
              value = va_arg(args, char*);
              attr = "level=";
              break;
            case SYNAPI_UNIQUE:
              value = va_arg(args, char*);
              attr = "unique=";
              break;
            }

          buffer_size += strlen(attr);
          strncat(buffer, attr, sizeof(buffer) - buffer_size);

          if (option == SYNAPI_SLOTS || option == SYNAPI_SCORE || option == SYNAPI_INTERNAL_ID)
            {
              buffer_size += strlen(numeric_value);
              strncat(buffer, numeric_value, sizeof(buffer) - buffer_size);
            }
          else
            {
              buffer_size += strlen(value);
              strncat(buffer, value, sizeof(buffer) - buffer_size);
            }
        }
    }

  va_end(options);

  char* result = new char[buffer_size];
  strncpy(result, buffer, buffer_size - 1);
  result[buffer_size] = '\0';
  return result;
}

/*
- new game server (api key)
- uptime hearbeat

Replaceable Stats
- game
- ip
- port
- name
- slots
- current level
-

Add/Remove
- player
   - name
   - score
   - server_internal_id
   - player_id

Flow
----
api.serversyn.com/servers (POST)
api.serversyn.com/servers/:api_key (PUT)
= {:game => "zombie_master", :ip => "", :port => "", :name => "", :slots => 16, :level => "zm_yar"}

api.serversyn.com/servers/:api_key/players (POST) (resets time player "connected")
= {:name => "", :server_internal_id => 0}
api.serversyn.com/servers/:api_key/players (POST) (resets time player "connected")
= {:name => "", :server_internal_id => 1}

(15 minutes later)

api.serversyn.com/servers/:api_key (PUT)
= {} (heartbeat request)

(Player 1 changes name)

api.serversyn.com/servers/:api_key/players/:internal_id (PUT)
{:name => "changed"}

(Player 0 leaves)

api.serversyn.com/servers/:api_key/players/:internal_id (DELETE)

(map changes)

api.serversyn.com/servers/:api_key (PUT)
= {:level => "zm_changed"}
  */

