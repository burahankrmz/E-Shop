import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: Text(
          'E-Shop',
          style: TextStyle(
              fontFamily: 'Signatra', fontSize: 40.0, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _adminIDTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        height: _screenHeight,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.pink, Colors.lightGreenAccent],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: _screenWidth / 3.5,
              height: _screenHeight / 3.5,
              child: Image.asset(
                'images/admin.png',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin Login",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: 'Admin ID',
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
                      _adminIDTextEditingController.text.isNotEmpty &&
                              _passwordTextEditingController.text.isNotEmpty
                          ? loginAdmin()
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
                              builder: (context) => AuthenticScreen()));
                    },
                    child: Text(
                      "i'm not Admin",
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

  loginAdmin() async {
    bool isThere = false;
    String adminName = '';
    Firestore.instance.collection('admins').getDocuments().then((snapshot) {
      snapshot.documents.forEach((result) {
        if (result.data['id'] == _adminIDTextEditingController.text.trim() &&
            result.data['password'] ==
                _passwordTextEditingController.text.trim()) {
          isThere = true;
          adminName = result.data['name'];
        }
      });
      if (isThere == false) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Your Login Information is not correct')));
      } else if (isThere == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome Dear Admin,' + adminName)));
        Route route = MaterialPageRoute(builder: (_) => UploadPage());
        Navigator.pushReplacement(context, route);
      }
    });
  }
}
