//
//  NSObject+BDVideoPlayer_ios.m
//  libcocos2d iOS
//
//  Created by 毛安杰 on 2019/4/25.
//

#import "BDVideoPlayer-ios.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS && !defined(CC_TARGET_OS_TVOS)

#include "VideoPlayer.h"
#include "platform/CCApplication.h"

USING_NS_CC;

#if PLAYER_TYPE == BD_VIDEO_PLAYER

@implementation BDUIVideoViewWrapperIos
{
    int _left;
    int _top;
    int _width;
    int _height;
    bool _keepRatioEnabled;
    bool _fullscreen;
    CGRect _restoreRect;
    VideoPlayer* _videoPlayer;
}

-(id)init:(void*)videoPlayer
{
    if (self = [super init]) {
        self.mediaPlayer = nullptr;
        _videoPlayer = (VideoPlayer*)videoPlayer;
        _keepRatioEnabled = false;
    }
    
    return self;
}

-(void) cleanup
{
    if (self.mediaPlayer != nullptr) {
        [self removeRegisteredObservers];
        
        [self.mediaPlayer stop];
        [self.mediaPlayer.view removeFromSuperview];
        self.mediaPlayer = nullptr;
    }
}

-(void) removeRegisteredObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BDCloudMediaPlayerPlaybackDidFinishNotification
                                                  object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BDCloudMediaPlayerPlaybackStateDidChangeNotification
                                                  object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BDCloudMediaPlayerMetadataNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BDCloudMediaPlayerLoadStateDidChangeNotification
                                                  object:nil];
    
}

-(void) dealloc
{
    [self cleanup];
    _videoPlayer = nullptr;
    [super dealloc];
}

-(void) setFrame:(int)left :(int)top :(int)width :(int)height
{
    if (_left == left && _width == width && _top == top && _height == height)
        return;
    
    _left = left;
    _width = width;
    _top = top;
    _height = height;
    if (self.mediaPlayer != nullptr) {
        _restoreRect = self.mediaPlayer.view.frame;
        
        if (_fullscreen)
            [self.mediaPlayer.view setFrame:[[UIScreen mainScreen] bounds]];
        else
            [self.mediaPlayer.view setFrame:CGRectMake(left, top, width, height)];
        //            [[self.mediaPlayer.view superview] setFrame:CGRectMake(left, top, width, height)];
    }
}

-(void) setFullScreenEnabled:(BOOL) enabled
{
    if (self.mediaPlayer != nullptr) {
        if (enabled)
        {
            //            _fullscreen = enabled;
            // 设置全屏，就强制后置视频
            [self setZOrderOnTop:false];
            self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeFill;
            CGRect rect = [[UIScreen mainScreen] bounds];
            _left = rect.origin.x;
            _width = rect.size.width;
            _top = rect.origin.y;
            _height = rect.size.height;
            [self.mediaPlayer.view setFrame:[[UIScreen mainScreen] bounds]];
        }
        else
        {
            //            _fullscreen = enabled;
            [self setKeepRatioEnabled:_keepRatioEnabled];
            _left = _restoreRect.origin.x;
            _width = _restoreRect.size.width;
            _top = _restoreRect.origin.y;
            _height = _restoreRect.size.height;
            [self.mediaPlayer.view setFrame:_restoreRect];
        }
        _fullscreen = enabled;
    }
}

-(BOOL) isFullScreenEnabled
{
    //    if (self.moviePlayer != nullptr) {
    //        return [self.moviePlayer isFullscreen];
    //    }
    //    if (self.mediaPlayer != nullptr) {
    //        return [self.mediaPlayer isFullscreen];
    //    }
    
    return false;
}

-(BOOL) isPlaying
{
    //    if(self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    //        return YES;
    //    else
    //        return NO;
    if(self.mediaPlayer.playbackState == BDCloudMediaPlayerPlaybackStatePlaying)
        return YES;
    else
        return NO;
}

