import 'package:flutter/material.dart';
import 'package:closr_chat/widgets/chat/chatScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Closr Chat",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: ChatScreen(),
    );
  }
}
