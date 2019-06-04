/*
 * Copyright (C) 2006 The Android Open Source Project
 * Copyright (c) 2014-2016 Chukong Technologies Inc.
 * Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.cocos2dx.lib;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.content.res.Resources;
import android.media.AudioManager;
//import android.media.MediaPlayer;
//import android.media.MediaPlayer.OnErrorListener;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.FrameLayout;
import android.widget.MediaController.MediaPlayerControl;
import android.widget.RelativeLayout;

import java.io.IOException;
import java.util.Map;

// 百度播放器
//import com.baidu.cloud.media.player.BDCloudMediaPlayer;
//import com.baidu.cloud.media.player.BDTimedText;
//import com.baidu.cloud.media.player.IMediaPlayer;
import java.io.File;

// 腾讯云播放器
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.ITXLivePlayListener;
import android.text.TextUtils;
import android.widget.Toast;

//class Test extends SurfaceView {
//    public Test(Context context) {
//        super(context);
//    }
//}

public class Cocos2dxTXVideoView extends SurfaceView implements ITXLivePlayListener {
    private String TAG = "Cocos2dxVideoView";

    private Uri         mVideoUri;
    private int         mDuration;

    // all possible internal states
    private static final int STATE_ERROR              = -1;
    private static final int STATE_IDLE               = 0;
    private static final int STATE_PREPARING          = 1;
    private static final int STATE_PREPARED           = 2;
    private static final int STATE_PLAYING            = 3;
    private static final int STATE_PAUSED             = 4;
    private static final int STATE_PLAYBACK_COMPLETED = 5;

    /**
     * mCurrentState is a VideoView object's current state.
     * mTargetState is the state that a method caller intends to reach.
     * For instance, regardless the VideoView object's current state,
     * calling pause() intends to bring the object to a target state
     * of STATE_PAUSED.
     */
    private int mCurrentState = STATE_IDLE;
    private int mTargetState  = STATE_IDLE;

    // All the stuff we need for playing and showing a video
    private SurfaceHolder mSurfaceHolder = null;
//    private MediaPlayer mMediaPlayer = null;
//    private BDCloudMediaPlayer mMediaPlayer = null;

    private TXLivePlayer mLivePlayer = null;
//    private TXCloudVideoView mPlayerView = null;
    private int              mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;

    public static final int ACTIVITY_TYPE_PUBLISH      = 1;
    public static final int ACTIVITY_TYPE_LIVE_PLAY    = 2;
    public static final int ACTIVITY_TYPE_VOD_PLAY     = 3;
    public static final int ACTIVITY_TYPE_LINK_MIC     = 4;
    public static final int ACTIVITY_TYPE_REALTIME_PLAY = 5;
    protected int            mActivityType = ACTIVITY_TYPE_LIVE_PLAY;
    private int              mCurrentRenderMode;


    private int         mVideoWidth = 0;
    private int         mVideoHeight = 0;

    private OnVideoEventListener mOnVideoEventListener;
//    private MediaPlayer.OnPreparedListener mOnPreparedListener;
//    private IMediaPlayer.OnPreparedListener mOnPreparedListener;
    private int         mCurrentBufferPercentage;
