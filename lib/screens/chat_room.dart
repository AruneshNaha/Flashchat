import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/chat_screen.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:Flashchat/screens/search_screen.dart';
import 'package:Flashchat/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'conversation.dart';

class ChatRoom extends StatefulWidget {
  static const String id = 'chatRoom';
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String loggedInUserEmail, loggedInUserName;
  QuerySnapshot searchSnapshot;

  void initiateState() async {
    loggedInUserEmail = await HelperFunctions.getUserEmailSharedPreference();
    loggedInUserName = await HelperFunctions.getUserNameSharedPreference();

    await Firestore.instance
        .collection("users")
        .getDocuments()
        .then((value) => {
              setState(() {
                searchSnapshot = value;
              })
            });
  }

  createChatRoomAndStartConversation({String username}) async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();

    // print("Users: $username & ${Constants.myName}");
    String chatRoomId = getChatRoomId(username, Constants.myName);

    List<String> users = [username, Constants.myName];
    Map<String, dynamic> chatRoomMap = {
      "user": users,
      "chatroomId": chatRoomId
    };

    DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(
                  chatRoomId,
                  username,
                )));
  }

  Widget userTile({String userName, userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: kNormalText.copyWith(fontSize: 20.0),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              userEmail,
              style: kNormalText.copyWith(fontSize: 12.0),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            createChatRoomAndStartConversation(username: userName);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.lightBlueAccent),
            child: Text(
              "Mesage",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ]),
    );
  }

  Widget usersList() {
    return searchSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot.documents.length,
            itemBuilder: (context, index) {
              print("Index:$index");
              return searchSnapshot.documents[index].data()["name"] ==
                      Constants.myName
                  ? SizedBox(
                      height: 0,
                    )
                  : userTile(
                      userEmail:
                          searchSnapshot.documents[index].data()["email"],
                      userName: searchSnapshot.documents[index].data()["name"],
                    );
            },
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  void initState() {
    initiateState();
    getUserInfo();
    // TODO: implement initState
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FlashChat Chatroom",
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
            },
            child: Icon(Icons.search),
          ),
          GestureDetector(
            onTap: () {
              auth.signOut();
              HelperFunctions.saveUserLoggedInSharedPreference(false);
              HelperFunctions.saveUserEmailSharedPreference("");
              HelperFunctions.saveUserNameSharedPreference("");
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    "Sign Out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.chat_bubble),
          onPressed: () {
            Navigator.pushNamed(context, ChatScreen.id);
          }),
      body: usersList(),
    );
  }
}
