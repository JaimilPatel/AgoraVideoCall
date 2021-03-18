import 'dart:async';

import 'package:agoravideocall/socket/model/res_call_accept_model.dart';
import 'package:agoravideocall/socket/model/res_call_request_model.dart';
import 'package:agoravideocall/socket/socket_constants.dart';
import 'package:agoravideocall/socket/socket_manager.dart';
import 'package:agoravideocall/utils/check_network_connectivity.dart';
import 'package:agoravideocall/utils/color_utils.dart';
import 'package:agoravideocall/utils/constants/arg_constants.dart';
import 'package:agoravideocall/utils/constants/file_constants.dart';
import 'package:agoravideocall/utils/constants/route_constants.dart';
import 'package:agoravideocall/utils/dimens.dart';
import 'package:agoravideocall/utils/localization/localization.dart';
import 'package:agoravideocall/utils/navigation.dart';
import 'package:agoravideocall/utils/permission_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class PickUpScreen extends StatefulWidget {
  final ResCallRequestModel resCallRequestModel;
  final ResCallAcceptModel resCallAcceptModel;
  final bool isForOutGoing;
  PickUpScreen({this.resCallRequestModel,
    this.resCallAcceptModel,
    this.isForOutGoing = false});
  @override
  _PickUpScreenState createState() => _PickUpScreenState();
}

class _PickUpScreenState extends State<PickUpScreen> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    FlutterRingtonePlayer.play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.electronic,
        looping: true,
        volume: 0.5,
        asAlarm: false);
    _timer = Timer(const Duration(milliseconds: 60 * 1000), _endCall);
  }

  @override
  void dispose() {
    FlutterRingtonePlayer.stop();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
            colors: [ColorUtils.accentColor, ColorUtils.primaryColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.isForOutGoing
                  ? Localization.of(context).outGoingCallTitle
                  : Localization.of(context).pickUpCallTitle,
              style: TextStyle(
                  color: ColorUtils.whiteColor,
                  fontSize: headerTitleSize,
                  fontWeight: fontWeightRegular),
            ),
            SizedBox(height: spacingXXXSLarge),
            _getImageUrlWidget(),
            SizedBox(height: spacingLarge),
            Text("Jaimil Patel",
                style: TextStyle(
                    color: ColorUtils.whiteColor,
                    fontSize: headerTitleSize,
                    fontWeight: fontWeightRegular)),
            SizedBox(height: spacingXXXSLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _callingButtonWidget(context, false),
                !widget.isForOutGoing
                    ? _callingButtonWidget(context, true)
                    : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _getImageUrlWidget() => ClipOval(
          child: CircleAvatar(
        backgroundColor: ColorUtils.whiteColor,
        radius: screenSize.width * 0.2,
        child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: imageXLarge,
            height: imageXLarge,
            placeholder: (context, url) => Center(
                  child: SizedBox(
                    height: spacingXXMLarge,
                    width: spacingXXMLarge,
                    child: CircularProgressIndicator(
                      backgroundColor: ColorUtils.accentColor,
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => SvgPicture.asset(
                  FileConstants.icUserPlaceholder,
                  color: ColorUtils.primaryColor.withAlpha(125),
                ),
            imageUrl: ""),
      ));

  _callingButtonWidget(BuildContext context, bool isCall) => RawMaterialButton(
      onPressed: () {
        if (isCall) {
          _timer?.cancel();
          pickUpCallPressed(context);
        } else {
          _endCall();
        }
      },
      child: Icon(isCall ? Icons.call : Icons.call_end,
          color: Colors.white, size: imageMTiny),
      shape: CircleBorder(),
      elevation: 2.0,
      fillColor: isCall ? Colors.green : Colors.redAccent,
      padding: const EdgeInsets.all(spacingMedium));

  void pickUpCallPressed(BuildContext context) {
    PermissionUtils.requestPermission(
        [PermissionGroup.camera, PermissionGroup.microphone], context,
        isOpenSettings: true, permissionGrant: () async {
      FlutterRingtonePlayer.stop();
      if (await checkNetworkConnection(context)) {
        emit(
            SocketConstants.acceptCall,
            ({
              ArgParams.connectId: widget.resCallRequestModel.id,
              ArgParams.channelKey: widget.resCallRequestModel.channel,
              ArgParams.channelTokenKey: widget.resCallRequestModel.token,
            }));
        NavigationUtils.pushReplacement(
            context, RouteConstants.routeVideoCall,
            arguments: {
              ArgParams.channelKey: widget.resCallRequestModel.channel,
              ArgParams.channelTokenKey: widget.resCallRequestModel.token,
              ArgParams.resCallRequestModel: widget.resCallRequestModel,
              ArgParams.resCallAcceptModel: ResCallAcceptModel(),
              ArgParams.isForOutGoing: widget.isForOutGoing,
            });
      }
    });
  }

  _endCall() async {
    Wakelock.disable();
    FlutterRingtonePlayer.stop();
    emit(
        SocketConstants.rejectCall,
        ({
          ArgParams.connectId:  widget.isForOutGoing
              ? widget.resCallAcceptModel.id
              : widget.resCallRequestModel.id,
        }));
    NavigationUtils.pop(context);
  }
}