-(void) setURL:(int)videoSource :(std::string &)videoUrl
{
    [self cleanup];
    
    
    if (videoSource == 1) {
        //        self.moviePlayer = [[[MPMoviePlayerController alloc] init] autorelease];
        //        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        //        [self.moviePlayer setContentURL:[NSURL URLWithString:@(videoUrl.c_str())]];
        self.mediaPlayer = [[[BDCloudMediaPlayerController alloc] initWithContentString:[NSString stringWithString:@(videoUrl.c_str())]] autorelease];
    } else {
        //        self.moviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:@(videoUrl.c_str())]] autorelease];
        //        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        self.mediaPlayer = [[[BDCloudMediaPlayerController alloc] initWithContentString:[NSString stringWithString:@(videoUrl.c_str())]] autorelease];
    }
    //    self.moviePlayer.allowsAirPlay = NO;
    //    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    //    self.moviePlayer.view.userInteractionEnabled = YES;
    self.mediaPlayer.view.userInteractionEnabled = YES;
    
    //    auto clearColor = [UIColor clearColor];
    //    self.moviePlayer.backgroundView.backgroundColor = clearColor;
    //    self.moviePlayer.view.backgroundColor = clearColor;
    //    for (UIView * subView in self.moviePlayer.view.subviews) {
    //        subView.backgroundColor = clearColor;
    //    }
    auto clearColor = [UIColor clearColor];
    //    self.mediaPlayer.backgroundView.backgroundColor = clearColor;
    self.mediaPlayer.view.backgroundColor = clearColor;
    for (UIView * subView in self.mediaPlayer.view.subviews) {
        subView.backgroundColor = clearColor;
    }
    
    //    if (_keepRatioEnabled) {
    //        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //    } else {
    //        self.moviePlayer.scalingMode = MPMovieScalingModeFill;
    //    }
    if (_keepRatioEnabled) {
        self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeAspectFit;
    } else {
        self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeFill;
    }
    
    auto eaglview = cocos2d::Application::getInstance()->getView();
    //    auto eaglview = (CCEAGLView *) view->getEAGLView();
    //    [eaglview addSubview:self.moviePlayer.view];
    //    [eaglview addSubview:self.mediaPlayer.view];
    [[[eaglview superview] viewWithTag:10] addSubview:self.mediaPlayer.view];
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(videoFinished:)
    //                                                 name:MPMoviePlayerPlaybackDidFinishNotification
    //                                               object:self.moviePlayer];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(playStateChange)
    //                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
    //                                               object:self.moviePlayer];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(metadataUpdate:)
    //                                                 name:MPMovieDurationAvailableNotification
    //                                               object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateUpdate:)
                                                 name:BDCloudMediaPlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayerPrepared:)
                                                 name:BDCloudMediaPlayerPlaybackIsPreparedToPlayNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished:)
                                                 name:BDCloudMediaPlayerPlaybackDidFinishNotification
                                               object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playStateChange:)
                                                 name:BDCloudMediaPlayerPlaybackStateDidChangeNotification
                                               object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(metadataUpdate:)
                                                 name:BDCloudMediaPlayerMetadataNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateUpdate:)
                                                 name:BDCloudMediaPlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    
    //    [self.moviePlayer.view addGestureRecognizer:singleFingerTap];
    [self.mediaPlayer.view addGestureRecognizer:singleFingerTap];
    
    //    [self.moviePlayer prepareToPlay];
    //    self.mediaPlayer.shouldAutoplay = YES;
    [self.mediaPlayer prepareToPlay];
    
    singleFingerTap.delegate = self;
    [singleFingerTap release];
    
}

// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::CLICKED);
}

// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)onPlayerPrepared:(NSNotification*)notification {
    if (notification.object != self.mediaPlayer) {
        return;
    }
    
    if(_videoPlayer != nullptr) {
        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::READY_TO_PLAY);
    }
    
}

-(void) videoFinished:(NSNotification *)notification
{
    //    if(_videoPlayer != nullptr)
    //    {
    //        if([self.moviePlayer playbackState] != MPMoviePlaybackStateStopped)
    //        {
    //            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
    //        }
    //    }
    if(_videoPlayer != nullptr)
    {
        //        BDCloudMediaPlayerPlaybackState state = [self.mediaPlayer playbackState];
        //        if(state != BDCloudMediaPlayerPlaybackStateStopped)
        //        {
        //            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
        //        }
        NSNumber* reasonNumber = notification.userInfo[BDCloudMediaPlayerPlaybackDidFinishReasonUserInfoKey];
        BDCloudMediaPlayerFinishReason reason = (BDCloudMediaPlayerFinishReason)reasonNumber.integerValue;
        switch (reason) {
            case BDCloudMediaPlayerFinishReasonEnd:
                NSLog(@"player finish with reason: play to end time");
                _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
                break;
            case BDCloudMediaPlayerFinishReasonError:
                NSLog(@"player finished with reason: error");
                _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
                break;
            case BDCloudMediaPlayerFinishReasonUser:
                NSLog(@"player finished with reason: stopped by user");
                _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::COMPLETED);
                break;
            default:
                break;
        }
    }
}

-(void) playStateChange:(NSNotification*) notification
{
    //    MPMoviePlaybackState state = [self.moviePlayer playbackState];
    //    switch (state) {
    //        case MPMoviePlaybackStatePlaying:
    //            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PLAYING);
    //            break;
    //        default:
    //            break;
    //    }
    BDCloudMediaPlayerPlaybackState state = [self.mediaPlayer playbackState];
    switch (state) {
        case BDCloudMediaPlayerPlaybackStatePlaying:
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PLAYING);
            break;
        default:
            break;
    }
}

-(void) loadStateUpdate:(NSNotification*)notification
{
    //    MPMovieLoadState state = [self.moviePlayer loadState];
    //    if(state == MPMovieLoadStatePlayable ||
    //       state == MPMovieLoadStatePlaythroughOK) {
    //        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::READY_TO_PLAY);
    //    }
    //    BDCloudMediaPlayerLoadState state = [self.mediaPlayer loadState];
    //    if(state == BDCloudMediaPlayerLoadStatePlayable ||
    //       state == BDCloudMediaPlayerLoadStatePlaythroughOK) {
    //        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::READY_TO_PLAY);
    //    }
}

