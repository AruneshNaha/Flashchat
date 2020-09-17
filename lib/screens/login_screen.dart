import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/chat_room.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  QuerySnapshot snapshotUserInfo;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String email, password;

  saveLocalData(String email) async {
    await databaseMethods.getUserByUserEmail(email).then((val) {
      snapshotUserInfo = val;
    });
    await HelperFunctions.saveUserEmailSharedPreference(email);
    String name = await snapshotUserInfo.documents[0].data()["name"];
    print("UserName: $name");

    HelperFunctions.saveUserNameSharedPreference(name);
    HelperFunctions.saveUserLoggedInSharedPreference(true);
  }

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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextfieldDecoration.copyWith(
                      hintText: "Enter your email")),
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
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: kNormalText,
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  title: "Log In",
                  onPressed: () {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser = auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      newUser.then((value) {
                        if (value == true) {
                          Navigator.pop(context);
                          setState(() {
                            showSpinner = false;
                          });
                        } else {
                          saveLocalData(email);
                          Navigator.pushNamed(context, ChatRoom.id);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }).catchError((onError) {
                        print("Debug 2 : $onError");
                        ErrorHandler(onError.toString());
                      });
                    } catch (e) {
                      print("Error: $e");
                    }
                  },
                  colour: Colors.lightBlueAccent,
                  tag: 'login'),
            ],
          ),
        ),
      ),
    );
  }
}
