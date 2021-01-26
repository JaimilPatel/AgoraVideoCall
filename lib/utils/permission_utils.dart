import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialog_utils.dart';
import 'localization/localization.dart';

class PermissionUtils {
  static void requestPermission(
    List<PermissionGroup> permission,
    BuildContext context, {
    Function permissionGrant,
    Function permissionDenied,
    Function permissionNotAskAgain,
    bool isOpenSettings = false,
    bool isShowMessage = false,
  }) {
    PermissionHandler().requestPermissions(permission).then((statuses) {
      var allPermissionGranted = true;

      statuses.forEach((key, value) {
        allPermissionGranted =
            allPermissionGranted && (value == PermissionStatus.granted);
      });

      if (allPermissionGranted) {
        if (permissionGrant != null) {
          permissionGrant();
        }
      } else {
        if (permissionDenied != null) {
          permissionDenied();
        }
        if (isOpenSettings) {
          DialogUtils.showOkCancelAlertDialog(
            context: context,
            message: Localization.of(context).alertPermissionNotRestricted,
            cancelButtonTitle: Platform.isAndroid
                ? Localization.of(context).no
                : Localization.of(context).cancel,
            okButtonTitle: Platform.isAndroid
                ? Localization.of(context).yes
                : Localization.of(context).ok,
            cancelButtonAction: () {},
            okButtonAction: () {
              PermissionHandler().openAppSettings();
            },
          );
        } else if (isShowMessage) {
          DialogUtils.showAlertDialog(
              context, Localization.of(context).alertPermissionNotRestricted);
        }
      }
    });
  }
}
