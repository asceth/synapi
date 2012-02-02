public Extension:__ext_synapi =
  {
    name = "synapi",
    file = "synapi.ext",
    autoload = 1,
    required = 1,
  };

/**
   Call this FIRST!
   If api_key is NULL then you should follow up with synapi_new_server
*/

native synapi_init(pool_size);
native synapi_init_with_api_key(const String:api_key[], pool_size);

/**
   Gets the api key stored, call on plugin unload
*/
native synapi_get_api_key(String:api_key[]);

/**
   Call this on plugin end, frees up resources being used
*/
native synapi_free();

/**
   Shows you how many pending api requests are waiting to finish
 */
native int:synapi_queued();



/**
   Creates a new server
   Use when you do not have an api key already.
*/
native synapi_new_server();

/**
   Updates a server's information - server_spawn
 */
native synapi_update_server(slots, const String:game_identifier[], const String:ip[], const String:port[], const String:name[]);

/**
   Updates a server's name - server_cvar (specific)
 */
native synapi_update_server_name(const String:name[]);

/**
   Server changed levels - game_newmap
 */
native synapi_update_server_level(const String:level_name[]);




/**
   Use when a player connects with information about player - player_connect
 */
native synapi_new_player(internal_id, score, const String:network_identifier[], const String:name[]);

/**
   Update a player's score - player_score
 */
native synapi_update_player_score(internal_id, score);

/**
   Update a player's name - player_changename
 */
native synapi_update_player_name(internal_id, const String:name[]);

/**
   Use when a player disconnects from the server
 */
native synapi_delete_player(internal_id);




/**
   This should be called periodically so the server is considered online
 */
native synapi_heartbeat();
