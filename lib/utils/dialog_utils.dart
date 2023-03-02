import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'localization/localization.dart';

class DialogUtils {
  static void showOkCancelAlertDialog({
    BuildContext? context,
    String? message,
    String? okButtonTitle,
    String? cancelButtonTitle,
    Function? cancelButtonAction,
    Function? okButtonAction,
    bool isCancelEnable = true,
  }) {
    showDialog(
      barrierDismissible: isCancelEnable,
      context: context!,
      builder: (context) {
        if (Platform.isIOS) {
          return WillPopScope(
            onWillPop: () async => false,
            child: _showOkCancelCupertinoAlertDialog(
                context,
                message!,
                okButtonTitle!,
                cancelButtonTitle!,
                okButtonAction!,
                isCancelEnable,
                cancelButtonAction!),
          );
        } else {
          return WillPopScope(
            onWillPop: () async => false,
            child: _showOkCancelMaterialAlertDialog(
                context,
                message!,
                okButtonTitle!,
                cancelButtonTitle!,
                okButtonAction!,
                isCancelEnable,
                cancelButtonAction!),
          );
        }
      },
    );
  }

  static void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          return WillPopScope(
              onWillPop: () async => false,
              child: _showCupertinoAlertDialog(context, message));
        } else {
          return WillPopScope(
              onWillPop: () async => false,
              child: _showMaterialAlertDialog(context, message));
        }
      },
    );
  }

  static CupertinoAlertDialog _showCupertinoAlertDialog(
      BuildContext context, String message) {
    return CupertinoAlertDialog(
      title: Text(Localization.of(context)!.appName),
      content: Text(message),
      actions: _actions(context),
    );
  }

  static AlertDialog _showMaterialAlertDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: Text(Localization.of(context)!.appName),
      content: Text(message),
      actions: _actions(context),
    );
  }

  static AlertDialog _showOkCancelMaterialAlertDialog(
      BuildContext context,
      String message,
      String okButtonTitle,
      String cancelButtonTitle,
      Function okButtonAction,
      bool isCancelEnable,
      Function cancelButtonAction) {
    return AlertDialog(
      title: Text(Localization.of(context)!.appName),
      content: Text(message),
      actions: _okCancelActions(
        context: context,
        okButtonTitle: okButtonTitle,
        cancelButtonTitle: cancelButtonTitle,
        okButtonAction: okButtonAction,
        isCancelEnable: isCancelEnable,
        cancelButtonAction: cancelButtonAction,
      ),
    );
  }

  static CupertinoAlertDialog _showOkCancelCupertinoAlertDialog(
    BuildContext context,
    String message,
    String okButtonTitle,
    String cancelButtonTitle,
    Function okButtonAction,
    bool isCancelEnable,
    Function cancelButtonAction,
  ) {
    return CupertinoAlertDialog(
        title: Text(Localization.of(context)!.appName),
        content: Text(message),
        actions: isCancelEnable
            ? _okCancelActions(
                context: context,
                okButtonTitle: okButtonTitle,
                cancelButtonTitle: cancelButtonTitle,
                okButtonAction: okButtonAction,
                isCancelEnable: isCancelEnable,
                cancelButtonAction: cancelButtonAction,
              )
            : _okAction(
                context: context,
                okButtonAction: okButtonAction,
                okButtonTitle: okButtonTitle));
  }

  static List<Widget> _actions(BuildContext context) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(Localization.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : TextButton(
              child: Text(Localization.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
    ];
  }

  static List<Widget> _okCancelActions({
    BuildContext? context,
    String? okButtonTitle,
    String? cancelButtonTitle,
    Function? okButtonAction,
    bool? isCancelEnable,
    Function? cancelButtonAction,
  }) {
    return <Widget>[
      cancelButtonTitle != null
          ? Platform.isIOS
              ? CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(cancelButtonTitle),
                  onPressed: cancelButtonAction == null
                      ? () {
                          Navigator.of(context!).pop();
                        }
                      : () {
                          Navigator.of(context!).pop();
                          cancelButtonAction();
                        },
                )
              : TextButton(
                  child: Text(cancelButtonTitle),
                  onPressed: cancelButtonAction == null
                      ? () {
                          Navigator.of(context!).pop();
                        }
                      : () {
                          Navigator.of(context!).pop();
                          cancelButtonAction();
                        },
                )
          : SizedBox(),
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle!),
              onPressed: () {
                Navigator.of(context!).pop();
                okButtonAction!();
              },
            )
          : ElevatedButton(
              child: Text(okButtonTitle ?? ""),
              onPressed: () {
                Navigator.of(context!).pop();
                okButtonAction!();
              },
            ),
    ];
  }

  static List<Widget> _okAction(
      {BuildContext? context,
      String? okButtonTitle,
      Function? okButtonAction}) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle ?? ""),
              onPressed: () {
                Navigator.of(context!).pop();
                okButtonAction!();
              },
            )
          : ElevatedButton(
              child: Text(okButtonTitle ?? ""),
              onPressed: () {
                Navigator.of(context!).pop();
                okButtonAction!();
              },
            ),
    ];
  }
}
