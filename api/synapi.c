#include <string.h>
#include <stdarg.h>
#include "stdlib.h"
#include "synapi.h"

int i = 0;
int multi_perform_counter = 0;

synapi_t* synapi_init(const char* api_key, int pool_size)
{
  synapi_t* handle = malloc(sizeof(synapi_t));
  handle->multi_handle = curl_multi_init();
  handle->pool_size = pool_size;

  handle->pool = calloc(sizeof(synapi_curl_handle_t*), pool_size);
  handle->requests = calloc(sizeof(synapi_request_t*), pool_size);
  for (i = 0; i < pool_size; i++)
    {
      handle->pool[i] = NULL;
      handle->requests[i] = NULL;
    }


  if (api_key != NULL)
    {
      strncpy(handle->api_key, api_key, sizeof(handle->api_key) - 1);
      handle->api_key[sizeof(handle->api_key)] = '\0';
      handle->api_key_set = 1;
    }
  else
    {
      handle->api_key[0] = '\0';
    }

  return handle;
}

void synapi_free(synapi_t* handle)
{
  curl_multi_cleanup(handle->multi_handle);

  for (i = 0; i < handle->pool_size; i++)
    {
      if (handle->pool[i] != NULL)
        {
          curl_easy_cleanup(handle->pool[i]->handle);
          free(handle->pool[i]);
          handle->pool[i] = NULL;
        }
    }

  free(handle);
}

int synapi_queued(synapi_t* handle)
{
  int number = 0;
  if (handle->api_key_set)
    {
      for (i = 0; i < handle->pool_size; i++)
        {
          if (handle->pool[i] != NULL)
            {
              ++number;
            }
        }
    }


  for (i = 0; i < handle->pool_size; i++)
    {
      if (handle->requests[i] != NULL)
        {
          ++number;
        }
    }

  return number;
}

void synapi_perform(synapi_t* handle)
{
  struct timeval timeout;
  int rc = -1; /* select() return code */

  fd_set fdread;
  fd_set fdwrite;
  fd_set fdexcep;
  int maxfd = -1;

  long curl_timeo = -1;

  FD_ZERO(&fdread);
  FD_ZERO(&fdwrite);
  FD_ZERO(&fdexcep);


  /* convert one queued request into a curl handle if api key set */
  if (handle->api_key_set)
    {
      for (i = 0; i < handle->pool_size; i++)
        {
          if (handle->requests[i] != NULL)
            {
              synapi_send(handle, handle->requests[i]);
              break;
            }
        }
    }

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
      ++multi_perform_counter;
      break;
    case 0:
      // timeout
      ++multi_perform_counter;
      break;
    default:
      // readable/writable sockets
      multi_perform_counter = 5;
      break;
    }

  // allows application to unconditionally call multi_perform every 5th perform
  // even on timeout/no socket activity
  if (multi_perform_counter == 5)
    {
      curl_multi_perform(handle->multi_handle, &handle->handles_running);
      multi_perform_counter = 0;
    }

  CURLMsg* existing_handle = curl_multi_info_read(handle->multi_handle, &handle->queued_messages);
  if (existing_handle && existing_handle->msg == CURLMSG_DONE)
    {
      for (i = 0; i < handle->pool_size; i++)
        {
          if (handle->pool[i] != NULL)
            {
              if (existing_handle->easy_handle == handle->pool[i]->handle)
                {
                  curl_multi_remove_handle(handle->multi_handle, handle->pool[i]->handle);
                  synapi_free_curl_handle(handle, handle->pool[i]);
                }
            }
        }
    }
}

