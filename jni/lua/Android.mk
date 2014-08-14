LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := lua
LOCAL_MODULE_FILENAME := liblua
LOCAL_LDLIBS := $(LOCAL_PATH)/libluajit.a

include $(BUILD_SHARED_LIBRARY)