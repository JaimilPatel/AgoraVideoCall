import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:agoravideocall/socket/model/res_call_accept_model.dart';
import 'package:agoravideocall/socket/model/res_call_request_model.dart';
import 'package:agoravideocall/socket/socket_constants.dart';
import 'package:agoravideocall/socket/socket_manager.dart';
import 'package:agoravideocall/utils/color_utils.dart';
import 'package:agoravideocall/utils/constants/app_constants.dart';
import 'package:agoravideocall/utils/constants/arg_constants.dart';
import 'package:agoravideocall/utils/constants/file_constants.dart';
import 'package:agoravideocall/utils/constants/route_constants.dart';
import 'package:agoravideocall/utils/dimens.dart';
import 'package:agoravideocall/utils/localization/localization.dart';
import 'package:agoravideocall/utils/navigation.dart';
import 'package:agoravideocall/utils/widgets/leave_dialog.dart';
import 'package:agoravideocall/utils/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakelock/wakelock.dart';

class VideoCallingScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final ResCallRequestModel resCallRequestModel;
  final ResCallAcceptModel resCallAcceptModel;
  final bool isForOutGoing;

  VideoCallingScreen(
      {this.channelName,
        this.token,
        this.resCallRequestModel,
        this.resCallAcceptModel,
        this.isForOutGoing});

  @override
  _VideoCallingScreenState createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> {
  bool _joined = false;
  int _remoteUid;
  bool _switch = false;
  final _infoStrings = <String>[];
  RtcEngine _engine;
  bool isCountDownVisible = false;
  bool isFront = false;
  bool reConnectingRemoteView = false;
  final GlobalKey<TimerViewState> _timerKey = GlobalKey();
  bool mutedAudio = false;
  bool mutedVideo = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initializeCalling();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.destroy();
    Wakelock.disable();
    super.dispose();
  }

  Future<void> initializeCalling() async {
    if (AppConstants.agoraAppId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      var configuration = VideoEncoderConfiguration();
      configuration.dimensions = VideoDimensions(1920, 1080);
      configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
      await _engine.setVideoEncoderConfiguration(configuration);
      await _engine.joinChannel(widget.token, widget.channelName, null, 0);
    });
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(AppConstants.agoraAppId);
    await _engine.enableVideo();
  }

  _onToggleCamera() {
    _engine?.switchCamera()?.then((value) {
      setState(() {
        isFront = !isFront;
      });
    })?.catchError((err) {});
  }

  void _onToggleMuteAudio() {
    setState(() {
      mutedAudio = !mutedAudio;
    });
    _engine.muteLocalAudioStream(mutedAudio);
  }

  void _onToggleMuteVideo() {
    setState(() {
      mutedVideo = !mutedVideo;
    });
    _engine.muteLocalVideoStream(mutedVideo);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError:$code ${code.index}';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          _joined = true;
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _remoteUid = uid;
          isCountDownVisible = true;
        });
      },
      userOffline: (uid, elapsed) async {
        if (elapsed == UserOfflineReason.Dropped) {
          Wakelock.disable();
        } else {
          setState(() {
            final info = 'userOffline: $uid';
            _infoStrings.add(info);
            _remoteUid = null;
            isCountDownVisible = false;
            _timerKey?.currentState?.cancelTimer();
          });
        }
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
      connectionStateChanged: (type, reason) async {
        if (type == ConnectionStateType.Connected) {
          setState(() {
            reConnectingRemoteView = false;
          });
        } else if (type == ConnectionStateType.Reconnecting) {
          setState(() {
            reConnectingRemoteView = true;
          });
        }
      },
      remoteVideoStats: (remoteVideoStats) {
        if (remoteVideoStats.receivedBitrate == 0) {
          setState(() {
            reConnectingRemoteView = true;
          });
        } else {
          setState(() {
            reConnectingRemoteView = false;
          });
        }
      },
    ));
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
          ),
          _timerView(),
          _cameraView(),
          _bottomPortionWidget(context),
          _cancelCallView()
        ],
      ),
    );
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return rtc_local_view.SurfaceView();
    } else {
      return Padding(
        padding: const EdgeInsets.all(spacingXSmall),
        child: Text(
          Localization.of(context).waitForJoiningLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: tabBarTitle,
              color: ColorUtils.whiteColor,
              fontWeight: fontWeightRegular),
        ),
      );
    }
  }

  // Generate remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return Stack(
        children: [
          rtc_remote_view.SurfaceView(
            uid: _remoteUid,
          ),
          reConnectingRemoteView
              ? Container(
                  color: Colors.black.withAlpha(200),
                  child: Center(
                      child: Text(
                    "${Localization.of(context).reConnecting}",
                    style: TextStyle(
                        color: ColorUtils.whiteColor, fontSize: labelFontSize),
                  )))
              : SizedBox(),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(spacingXSmall),
        child: Text(
          Localization.of(context).waitForJoiningLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: tabBarTitle,
              color: ColorUtils.whiteColor,
              fontWeight: fontWeightRegular),
        ),
      );
    }
  }

  Widget _timerView() => Positioned(
        top: 45,
        left: spacingXXXSLarge,
        child: Opacity(
          opacity: 1,
          child: Row(
            children: [
              SvgPicture.asset(FileConstants.icTimer, width: 12, height: 12),
              SizedBox(width: spacingMedium),
              TimerView(
                key: _timerKey,
              )
            ],
          ),
        ),
      );

  Widget _cameraView() => Container(
        padding: const EdgeInsets.symmetric(
            vertical: spacingXXXXLarge, horizontal: spacingLarge),
        alignment: Alignment.bottomRight,
        child: FractionallySizedBox(
          child: Container(
            width: 110,
            height: 139,
            alignment: Alignment.topRight,
            color: Colors.black,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _switch = !_switch;
                });
              },
              child: Center(
                child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
              ),
            ),
          ),
        ),
      );

  Widget _bottomPortionWidget(BuildContext context) => Container(
        margin: EdgeInsets.only(
            bottom: spacingLarge, left: spacingXXMLarge, right: spacingXLarge),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _onToggleCamera,
              child: Icon(
                isFront ? Icons.camera_front : Icons.camera_rear,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  isFront ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteVideo,
              child: Icon(
                mutedVideo ? Icons.videocam_off : Icons.videocam,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  mutedVideo ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteAudio,
              child: Icon(
                mutedAudio ? Icons.mic_off : Icons.mic,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  mutedAudio ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
          ],
        ),
      );

  Widget _cancelCallView() => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding:
              const EdgeInsets.only(top: spacingXXXLarge, right: spacingXLarge),
          child: InkWell(
            onTap: () {
              showCallLeaveDialog(
                  context,
                  Localization.of(context).labelEndCall,
                  Localization.of(context).labelEndCallNow,
                  Localization.of(context).labelEndCallCancel, () {
                _onCallEnd(context);
              });
            },
            child: Icon(
              Icons.cancel,
              color: ColorUtils.whiteColor,
              size: 30,
            ),
          ),
        ),
      );

  void _onCallEnd(BuildContext context) async {
    Wakelock.disable();
      emit(
          SocketConstants.rejectCall,
          ({
            ArgParams.connectId:  widget.isForOutGoing
                ? widget.resCallAcceptModel.id
                : widget.resCallRequestModel.id,
          }));
      NavigationUtils.pushAndRemoveUntil(
          context, RouteConstants.routeCommon,
       );
  }
}
