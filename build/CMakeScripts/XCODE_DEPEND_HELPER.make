# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to, avoiding a bug in XCode 1.5
all.Debug: \
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/active_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/basic_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/bot_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/roster_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Debug/Demo_Hello.app/Contents/MacOS/Demo_Hello

all.Release: \
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/active_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/basic_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/bot_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/roster_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Release/Demo_Hello.app/Contents/MacOS/Demo_Hello

all.MinSizeRel: \
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/active_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/basic_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/bot_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/roster_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/MinSizeRel/Demo_Hello.app/Contents/MacOS/Demo_Hello

all.RelWithDebInfo: \
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/active_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/basic_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/bot_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/roster_example\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/RelWithDebInfo/Demo_Hello.app/Contents/MacOS/Demo_Hello

# For each target create a dummy rule so the target does not have to exist
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/Debug/libGameSynAPIStatic.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/MinSizeRel/libGameSynAPIStatic.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/RelWithDebInfo/libGameSynAPIStatic.a:
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/Release/libGameSynAPIStatic.a:


# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/active_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/active_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/basic_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/basic_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/bot_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/bot_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/roster_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Debug/roster_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Debug/Demo_Hello.app/Contents/MacOS/Demo_Hello:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/Debug/libGameSynAPIStatic.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Debug/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Debug/Demo_Hello.app/Contents/MacOS/Demo_Hello


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/active_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/active_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/basic_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/basic_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/bot_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/bot_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/roster_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/Release/roster_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Release/Demo_Hello.app/Contents/MacOS/Demo_Hello:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/Release/libGameSynAPIStatic.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/Release/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/Release/Demo_Hello.app/Contents/MacOS/Demo_Hello


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/active_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/active_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/basic_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/basic_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/bot_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/bot_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/roster_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/MinSizeRel/roster_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/MinSizeRel/Demo_Hello.app/Contents/MacOS/Demo_Hello:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/MinSizeRel/libGameSynAPIStatic.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/MinSizeRel/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/MinSizeRel/Demo_Hello.app/Contents/MacOS/Demo_Hello


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/active_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/active_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/basic_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/basic_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/bot_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/bot_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/roster_example:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/bin/RelWithDebInfo/roster_example


/Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/RelWithDebInfo/Demo_Hello.app/Contents/MacOS/Demo_Hello:\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/lib/RelWithDebInfo/libGameSynAPIStatic.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libStrophe.a\
	/Users/jlong/development/personal/cplusplus/gamesyn_api/build/deps/libstrophe/lib/RelWithDebInfo/libExpat.a
	/bin/rm -f /Users/jlong/development/personal/cplusplus/gamesyn_api/build/bin/RelWithDebInfo/Demo_Hello.app/Contents/MacOS/Demo_Hello


