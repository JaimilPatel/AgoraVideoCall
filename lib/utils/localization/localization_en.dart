import 'localization.dart';

class LocalizationEN implements Localization {
  @override
  String get appName => "Rickshaw";

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
}
