//
//  NSObject+TXVideoPlayer_ios_mm.m
//  libcocos2d iOS
//
//  Created by 毛安杰 on 2019/4/22.
//

#import "TXVideoPlayer-ios.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS && !defined(CC_TARGET_OS_TVOS)

#include "VideoPlayer.h"
#include "platform/CCApplication.h"

USING_NS_CC;

@interface TXUIVideoViewWrapperIos ()<TXLivePlayListener>
@end

@implementation TXUIVideoViewWrapperIos
{
    int _left;
    int _top;
    int _width;
    int _height;
    bool _keepRatioEnabled;
    bool _fullscreen;
    CGRect _restoreRect;
    VideoPlayer* _videoPlayer;
    // 播放地址
    NSString    *_playUrl;
    // 播放类型
    TX_Enum_PlayType _playType;

}

-(id)init:(void*)videoPlayer
{
    if (self = [super init]) {
        self.txLivePlayer = nullptr;
        _videoPlayer = (VideoPlayer*)videoPlayer;
//        _keepRatioEnabled = false;
        
        self.isLivePlay = true;
        self.isRealtime = false;
    }
    
    return self;
}

-(void) dealloc
{
    [self cleanup];
    _videoPlayer = nullptr;
    [super dealloc];
}

-(BOOL)checkPlayUrl:(NSString*)playUrl {
    if (self.isLivePlay) {
        if (self.isRealtime) {
            _playType = PLAY_TYPE_LIVE_RTMP_ACC;
            if (!([playUrl containsString:@"txSecret"] || [playUrl containsString:@"txTime"])) {
//                ToastTextView *toast = [self toastTip:@"低延时拉流地址需要防盗链签名，详情参考 https://cloud.tencent.com/document/product/454/7880#RealTimePlay"];
//                toast.url = @"https://cloud.tencent.com/document/product/454/7880#RealTimePlay";
                return NO;
            }
            
        }
        else {
            if ([playUrl hasPrefix:@"rtmp:"]) {
                _playType = PLAY_TYPE_LIVE_RTMP;
            } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && ([playUrl rangeOfString:@".flv"].length > 0)) {
                _playType = PLAY_TYPE_LIVE_FLV;
            } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".m3u8"].length > 0) {
                _playType = PLAY_TYPE_VOD_HLS;
            } else{
//                [self toastTip:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!"];
                return NO;
            }
        }
    } else {
        if ([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) {
            if ([playUrl rangeOfString:@".flv"].length > 0) {
                _playType = PLAY_TYPE_VOD_FLV;
            } else if ([playUrl rangeOfString:@".m3u8"].length > 0){
                _playType= PLAY_TYPE_VOD_HLS;
            } else if ([playUrl rangeOfString:@".mp4"].length > 0){
                _playType= PLAY_TYPE_VOD_MP4;
            } else {
//                [self toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!"];
                return NO;
            }
            
        } else {
            _playType = PLAY_TYPE_LOCAL_VIDEO;
        }
    }
    
    return YES;
}


