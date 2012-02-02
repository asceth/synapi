#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include "xmpp.inc"


#define GLOBAL_CHAT_VERSION "0.2.0"
#define MAX_FILE_LEN 80
#define PLUGIN_TOKEN "globalchat"

#define DEFAULT_MUC "lobby@chat.localhost/S-VB"
#define MUC_NICK "S-VB"
#define JID "test@localhost/vodous_bokor"
#define PASSWORD "test"

public Plugin:myinfo =
{
  name = "Global Chat",
  author = "GameSyn (asceth)",
  description = "Allows servers to globally chat across each other.",
  version = GLOBAL_CHAT_VERSION,
  url = "http://www.gamesyn.com",
};

new Handle:cvar_enable;
new Handle:xmpp_client_global;

public OnPluginStart()
{
  CreateConVar("sm_global_chat_version", GLOBAL_CHAT_VERSION, _, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
  cvar_enable = CreateConVar("sm_global_chat_enable", "1", "Adds global chat to your server", FCVAR_PLUGIN, true, 0.0, true, 1.0);
  CreateTimer(3.0, OnPluginStart_Delayed);

  RegConsoleCmd("say", Command_Say);

  RegAdminCmd("sm_xmpp_say", Command_XMPPSay, ADMFLAG_GENERIC, "sm_xmpp_say 'message'");
  RegAdminCmd("sm_xmpp_muc_say", Command_XMPPMUCSay, ADMFLAG_GENERIC, "sm_xmpp_muc_say 'message'");
}

public OnPluginEnd()
{
  xmpp_disconnect(xmpp_client_global, PLUGIN_TOKEN);
  xmpp_destroy(xmpp_client_global, PLUGIN_TOKEN);
}

public Action:OnPluginStart_Delayed(Handle:timer)
{
  LogMessage("[GlobalChat] Looking up xmpp client");
  xmpp_client_global = xmpp_lookup(PLUGIN_TOKEN, JID);
  LogMessage("[GlobalChat] After looking up xmpp client");
  if(!xmpp_client_global)
    {
      LogMessage("[GlobalChat] Failed to find... creating xmpp client");
      xmpp_client_global = xmpp_create(PLUGIN_TOKEN, JID, PASSWORD);
    }
  if(xmpp_client_global)
    {
      LogMessage("[GlobalChat] - Loading Callbacks");
      xmpp_set_callback(xmpp_client_global, cb_xmpp_on_connect, PLUGIN_TOKEN, OnXMPPConnect);
      xmpp_set_callback(xmpp_client_global, cb_xmpp_on_disconnect, PLUGIN_TOKEN, OnXMPPDisconnect);
    }

  if(GetConVarInt(cvar_enable) > 0)
  {
    HookConVarChange(cvar_enable, AchievementsCvarChange);

    LogMessage("[GlobalChat] - Loaded");
    xmpp_connect(xmpp_client_global);
  }
}

public OnClientPutInServer(client)
{
  if (!xmpp_client_global)
    return;

  if (!xmpp_is_connected(xmpp_client_global))
    return;

  decl String:client_name[64];
  GetClientName(client, client_name, sizeof(client_name));

  decl String:msg[192];
  Format(msg, sizeof(msg), "%s joined the server", client_name);

  xmpp_muc_message(xmpp_client_global, DEFAULT_MUC, msg);
}

public OnClientDisconnect(client)
{
  if (!xmpp_client_global)
    return;

  if (!xmpp_is_connected(xmpp_client_global))
    return;

  decl String:client_name[64];
  GetClientName(client, client_name, sizeof(client_name));

  decl String:msg[192];
  Format(msg, sizeof(msg), "%s left the server", client_name);

  xmpp_muc_message(xmpp_client_global, DEFAULT_MUC, msg);
}

public OnMapStart()
{
  if (!xmpp_client_global)
    return;

  if (!xmpp_is_connected(xmpp_client_global))
    return;

  decl String:map_name[96];
  GetCurrentMap(map_name, sizeof(map_name));

  decl String:msg[192];
  Format(msg, sizeof(msg), "/me changed map to %s", map_name);

  xmpp_muc_message(xmpp_client_global, DEFAULT_MUC, msg);
}

public OnXMPPConnect()
{
  xmpp_message(xmpp_client_global, "asceth@localhost", "XMPP client loaded");

  xmpp_set_callback(xmpp_client_global, cb_xmpp_message_received, PLUGIN_TOKEN, OnXMPPMessageReceived);
  xmpp_set_callback(xmpp_client_global, cb_xmpp_muc_presence_avail, PLUGIN_TOKEN, OnXMPPMUCPresenceAvailable);
  xmpp_set_callback(xmpp_client_global, cb_xmpp_muc_presence_unavail, PLUGIN_TOKEN, OnXMPPMUCPresenceUnavailable);
  xmpp_set_callback(xmpp_client_global, cb_xmpp_muc_subject_changed, PLUGIN_TOKEN, OnXMPPMUCSubjectChanged);
  xmpp_set_callback(xmpp_client_global, cb_xmpp_muc_message_received, PLUGIN_TOKEN, OnXMPPMUCMessageReceived);

  xmpp_muc_connect(xmpp_client_global, DEFAULT_MUC);
}

public OnXMPPDisconnect(const String:reason[])
{
  PrintToServer("[GlobalChat] disconnected: %s", reason);
}

public OnXMPPMessageReceived(const String:from[], const String:message[])
{
  PrintToServer("Message: %s", message);
}

public OnXMPPMUCPresenceAvailable(const String:room[], const String:nick[])
{
  PrintToChatAll("[%s] %s joined the chat room.", room, nick);
  PrintToServer("[%s] %s joined the chat room.", room, nick);
}

public OnXMPPMUCPresenceUnavailable(const String:room[], const String:nick[])
{
  PrintToChatAll("[%s] %s left the chat room.", room, nick);
  PrintToServer("[%s] %s left the chat room.", room, nick);
}

public OnXMPPMUCSubjectChanged(const String:room[], const String:nick[], const String:subject[])
{
  PrintToChatAll("[%s] %s changed subject to %s", room, nick, subject);
  PrintToServer("[%s] %s changed subject to %s", room, nick, subject);
}

public OnXMPPMUCMessageReceived(const String:room[], const String:nick[], const String:message[])
{
  // ignore ourselves
  if(!StrEqual(nick, MUC_NICK))
  {
    decl String:message2[192];
    strcopy(message2, sizeof(message2), message);

    decl String:msg[192];
    if(ReplaceString(message2, sizeof(message2), "/me", "") > 0)
      {
        Format(msg, sizeof(msg), "\x04[%s]**%s \x01%s", room, nick, TrimString(message2));
      }
    else
      {
        Format(msg, sizeof(msg), "\x04[%s] %s: \x01%s", room, nick, message2);
      }
    PrintToChatAll(msg);
    PrintToServer(msg);
  }
}

public AchievementsCvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
  if (!xmpp_client_global)
    return;

  if (!xmpp_is_connected(xmpp_client_global))
    return;


  if(GetConVarInt(cvar_enable) <= 0)
    {
      xmpp_muc_disconnect(xmpp_client_global, DEFAULT_MUC);
    }
  else
    {
      xmpp_muc_connect(xmpp_client_global, DEFAULT_MUC);
    }
}