//    private OnErrorListener mOnErrorListener;
//    private IMediaPlayer.OnErrorListener mOnErrorListener;

    // recording the seek position while preparing
    private int         mSeekWhenPrepared = 0;

    protected Cocos2dxActivity mCocos2dxActivity = null;

    protected int mViewLeft = 0;
    protected int mViewTop = 0;
    protected int mViewWidth = 0;
    protected int mViewHeight = 0;

    protected int mVisibleLeft = 0;
    protected int mVisibleTop = 0;
    protected int mVisibleWidth = 0;
    protected int mVisibleHeight = 0;

    protected boolean mFullScreenEnabled = false;
    protected int mFullScreenWidth = 0;
    protected int mFullScreenHeight = 0;

    private int mViewTag = 0;

    public Cocos2dxTXVideoView(Cocos2dxActivity activity,int tag) {
        super(activity);

        mViewTag = tag;
        mCocos2dxActivity = activity;

        initVideoView();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(mVisibleWidth, mVisibleHeight);

    }

    public void setVideoRect(int left, int top, int maxWidth, int maxHeight) {
        if (mViewLeft == left && mViewTop == top && mViewWidth == maxWidth && mViewHeight == maxHeight)
            return;

        mViewLeft = left;
        mViewTop = top;
        mViewWidth = maxWidth;
        mViewHeight = maxHeight;

        fixSize(mViewLeft, mViewTop, mViewWidth, mViewHeight);
    }

    public void setFullScreenEnabled(boolean enabled) {
        if (mFullScreenEnabled != enabled) {
            mFullScreenEnabled = enabled;
            fixSize();
        }
    }

    public int resolveAdjustedSize(int desiredSize, int measureSpec) {
        int result = desiredSize;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize =  MeasureSpec.getSize(measureSpec);

        switch (specMode) {
            case MeasureSpec.UNSPECIFIED:
                /* Parent says we can be as big as we want. Just don't be larger
                 * than max size imposed on ourselves.
                 */
                result = desiredSize;
                break;

            case MeasureSpec.AT_MOST:
                /* Parent says we can be as big as we want, up to specSize.
                 * Don't be larger than specSize, and don't be larger than
                 * the max size imposed on ourselves.
                 */
                result = Math.min(desiredSize, specSize);
                break;

            case MeasureSpec.EXACTLY:
                // No choice. Do what we are told.
                result = specSize;
                break;
        }

        return result;
    }

    private boolean mMetaUpdated = false;

    @Override
    public void setVisibility(int visibility) {
        if (visibility == INVISIBLE) {
            if (getCurrentPosition() > 0 && mSeekWhenPrepared == 0) {
                mSeekWhenPrepared = getCurrentPosition();
            }
        }

        super.setVisibility(visibility);
    }

    private void initVideoView() {
        mVideoWidth = 0;
        mVideoHeight = 0;
        getHolder().addCallback(mSHCallback);
        //Fix issue#11516:Can't play video on Android 2.3.x
        getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        setFocusable(true);
        setFocusableInTouchMode(true);

        mCurrentState = STATE_IDLE;
        mTargetState  = STATE_IDLE;

        mCurrentRenderMode = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
//        mLivePlayer = new TXLivePlayer(this.mCocos2dxActivity);
//        mLivePlayer.setPlayListener(this);

    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if((event.getAction() & MotionEvent.ACTION_MASK) == MotionEvent.ACTION_UP) {
            if (mOnVideoEventListener != null) {
                mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_CLICKED);
            }
        }
        return false;
    }

    private boolean mIsAssetRouse = false;
    private String mVideoFilePath = null;
    private static final String AssetResourceRoot = "assets/";

    public void setVideoFileName(String path) {
        if (path.startsWith(AssetResourceRoot)) {
            path = path.substring(AssetResourceRoot.length());
        }

        if (path.startsWith("/")) {
            mIsAssetRouse = false;
            setVideoURI(Uri.parse(path),null);
        }
        else {

            mVideoFilePath = path;
            mIsAssetRouse = true;
            setVideoURI(Uri.parse(path), null);
        }
    }

    public void setVideoURL(String url) {
        mIsAssetRouse = false;
        setVideoURI(Uri.parse(url), null);
    }

    /**
     * @hide
     */
    private void setVideoURI(Uri uri, Map<String, String> headers) {
        mVideoUri = uri;
        mSeekWhenPrepared = 0;
        mVideoWidth = 0;
        mVideoHeight = 0;
        mMetaUpdated = false;
        openVideo();
        requestLayout();
        invalidate();
    }

    public void stopPlayback() {
        if (mLivePlayer != null) {
//            mMediaPlayer.stop();
//            mMediaPlayer.release();
//            mMediaPlayer = null;
            mLivePlayer.stopPlay(true);
            mLivePlayer = null;
//            mPlayerView.onDestroy();
            mCurrentState = STATE_IDLE;
            mTargetState  = STATE_IDLE;
        }
    }

