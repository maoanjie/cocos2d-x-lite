#pragma once
#include "base/ccConfig.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"

extern se::Object* __jsb_ThirdUtil_proto;
extern se::Class* __jsb_ThirdUtil_class;

bool js_register_ThirdUtil(se::Object* obj);
bool register_all_goldenlemon(se::Object* obj);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_setIAPCallback);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getLocation);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_xgpushUnbindUserID);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_buyItemByIAP);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getAppVersion);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_savePhotoToAlbum);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getNetworkType);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_xgpushBindUserID);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getDeviceID);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_vibrate);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_phone);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getPasteboard);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getBatteryLevel);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_getNetLevel);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_copy);
SE_DECLARE_FUNC(js_goldenlemon_ThirdUtil_checkLocationAvailable);

extern se::Object* __jsb_WeChatUtil_proto;
extern se::Class* __jsb_WeChatUtil_class;

bool js_register_WeChatUtil(se::Object* obj);
bool register_all_goldenlemon(se::Object* obj);
SE_DECLARE_FUNC(js_goldenlemon_WeChatUtil_directShare);
SE_DECLARE_FUNC(js_goldenlemon_WeChatUtil_shareMiniProgram);
SE_DECLARE_FUNC(js_goldenlemon_WeChatUtil_isInstallWeChat);
SE_DECLARE_FUNC(js_goldenlemon_WeChatUtil_registerApp);
SE_DECLARE_FUNC(js_goldenlemon_WeChatUtil_sendAuthReq);

#endif //#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
