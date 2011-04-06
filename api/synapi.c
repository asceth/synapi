#include "synapi/synapi.h"

synapi_t* synapi_init(const char* api_key, int pool_size = 6)
{
  handle = new synapi_t;
  handle->multi_handle = curl_multi_init();
  handle->pool_size = pool_size;

  handle->pool = new synapi_curl_handle_t[pool_size];
  for (i = 0; i < pool_size; i++)
    {
      handle->pool[i] = new synapi_curl_handle_t;
      handle->pool[i]->handle = curl_easy_init();
      handle->pool[i]->free = true
    }

  strncpy(handle->api_key, api_key, sizeof(handle->api_key) - 1);
  handle->api_key[sizeof(handle->api_key)] = '\0';

  return handle;
}

void synapi_free(synapi_t* handle)
{
  for (i = 0; i < pool-size; i++)
    {
      handle->pool[i]->handle;
      delete handle->pool[i];
    }

  handle->multi_handle;
  delete handle;
}

void synapi_change(synapi_t* handle, ...)
{
  va_list args;
  va_start(args, handle);

  unsigned char buffer[2048];
  strncpy(buffer, "{", sizeof(buffer) - 1);
  buffer[sizeof(buffer) - 1] = '\0';
  int buffer_size = 1;

  synapi_server_attribute_t attribute;
  bool keep_processing = true;

  char* value = NULL;
  char* attr = NULL;
  char slots_value[8];

  while(keep_processing)
    {
      attribute = va_arg(args, synapi_server_attribute_t);
      if (attribute == SYNAPI_END)
        {
          break;
        }
      else
        {
          switch(attribute)
            {
            case SYNAPI_SLOTS:
              int slots = va_arg(args, int);
              snprintf(slots_value, sizeof(slots_value) - 1, "%d", slots);

              buffer_size += strlen(slots_value);
              strncat(buffer, slots_value, sizeof(buffer) - buffer_size);
              break;
            case SYNAPI_GAME:
              value = va_arg(args, char*);
              attr = "game:";
              break;
            case SYNAPI_IP:
              value = va_arg(args, char*);
              break;
            case SYNAPI_PORT:
              value = va_arg(args, char*);
              break;
            case SYNAPI_NAME:
              value = va_arg(args, char*);
              break;
            case SYNAPI_LEVEL:
              value = va_arg(args, char*);
              break;
            }

          buffer_size += strlen(attr);

          if (attribute == SYNAPI_SLOTS)
            {
            }
          else
            {
              buffer_size += strlen(value);
              strncat(buffer, value, sizeof(buffer) - buffer_size);
            }
          buffer_size += 1;
          strncat(buffer, ",", sizeof(buffer) - buffer_size);
        }

    }

  va_end(args);
}

void synapi_player_add(synapi_t* handle, const char* name, unsigned int score, int internal_id, const char* platform_unique_id)
{
}

void synapi_player_delete(synapi_t* handle, int internal_id)
{
}

void synapi_heartbeat(synapi_t* handle)
{
}

char* synapi_itoa(int value, char* str, int radix)
{
  static char dig[] =
    "0123456789"
    "abcdefghijklmnopqrstuvwxyz";
  int n = 0, neg = 0;
  unsigned int v;
  char* p, *q;
  char c;

  if (radix == 10 && value < 0)
    {
      value = -value;
      neg = 1;
    }

  v = value;
  do
    {
      str[n++] = dig[v%radix];
      v /= radix;
    } while (v);

  if (neg)
    {
      str[n++] = '-';
    }
  str[n] = '\0';

  for (p = str, q = p + (n-1); p < q; ++p, --q)
    {
      c = *p, *p = *q, *q = c;
    }
  return str;
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

