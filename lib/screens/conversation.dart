import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ConversationScreen extends StatefulWidget {
  String chatRoomId, receiver;
  ConversationScreen(this.chatRoomId, this.receiver);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

String loggedInUserName, chatroomid;

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController textEditingController = new TextEditingController();

  Stream chatMessagesStream;

  sendMessage() {
    if (textEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": textEditingController.text,
        "sentBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
    }
    textEditingController.text = "";
  }

  getCurrentUser() async {
    loggedInUserName = await HelperFunctions.getUserNameSharedPreference();
  }

  @override
  void initState() {
    chatroomid = widget.chatRoomId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.receiver),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                MessagesStream(),
                Container(
                  decoration: kMessageContainerDecoration,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: textEditingController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "Type a message ...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      )),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0)),
                          child: Icon(
                            Icons.send,
                            size: 20.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatroomid)
          .collection('Chats')
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageText = message.data()['message'];
          final messageSender = message.data()['sentBy'];

          final messageBubble = MessageBubble(
            messageSender: messageSender,
            messageText: messageText,
            isMe: Constants.myName == messageSender,
          );
          messageWidgets.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageSender, this.messageText, this.isMe});
  final String messageText, messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            messageSender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(
                "$messageText",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
