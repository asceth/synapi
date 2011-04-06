#include "prereq.h"
#include "hello_application.h"

HelloApplication::HelloApplication()
{
  _sent = false;
}

HelloApplication::~HelloApplication()
{
}

void HelloApplication::initialise()
{
  _root = new GameSyn::Root();
  _root->initialise();
  _root->connect("test@gamesyn.net", "test");
}

void HelloApplication::loop()
{
  while(true)
    {
      _root->update(100);

      if(_root->connected() && !_sent)
        {
          xmpp_stanza_t* reply, *body, *text;
          reply = xmpp_stanza_new(_root->context());
          xmpp_stanza_set_name(reply, "message");
          xmpp_stanza_set_type(reply, "chat");
          xmpp_stanza_set_attribute(reply, "to", "asceth@gamesyn.net");

          body = xmpp_stanza_new(_root->context());
          xmpp_stanza_set_name(body, "body");

          text = xmpp_stanza_new(_root->context());
          xmpp_stanza_set_text(text, "hello from the gamesyn api!!");
          xmpp_stanza_add_child(body, text);
          xmpp_stanza_add_child(reply, body);

          xmpp_send(_root->connection(), reply);
          xmpp_stanza_release(reply);
          _sent = true;
        }
    }

  shutdown();
}

void HelloApplication::shutdown()
{
  _root->shutdown();
}