//    @Override
    public void onDestroy() {
//        mPlayerView.onDestroy();

    }

    private void openVideo() {
        if (mSurfaceHolder == null) {
            // not ready for playback just yet, will try again later
            return;
        }
        if (mIsAssetRouse) {
            if(mVideoFilePath == null)
                return;
        } else if(mVideoUri == null) {
            return;
        }

        // Tell the music playback service to pause
        // REFINE: these constants need to be published somewhere in the framework.
        Intent i = new Intent("com.android.music.musicservicecommand");
        i.putExtra("command", "pause");
        mCocos2dxActivity.sendBroadcast(i);

        // we shouldn't clear the target state, because somebody might have
        // called start() previously
        release(false);

        try {

            mLivePlayer = new TXLivePlayer(this.mCocos2dxActivity);
            mLivePlayer.setPlayListener(this);
            mLivePlayer.setSurface(mSurfaceHolder.getSurface());
            this.mLivePlayer.setSurfaceSize(mVisibleWidth, mVisibleHeight);


            if (!checkPlayUrl(mVideoUri.toString())) {
                return;
            }

            mLivePlayer.setRenderMode(mCurrentRenderMode);
//            mLivePlayer.startPlay(mVideoUri.toString(), mPlayType);

            mDuration = -1;
            mCurrentBufferPercentage = 0;
            if (mIsAssetRouse) {
                AssetFileDescriptor afd = mCocos2dxActivity.getAssets().openFd(mVideoFilePath);
                mVideoUri = Uri.fromFile(new File(mVideoFilePath));
            } else {
            }


            /**
             * Don't set the target state here either, but preserve the target state that was there before.
             */
            mCurrentState = STATE_PREPARED;
//            if (mTargetState == STATE_PLAYING) {
//                start();
//            }
        } catch (IOException ex) {
            Log.w(TAG, "Unable to open content: " + mVideoUri, ex);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
//            mErrorListener.onError(mMediaPlayer, MediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
//            mErrorListener.onError(mMediaPlayer, IMediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
            return;
        } catch (IllegalArgumentException ex) {
            Log.w(TAG, "Unable to open content: " + mVideoUri, ex);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
//            mErrorListener.onError(mMediaPlayer, MediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
//            mErrorListener.onError(mMediaPlayer, IMediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
            return;
        }
    }

    private boolean mKeepRatio = false;

    public void setKeepRatio(boolean enabled) {
        mKeepRatio = enabled;
        fixSize();
    }

    public void fixSize() {
        if (mFullScreenEnabled) {
            mFullScreenWidth = mCocos2dxActivity.getGLSurfaceView().getWidth();
            mFullScreenHeight = mCocos2dxActivity.getGLSurfaceView().getHeight();

            fixSize(0, 0, mFullScreenWidth, mFullScreenHeight);
        } else {
            fixSize(mViewLeft, mViewTop, mViewWidth, mViewHeight);
        }
    }

    public void fixSize(int left, int top, int width, int height) {
        if (mVideoWidth == 0 || mVideoHeight == 0) {
            mVisibleLeft = left;
            mVisibleTop = top;
            mVisibleWidth = width;
            mVisibleHeight = height;
        }
        else if (width != 0 && height != 0) {
            if (mKeepRatio && !mFullScreenEnabled) {
                if ( mVideoWidth * height  > width * mVideoHeight ) {
                    mVisibleWidth = width;
                    mVisibleHeight = width * mVideoHeight / mVideoWidth;
                } else if ( mVideoWidth * height  < width * mVideoHeight ) {
                    mVisibleWidth = height * mVideoWidth / mVideoHeight;
                    mVisibleHeight = height;
                }
                mVisibleLeft = left + (width - mVisibleWidth) / 2;
                mVisibleTop = top + (height - mVisibleHeight) / 2;
            } else {
                mVisibleLeft = left;
                mVisibleTop = top;
                mVisibleWidth = width;
                mVisibleHeight = height;
            }
        }
        else {
            mVisibleLeft = left;
            mVisibleTop = top;
            mVisibleWidth = mVideoWidth;
            mVisibleHeight = mVideoHeight;
        }

        getHolder().setFixedSize(mVisibleWidth, mVisibleHeight);
        mVideoWidth = mVisibleWidth;
        mVideoHeight = mVisibleHeight;

        if (this.mLivePlayer != null) {
            this.mLivePlayer.setSurfaceSize(mVisibleWidth, mVisibleHeight);
        }

        RelativeLayout.LayoutParams lParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);
        lParams.leftMargin = mVisibleLeft;
        lParams.topMargin = mVisibleTop;
        lParams.width = mVisibleWidth;
        lParams.height = mVisibleHeight;
        setLayoutParams(lParams);
    }

