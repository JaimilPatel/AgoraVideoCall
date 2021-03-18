import 'package:agoravideocall/socket/socket_constants.dart';
import 'package:agoravideocall/socket/socket_manager.dart';
import 'package:agoravideocall/utils/constants/arg_constants.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CommonScreen extends StatefulWidget {
  @override
  _CommonScreenState createState() => _CommonScreenState();
}

class _CommonScreenState extends State<CommonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text(""),
          onPressed: () {
            var uuid = Uuid();
            emit(
                SocketConstants.connectCall,
                ({
                  ArgParams.connectId: uuid.v1(),
                }));
          },
        ),
      ),
    );
  }
}
