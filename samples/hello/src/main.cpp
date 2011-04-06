#include "prereq.h"
#include "hello_application.h"

#if GAMESYN_PLATFORM == GAMESYN_PLATFORM_WIN32
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#endif

#if GAMESYN_PLATFORM == GAMESYN_PLATFORM_WIN32
INT WINAPI WinMain( HINSTANCE hInst, HINSTANCE, LPSTR strCmdLine, INT )
#else
int main(int argc, char *argv[])
#endif
{

	HelloApplication app;

	try
	{
		app.initialise();
    app.loop();
	}
	catch(GameSyn::Exception& ex)
	{
#if GAMESYN_PLATFORM == GAMESYN_PLATFORM_WIN32
        MessageBox( NULL, ex.getFullDescription().c_str(), "An exception has occured!", MB_OK | MB_ICONERROR | MB_TASKMODAL);
#else
        std::cerr << "An exception has occured: " <<
            ex.getFullDescription().c_str() << std::endl;
#endif
		app.shutdown();
	}

	return 0;
}
