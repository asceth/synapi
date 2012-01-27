/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Sample Extension
 * Copyright (C) 2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#include "extension.h"

/**
 * @file extension.cpp
 * @brief Implement extension code here.
 */

SMSynapi g_synapi;		/**< Global singleton for extension's main interface */
SMEXT_LINK(&g_synapi);

extern const sp_nativeinfo_t sm_synapi_natives[];

// native synapi_init();
cell_t sm_synapi_init(IPluginContext *pContext, const cell_t *params)
{
  g_synapi.handle = synapi_init(NULL, 10);
  return true;
}

// native synapi_init_with_api_key(String);
cell_t sm_synapi_init_with_api_key(IPluginContext *pContext, const cell_t *params)
{
  char* api_key;
  pContext->LocalToString(params[1], &api_key);
  g_synapi.handle = synapi_init(api_key, 10);

  return true;
}

// native synapi_new_server();
cell_t sm_synapi_new_server(IPluginContext *pContext, const cell_t *params)
{
}

// native synapi_update_server(...);
cell_t sm_synapi_update_server(IPluginContext *pContext, const cell_t *params)
{
}

// native synapi_player(...);
cell_t sm_synapi_player(IPluginContext *pContext, const cell_t *params)
{
}

// native synapi_update_player(internal_id, ...);
cell_t sm_synapi_update_player(IPluginContext *pContext, const cell_t *params)
{
}

// native synapi_delete_player(internal_id);
cell_t sm_synapi_delete_player(IPluginContext *pContext, const cell_t *params)
{
}

// native synapi_heartbeat();
cell_t sm_synapi_heartbeat(IPluginContext *pContext, const cell_t *params)
{
}


const sp_nativeinfo_t sm_synapi_natives[] = {
  {"synapi_init", sm_synapi_init},
  {"synapi_init_with_api_key", sm_synapi_init_with_api_key},
  {"synapi_new_server", sm_synapi_new_server},
  {"synapi_update_server", sm_synapi_update_server},
  {"synapi_player", sm_synapi_player},
  {"synapi_update_player", sm_synapi_update_player},
  {"synapi_delete_player", sm_synapi_delete_player},
  {"synapi_heartbeat", sm_synapi_heartbeat},
  {NULL, NULL},
};
