import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'utils/auth.dart' as fbAuth;
import 'utils/storage.dart' as fbStorage;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

void main() async {
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'closr_chat',
      options: FirebaseOptions(
        googleAppID: "1:94320095180:android:76cbcbf742825ec6",
        gcmSenderID: "94320095180",
        apiKey: "AIzaSyABcU0VQiNY1V4BAT8PCbMLN7MGsXuWAZs",
        projectID: "closrchat",
      ));

  final FirebaseStorage storage =
      FirebaseStorage(app: app, storageBucket: 'gs://closrchat.appspot.com');

  runApp(MaterialApp(
    home: MyApp(storage: storage),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({this.storage});
  final FirebaseStorage storage;

  @override
  _State createState() => _State(storage: storage);
}

class _State extends State<MyApp> {
  _State({this.storage});
  final FirebaseStorage storage;

  String _status;
  String _location;

  @override
  void initState() {
    _status = "Not Authenticated";
    _signIn();
  }

  void _signIn() async {
    if (await fbAuth.signInGoogle() == true) {
      setState(() {
        _status = "Signed In";
      });
    } else {
      setState(() {
        _status = "Could not sign in";
      });
    }
  }

  void _signOut() async {
    if (await fbAuth.signOut() == true) {
      setState(() {
        _status = "Signed out";
      });
    } else {
      setState(() {
        _status = "Signed in";
      });
    }
  }

  void _upload() async {
    Directory systemTempDir = Directory.systemTemp;
    File file = await File('${systemTempDir.path}/foo.txt').create();
    file.writeAsString("hello world");

    String location = await fbStorage.upload(file, basename(file.path));
    setState(() {
      _location = location;
      _status = 'Uploaded!';
    });
    print("Uploaded to ${_location}");
  }

  void _download() async {
    if (_location.isEmpty) {
      setState(() {
        _status = "Please Upload first!";
      });
      return;
    }
    Uri location = Uri.parse(_location);
    String data = await fbStorage.download(location);
    setState(() {
      _status = "Downloaded: ${data}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Closr Chat"),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(_status),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: _signOut,
                    child: Text("Sign Out"),
                  ),
                  RaisedButton(
                    onPressed: _signIn,
                    child: Text("Sign In"),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: _upload,
                    child: Text("Upload"),
                  ),
                  RaisedButton(
                    onPressed: _download,
                    child: Text("Download"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