void synapi_send(synapi_t* handle, synapi_request_t* request)
{
  synapi_curl_handle_t* curl = NULL;

  // build url now that we have api key
  synapi_build_url(handle, request);

  // send buffer off to payload
  curl = synapi_get_curl_handle(handle);
  curl_easy_setopt(curl->handle, CURLOPT_URL, request->url);
  curl_easy_setopt(curl->handle, CURLOPT_COPYPOSTFIELDS, request->query);

  switch (request->method)
    {
    case SYN_POST:
      curl_easy_setopt(curl->handle, CURLOPT_POST, 1);
      break;
    case SYN_PUT:
      curl_easy_setopt(curl->handle, CURLOPT_POST, 1);
      break;
    case SYN_DELETE:
      curl_easy_setopt(curl->handle, CURLOPT_POST, 1);
      curl_easy_setopt(curl->handle, CURLOPT_CUSTOMREQUEST, "DELETE");
      break;
    }

  if (request->api_key_request)
    {
      handle->api_key_set = 0;
      handle->api_key[0] = '\0';
      curl_easy_setopt(curl->handle, CURLOPT_WRITEFUNCTION, synapi_api_key_write);
      curl_easy_setopt(curl->handle, CURLOPT_WRITEDATA, handle);
    }

  curl_multi_add_handle(handle->multi_handle, curl->handle);

  synapi_free_request(handle, request);
}

int synapi_queue(synapi_t* handle, synapi_action action, synapi_method method, int api_key_request, int user_data, va_list options)
{
  synapi_request_t* request = calloc(sizeof(synapi_request_t), 1);

  request->action = action;
  request->method = method;
  request->api_key_request = api_key_request;
  request->user_data = user_data;
  synapi_build_query_string(handle, request, options);

  // if new server/api key request go ahead and send
  if (request->api_key_request)
    {
      synapi_send(handle, request);
      return 0;
    }

  for (i = 0; i < handle->pool_size; i++)
    {
      if (handle->requests[i] == NULL)
        {
          handle->requests[i] = request;
          return i;
        }
    }
  return -1;
}

void synapi_free_curl_handle(synapi_t* handle, synapi_curl_handle_t* curl)
{
  for (i = 0; i < handle->pool_size; i++)
    {
      if (handle->pool[i] != NULL && handle->pool[i] == curl)
        {
          handle->pool[i] = NULL;
        }
    }
  curl_easy_cleanup(curl->handle);
  free(curl);
}

void synapi_free_request(synapi_t* handle, synapi_request_t* request)
{
  if (request->api_key_request == 0)
    {
      for (i = 0; i < handle->pool_size; i++)
        {
          if (handle->requests[i] == request)
            {
              handle->requests[i] = NULL;
            }
        }
    }
  free(request->query);
  free(request);
}

synapi_curl_handle_t* synapi_get_curl_handle(synapi_t* handle)
{
  for (i = 0; i < handle->pool_size; i++)
    {
      if (handle->pool[i] == NULL)
        {
          handle->pool[i] = calloc(sizeof(synapi_curl_handle_t), 1);
          handle->pool[i]->handle = curl_easy_init();
          return handle->pool[i];
        }
    }
}

void synapi_build_url(synapi_t* handle, synapi_request_t* request)
{
  switch (request->action)
    {
    case SYN_SERVERS_NEW:
      snprintf(request->url, sizeof(request->url), "http://localhost:3000/servers");
      break;
    case SYN_SERVERS_UPDATE:
      snprintf(request->url, sizeof(request->url), "http://localhost:3000/servers/%s", handle->api_key);
      break;
    case SYN_PLAYERS_NEW:
      snprintf(request->url, sizeof(request->url), "http://localhost:3000/servers/%s/server_players", handle->api_key);
      break;
    case SYN_PLAYERS_UPDATE:
      snprintf(request->url, sizeof(request->url), "http://localhost:3000/servers/%s/server_players/%d", handle->api_key, request->user_data);
      break;
    case SYN_PLAYERS_DELETE:
      snprintf(request->url, sizeof(request->url), "http://localhost:3000/servers/%s/server_players/%d", handle->api_key, request->user_data);
      break;
    case SYN_HEARTBEAT:
      break;
    }
}

void synapi_add_parameter(int* buffer_size, int buffer_max, char* buffer, char* attr, char* value)
{
  strncat(buffer, attr, buffer_max - *buffer_size);
  *buffer_size += strlen(attr);

  strncat(buffer, value, buffer_max - *buffer_size);
  *buffer_size += strlen(value);
}

