import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Flashchat/constants.dart';

class ConversationScreen extends StatefulWidget {
  final String reciever, chatroomId;
  const ConversationScreen({Key key, this.reciever, this.chatroomId})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

final messageTextController = TextEditingController();
String messageText, chatRoomId;
Stream snapshot;
String loggedInUserEmail;
final _firestore = Firestore.instance;

class _ConversationScreenState extends State<ConversationScreen> {
  void initiateState() async {
    loggedInUserEmail = await HelperFunctions.getUserEmailSharedPreference();
    chatRoomId = widget.chatroomId;
  }

  @override
  void initState() {
    initiateState();
    getMessages();

    super.initState();
  }

  getMessages() async {
    snapshot = await messagesStream(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.reciever}"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () async {
                        messageTextController.clear();
                        await sendMessage(
                            chatRoomId, messageText, loggedInUserEmail);
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageText, this.isMe});
  final String messageText;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: snapshot,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.documents.reversed;
        print(messages);
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageText = message.data()['Text'];
          final messageSender = message.data()['Sender'];

          final messageBubble = MessageBubble(
            messageText: messageText,
            isMe: loggedInUserEmail == messageSender,
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
