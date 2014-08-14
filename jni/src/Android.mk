LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

APP_PLATFORM := android-8

LOCAL_MODULE := main

SDL_PATH := ../SDL
LUA_PATH := ../lua

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include $(LOCAL_PATH)/$(LUA_PATH)/include

# Add your application source files here...
LOCAL_SRC_FILES := $(SDL_PATH)/src/main/android/SDL_android_main.c \
	luabridge.cpp

LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image EGL GLESv2

LOCAL_LDLIBS := -lEGL -lGLESv1_CM -lGLESv2 -llog $(LOCAL_PATH)/$(LUA_PATH)/libluajit.a

include $(BUILD_SHARED_LIBRARY)
