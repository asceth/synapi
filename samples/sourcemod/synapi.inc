/**
   Call this FIRST!
   If api_key is NULL then you should follow up with synapi_new_server
*/

native synapi_init();
native synapi_init_with_api_key(const String:api_key[]);

/**
   Creates a new server
   Use when you do not have an api key already.
*/
native synapi_new_server();

/**
   Updates a server's information
 */
native synapi_update_server({String,_}:...);

/**
   Use when a player connects with information about player
 */
native synapi_player({String,_}:...);

/**
   Update a player's information (name, score, etc)
 */
native synapi_update_player(internal_id, {String,_}:...);

/**
   Use when a player disconnects from the server
 */
native synapi_delete_player(internal_id);

/**
   This should be called periodically so the server is considered online
 */
native synapi_heartbeat();
