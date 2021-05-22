import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter_app/constants.dart';
import 'package:bubble/bubble.dart';

class MessagesService {
  User? currentUser;

  CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<void> sendMessage({message, sender}) {
    return _messagesCollection
        .add({
          'sender': sender,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((value) => print('Messages added'))
        .catchError((onError) => print('Failed to add the message : $onError'));
  }

  StreamBuilder<QuerySnapshot> getMessages({User? loggedInUser}) {
    currentUser = loggedInUser;
    return StreamBuilder<QuerySnapshot>(
        stream: _messagesCollection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Some thing went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading');
          }
          if (loggedInUser == null) {
            return Text("No message");
          }
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data != null) {
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              reverse: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Bubble(
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            document['message'],
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                        style: loggedInUser.email == document['sender']
                            ? kStyleMe
                            : kStyleSomebody,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
          return Text('');
        });
  }
}
