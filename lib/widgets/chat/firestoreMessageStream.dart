import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:closr_chat/widgets/chat/chatList.dart';

class FirestoreMessageStream extends StatelessWidget {

   @override
   Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
       stream: Firestore.instance.collection('chat_messages').snapshots(),
       builder: (context, snapshot){
         if(!snapshot.hasData)
           return LinearProgressIndicator();
         return ChatList(snapshots: snapshot.data.documents,);
       },
     );
   }
 }
