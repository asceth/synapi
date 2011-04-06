#ifndef _Hello_Application_H_
#define _Hello_Application_H_

class HelloApplication
{
public:
  HelloApplication();
  ~HelloApplication();

  void initialise();
  void shutdown();
  void loop();

protected:
  GameSyn::Root* _root;
  bool _sent;
};

#endif