//    protected
//    MediaPlayer.OnVideoSizeChangedListener mSizeChangedListener =
//        new MediaPlayer.OnVideoSizeChangedListener() {
//            public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
//    IMediaPlayer.OnVideoSizeChangedListener mSizeChangedListener =
//        new IMediaPlayer.OnVideoSizeChangedListener() {
//            public void onVideoSizeChanged(IMediaPlayer mp, int width, int height, int sarNum, int sarDen) {
//
//                mVideoWidth = mp.getVideoWidth();
//                mVideoHeight = mp.getVideoHeight();
//                if (mVideoWidth != 0 && mVideoHeight != 0) {
//                    getHolder().setFixedSize(mVideoWidth, mVideoHeight);
//                }
//            }
//        };


//    MediaPlayer.OnPreparedListener mPreparedListener = new MediaPlayer.OnPreparedListener() {
//        public void onPrepared(MediaPlayer mp) {

//IMediaPlayer.OnPreparedListener mPreparedListener = new IMediaPlayer.OnPreparedListener() {
//    public void onPrepared(IMediaPlayer mp) {
//            mCurrentState = STATE_PREPARED;
//
//            if (mOnPreparedListener != null) {
//                mOnPreparedListener.onPrepared(mMediaPlayer);
//            }
//
//            mVideoWidth = mp.getVideoWidth();
//            mVideoHeight = mp.getVideoHeight();
//
//            // mSeekWhenPrepared may be changed after seekTo() call
////            int seekToPosition = mSeekWhenPrepared;
////            seekTo(seekToPosition);
//
//
//            if (mVideoWidth != 0 && mVideoHeight != 0) {
//                fixSize();
//            }
//
//            if(!mMetaUpdated) {
//                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_META_LOADED);
//                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_READY_TO_PLAY);
//                mMetaUpdated = true;
//            }
//
//            if (mTargetState == STATE_PLAYING) {
//                start();
//            }
//        }
//    };

//    private IMediaPlayer.OnCompletionListener mCompletionListener =
//            new IMediaPlayer.OnCompletionListener() {
//                public void onCompletion(IMediaPlayer mp) {
//                    mCurrentState = STATE_PLAYBACK_COMPLETED;
//                    mTargetState = STATE_PLAYBACK_COMPLETED;
//
//                    if (mOnVideoEventListener != null) {
//                        mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_COMPLETED);
//                    }
//                }
//            };

//    private IMediaPlayer.OnMetadataListener mMetadataListener = new IMediaPlayer.OnMetadataListener() {
//        @Override
//        public void onMetadata(IMediaPlayer mp, Bundle meta) {
//            for (String key : meta.keySet()) {
//                Log.d(TAG, "onMetadata: key = " + key + ", value = " + meta.getString(key));
//            }
//        }
//    };


    private static final int EVENT_PLAYING = 0;
    private static final int EVENT_PAUSED = 1;
    private static final int EVENT_STOPPED = 2;
    private static final int EVENT_COMPLETED = 3;
    private static final int EVENT_META_LOADED = 4;
    private static final int EVENT_CLICKED = 5;
    private static final int EVENT_READY_TO_PLAY = 6;

    public interface OnVideoEventListener
    {
        void onVideoEvent(int tag,int event);
    }

//    private IMediaPlayer.OnErrorListener mErrorListener =
//            new IMediaPlayer.OnErrorListener() {
//                public boolean onError(IMediaPlayer mp, int framework_err, int impl_err) {
//            Log.d(TAG, "Error: " + framework_err + "," + impl_err);
//            mCurrentState = STATE_ERROR;
//            mTargetState = STATE_ERROR;
//
//            /* If an error handler has been supplied, use it and finish. */
//            if (mOnErrorListener != null) {
//                if (mOnErrorListener.onError(mMediaPlayer, framework_err, impl_err)) {
//                    return true;
//                }
//            }
//
//            /* Otherwise, pop up an error dialog so the user knows that
//             * something bad has happened. Only try and pop up the dialog
//             * if we're attached to a window. When we're going away and no
//             * longer have a window, don't bother showing the user an error.
//             */
//            if (getWindowToken() != null) {
//                Resources r = mCocos2dxActivity.getResources();
//                int messageId;
//
////                if (framework_err == MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK) {
//                if (framework_err == IMediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK) {
//                    // messageId = com.android.internal.R.string.VideoView_error_text_invalid_progressive_playback;
//                    messageId = r.getIdentifier("VideoView_error_text_invalid_progressive_playback", "string", "android");
//                } else {
//                    // messageId = com.android.internal.R.string.VideoView_error_text_unknown;
//                    messageId = r.getIdentifier("VideoView_error_text_unknown", "string", "android");
//                }
//
//                int titleId = r.getIdentifier("VideoView_error_title", "string", "android");
//                int buttonStringId = r.getIdentifier("VideoView_error_button", "string", "android");
//
////                new AlertDialog.Builder(mCocos2dxActivity)
////                        .setTitle(r.getString(titleId))
////                        .setMessage(messageId)
////                        .setPositiveButton(r.getString(buttonStringId),
////                                new DialogInterface.OnClickListener() {
////                                    public void onClick(DialogInterface dialog, int whichButton) {
//                                        /* If we get here, there is no onError listener, so
//                                         * at least inform them that the video is over.
//                                         */
//                                        if (mOnVideoEventListener != null) {
//                                            mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_COMPLETED);
//                                        }
////                                    }
////                                })
////                        .setCancelable(false)
////                        .show();
//            }
//            return true;
//        }
//    };



