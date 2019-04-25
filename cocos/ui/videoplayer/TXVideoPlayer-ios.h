//
//  NSObject+TXVideoPlayer_ios_mm.h
//  libcocos2d iOS
//
//  Created by 毛安杰 on 2019/4/22.
//

#pragma once


//#include "base/ccMacros.h"
//#include "base/CCRef.h"
//#include <functional>
#include <string>
//#include <map>

//#import "VideoPlayer.h"

//#ifndef OBJC_CLASS
//#ifdef __OBJC__
//#define OBJC_CLASS(name) @class name
//#else
//#define OBJC_CLASS(name) class name
//#endif
//#endif // OBJC_CLASS


//#import <Foundation/Foundation.h>
//#import <MediaPlayer/MediaPlayer.h>
//#include "platform/CCApplication.h"
//#include "platform/ios/CCEAGLView-ios.h"
//#include "platform/CCFileUtils.h"



#import <TXLiteAVSDK_Smart/TXLivePlayer.h>


//NS_ASSUME_NONNULL_BEGIN

@interface TXUIVideoViewWrapperIos : NSObject<UIGestureRecognizerDelegate>


@property (strong,nonatomic) TXLivePlayer *  txLivePlayer;
@property (nonatomic, assign) BOOL isLivePlay;
@property (nonatomic, assign) BOOL isRealtime;



- (void) setFrame:(int) left :(int) top :(int) width :(int) height;
- (void) setURL:(int) videoSource :(std::string&) videoUrl;
- (void) play;
- (void) pause;
- (void) resume;
- (void) stop;
- (BOOL) isPlaying;
- (void) seekTo:(float) sec;
- (float) currentTime;
- (float) duration;
- (void) setVisible:(BOOL) visible;
- (void) setKeepRatioEnabled:(BOOL) enabled;
- (void) setFullScreenEnabled:(BOOL) enabled;
- (BOOL) isFullScreenEnabled;
- (void) cleanup;
// added by anjay
// 调整视频播放组件层级
- (void) setZOrderOnTop:(BOOL) top;
// added end
-(id) init:(void*) videoPlayer;

-(void) videoFinished:(NSNotification*) notification;
-(void) playStateChange:(NSNotification*) notification;


@end

//NS_ASSUME_NONNULL_END
