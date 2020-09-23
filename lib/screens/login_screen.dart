import 'package:Flashchat/constants.dart';
import 'package:Flashchat/screens/chat_room.dart';
import 'package:Flashchat/screens/helperFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  GoogleSignIn googleuser = GoogleSignIn();

  saveLocalData(String email, String uid) async {
    await databaseMethods.getUserByUserEmail(email).then((val) {
      snapshotUserInfo = val;
    });
    await HelperFunctions.saveUserEmailSharedPreference(email);
    String name = await snapshotUserInfo.documents[0].data()["name"];
    String fetchuid = await snapshotUserInfo.documents[0].data()["uid"];
    String docID = snapshotUserInfo.docs[0].id;

    print("User uid: $fetchuid");
    print("UserName: $name");

    if (fetchuid == null) {
      print("UID in if block:$uid");
      print("Document ID: $docID");
      Map<String, String> userInfoMap = {
        "name": name,
        "email": email,
        "uid": uid.toString()
      };
      await FirebaseFirestore.instance
          .collection("users")
          .doc(docID)
          .set(userInfoMap);
    }

    await HelperFunctions.saveUserNameSharedPreference(name);
    await HelperFunctions.saveUserUidSharedPreference(uid);
    await HelperFunctions.saveUserLoggedInSharedPreference(true);
    Constants.myName = name;
    Constants.myEmail = email;
    Constants.myUid = uid;
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
                    signInWithEmail(email, password);
                  },
                  colour: Colors.lightBlueAccent,
                  tag: 'login'),
              RoundedButton(
                  title: "Sign in with Google",
                  onPressed: () {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      signinWithGoogle();
                    } catch (e) {
                      print(
                          "Error while signing in with Google: ${e.toString()}");
                      ErrorHandler(e.toString());
                    }
                  },
                  colour: Colors.lightBlueAccent,
                  tag: 'login2'),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> signinWithGoogle() async {
    try {
      bool isLoggedIn = await googleuser.isSignedIn();

      final GoogleSignInAccount user = await googleuser.signIn();
      final GoogleSignInAuthentication googleAuth = await user.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final FirebaseUser firebaseUser =
          (await auth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection("user")
            .where("id", isEqualTo: firebaseUser.uid)
            .get();

        List<QueryDocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          if (isLoggedIn) {
            FirebaseFirestore.instance
                .collection("user")
                .doc(firebaseUser.uid)
                .setData({
              "email": firebaseUser.email,
              "name": firebaseUser.displayName,
              "id": firebaseUser.uid
            });

            HelperFunctions.saveUserNameSharedPreference(
                firebaseUser.displayName);
            HelperFunctions.saveUserEmailSharedPreference(firebaseUser.email);
            HelperFunctions.saveUserLoggedInSharedPreference(true);

            Constants.myEmail = firebaseUser.email;
            Constants.myName = firebaseUser.displayName;
            Constants.myUid = firebaseUser.uid;
            setState(() {
              saveLocalData(email, firebaseUser.uid);
              showSpinner = false;
              Navigator.pushNamed(context, ChatRoom.id);
            });
          }
        }
      }
    } catch (e) {
      print("Debug 2 : $e");
      ErrorHandler(e.toString());
    }
  }

  Future<Null> signInWithEmail(String email, password) async {
    try {
      final newuser = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (newuser.uid != null) {
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
}
