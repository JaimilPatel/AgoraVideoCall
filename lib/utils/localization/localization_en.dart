import 'localization.dart';

class LocalizationEN implements Localization {
  @override
  String get appName => "Agora VideoCall";

  @override
  String get internetNotConnected => "Please check your internet connection";

  @override
  String get internetConnectionFailed => "Internet Connection Failed";

  @override
  String get alertPermissionNotRestricted =>
      """Please grant the required permission from settings to access this feature.""";

  @override
  String get no => "No";

  @override
  String get cancel => "Cancel";

  @override
  String get yes => "Yes";

  @override
  String get ok => "Ok";

  @override
  String get pickUpCallTitle => "Incoming Call...";

  @override
  String get outGoingCallTitle => "Outgoing Call...";

  @override
  String get waitForJoiningLabel => 'Please wait for joining...';

  @override
  String get reConnecting => "Reconnecting...";

  @override
  String get labelEndCall => "Are you sure you want to end your call?";

  @override
  String get labelEndCallCancel => "No cancel & return to call";

  @override
  String get labelEndCallNow => "Yes end call now";

  @override
  String get appBarLabel => "Video Calling Using Agora";

  @override
  String get primaryBtnLabel => "Video Call To Student / Teacher";

  @override
  String get pickupScreenUserName => "Student / Teacher";
}