//    private MediaPlayer.OnBufferingUpdateListener mBufferingUpdateListener =
//        new MediaPlayer.OnBufferingUpdateListener() {
//        public void onBufferingUpdate(MediaPlayer mp, int percent) {
//    private IMediaPlayer.OnBufferingUpdateListener mBufferingUpdateListener =
//        new IMediaPlayer.OnBufferingUpdateListener() {
//            public void onBufferingUpdate(IMediaPlayer mp, int percent) {
//                mCurrentBufferPercentage = percent;
//        }
//    };

    /**
     * Register a callback to be invoked when the media file
     * is loaded and ready to go.
     *
     * @param l The callback that will be run
     */
//    public void setOnPreparedListener(IMediaPlayer.OnPreparedListener l)
//    {
//        mOnPreparedListener = l;
//    }

    /**
     * Register a callback to be invoked when the end of a media file
     * has been reached during play back.
     *
     * @param l The callback that will be run
     */
    public void setOnCompletionListener(OnVideoEventListener l)
    {
        mOnVideoEventListener = l;
    }

//    /**
//     * Register a callback to be invoked when an error occurs
//     * during play back or setup.  If no listener is specified,
//     * or if the listener returned false, VideoView will inform
//     * the user of any errors.
//     *
//     * @param l The callback that will be run
//     */
//    public void setOnErrorListener(IMediaPlayer.OnErrorListener l)
//    {
//        mOnErrorListener = l;
//    }

    SurfaceHolder.Callback mSHCallback = new SurfaceHolder.Callback()
    {
        public void surfaceChanged(SurfaceHolder holder, int format,
                                    int w, int h)
        {
            boolean isValidState =  (mTargetState == STATE_PLAYING);
            boolean hasValidSize = (mVideoWidth == w && mVideoHeight == h);
            if (mLivePlayer != null && isValidState && hasValidSize) {
//                if (mSeekWhenPrepared != 0) {
//                    seekTo(mSeekWhenPrepared);
//                }
                start();
            }
        }

        public void surfaceCreated(SurfaceHolder holder)
        {
            mSurfaceHolder = holder;
            openVideo();
        }

        public void surfaceDestroyed(SurfaceHolder holder)
        {
            // after we return from this we can't use the surface any more
            mSurfaceHolder = null;

            release(true);


//            if (mOnVideoEventListener != null && mCurrentState == STATE_PLAYING) {
//                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PAUSED);
//            }

        }
    };

//    private void releaseWithoutStop() {
//        if (mMediaPlayer != null) {
//                mMediaPlayer.setDisplay(null);
//        }
//
//    }

    @Override
    public void onPlayEvent(int event, Bundle param) {
        String playEventLog = "receive event: " + event + ", " + param.getString(TXLiveConstants.EVT_DESCRIPTION);
        Log.d(TAG, playEventLog);

        if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
            int i = 0;
//            stopLoadingAnimation();
//            Log.d("AutoMonitor", "PlayFirstRender,cost=" +(System.currentTimeMillis()-mStartPlayTS));
//            mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_READY_TO_PLAY);
            mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PLAYING);
        } else if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT || event == TXLiveConstants.PLAY_EVT_PLAY_END) {
            mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_COMPLETED);