void synapi_build_query_string(synapi_t* handle, synapi_request_t* request, va_list options)
{
  int buffer_max = 2048;
  char* buffer = calloc(sizeof(char), buffer_max);
  int buffer_size = 1;

  char* value = calloc(sizeof(char), 64);
  char* result = NULL;
  synapi_option option = 0;

  int va_list_end = 0;

  if (options == NULL)
    {
      buffer[0] = '\0';
    }
  else
    {
      buffer[sizeof(buffer) - 1] = '\0';

      while(va_list_end == 0)
        {
          option = va_arg(options, synapi_option);
          if (option == SYNAPI_END)
            {
              va_list_end = 1;
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
                case SYNAPI_SERVER_SLOTS:
                  snprintf(value, sizeof(value) - 1, "%d", va_arg(options, int));
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][slots]=", value);
                  break;
                case SYNAPI_SERVER_GAME:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][game_identifier]=", va_arg(options, char*));
                  break;
                case SYNAPI_SERVER_IP:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][ip]=", va_arg(options, char*));
                  break;
                case SYNAPI_SERVER_PORT:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][port]=", va_arg(options, char*));
                  break;
                case SYNAPI_SERVER_NAME:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][name]=", va_arg(options, char*));
                  break;
                case SYNAPI_SERVER_LEVEL:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server[server_profile_attributes][level_name]=", va_arg(options, char*));
                  break;
                case SYNAPI_PLAYER_NAME:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server_player[name]=", va_arg(options, char*));
                  break;
                case SYNAPI_PLAYER_SCORE:
                  snprintf(value, sizeof(value) - 1, "%d", va_arg(options, int));
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server_player[score]=", value);
                  break;
                case SYNAPI_PLAYER_INTERNAL_ID:
                  snprintf(value, sizeof(value) - 1, "%d", va_arg(options, int));
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server_player[internal_id]=", value);
                  break;
                case SYNAPI_PLAYER_NETWORK_ID:
                  synapi_add_parameter(&buffer_size, buffer_max, buffer, "server_player[network_identifier]=", va_arg(options, char*));
                  break;
                }
            }
        }
    }

  buffer_size += 1;
  strncat(buffer, "&", sizeof(buffer) - buffer_size);
  switch (request->method)
    {
    case SYN_POST:
      synapi_add_parameter(&buffer_size, buffer_max, buffer, "_method=", "post");
      break;
    case SYN_PUT:
      synapi_add_parameter(&buffer_size, buffer_max, buffer, "_method=", "put");
      break;
    case SYN_DELETE:
      synapi_add_parameter(&buffer_size, buffer_max, buffer, "_method=", "delete");
      break;
    }

  result = calloc(sizeof(char), buffer_size);
  strncpy(result, buffer, buffer_size - 1);
  result[buffer_size] = '\0';

  request->query = result;

  free(value);
  free(buffer);
}


// CALLBACKS
size_t synapi_api_key_write(void* ptr, size_t size, size_t nmemb, void* stream)
{
  synapi_t* handle = (synapi_t*) stream;

  snprintf(handle->api_key, sizeof(handle->api_key), "%s", (char*) ptr);
  handle->api_key_set = 1;

  return size * nmemb;
}


// ACTIONS
void synapi_new_server(synapi_t* handle)
{
  synapi_queue(handle, SYN_SERVERS_NEW, SYN_POST, 1, 0, NULL);
}

void synapi_update_server(synapi_t* handle, ...)
{
  va_list options;
  va_start(options, handle);

  synapi_queue(handle, SYN_SERVERS_UPDATE, SYN_PUT, 0, 0, options);

  va_end(options);
}

void synapi_player(synapi_t* handle, ...)
{
  va_list options;
  va_start(options, handle);

  synapi_queue(handle, SYN_PLAYERS_NEW, SYN_POST, 0, 0, options);

  va_end(options);
}

void synapi_update_player(synapi_t* handle, int internal_id, ...)
{
  va_list options;
  va_start(options, internal_id);

  synapi_queue(handle, SYN_PLAYERS_UPDATE, SYN_PUT, 0, internal_id, options);

  va_end(options);
}

void synapi_delete_player(synapi_t* handle, int internal_id)
{
  synapi_queue(handle, SYN_PLAYERS_DELETE, SYN_DELETE, 0, internal_id, NULL);
}

void synapi_heartbeat(synapi_t* handle)
{
  synapi_queue(handle, SYN_HEARTBEAT, SYN_PUT, 0, 0, NULL);
}

