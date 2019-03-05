import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'utils/auth.dart' as fbAuth;
import 'utils/storage.dart' as fbStorage;
import 'utils/database.dart' as fbDatabase;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'untracked/specs.dart';

void main() async {

  final FirebaseApp app = await FirebaseApp.configure(
      name: 'closr_chat',
      options: FirebaseOptions(
        googleAppID: googleAppID,
        gcmSenderID: gcmSenderID,
        apiKey: apiKey,
        projectID: projectID,
      ));

  final FirebaseStorage storage =
      FirebaseStorage(
          app: app,
          storageBucket: storageBucket
      );
  final FirebaseDatabase database = FirebaseDatabase(app: app);

  runApp(MaterialApp(
    home: MyApp(
      app:app,
      storage: storage,
      database: database,
    ),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({this.app, this.storage, this.database});
  final FirebaseApp app;
  final FirebaseStorage storage;
  final FirebaseDatabase database;

  @override
  _State createState() => _State(app:app,storage: storage,database:database);
}

class _State extends State<MyApp> {
  _State({this.app,this.storage, this.database});
  final FirebaseApp app;
  final FirebaseStorage storage;
  final FirebaseDatabase database;

  String _status;
  String _location;
  StreamSubscription<Event> _counterSubscription;

  String _username;

  @override
  void initState() {
    super.initState();
    _status = "Not Authenticated";
    _signIn();
  }

  void _signIn() async {
    if (await fbAuth.signInGoogle() == true) {
      _username = await fbAuth.username();
      setState(() {
        _status = "Signed In";

      });
      _initDatabase();
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
    print("Uploaded to $_location");
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
      _status = "Downloaded: $data";
    });
  }

  void _initDatabase() async {
    fbDatabase.init(database);
    _counterSubscription = fbDatabase.counterRef.onValue.listen((Event event){
      setState(() {
        fbDatabase.error = null;
        fbDatabase.counter = event.snapshot.value ?? 0;
      });
    }, onError: (Object o){
      final DatabaseError error = o;
      setState(() {
        fbDatabase.error = error;
      });
    });
  }

  void _increment() async {
    int value = fbDatabase.counter + 1;
    fbDatabase.setCounter(value);
  }

  void _decrement() async {
    int value = fbDatabase.counter - 1;
    fbDatabase.setCounter(value);
  }

  void _addData() async {
    await fbDatabase.addData(_username);
    setState(() {
      _status = "Data Added";
    });
  }

  void _removeData() async {
    await fbDatabase.removeData(_username);
    setState(() {
      _status = "Data Removed";
    });
  }
  
  void _setData(String key, String value) async {
    await fbDatabase.setData(_username, key, value);
    setState(() {
      _status = "Data set";
    });
  }

  void _updateData(String key, String value) async {
    await fbDatabase.updateData(_username, key, value);
    setState(() {
      _status = "Data updated";
    });
  }

  void _findData(String key) async {
    String value = await fbDatabase.findData(_username, key);
    setState(() {
      _status = value;
    });
  }

  void _findRange(String key) async {
    String value = await fbDatabase.findRange(_username, key);
    setState(() {
      _status = value;
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
              Text('Counter ${fbDatabase.counter}'),
              Text('Counter ${fbDatabase.error.toString()}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(onPressed: _signOut, child: Text("Sign Out"),),
                  RaisedButton(onPressed: _signIn, child: Text("Sign In Google"),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(onPressed: _addData, child: Text("Add Data"),),
                  RaisedButton(onPressed: _removeData, child: Text("Remove Data"),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(onPressed:() => _setData('Key2','This is a set value'), child: Text("Set Data"),),
                  RaisedButton(onPressed:() => _updateData('Key2','This is a updated value'), child: Text("Update Data"),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(onPressed:() => _findData('Key2'), child: Text("Find Data"),),
                  RaisedButton(onPressed:() => _findRange('Key2'), child: Text("Find Range"),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