-(void) setURL:(int)videoSource :(std::string &)videoUrl
{
    [self cleanup];
    
    _playUrl = [NSString stringWithString:@(videoUrl.c_str())];
    
    self.txLivePlayer = [[TXLivePlayer alloc] init];
    
    TXLivePlayConfig*  _config = [[TXLivePlayConfig alloc] init];
    // 自动模式
    _config.bAutoAdjustCacheTime   = YES;
    _config.minAutoAdjustCacheTime = 1;
    _config.maxAutoAdjustCacheTime = 5;
    //极速模式
//    _config.bAutoAdjustCacheTime   = YES;
//    _config.minAutoAdjustCacheTime = 1;
//    _config.maxAutoAdjustCacheTime = 1;
    //流畅模式
//    _config.bAutoAdjustCacheTime   = NO;
//    _config.minAutoAdjustCacheTime = 5;
//    _config.maxAutoAdjustCacheTime = 5;
    
    [self.txLivePlayer setConfig:_config];

    [self.txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
}

-(void) play
{
    if (![self checkPlayUrl:_playUrl]) {
        return;
    }
    
    if (self.txLivePlayer != NULL) {
        
        self.txLivePlayer.delegate = self;
        
        if (_fullscreen)
        {
//            self.txLivePlayer.scalingMode = BDCloudMediaPlayerScalingModeFill;
//            [self.mediaPlayer.view setFrame:[[UIScreen mainScreen] bounds]];
        }
        else
        {
//            [self setKeepRatioEnabled:_keepRatioEnabled];
//            [self.mediaPlayer.view setFrame:CGRectMake(_left, _top, _width, _height)];
        }
        
        auto eaglview = cocos2d::Application::getInstance()->getView();
        //    auto eaglview = (CCEAGLView *) view->getEAGLView();
        //    [eaglview addSubview:self.moviePlayer.view];
        //    [eaglview addSubview:self.mediaPlayer.view];
//        [eaglview superview] viewWithTag:10];
        
        if (self.isLivePlay) {
            [self.txLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:[[eaglview superview] viewWithTag:10] insertIndex:0];
        }

        
        int result = [self.txLivePlayer startPlay:_playUrl type:_playType];

        if( result != 0)
        {
            NSLog(@"播放器启动失败");
            return;
        }
    }

}

-(void) setVisible:(BOOL)visible
{
    if (self.txLivePlayer != NULL) {
        auto eaglview = cocos2d::Application::getInstance()->getView();
        UIView* videoView = [[eaglview superview] viewWithTag:10];
        [videoView setHidden:!visible];
        
        if (!visible) {
            [self pause];
        }
    }
}

- (void) setFrame:(int) left :(int) top :(int) width :(int) height
{
    if (_left == left && _width == width && _top == top && _height == height)
        return;
    
    _left = left;
    _width = width;
    _top = top;
    _height = height;
    
    auto eaglview = cocos2d::Application::getInstance()->getView();
    UIView* videoView = [[eaglview superview] viewWithTag:10];

    if (videoView != nullptr) {
        if (_fullscreen)
            [videoView setFrame:[[UIScreen mainScreen] bounds]];
        else
            [videoView setFrame:CGRectMake(left, top, width, height)];
    }
}

- (void) pause
{
    if (self.txLivePlayer != NULL) {
//        if([self.mediaPlayer playbackState] == BDCloudMediaPlayerPlaybackStatePlaying) {
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PAUSED);
//        }
        
        [self.txLivePlayer pause];
    }
}
- (void) resume
{
    if (self.txLivePlayer != NULL) {
        [self.txLivePlayer resume];
    }
}
- (void) stop
{
    if (self.txLivePlayer != NULL) {
        [self.txLivePlayer stopPlay];
//        [self seekTo:0];
        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::STOPPED);
    }
}
- (BOOL) isPlaying
{
    return TRUE;
}
- (void) seekTo:(float) sec
{
    
}
- (float) currentTime
{
    return 0.0;
}

- (float) duration
{
    return -1;
}


- (void) setKeepRatioEnabled:(BOOL) enabled
{
    
}

- (void) setFullScreenEnabled:(BOOL) enabled
{
    
}

- (BOOL) isFullScreenEnabled
{
    
}

// added by anjay
// 调整视频播放组件层级
- (void) setZOrderOnTop:(BOOL) top
{
    auto eaglview = cocos2d::Application::getInstance()->getView();
    UIView* uiParentView = [eaglview superview];
    UIView* uiView = [[eaglview superview] viewWithTag:10];
    if (top) {
        // 置顶
        [uiParentView bringSubviewToFront:(uiView)];
    }
    else {
        // 后置
        [uiParentView sendSubviewToBack:(uiView)];
    }
}
// added end

-(void) cleanup
{

    if (self.txLivePlayer != nullptr) {
//        [self removeRegisteredObservers];
        
        [self.txLivePlayer stopPlay];
        [self.txLivePlayer removeVideoWidget];
        self.txLivePlayer = nullptr;
    }
}

-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"// 已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN) {
            NSLog(@"// 已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
            NSLog(@"// 渲染首个视频数据包(IDR)");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN) {
            NSLog(@"// 视频播放开始");
//            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::READY_TO_PLAY);
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PLAYING);
        }
        else if (EvtID == PLAY_EVT_PLAY_PROGRESS) {
            NSLog(@"// 视频播放进度");
        }
        else if (EvtID == PLAY_EVT_PLAY_END || EvtID == PLAY_ERR_NET_DISCONNECT) {
            NSLog(@"// 视频播放结束");
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
        }
        else if (EvtID == PLAY_EVT_PLAY_LOADING) {
            NSLog(@"// 视频播放loading");
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::META_LOADED);
        }
    
    });
}


@end

#endif