public Action:Command_Say(client, args)
{
  if(!client)
    return Plugin_Continue;

  if(!xmpp_client_global)
    return Plugin_Continue;

  if(!xmpp_is_connected(xmpp_client_global))
    return Plugin_Continue;

  decl String:text[192];
  if(!GetCmdArgString(text, sizeof(text)))
    return Plugin_Continue;

  new startidx = 0;
  if(text[strlen(text)-1] == '"')
  {
    text[strlen(text)-1] = '\0';
    startidx = 1;
  }

  new String:name[64];
  GetClientName(client, name, sizeof(name));

  decl String:msg[264];
  Format(msg, sizeof(msg), "%s: %s", name, text[startidx]);

  xmpp_muc_message(xmpp_client_global, DEFAULT_MUC, msg);
  return Plugin_Continue;
}

public Action:Command_XMPPSay(client, args)
{
  if(args < 1)
  {
    ReplyToCommand(client, "[SM] Usage: sm_xmpp_say 'message'");
    return Plugin_Handled;
  }

  if(!xmpp_client_global)
    return Plugin_Handled;

  if(!xmpp_is_connected(xmpp_client_global))
    return Plugin_Handled;

  decl String:message[192];
  GetCmdArg(1, message, sizeof(message));

  xmpp_message(xmpp_client_global, "asceth@localhost/Home", message);
  return Plugin_Handled;
}

public Action:Command_XMPPMUCSay(client, args)
{
  if(args < 1)
  {
    ReplyToCommand(client, "[SM] Usage: sm_xmpp_muc_say 'message'");
    return Plugin_Handled;
  }

  if(!xmpp_client_global)
    return Plugin_Handled;

  if(!xmpp_is_connected(xmpp_client_global))
    return Plugin_Handled;

  decl String:client_name[64];
  if(client != 0 && IsClientConnected(client))
  {
    GetClientName(client, client_name, sizeof(client_name));
  }
  else
  {
    strcopy(client_name, sizeof(client_name), "Console");
  }

  decl String:message[192];
  GetCmdArg(1, message, sizeof(message));

  decl String:msg[264];
  Format(msg, sizeof(msg), "%s: %s", client_name, message);

  xmpp_muc_message(xmpp_client_global, DEFAULT_MUC, msg);
  return Plugin_Handled;
}

