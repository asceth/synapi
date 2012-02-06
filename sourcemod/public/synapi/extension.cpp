#include "synapi.h"
#include "smsdk_ext.h"
#include "extension.h"

SynAPI g_synapi;
SMEXT_LINK(&g_synapi);

extern const sp_nativeinfo_t sm_synapi_natives[];

/**
 * Global Hooks
 */
void GameFrame(bool simulating)
{
  if (g_synapi.handle != NULL)
    {
      synapi_perform(g_synapi.handle);
    }
}

/**
 * Extension Definitions
 */
bool SynAPI::SDK_OnLoad(char* error, size_t maxlength, bool late)
{
  synapi_global_init();
  g_synapi.handle = NULL;
  sharesys->RegisterLibrary(myself, "synapi");

  // Game Frame Hook
  smutils->AddGameFrameHook(&GameFrame);

  return true;
}

void SynAPI::SDK_OnAllLoaded()
{
	sharesys->AddNatives(myself, sm_synapi_natives);
}

void SynAPI::SDK_OnUnload()
{
  // Game Frame Hook
  smutils->RemoveGameFrameHook(&GameFrame);
  synapi_global_free();
}



/**
 * Native Definitions
 */

// native synapi_init();
cell_t sm_synapi_init(IPluginContext *pContext, const cell_t *params)
{
  g_synapi.handle = synapi_init(NULL, params[1]);
  synapi_url(g_synapi.handle, "http://127.0.0.1", "Host: api.serversyn.local");
  return true;
}

// native synapi_init_with_api_key(String);
cell_t sm_synapi_init_with_api_key(IPluginContext *pContext, const cell_t *params)
{
  char* api_key;
  pContext->LocalToString(params[1], &api_key);
  g_synapi.handle = synapi_init(api_key, params[2]);
  synapi_url(g_synapi.handle, "http://127.0.0.1", "Host: api.serversyn.local");

  return true;
}

// native synapi_get_api_key(String:api_key[], length);
cell_t sm_synapi_get_api_key(IPluginContext *pContext, const cell_t *params)
{
  unsigned int size = params[2];
  if (size > sizeof(g_synapi.handle->api_key))
    {
      size = sizeof(g_synapi.handle->api_key);
    }

  char buffer[size];

  if (g_synapi.handle != NULL)
    {
      snprintf(buffer, size - 1, "%s", g_synapi.handle->api_key);
      pContext->StringToLocal(params[1], size - 1, buffer);
    }

  return 1;
}

// native synapi_free();
cell_t sm_synapi_free(IPluginContext *pContext, const cell_t *params)
{
  if (g_synapi.handle != NULL)
    {
      synapi_free(g_synapi.handle);
    }
  return true;
}

// native int:synapi_queued();
cell_t sm_synapi_queued(IPluginContext *pContext, const cell_t *params)
{
  return synapi_queued(g_synapi.handle);
}

// native bool:synapi_ready();
cell_t sm_synapi_ready(IPluginContext *pContext, const cell_t *params)
{
  if (g_synapi.handle != NULL && g_synapi.handle->api_key_set == 1)
    {
      return true;
    }
  return false;
}




// native synapi_new_server();
cell_t sm_synapi_new_server(IPluginContext *pContext, const cell_t *params)
{
  synapi_new_server(g_synapi.handle);
  return true;
}

// native synapi_update_server(slots, const String:game_identifier[], const String:ip[], const String:port[], const String:name[]);
cell_t sm_synapi_update_server(IPluginContext *pContext, const cell_t *params)
{
  int slots;
  char* game_identifier;
  char* ip;
  char* port;
  char* name;

  slots = params[1];
  pContext->LocalToString(params[2], &game_identifier);
  pContext->LocalToString(params[3], &ip);
  pContext->LocalToString(params[4], &port);
  pContext->LocalToString(params[5], &name);

  synapi_update_server(g_synapi.handle,
                       SYNAPI_SERVER_GAME, game_identifier,
                       SYNAPI_SERVER_IP, ip,
                       SYNAPI_SERVER_PORT, port,
                       SYNAPI_SERVER_NAME, name,
                       SYNAPI_SERVER_SLOTS, slots,
                       SYNAPI_END);
  return true;
}

