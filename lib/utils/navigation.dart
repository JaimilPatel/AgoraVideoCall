import 'package:agoravideocall/socket/model/res_call_accept_model.dart';
import 'package:agoravideocall/socket/model/res_call_request_model.dart';
import 'package:agoravideocall/ui/call/video_call_screen.dart';
import 'package:agoravideocall/ui/common/common_screen.dart';
import 'package:agoravideocall/ui/pickup/pickup_screen.dart';
import 'package:agoravideocall/utils/constants/arg_constants.dart';
import 'package:flutter/material.dart';

import 'constants/route_constants.dart';

class NavigationUtils {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case RouteConstants.routeCommon:
        return MaterialPageRoute(builder: (_) => CommonScreen());
      case RouteConstants.routePickUpScreen:
        ResCallRequestModel reqModel = args![ArgParams.resCallRequestModel];
        ResCallAcceptModel joinModel = args[ArgParams.resCallAcceptModel];
        bool isForOutGoing = args[ArgParams.isForOutGoing];
        return MaterialPageRoute(
            builder: (_) => PickUpScreen(
                resCallRequestModel: reqModel,
                resCallAcceptModel: joinModel,
                isForOutGoing: isForOutGoing));
      case RouteConstants.routeVideoCall:
        String name = args![ArgParams.channelKey];
        String token = args[ArgParams.channelTokenKey];
        ResCallRequestModel reqModel = args[ArgParams.resCallRequestModel];
        ResCallAcceptModel joinModel = args[ArgParams.resCallAcceptModel];
        bool isForOutGoing = args[ArgParams.isForOutGoing];
        return MaterialPageRoute(
            builder: (_) => VideoCallingScreen(
                  channelName: name,
                  token: token,
                  resCallRequestModel: reqModel,
                  resCallAcceptModel: joinModel,
                  isForOutGoing: isForOutGoing,
                ));
      default:
        return _errorRoute(" Comming soon...");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: Text('Error')),
          body: Center(child: Text(message)));
    });
  }

  static void pushReplacement(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> push(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void pop(BuildContext context, {dynamic args}) {
    Navigator.of(context).pop(args);
  }

  static Future<dynamic> pushAndRemoveUntil(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (route) => false,
        arguments: arguments);
  }
}