//            stopPlay();
        } else if (event == TXLiveConstants.PLAY_EVT_PLAY_LOADING){
            int i = 0;
            mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_META_LOADED);
        } else if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
        } else if (event == TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION) {
            Log.d(TAG, "size "+param.getInt(TXLiveConstants.EVT_PARAM1) + "x" + param.getInt(TXLiveConstants.EVT_PARAM2));
        } else if (event == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION) {
            return;
        }
        else if (event == TXLiveConstants.PLAY_EVT_PLAY_PROGRESS) {
        }
    }

    //公用打印辅助函数
    protected String getNetStatusString(Bundle status) {
        String str = String.format("%-14s %-14s %-12s\n%-8s %-8s %-8s %-8s\n%-14s %-14s\n%-14s %-14s",
                "CPU:"+status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH)+"*"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:"+status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED)+"Kbps",
                "JIT:"+status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP)+"s",
                "ARA:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE)+"Kbps",
                "QUE:"+status.getInt(TXLiveConstants.NET_STATUS_CODEC_CACHE)
                        +"|"+status.getInt(TXLiveConstants.NET_STATUS_CACHE_SIZE)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE_SIZE)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_V_DEC_CACHE_SIZE)
                        +"|"+status.getInt(TXLiveConstants.NET_STATUS_AV_RECV_INTERVAL)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_AV_PLAY_INTERVAL)
                        +","+String.format("%.1f", status.getFloat(TXLiveConstants.NET_STATUS_AUDIO_PLAY_SPEED)).toString(),
                "VRA:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE)+"Kbps",
                "SVR:"+status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:"+status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

    @Override
    public void onNetStatus(Bundle status) {
        String str = getNetStatusString(status);
        Log.d(TAG, "Current status, CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");

//        mPlayVisibleLogView.setLogText(status, null, 0);
    }


    /*
     * release the media player in any state
     */
    private void release(boolean cleartargetstate) {
//        if (mMediaPlayer != null) {
//            mMediaPlayer.reset();
//            mMediaPlayer.release();
//            mMediaPlayer = null;
//            mMetaUpdated = false;
//            mCurrentState = STATE_IDLE;
//            mMetaUpdated = false;
//            if (cleartargetstate) {
//                mTargetState  = STATE_IDLE;
//            }
//        }
        if (mLivePlayer != null) {
            mLivePlayer.stopPlay(true);
        }
    }