// native synapi_update_server_name(const String:name[]);
cell_t sm_synapi_update_server_name(IPluginContext *pContext, const cell_t *params)
{
  char* name;
  pContext->LocalToString(params[1], &name);
  synapi_update_server(g_synapi.handle, SYNAPI_SERVER_NAME, name, SYNAPI_END);
  return true;
}

// native synapi_update_server_level(const String:level_name[]);
cell_t sm_synapi_update_server_level(IPluginContext *pContext, const cell_t *params)
{
  char* level_name;
  pContext->LocalToString(params[1], &level_name);
  synapi_update_server(g_synapi.handle, SYNAPI_SERVER_LEVEL, level_name, SYNAPI_END);
  return true;
}



// native synapi_new_player(internal_id, score, const String:network_identifier[], const String:name[]);
cell_t sm_synapi_new_player(IPluginContext *pContext, const cell_t *params)
{
  int internal_id;
  int score;
  char* network_identifier;
  char* name;

  internal_id = params[1];
  score = params[2];
  pContext->LocalToString(params[3], &network_identifier);
  pContext->LocalToString(params[4], &name);

  synapi_new_player(g_synapi.handle,
                    SYNAPI_PLAYER_INTERNAL_ID, internal_id,
                    SYNAPI_PLAYER_SCORE, score,
                    SYNAPI_PLAYER_NAME, name,
                    SYNAPI_PLAYER_NETWORK_ID, network_identifier,
                    SYNAPI_END);
  return true;
}

// native synapi_update_player_score(internal_id, score);
cell_t sm_synapi_update_player_score(IPluginContext *pContext, const cell_t *params)
{
  int internal_id;
  int score;

  internal_id = params[1];
  score = params[2];

  synapi_update_player(g_synapi.handle, internal_id,
                    SYNAPI_PLAYER_SCORE, score,
                    SYNAPI_END);
  return true;
}

// native synapi_update_player_name(internal_id, const String:name[]);
cell_t sm_synapi_update_player_name(IPluginContext *pContext, const cell_t *params)
{
  int internal_id;
  char* name;

  internal_id = params[1];
  pContext->LocalToString(params[2], &name);

  synapi_update_player(g_synapi.handle, internal_id,
                    SYNAPI_PLAYER_NAME, name,
                    SYNAPI_END);
  return true;
}

// native synapi_delete_player(internal_id);
cell_t sm_synapi_delete_player(IPluginContext *pContext, const cell_t *params)
{
  synapi_delete_player(g_synapi.handle, params[1]);
  return true;
}




// native synapi_heartbeat();
cell_t sm_synapi_heartbeat(IPluginContext *pContext, const cell_t *params)
{
  synapi_heartbeat(g_synapi.handle);
  return true;
}


const sp_nativeinfo_t sm_synapi_natives[] = {
  {"synapi_init", sm_synapi_init},
  {"synapi_init_with_api_key", sm_synapi_init_with_api_key},
  {"synapi_get_api_key", sm_synapi_get_api_key},
  {"synapi_free", sm_synapi_free},
  {"synapi_queued", sm_synapi_queued},
  {"synapi_new_server", sm_synapi_new_server},
  {"synapi_update_server", sm_synapi_update_server},
  {"synapi_update_server_name", sm_synapi_update_server_name},
  {"synapi_update_server_level", sm_synapi_update_server_level},
  {"synapi_new_player", sm_synapi_new_player},
  {"synapi_update_player_score", sm_synapi_update_player_score},
  {"synapi_update_player_name", sm_synapi_update_player_name},
  {"synapi_delete_player", sm_synapi_delete_player},
  {"synapi_heartbeat", sm_synapi_heartbeat},
  {NULL, NULL},
};
