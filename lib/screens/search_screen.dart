import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/conversation.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String user = "";

  DatabaseMethods databaseMethods = new DatabaseMethods();

  QuerySnapshot searchSnapshot;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot.documents.length,
            itemBuilder: (context, index) {
              print("Index:$index");
              return searchTile(
                  userEmail: searchSnapshot.documents[index].data()["email"],
                  userName: searchSnapshot.documents[index].data()["name"],
                  userUid: searchSnapshot.docs[index].data()["uid"]);
            },
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  initiateSearch() {
    databaseMethods.getUserByUsername(user).then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  createChatRoomAndStartConversation({String username, useruid}) async {
    Constants.myUid = await HelperFunctions.getUserUidSharedPreference();
    if (username != Constants.myName) {
      print("Users: $username & ${Constants.myName}");
      String chatRoomId = getChatRoomId(useruid, Constants.myUid);

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
    } else {
      setState(() {
        Alert(
          type: AlertType.error,
          context: context,
          desc: "You cannot send message to yourself",
          title: "ERROR",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              width: 120,
            )
          ],
        ).show();
      });
    }
  }

  Widget searchTile({String userName, userEmail, userUid}) {
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
            createChatRoomAndStartConversation(
                username: userName, useruid: userUid);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiateSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search user"),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    onChanged: (val) {
                      setState(() {
                        user = val;
                        initiateSearch();
                      });
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Search username ...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                  )),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0)),
                    child: GestureDetector(
                      onTap: () {
                        initiateSearch();
                      },
                      child: Icon(
                        Icons.search,
                        size: 20.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