-(void) metadataUpdate:(NSNotification *)notification
{
    _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::META_LOADED);
}

-(void) seekTo:(float)sec
{
    //    if (self.moviePlayer != NULL) {
    //        [self.moviePlayer setCurrentPlaybackTime:(sec)];
    //    }
    if (self.mediaPlayer != NULL) {
        [self.mediaPlayer setCurrentPlaybackTime:(sec)];
    }
}

-(float) currentTime
{
    //    if (self.moviePlayer != NULL) {
    //        return [self.moviePlayer currentPlaybackTime];
    //    }
    if (self.mediaPlayer != NULL) {
        float ret = [self.mediaPlayer currentPlaybackTime];
        if (!isnan(ret)) return ret;
    }
    return -1;
}

-(float) duration
{
    float duration = -1;
    //    if (self.moviePlayer != NULL) {
    //        duration = [self.moviePlayer duration];
    //        if(duration <= 0) {
    //            CCLOG("Video player's duration is not ready to get now!");
    //        }
    //    }
    if (self.mediaPlayer != NULL) {
        duration = [self.mediaPlayer duration];
        if(duration <= 0) {
            CCLOG("Video player's duration is not ready to get now!");
        }
    }
    return duration;
}

-(void) setVisible:(BOOL)visible
{
    //    if (self.moviePlayer != NULL) {
    //        [self.moviePlayer.view setHidden:!visible];
    //        if (!visible) {
    //            [self pause];
    //        }
    //    }
    if (self.mediaPlayer != NULL) {
        [self.mediaPlayer.view setHidden:!visible];
        if (!visible) {
            [self pause];
        }
    }
}

-(void) setKeepRatioEnabled:(BOOL)enabled
{
    _keepRatioEnabled = enabled;
    //    if (self.moviePlayer != NULL) {
    //        if (enabled) {
    //            self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //        } else {
    //            self.moviePlayer.scalingMode = MPMovieScalingModeFill;
    //        }
    //    }
    if (self.mediaPlayer != NULL) {
        if (_keepRatioEnabled) {
            self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeAspectFit;
        } else {
            self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeFill;
        }
    }
}

-(void) play
{
    if (self.mediaPlayer != NULL) {
        if (_fullscreen)
        {
            self.mediaPlayer.scalingMode = BDCloudMediaPlayerScalingModeFill;
            [self.mediaPlayer.view setFrame:[[UIScreen mainScreen] bounds]];
        }
        else
        {
            [self setKeepRatioEnabled:_keepRatioEnabled];
            [self.mediaPlayer.view setFrame:CGRectMake(_left, _top, _width, _height)];
        }
        
        [self.mediaPlayer play];
    }
}

-(void) pause
{
    //    if (self.moviePlayer != NULL) {
    //        if([self.moviePlayer playbackState] == MPMoviePlaybackStatePlaying) {
    //            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PAUSED);
    //        }
    //
    //        [self.moviePlayer pause];
    //    }
    
    if (self.mediaPlayer != NULL) {
        if([self.mediaPlayer playbackState] == BDCloudMediaPlayerPlaybackStatePlaying) {
            _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::PAUSED);
        }
        
        [self.mediaPlayer pause];
    }
    
    
}

-(void) resume
{
    //    if (self.moviePlayer != NULL) {
    //        if([self.moviePlayer playbackState] == MPMoviePlaybackStatePaused)
    //        {
    //            [self.moviePlayer play];
    //        }
    //    }
    if (self.mediaPlayer != NULL) {
        if([self.mediaPlayer playbackState] == BDCloudMediaPlayerPlaybackStatePaused)
        {
            [self.mediaPlayer play];
        }
    }
}

-(void) stop
{
    //    if (self.moviePlayer != NULL) {
    //        [self.moviePlayer pause];
    //        [self seekTo:0];
    //        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::STOPPED);
    //    }
    if (self.mediaPlayer != NULL) {
        [self.mediaPlayer pause];
        [self seekTo:0];
        _videoPlayer->onPlayEvent((int)VideoPlayer::EventType::STOPPED);
    }
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
        //        CGRect rect = CGRectMake(0, 0, 0, 0);
        //        [uiView setFrame:rect];
        [uiParentView bringSubviewToFront:(uiView)];
    }
    else {
        // 后置
        [uiParentView sendSubviewToBack:(uiView)];
    }
    //    UIWindow* uiWindow = eaglview.windows;
    //    auto eaglview = (CCEAGLView *) view->getEAGLView();
    //    [eaglview addSubview:self.moviePlayer.view];
    //    [eaglview addSubview:self.mediaPlayer.view];
    //    [[ viewWithTag:10] addSubview:self.mediaPlayer.view];
    
}
// added end


@end

#endif

#endif
