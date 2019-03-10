import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatMessage.dart';

class ChatList extends StatelessWidget {
  final List<DocumentSnapshot> snapshots;
  const ChatList({Key key, this.snapshots}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          reverse: true,
          itemCount: snapshots.length,
          itemBuilder: (_, int index) => ChatMessage(
            snapshot: snapshots[index],
      )),
    );
  }
}
