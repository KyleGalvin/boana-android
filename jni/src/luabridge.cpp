//luabridge.cpp

//load our lua environment
extern "C" {
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "SDL.h"//this is needed to retrieve the SDL-enabled JNI environment

//allow binding to and from the java application environment
#include <jni.h>
#include <android/log.h>

//Create terse logging functions that display on the android debugger
#define TAG  "Engine"
#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, TAG,__VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG  , TAG,__VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO   , TAG,__VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN   , TAG,__VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR  , TAG,__VA_ARGS__)

//------------------		Java layer access			------------------//

//filesystem access goes through the java API (Engine.readFile method)
const char* get_script(const char* src){
	JNIEnv *menv = (JNIEnv*)(SDL_AndroidGetJNIEnv()); 
	jclass mclass = (*menv).FindClass ("com/littlereddevshed/androidEngine/Engine");
	jmethodID mmethod = (*menv).GetStaticMethodID(mclass,"readFile", "(Ljava/lang/String;)Ljava/lang/String;");

	jstring luaFile = (jstring) (*menv).CallStaticObjectMethod(
		mclass,
		mmethod,
		(*menv).NewStringUTF(src)
	);
	return (*menv).GetStringUTFChars(luaFile, 0);

}


//------------------		Lua environment utilities	------------------//

lua_State* L;//lua state machine singleton

//execute a string of lua with our lua state machine
int lua_exec(const char* script){
	int result = luaL_loadstring(L,script) || lua_pcall(L, 0, 0, 0);
	if(result){
		const char* error = (lua_tostring(L, -1));
		lua_pop(L, 1);
		LOGE("Lua Error %s", error);
	}
	return 0;
}

//filesystem access goes through the java API (Engine.readFile method)
//This does the same as the above get_script function, but the request/response originates from the Lua environment's 'require' method.
int lua_get_script(lua_State* Lua){
	const char* fileName = lua_tostring(Lua, 1);
	LOGI("requesting %s",fileName);
	JNIEnv *menv = (JNIEnv*)(SDL_AndroidGetJNIEnv()); 
	jclass mclass = (*menv).FindClass ("com/littlereddevshed/androidEngine/Engine");
	jmethodID mmethod = (*menv).GetStaticMethodID(mclass,"readFile", "(Ljava/lang/String;)Ljava/lang/String;");

	//Call the java method. This returns a script, or an empty string if no script exists.
	jstring luaFile = (jstring) (*menv).CallStaticObjectMethod(
		mclass,
		mmethod,
		(*menv).NewStringUTF(fileName)
	);

	const char * src = (*menv).GetStringUTFChars(luaFile, 0);
	LOGI("script:",src);
	jsize length = (*menv).GetStringUTFLength(luaFile);
	if (length > 0) {
		lua_pushlstring(Lua,src,length);
		return 1;//success; run the script
	}else{
		return 0;//failure; Lua's 'require' method will move on to the next source in search of the requested script.
	}
}

//This is used once to boostrap the first lua script.
//Once bootstrapped, scripts are pulled using lua's 'require' method.
void lua_run_script(const char* filename){
	const char* script = get_script(filename);
	lua_exec(get_script(filename));
}

//redirect lua print to android log
int lua_print(lua_State* Lua){
	const char* text = lua_tostring(Lua, 1);
	LOGI(text);
	return 0;
}

//initialize lua state machine
void lua_init(const char* script)
{
	LOGI("Init lua state %s", script);
    L = lua_open();
    luaL_openlibs(L);

    //create a lua function to print to android log
    lua_pushcfunction(L, lua_print);
	lua_setglobal(L, "_lua_print");

	//redirect any lua print statements to the android log function
	//by overriding lua's native print function
	lua_exec(
			"print = function(...)\n"
				"_lua_print(table.concat({...}, '\t'))\n"
			"end\n"
			);

	//create a lua function for loading files from the native FS
	lua_pushcfunction(L, lua_get_script);
	lua_setglobal(L, "_lua_get_script");

	//set a new source for Lua's 'require' function to search. 
	//This allows Lua to look for lua packages in the project's assets folder.	
	lua_exec(
		"table.insert(package.loaders, 1, function(name) \n"
		"   local module = _lua_get_script(name .. '.lua')"
		"	print('custom package loader')\n"
		"	if module then\n"
		"		return function()\n "
		"			local f, e = loadstring(module)\n "
		" 			if f then\n"
		"				return f()\n "
		"			else\n "
		" 				print(e)\n"
		"			end\n"
		"		end\n"
		"	end\n"
		"end)\n"
	);

	//Launch the Lua interpreter with our startup script.
	lua_run_script(script);
    LOGI("Done init lua state");
}

int SDL_main(int argc, char* args[]){
	lua_init("main.lua");
	return 0;
}
