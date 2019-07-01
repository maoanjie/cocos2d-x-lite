#include "scripting/js-bindings/auto/jsb_goldenlemon_auto.hpp"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "scripting/js-bindings/manual/jsb_conversions.hpp"
#include "scripting/js-bindings/manual/jsb_global.h"
#include "../../../ThirdUtil.h"
#include "../../../WeChatUtil.h"

se::Object* __jsb_ThirdUtil_proto = nullptr;
se::Class* __jsb_ThirdUtil_class = nullptr;

static bool js_goldenlemon_ThirdUtil_setIAPCallback(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::function<void (int, const std::string&)> arg0;
        do {
            if (args[0].isObject() && args[0].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[0]);
                jsFunc.toObject()->root();
                auto lambda = [=](int larg0, const std::string& larg1) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(2);
                    ok &= int32_to_seval(larg0, &args[0]);
                    ok &= std_string_to_seval(larg1, &args[1]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg0 = lambda;
            }
            else
            {
                arg0 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_setIAPCallback : Error processing arguments");
        ThirdUtil::setIAPCallback(arg0);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_setIAPCallback)

static bool js_goldenlemon_ThirdUtil_getLocation(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::function<void (const std::string&)> arg0;
        do {
            if (args[0].isObject() && args[0].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[0]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::string& larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg0 = lambda;
            }
            else
            {
                arg0 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getLocation : Error processing arguments");
        ThirdUtil::getLocation(arg0);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getLocation)

static bool js_goldenlemon_ThirdUtil_xgpushUnbindUserID(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string arg0;
        ok &= seval_to_std_string(args[0], &arg0);
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_xgpushUnbindUserID : Error processing arguments");
        ThirdUtil::xgpushUnbindUserID(arg0);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_xgpushUnbindUserID)

static bool js_goldenlemon_ThirdUtil_buyItemByIAP(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 2) {
        std::string arg0;
        std::function<void (int, const std::string&)> arg1;
        ok &= seval_to_std_string(args[0], &arg0);
        do {
            if (args[1].isObject() && args[1].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[1]);
                jsFunc.toObject()->root();
                auto lambda = [=](int larg0, const std::string& larg1) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(2);
                    ok &= int32_to_seval(larg0, &args[0]);
                    ok &= std_string_to_seval(larg1, &args[1]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg1 = lambda;
            }
            else
            {
                arg1 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_buyItemByIAP : Error processing arguments");
        bool result = ThirdUtil::buyItemByIAP(arg0, arg1);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_buyItemByIAP : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 2);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_buyItemByIAP)

static bool js_goldenlemon_ThirdUtil_getAppVersion(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        std::string result = ThirdUtil::getAppVersion();
        ok &= std_string_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getAppVersion : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getAppVersion)

static bool js_goldenlemon_ThirdUtil_savePhotoToAlbum(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 2) {
        std::string arg0;
        std::function<void (const std::string&)> arg1;
        ok &= seval_to_std_string(args[0], &arg0);
        do {
            if (args[1].isObject() && args[1].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[1]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::string& larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg1 = lambda;
            }
            else
            {
                arg1 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_savePhotoToAlbum : Error processing arguments");
        ThirdUtil::savePhotoToAlbum(arg0, arg1);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 2);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_savePhotoToAlbum)

static bool js_goldenlemon_ThirdUtil_getNetworkType(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        std::string result = ThirdUtil::getNetworkType();
        ok &= std_string_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getNetworkType : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getNetworkType)

static bool js_goldenlemon_ThirdUtil_xgpushBindUserID(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string arg0;
        ok &= seval_to_std_string(args[0], &arg0);
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_xgpushBindUserID : Error processing arguments");
        ThirdUtil::xgpushBindUserID(arg0);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_xgpushBindUserID)

static bool js_goldenlemon_ThirdUtil_getDeviceID(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        std::string result = ThirdUtil::getDeviceID();
        ok &= std_string_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getDeviceID : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getDeviceID)

static bool js_goldenlemon_ThirdUtil_vibrate(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    if (argc == 0) {
        ThirdUtil::vibrate();
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_vibrate)

static bool js_goldenlemon_ThirdUtil_phone(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string arg0;
        ok &= seval_to_std_string(args[0], &arg0);
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_phone : Error processing arguments");
        ThirdUtil::phone(arg0);
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_phone)

static bool js_goldenlemon_ThirdUtil_getPasteboard(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        std::string result = ThirdUtil::getPasteboard();
        ok &= std_string_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getPasteboard : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getPasteboard)

static bool js_goldenlemon_ThirdUtil_getBatteryLevel(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        float result = ThirdUtil::getBatteryLevel();
        ok &= float_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getBatteryLevel : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getBatteryLevel)

static bool js_goldenlemon_ThirdUtil_getNetLevel(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        std::string result = ThirdUtil::getNetLevel();
        ok &= std_string_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_getNetLevel : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_getNetLevel)

static bool js_goldenlemon_ThirdUtil_copy(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 1) {
        std::string arg0;
        ok &= seval_to_std_string(args[0], &arg0);
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_copy : Error processing arguments");
        bool result = ThirdUtil::copy(arg0);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_copy : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 1);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_copy)

static bool js_goldenlemon_ThirdUtil_checkLocationAvailable(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        bool result = ThirdUtil::checkLocationAvailable();
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_ThirdUtil_checkLocationAvailable : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_ThirdUtil_checkLocationAvailable)




bool js_register_goldenlemon_ThirdUtil(se::Object* obj)
{
    auto cls = se::Class::create("ThirdUtil", obj, nullptr, nullptr);

    cls->defineStaticFunction("setIAPCallback", _SE(js_goldenlemon_ThirdUtil_setIAPCallback));
    cls->defineStaticFunction("getLocation", _SE(js_goldenlemon_ThirdUtil_getLocation));
    cls->defineStaticFunction("xgpushUnbindUserID", _SE(js_goldenlemon_ThirdUtil_xgpushUnbindUserID));
    cls->defineStaticFunction("buyItemByIAP", _SE(js_goldenlemon_ThirdUtil_buyItemByIAP));
    cls->defineStaticFunction("getAppVersion", _SE(js_goldenlemon_ThirdUtil_getAppVersion));
    cls->defineStaticFunction("savePhotoToAlbum", _SE(js_goldenlemon_ThirdUtil_savePhotoToAlbum));
    cls->defineStaticFunction("getNetworkType", _SE(js_goldenlemon_ThirdUtil_getNetworkType));
    cls->defineStaticFunction("xgpushBindUserID", _SE(js_goldenlemon_ThirdUtil_xgpushBindUserID));
    cls->defineStaticFunction("getDeviceID", _SE(js_goldenlemon_ThirdUtil_getDeviceID));
    cls->defineStaticFunction("vibrate", _SE(js_goldenlemon_ThirdUtil_vibrate));
    cls->defineStaticFunction("phone", _SE(js_goldenlemon_ThirdUtil_phone));
    cls->defineStaticFunction("getPasteboard", _SE(js_goldenlemon_ThirdUtil_getPasteboard));
    cls->defineStaticFunction("getBatteryLevel", _SE(js_goldenlemon_ThirdUtil_getBatteryLevel));
    cls->defineStaticFunction("getNetLevel", _SE(js_goldenlemon_ThirdUtil_getNetLevel));
    cls->defineStaticFunction("copy", _SE(js_goldenlemon_ThirdUtil_copy));
    cls->defineStaticFunction("checkLocationAvailable", _SE(js_goldenlemon_ThirdUtil_checkLocationAvailable));
    cls->install();
    JSBClassType::registerClass<ThirdUtil>(cls);

    __jsb_ThirdUtil_proto = cls->getProto();
    __jsb_ThirdUtil_class = cls;

    se::ScriptEngine::getInstance()->clearException();
    return true;
}

se::Object* __jsb_WeChatUtil_proto = nullptr;
se::Class* __jsb_WeChatUtil_class = nullptr;

static bool js_goldenlemon_WeChatUtil_directShare(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 6) {
        int arg0 = 0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        std::string arg4;
        std::function<void (const std::string&)> arg5;
        do { int32_t tmp = 0; ok &= seval_to_int32(args[0], &tmp); arg0 = (int)tmp; } while(false);
        ok &= seval_to_std_string(args[1], &arg1);
        ok &= seval_to_std_string(args[2], &arg2);
        ok &= seval_to_std_string(args[3], &arg3);
        ok &= seval_to_std_string(args[4], &arg4);
        do {
            if (args[5].isObject() && args[5].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[5]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::string& larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg5 = lambda;
            }
            else
            {
                arg5 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_directShare : Error processing arguments");
        bool result = WeChatUtil::directShare(arg0, arg1, arg2, arg3, arg4, arg5);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_directShare : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 6);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_WeChatUtil_directShare)

static bool js_goldenlemon_WeChatUtil_shareMiniProgram(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 8) {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        std::string arg4;
        std::string arg5;
        int arg6 = 0;
        std::function<void (const std::string&)> arg7;
        ok &= seval_to_std_string(args[0], &arg0);
        ok &= seval_to_std_string(args[1], &arg1);
        ok &= seval_to_std_string(args[2], &arg2);
        ok &= seval_to_std_string(args[3], &arg3);
        ok &= seval_to_std_string(args[4], &arg4);
        ok &= seval_to_std_string(args[5], &arg5);
        do { int32_t tmp = 0; ok &= seval_to_int32(args[6], &tmp); arg6 = (int)tmp; } while(false);
        do {
            if (args[7].isObject() && args[7].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[7]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::string& larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg7 = lambda;
            }
            else
            {
                arg7 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_shareMiniProgram : Error processing arguments");
        bool result = WeChatUtil::shareMiniProgram(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_shareMiniProgram : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 8);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_WeChatUtil_shareMiniProgram)

static bool js_goldenlemon_WeChatUtil_isInstallWeChat(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 0) {
        bool result = WeChatUtil::isInstallWeChat();
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_isInstallWeChat : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 0);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_WeChatUtil_isInstallWeChat)

static bool js_goldenlemon_WeChatUtil_registerApp(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 2) {
        std::string arg0;
        bool arg1;
        ok &= seval_to_std_string(args[0], &arg0);
        ok &= seval_to_boolean(args[1], &arg1);
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_registerApp : Error processing arguments");
        bool result = WeChatUtil::registerApp(arg0, arg1);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_registerApp : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 2);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_WeChatUtil_registerApp)

static bool js_goldenlemon_WeChatUtil_sendAuthReq(se::State& s)
{
    const auto& args = s.args();
    size_t argc = args.size();
    CC_UNUSED bool ok = true;
    if (argc == 4) {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::function<void (const std::string&)> arg3;
        ok &= seval_to_std_string(args[0], &arg0);
        ok &= seval_to_std_string(args[1], &arg1);
        ok &= seval_to_std_string(args[2], &arg2);
        do {
            if (args[3].isObject() && args[3].toObject()->isFunction())
            {
                se::Value jsThis(s.thisObject());
                se::Value jsFunc(args[3]);
                jsFunc.toObject()->root();
                auto lambda = [=](const std::string& larg0) -> void {
                    se::ScriptEngine::getInstance()->clearException();
                    se::AutoHandleScope hs;
        
                    CC_UNUSED bool ok = true;
                    se::ValueArray args;
                    args.resize(1);
                    ok &= std_string_to_seval(larg0, &args[0]);
                    se::Value rval;
                    se::Object* thisObj = jsThis.isObject() ? jsThis.toObject() : nullptr;
                    se::Object* funcObj = jsFunc.toObject();
                    bool succeed = funcObj->call(args, thisObj, &rval);
                    if (!succeed) {
                        se::ScriptEngine::getInstance()->clearException();
                    }
                };
                arg3 = lambda;
            }
            else
            {
                arg3 = nullptr;
            }
        } while(false)
        ;
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_sendAuthReq : Error processing arguments");
        bool result = WeChatUtil::sendAuthReq(arg0, arg1, arg2, arg3);
        ok &= boolean_to_seval(result, &s.rval());
        SE_PRECONDITION2(ok, false, "js_goldenlemon_WeChatUtil_sendAuthReq : Error processing arguments");
        return true;
    }
    SE_REPORT_ERROR("wrong number of arguments: %d, was expecting %d", (int)argc, 4);
    return false;
}
SE_BIND_FUNC(js_goldenlemon_WeChatUtil_sendAuthReq)




bool js_register_goldenlemon_WeChatUtil(se::Object* obj)
{
    auto cls = se::Class::create("WeChatUtil", obj, nullptr, nullptr);

    cls->defineStaticFunction("directShare", _SE(js_goldenlemon_WeChatUtil_directShare));
    cls->defineStaticFunction("shareMiniProgram", _SE(js_goldenlemon_WeChatUtil_shareMiniProgram));
    cls->defineStaticFunction("isInstallWeChat", _SE(js_goldenlemon_WeChatUtil_isInstallWeChat));
    cls->defineStaticFunction("registerApp", _SE(js_goldenlemon_WeChatUtil_registerApp));
    cls->defineStaticFunction("sendAuthReq", _SE(js_goldenlemon_WeChatUtil_sendAuthReq));
    cls->install();
    JSBClassType::registerClass<WeChatUtil>(cls);

    __jsb_WeChatUtil_proto = cls->getProto();
    __jsb_WeChatUtil_class = cls;

    se::ScriptEngine::getInstance()->clearException();
    return true;
}

bool register_all_goldenlemon(se::Object* obj)
{
    // Get the ns
    se::Value nsVal;
    if (!obj->getProperty("gljsb", &nsVal))
    {
        se::HandleObject jsobj(se::Object::createPlainObject());
        nsVal.setObject(jsobj);
        obj->setProperty("gljsb", nsVal);
    }
    se::Object* ns = nsVal.toObject();

    js_register_goldenlemon_WeChatUtil(ns);
    js_register_goldenlemon_ThirdUtil(ns);
    return true;
}

#endif //#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
