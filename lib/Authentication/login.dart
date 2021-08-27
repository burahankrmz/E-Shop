import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: _screenWidth / 3.5,
              height: _screenHeight / 3.5,
              child: Image.asset(
                'images/login.png',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Login to your account",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.mail,
                    hintText: 'Mail Adress',
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.lock,
                    hintText: 'Password',
                    isObsecure: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _emailTextEditingController.text.isNotEmpty &&
                              _passwordTextEditingController.text.isNotEmpty
                          ? loginUser()
                          : showDialog(
                              context: (context),
                              builder: (c) {
                                return ErrorAlertDialog(
                                  message: 'Please write email and password.',
                                );
                              });
                    },
                    child: Text(
                      'Login',
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.pink),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    height: 4.0,
                    width: _screenWidth * 0.8,
                    color: Colors.pink,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminSignInPage()));
                    },
                    child: Text(
                      "i'm Admin",
                      style: TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  loginUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: "Authenticating, Please wait...",
          );
        });
    FirebaseUser firebaseUser;
    await _auth
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((value) {
      firebaseUser = value.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });
    if (firebaseUser != null) {
      readData(firebaseUser).then((s) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future readData(FirebaseUser firebaseUser) async {
    await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .get()
        .then((dataSnapshot) async {
      await EcommerceApp.sharedPreferences
          .setString('uid', dataSnapshot.data[EcommerceApp.userUID]);
      await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userEmail, dataSnapshot.data[EcommerceApp.userEmail]);
      await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userName, dataSnapshot.data[EcommerceApp.userName]);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl,
          dataSnapshot.data[EcommerceApp.userAvatarUrl]);

      List<String> cartList;
      dataSnapshot.data[EcommerceApp.userCartList] != null
          ? cartList =
              dataSnapshot.data[EcommerceApp.userCartList].cast<String>()
          : cartList = null;
      await EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, cartList);

      print(cartList);
    });
  }
}
