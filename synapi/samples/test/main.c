#include "synapi.h"

int main(int argc, char* argv[])
{
  synapi_global_init();
  synapi_t* handle = synapi_init(NULL, 5);
  synapi_url(handle, "http://127.0.0.1", "Host: api.serversyn.local");
  //synapi_url(handle, "http://localhost:3000", "Host: localhost:3000");
  //synapi_url(handle, "http://api.serversyn.com", "Host: api.serversyn.com");

  synapi_new_server(handle);

  synapi_update_server(handle, SYNAPI_SERVER_GAME, "zombie_master", SYNAPI_SERVER_IP, "0.0.0.0", SYNAPI_SERVER_PORT, "27015", SYNAPI_SERVER_NAME, "GameSyn API Test", SYNAPI_SERVER_SLOTS, 16, SYNAPI_SERVER_LEVEL, "zm_plundergrounds_b1", SYNAPI_END);

  while(synapi_queued(handle) != 0)
    {
      synapi_perform(handle);
    }

  synapi_new_player(handle, SYNAPI_PLAYER_INTERNAL_ID, 1, SYNAPI_PLAYER_SCORE, 100, SYNAPI_PLAYER_NAME, "player1", SYNAPI_PLAYER_NETWORK_ID, "STEAM:0:1", SYNAPI_END);

  synapi_perform(handle);

  synapi_heartbeat(handle);

  synapi_update_player(handle, 1, SYNAPI_PLAYER_SCORE, 200, SYNAPI_END);

  while(synapi_queued(handle) != 0)
    {
      synapi_perform(handle);
    }

  synapi_free(handle);
  synapi_global_free();
}

