//
//  NSObject+BDVideoPlayer_ios.h
//  libcocos2d iOS
//
//  Created by 毛安杰 on 2019/4/25.
//

#import <BDCloudMediaPlayer/BDCloudMediaPlayer.h>

@interface BDUIVideoViewWrapperIos : NSObject<UIGestureRecognizerDelegate>

@property (strong,nonatomic) BDCloudMediaPlayerController * mediaPlayer;


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
