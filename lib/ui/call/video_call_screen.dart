import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
  final String? channelName;
  final String? token;
  final ResCallRequestModel? resCallRequestModel;
  final ResCallAcceptModel? resCallAcceptModel;
  final bool? isForOutGoing;

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
  int? _remoteUid;
  bool _switch = false;
  final _infoStrings = <String>[];
  RtcEngine? _engine;
  bool _isFront = false;
  bool _reConnectingRemoteView = false;
  final GlobalKey<TimerViewState> _timerKey = GlobalKey();
  bool _mutedAudio = false;
  bool _mutedVideo = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable(); // Turn on wakelock feature till call is running
    initializeCalling();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    Wakelock.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  //Initialize All The Setup For Agora Video Call
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
      var configuration = VideoEncoderConfiguration(
          dimensions: VideoDimensions(
            width: 1920,
            height: 1080,
          ),
          orientationMode: OrientationMode.orientationModeAdaptive);
      await _engine?.setVideoEncoderConfiguration(configuration);
      await _engine?.joinChannel(
          token: widget.token ?? "",
          channelId: widget.channelName ?? "",
          uid: 0,
          options: ChannelMediaOptions());
    });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine?.initialize(const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication));
    await _engine?.enableVideo();
  }

  //Switch Camera
  _onToggleCamera() {
    _engine?.switchCamera().then((value) {
      setState(() {
        _isFront = !_isFront;
      });
    }).catchError((err) {});
  }

  //Audio On / Off
  void _onToggleMuteAudio() {
    setState(() {
      _mutedAudio = !_mutedAudio;
    });
    _engine?.muteLocalAudioStream(_mutedAudio);
  }

  //Video On / Off
  void _onToggleMuteVideo() {
    setState(() {
      _mutedVideo = !_mutedVideo;
    });
    _engine?.muteLocalVideoStream(_mutedVideo);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    _engine?.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joined = true;
          final info =
              'onJoinChannel: ${connection.channelId}, uid:  ${connection.localUid}';
          _infoStrings.add(info);
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          final info = 'userJoined: $remoteUid';
          _infoStrings.add(info);
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        if (reason == UserOfflineReasonType.userOfflineDropped) {
          Wakelock.disable();
        } else {
          setState(() {
            final info = 'userOffline: $remoteUid';
            _infoStrings.add(info);
            _remoteUid = null;
            _timerKey.currentState?.cancelTimer();
          });
        }
      },
      onError: (ErrorCodeType code, String str) {
        setState(() {
          final info = 'onError:$code ${code.index}';
          _infoStrings.add(info);
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
        });
      },
      onFirstRemoteAudioFrame:
          (RtcConnection connection, int width, int height) {
        setState(() {
          final info =
              'firstRemoteVideo: ${connection.localUid} ${width}x $height';
          _infoStrings.add(info);
        });
      },
      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType type, ConnectionChangedReasonType reason) {
        if (type == ConnectionStateType.connectionStateConnected) {
          setState(() {
            _reConnectingRemoteView = false;
          });
        } else if (type == ConnectionStateType.connectionStateReconnecting) {
          setState(() {
            _reConnectingRemoteView = true;
          });
        }
      },
      onRemoteVideoStats: (RtcConnection connection, RemoteVideoStats stats) {
        if (stats.receivedBitrate == 0) {
          setState(() {
            _reConnectingRemoteView = true;
          });
        } else {
          setState(() {
            _reConnectingRemoteView = false;
          });
        }
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      },
    ));
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _onBackPressed(context)!;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
            ),
            //_logPanelWidget(), //Uncomment It During Development To Ensure Proper Agora Setup
            _timerView(),
            _cameraView(),
            _bottomPortionWidget(context),
            _cancelCallView()
          ],
        ),
      ),
    );
  }

  //Get This Alert Dialog When User Press On Back Button
  Future<bool>? _onBackPressed(BuildContext context) {
    showCallLeaveDialog(
        context,
        Localization.of(context)!.labelEndCall,
        Localization.of(context)!.labelEndCallNow,
        Localization.of(context)!.labelEndCallCancel, () {
      _onCallEnd(context);
    });
    return Future.value(false);
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(spacingXSmall),
        child: Text(
          Localization.of(context)!.waitForJoiningLabel,
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
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
          _reConnectingRemoteView
              ? Container(
                  color: Colors.black.withAlpha(200),
                  child: Center(
                      child: Text(
                    "${Localization.of(context)!.reConnecting}",
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
          Localization.of(context)!.waitForJoiningLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: tabBarTitle,
              color: ColorUtils.whiteColor,
              fontWeight: fontWeightRegular),
        ),
      );
    }
  }

  //Timer Ui
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

  //Local Camera View
  Widget _cameraView() => Container(
        padding: const EdgeInsets.symmetric(
            vertical: spacingXXXXLarge, horizontal: spacingLarge),
        alignment: Alignment.bottomRight,
        child: FractionallySizedBox(
          child: Container(
            width: horizontalWidth,
            height: verticalLength,
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

  //Only For Development Purpose (Please Comment It For Release)
  Widget _logPanelWidget() => Container(
        padding: const EdgeInsets.symmetric(vertical: spacingXXXSLarge),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: spacingXXXSLarge),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (context, index) {
                if (_infoStrings.isEmpty) {
                  return null;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: spacingTiny,
                    horizontal: spacingSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: spacingTiny,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(spacingTiny),
                          ),
                          child: Text(
                            _infoStrings[index],
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

  // Ui & UX For Bottom Portion (Switch Camera,Video On/Off,Mic On/Off)
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
                _isFront ? Icons.camera_front : Icons.camera_rear,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  _isFront ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteVideo,
              child: Icon(
                _mutedVideo ? Icons.videocam_off : Icons.videocam,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _mutedVideo
                  ? Colors.white.withAlpha(100)
                  : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteAudio,
              child: Icon(
                _mutedAudio ? Icons.mic_off : Icons.mic,
                color: ColorUtils.whiteColor,
                size: smallIconSize,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _mutedAudio
                  ? Colors.white.withAlpha(100)
                  : Colors.transparent,
              padding: const EdgeInsets.all(spacingMedium),
            ),
          ],
        ),
      );

  //Cancel Button Ui/Ux
  Widget _cancelCallView() => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding:
              const EdgeInsets.only(top: spacingXXXLarge, right: spacingXLarge),
          child: InkWell(
            onTap: () {
              showCallLeaveDialog(
                  context,
                  Localization.of(context)!.labelEndCall,
                  Localization.of(context)!.labelEndCallNow,
                  Localization.of(context)!.labelEndCallCancel, () {
                _onCallEnd(context);
              });
            },
            child: Icon(
              Icons.cancel,
              color: ColorUtils.whiteColor,
              size: imageMTiny,
            ),
          ),
        ),
      );

  //Use This Method To End Call
  void _onCallEnd(BuildContext context) async {
    Wakelock.disable(); // Turn off wakelock feature after call end
    //Emit Reject Call Event Into Socket
    emit(
        SocketConstants.rejectCall,
        ({
          ArgParams.connectId:
              widget.isForOutGoing != null && widget.isForOutGoing == true
                  ? widget.resCallAcceptModel?.otherUserId
                  : widget.resCallRequestModel?.id,
        }));
    NavigationUtils.pushAndRemoveUntil(
      context,
      RouteConstants.routeCommon,
    );
  }
}
