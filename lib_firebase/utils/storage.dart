import 'dart:io';
import 'dart:async';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
//import 'utils/auth.dart' as auth;
import 'auth.dart' as auth;

Future<String> upload(File file, String basename) async {
  await auth.ensureLoggedIn();
  StorageReference ref =
      FirebaseStorage.instance.ref().child('file/test/$basename');

  StorageUploadTask uploadTask = ref.putFile(file);

  await uploadTask.onComplete;
  String location = await uploadTask.lastSnapshot.ref.getDownloadURL();
  String name = await ref.getName();
  String bucket = await ref.getBucket();
  String path = await ref.getPath();

  print("url: $location");
  print("Name: $name");
  print("Bucket: $bucket");
  print("Path: $path");

  return location;
}

Future<String> download(Uri location) async {
  http.Response data = await http.get(location);
  return data.body;
}
