#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include "synapi.inc"

#define SYNAPI_SM_VERSION "0.1.0"
#define POOL_SIZE 15
#define CONFIG_FILE "addons/sourcemod/configs/synapi.cfg"

public Plugin:myinfo =
  {
    name = "Sourcemod SynAPI",
    author = "asceth",
    description = "Allows servers to use the ServerSyn API",
    version = SYNAPI_SM_VERSION,
    url = "http://www.serversyn.com"
  };

new Handle:cvar_enable;

public OnPluginStart()
{
  CreateConVar("sm_synapi_version", SYNAPI_SM_VERSION, _, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
  //cvar_enable = CreateConVar("sm_synapi_enable", "1", "Enables use of the ServerSyn API", FCVAR_PLUGIN, true, 0.0, true, 1.0);

  LogMessage("[SynAPI] Initializing...");

  new String:api_key[256];
  if (find_api_key(api_key, 255))
    {
      synapi_init_with_api_key(api_key, POOL_SIZE);
    }
  else
    {
      synapi_init(POOL_SIZE);
      LogMessage("[SynAPI] Registering new server...");
      synapi_new_server();
    }

  CreateTimer(10.0, UpdateServer);
  CreateTimer(60.0 * 5.0, Heartbeat, _, TIMER_REPEAT);

  HookEvent("player_score", Event_PlayerScore, EventHookMode_Pre);
  HookEvent("player_changename", Event_PlayerChangeName, EventHookMode_Pre);

  // doesn't seem to hook hostname...
  // HookEvent("server_cvar", Event_ServerCvar, EventHookMode_Pre);
}

public OnPluginEnd()
{
  store_api_key();
  synapi_free();
}


// API Usage
public Action:UpdateServer(Handle:timer)
{
  new Handle:hostname_handle = FindConVar("hostname");
  new Handle:ip_handle = FindConVar("ip");
  new Handle:port_handle = FindConVar("hostport");


  decl String:game_identifier[64];
  decl String:name[64];
  decl String:ip[64];
  decl String:port[10];

  GetGameFolderName(game_identifier, sizeof(game_identifier));
  GetConVarString(hostname_handle, name, sizeof(name));
  GetConVarString(ip_handle, ip, sizeof(ip));
  GetConVarString(port_handle, port, sizeof(port));

  LogMessage("[SynAPI] Updating server information...");

  synapi_update_server(MaxClients, game_identifier, ip, port, name);

  CloseHandle(hostname_handle);
  CloseHandle(ip_handle);
  CloseHandle(port_handle);

  return Plugin_Stop;
}

public Action:Heartbeat(Handle:timer)
{
  new Handle:hostname_handle = FindConVar("hostname");
  decl String:name[64];
  GetConVarString(hostname_handle, name, sizeof(name));


  LogMessage("[SynAPI] Heartbeat");
  // not really a heartbeat...
  synapi_update_server_name(name);


  CloseHandle(hostname_handle);
  return Plugin_Continue;
}

public OnMapStart()
{
  decl String:level[64];
  GetCurrentMap(level, sizeof(level));

  LogMessage("[SynAPI] updating map...");
  synapi_update_server_level(level);
}

public Action:Event_ServerCvar(Handle:event, const String:name[], bool:dontBroadcast)
{
  decl String:cvar[64];
  decl String:value[64];
  GetEventString(event, "cvarname", cvar, sizeof(cvar));
  GetEventString(event, "cvarvalue", value, sizeof(value));

  LogMessage("[SynAPI] cvar updating... %s", cvar);
  if (StrEqual(cvar, "hostname"))
    {
      LogMessage("[SynAPI] updating server name...");
      synapi_update_server_name(value);
    }

  return Plugin_Continue;
}


public OnClientPostAdminCheck(client_id)
{
  decl String:pname[64];
  decl String:network_id[64];
  decl String:ip[64];

  GetClientName(client_id, pname, sizeof(pname));
  GetClientAuthString(client_id, network_id, sizeof(network_id));
  GetClientIP(client_id, ip, sizeof(ip));

  LogMessage("[SynAPI] new player...");
  synapi_new_player(client_id, 0, network_id, pname);
}

public OnClientDisconnect(client_id)
{
  LogMessage("[SynAPI] deleting player...");
  synapi_delete_player(client_id);
}

public Action:Event_PlayerScore(Handle:event, const String:name[], bool:dontBroadcast)
{
  new internal_id = GetEventInt(event, "userid");
  new score = GetEventInt(event, "score");

  LogMessage("[SynAPI] updating player score...");
  synapi_update_player_score(internal_id, score);

  return Plugin_Continue;
}

public Action:Event_PlayerChangeName(Handle:event, const String:name[], bool:dontBroadcast)
{
  decl String:pname[64];
  new internal_id = GetEventInt(event, "userid");
  GetEventString(event, "newname", pname, sizeof(pname));

  LogMessage("[SynAPI] updating player name...");
  synapi_update_player_name(internal_id, pname);

  return Plugin_Continue;
}


// Helpers
public store_api_key()
{
  decl String:api_key[256];
  synapi_get_api_key(api_key, 255);

  new Handle:kv = CreateKeyValues("SynAPI");

  FileToKeyValues(kv, CONFIG_FILE);
  KvSetString(kv, "api_key", api_key);
  KeyValuesToFile(kv, CONFIG_FILE);

	CloseHandle(kv);
}

public bool:find_api_key(String:api_key[], maxlength)
{
  new bool:result = false;

  // need to try and lookup the api key
  new Handle:kv = CreateKeyValues("SynAPI");
	if (FileToKeyValues(kv, CONFIG_FILE))
    {
      KvGetString(kv, "api_key", api_key, maxlength, "none");
      if (StrEqual(api_key, "none", false))
        {
          result = false;
        }
      else
        {
          result = true;
        }
    }
  else
    {
      KvSetString(kv, "api_key", "none");
      KeyValuesToFile(kv, CONFIG_FILE);
      result = false;
    }

	CloseHandle(kv);
	return result;
}