//    @Override
    public void start() {
        if (isInPlaybackState()) {
            mLivePlayer.startPlay(mVideoUri.toString(), mPlayType);
//            if (mCurrentState != STATE_PLAYING && mOnVideoEventListener != null) {
//                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PLAYING);
//            }

            mCurrentState = STATE_PLAYING;
        }

        mTargetState = STATE_PLAYING;

    }

    private boolean checkPlayUrl(final String playUrl) {
        if (TextUtils.isEmpty(playUrl) || (!playUrl.startsWith("http://") && !playUrl.startsWith("https://") && !playUrl.startsWith("rtmp://")  && !playUrl.startsWith("/"))) {
            Toast.makeText(mCocos2dxActivity.getApplicationContext(), "播放地址不合法，直播目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
            return false;
        }

        switch (mActivityType) {
            case ACTIVITY_TYPE_LIVE_PLAY:
            {
                if (playUrl.startsWith("rtmp://")) {
                    mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
                } else if ((playUrl.startsWith("http://") || playUrl.startsWith("https://"))&& playUrl.contains(".flv")) {
                    mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_FLV;
                } else {
                    Toast.makeText(mCocos2dxActivity.getApplicationContext(), "播放地址不合法，直播目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
                    return false;
                }
            }
            break;
//            case ACTIVITY_TYPE_REALTIME_PLAY:
//            {
//                if (!playUrl.startsWith("rtmp://")) {
//                    Toast.makeText(mCocos2dxActivity.getApplicationContext(), "低延时拉流仅支持rtmp播放方式", Toast.LENGTH_SHORT).show();
//                    return false;
//                } else if (!playUrl.contains("txSecret")) {
//                    new AlertDialog.Builder(this)
//                            .setTitle("播放出错")
//                            .setMessage("低延时拉流地址需要防盗链签名，详情参考 https://cloud.tencent.com/document/product/454/7880#RealTimePlay!")
//                            .setNegativeButton("取消", new DialogInterface.OnClickListener() {
//                                @Override
//                                public void onClick(DialogInterface dialog, int which) {
//                                    dialog.dismiss();
//                                }
//                            }).setPositiveButton("确定", new DialogInterface.OnClickListener() {
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//                            Uri uri = Uri.parse("https://cloud.tencent.com/document/product/454/7880#RealTimePlay!");
//                            startActivity(new Intent(Intent.ACTION_VIEW,uri));
//                            dialog.dismiss();
//                        }
//                    }).show();
//                    return false;
//                }
//
//                mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC;
//                break;
//            }
            default:
                Toast.makeText(mCocos2dxActivity.getApplicationContext(), "播放地址不合法，目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
                return false;
        }
        return true;
    }


//    @Override
    public void pause() {
        if (isInPlaybackState()) {
            if (mLivePlayer.isPlaying()) {
//                mSeekWhenPrepared = (int)mMediaPlayer.getCurrentPosition();
                mLivePlayer.pause();
                mCurrentState = STATE_PAUSED;
                if (mOnVideoEventListener != null) {
                    mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PAUSED);
                }
            }
        }
        mTargetState = STATE_PAUSED;
    }

    public void stop() {
        if (isInPlaybackState()) {
            mLivePlayer.stopPlay(true);
//            this.pause();
//            this.seekTo(0);
            if (mOnVideoEventListener != null) {
                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_STOPPED);
            }
        }
    }

//    public void suspend() {
//        release(false);
//    }

    public void resume() {
        if (isInPlaybackState()) {
            if (mCurrentState == STATE_PAUSED) {
                mLivePlayer.resume();
                mCurrentState = STATE_PLAYING;
//                if (mOnVideoEventListener != null) {
//                    mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PLAYING);
//                }
            }
        }
    }

    public void restart() {
//        if (isInPlaybackState()) {
//            mMediaPlayer.seekTo(0);
//            mMediaPlayer.start();
//            mCurrentState = STATE_PLAYING;
//            mTargetState = STATE_PLAYING;
//        }
    }

//    @Override
    public int getDuration() {
//        if (isInPlaybackState()) {
//            if (mDuration > 0) {
//                return mDuration;
//            }
//            mDuration = (int)mMediaPlayer.getDuration();
//            return mDuration;
//        }
        mDuration = -1;
        return mDuration;
    }

//    @Override
    public int getCurrentPosition() {
//        if (isInPlaybackState()) {
//            return (int)mLivePlayer.getCurrentPosition();
//        } else {
//            return mSeekWhenPrepared;
//        }
        return 0;
    }

//    @Override
    public void seekTo(int msec) {
        Log.w(TAG,"seek to :"+msec);
//        if (isInPlaybackState()) {
//            mLivePlayer.seekTo(msec);
//            mSeekWhenPrepared = 0;
//        } else {
//            mSeekWhenPrepared = msec;
//        }
    }

//    @Override
    public boolean isPlaying() {
        return isInPlaybackState() && mLivePlayer.isPlaying();
    }

//    @Override
//    public int getBufferPercentage() {
//        if (mMediaPlayer != null) {
//            return mCurrentBufferPercentage;
//        }
//        return 0;
//    }

    public boolean isInPlaybackState() {
//        return (mLivePlayer != null &&
//         this.getVisibility() != INVISIBLE);
        return (mLivePlayer != null &&
                mCurrentState != STATE_ERROR &&
                mCurrentState != STATE_IDLE &&
                mCurrentState != STATE_PREPARING
                && this.getVisibility() != INVISIBLE);
    }

//    @Override
//    public boolean canPause() {
//        return true;
//    }
//
//    @Override
//    public boolean canSeekBackward() {
//        return true;
//    }
//
//    @Override
//    public boolean canSeekForward() {
//        return true;
//    }

//    public int getAudioSessionId () {
//       return mMediaPlayer.getAudioSessionId();
//    }

    public void setVolume (float volume) {
//        if (mMediaPlayer != null) {
//            mMediaPlayer.setVolume(volume, volume);
//        }
        if (mLivePlayer != null) {

        }
    }

//    public void setZOrderOnTop(boolean bTop) {
//        if (this.mVideoView != null) {
//            if (bTop) {
//                this.mVideoView.bringToFront();
//            }
//        }
//
//        if (this.mGLSurfaceView != null) {
//            this.mGLSurfaceView.setZOrderOnTop(bTop);
//        }
//
//    }
}
