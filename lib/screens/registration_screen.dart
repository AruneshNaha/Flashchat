import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/chat_room.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email, password, name;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot snapshotUserInfo;

  void ErrorHandler(String error) {
    setState(() {
      Alert(
        type: AlertType.error,
        context: context,
        desc: error,
        title: "ERROR",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: kTextfieldDecoration.copyWith(
                      hintText: "Enter your Name"),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextfieldDecoration.copyWith(
                      hintText: "Enter your email"),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextfieldDecoration.copyWith(
                      hintText: "Enter your password"),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Register',
                  onPressed: () async {
                    if (name == null) {
                      ErrorHandler("You didn't give a proper user name");
                      return;
                    }
                    setState(() {
                      showSpinner = !showSpinner;
                    });
                    print(email);
                    print(password);
                    createNewUser(email, password);
                  },
                  colour: Colors.blueAccent,
                  tag: 'registration',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> createNewUser(String email, password) async {
    try {
      final newuser = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (newuser.uid != null) {
        Map<String, String> userInfoMap = {
          "name": name,
          "email": email,
          "uid": (newuser.uid).toString()
        };
        databaseMethods.uploadUserInfo(userInfoMap);
        saveLocalData(email, newuser.uid);
        Navigator.pushNamed(context, ChatRoom.id);
        setState(() {
          showSpinner = false;
        });
      }
    } catch (e) {
      print("Debug 2 : $e");
      ErrorHandler(e.toString());
    }
  }

  saveLocalData(String email, String uid) async {
    await databaseMethods.getUserByUserEmail(email).then((val) {
      snapshotUserInfo = val;
    });

    await HelperFunctions.saveUserEmailSharedPreference(email);
    String name = await snapshotUserInfo.documents[0].data()["name"];
    print("UserName: $name");

    HelperFunctions.saveUserNameSharedPreference(name);
    HelperFunctions.saveUserUidSharedPreference(uid);
    HelperFunctions.saveUserLoggedInSharedPreference(true);
    Constants.myName = name;
    Constants.myEmail = email;
    Constants.myUid = uid;
  }
}
