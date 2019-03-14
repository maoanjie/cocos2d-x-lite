/****************************************************************************
 Copyright (c) 2014-2016 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "VideoPlayer.h"

USING_NS_CC;

// No Available on tvOS
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS && !defined(CC_TARGET_OS_TVOS)

//-------------------------------------------------------------------------------------

#import <MediaPlayer/MediaPlayer.h>
#include "platform/CCApplication.h"
#include "platform/ios/CCEAGLView-ios.h"
#include "platform/CCFileUtils.h"

#import <BDCloudMediaPlayer/BDCloudMediaPlayer.h>

@interface UIVideoViewWrapperIos : NSObject<UIGestureRecognizerDelegate>

//@property (strong,nonatomic) MPMoviePlayerController * moviePlayer;
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

@implementation UIVideoViewWrapperIos
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
//        self.moviePlayer = nullptr;
        self.mediaPlayer = nullptr;
        _videoPlayer = (VideoPlayer*)videoPlayer;
        _keepRatioEnabled = false;
    }

    return self;
}

-(void) cleanup
{
//    if (self.moviePlayer != nullptr) {
//        [self removeRegisteredObservers];
//
//        [self.moviePlayer stop];
//        [self.moviePlayer.view removeFromSuperview];
//        self.moviePlayer = nullptr;
//    }
    if (self.mediaPlayer != nullptr) {
        [self removeRegisteredObservers];
        
        [self.mediaPlayer stop];
        [self.mediaPlayer.view removeFromSuperview];
        self.mediaPlayer = nullptr;
    }
}

-(void) removeRegisteredObservers {
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:self.moviePlayer];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                                  object:self.moviePlayer];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMovieDurationAvailableNotification
//                                                  object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerLoadStateDidChangeNotification
//                                                  object:nil];
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
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
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
//------------------------------------------------------------------------------------------------------------

VideoPlayer::VideoPlayer()
: _videoPlayerIndex(-1)
, _fullScreenEnabled(false)
, _fullScreenDirty(false)
, _keepAspectRatioEnabled(false)
{
    [[BDCloudMediaPlayerAuth sharedInstance] setAccessKey:@"7da96283643247a082b632f525048a80"];
    
    _videoView = [[UIVideoViewWrapperIos alloc] init:this];

#if CC_VIDEOPLAYER_DEBUG_DRAW
    _debugDrawNode = DrawNode::create();
    addChild(_debugDrawNode);
#endif
}

VideoPlayer::~VideoPlayer()
{
    if(_videoView)
    {
        [((UIVideoViewWrapperIos*)_videoView) dealloc];
    }
}

void VideoPlayer::setURL(const std::string& videoUrl)
{
    if (videoUrl.find("://") == std::string::npos)
    {
        _videoURL = FileUtils::getInstance()->fullPathForFilename(videoUrl);
        _videoSource = VideoPlayer::Source::FILENAME;
    }
    else
    {
        _videoURL = videoUrl;
        _videoSource = VideoPlayer::Source::URL;
    }
    
    [((UIVideoViewWrapperIos*)_videoView) setURL:(int)_videoSource :_videoURL];
}

void VideoPlayer::setFullScreenEnabled(bool enabled)
{
    [((UIVideoViewWrapperIos*)_videoView) setFullScreenEnabled:enabled];
}

void VideoPlayer::setKeepAspectRatioEnabled(bool enable)
{
    if (_keepAspectRatioEnabled != enable)
    {
        _keepAspectRatioEnabled = enable;
        [((UIVideoViewWrapperIos*)_videoView) setKeepRatioEnabled:enable];
    }
}

void VideoPlayer::play()
{
    if (! _videoURL.empty() && _isVisible)
    {
        [((UIVideoViewWrapperIos*)_videoView) play];
    }
}

void VideoPlayer::pause()
{
    if (! _videoURL.empty())
    {
        [((UIVideoViewWrapperIos*)_videoView) pause];
    }
}

void VideoPlayer::stop()
{
    if (! _videoURL.empty())
    {
        [((UIVideoViewWrapperIos*)_videoView) stop];
    }
}

void VideoPlayer::seekTo(float sec)
{
    if (! _videoURL.empty())
    {
        [((UIVideoViewWrapperIos*)_videoView) seekTo:sec];
    }
}

float VideoPlayer::currentTime()const
{
    return [((UIVideoViewWrapperIos*)_videoView) currentTime];
}

float VideoPlayer::duration()const
{
    return [((UIVideoViewWrapperIos*)_videoView) duration];
}

void VideoPlayer::setVisible(bool visible)
{
    _isVisible = visible;

    if (!visible)
    {
        [((UIVideoViewWrapperIos*)_videoView) setVisible:NO];
    }
    else
    {
        [((UIVideoViewWrapperIos*)_videoView) setVisible:YES];
    }
}

void VideoPlayer::addEventListener(const std::string& name, const VideoPlayer::ccVideoPlayerCallback& callback)
{
    _eventCallback[name] = callback;
}

void VideoPlayer::onPlayEvent(int event)
{
    switch ((EventType)event) {
        case EventType::PLAYING:
            _eventCallback["play"]();
            break;
        case EventType::PAUSED:
            _eventCallback["pause"]();
            break;
        case EventType::STOPPED:
            _eventCallback["stoped"]();
            break;
        case EventType::COMPLETED:
            _eventCallback["ended"]();
            break;
        case EventType::META_LOADED:
            _eventCallback["loadedmetadata"]();
            break;
        case EventType::CLICKED:
            _eventCallback["click"]();
            break;
        case EventType::READY_TO_PLAY:
            _eventCallback["suspend"]();
            break;
        default:
            break;
    }
}

void VideoPlayer::setFrame(float x, float y, float width, float height)
{
    auto eaglview = (CCEAGLView*)cocos2d::Application::getInstance()->getView();
    auto scaleFactor = [eaglview contentScaleFactor];
    [((UIVideoViewWrapperIos*)_videoView) setFrame:x/scaleFactor
                                                  :y/scaleFactor
                                                  :width/scaleFactor
                                                  :height/scaleFactor];
}

// 调整播放器层级
void VideoPlayer::setZOrderOnTop(bool bTop)
{
    if (!bTop)
    {
        [((UIVideoViewWrapperIos*)_videoView) setZOrderOnTop:NO];
    }
    else
    {
        [((UIVideoViewWrapperIos*)_videoView) setZOrderOnTop:YES];
    }
}


#endif
