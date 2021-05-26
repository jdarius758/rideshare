import 'package:driver/widgets/TaxiButton.dart';

import 'package:connectivity/connectivity.dart';
import 'package:driver/screens/registration.dart';
import 'package:driver/widgets/ProgressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand_colors.dart';
import 'mainpage.dart';



class LoginPage extends StatefulWidget {

  static const String id ='login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);


  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async{

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Logging you in',),

    );

    final UserCredential1 = (await _auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,

    ).catchError((ex){
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }
    ));


    if(UserCredential1 != null){
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${UserCredential1.user.uid}');
      userRef.once().then((DataSnapshot snapshot) {
        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
        }
      });

    }

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: scaffoldKey,

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 70,),
                Image(
                  alignment: Alignment.center,
                  height: 220.0,
                  width: 220.0,
                  image: AssetImage('images/logo3.png'),

                ),
                SizedBox(height: 40,),

                Text('Sign in as a Driver',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),

                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),

                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )

                        ),
                        style: TextStyle(fontSize: 14),

                      ),
                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
                        obscureText: true,

                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),

                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )

                        ),
                        style: TextStyle(fontSize: 14),

                      ),
                      SizedBox(height: 40,),

                      TaxiButton(

                        title: 'LOGIN',
                        color: BrandColors.colorOrange,

                        onPressed: () async {

                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No Internet');
                            return;
                          }
                          if(!emailController.text.contains('@')) {
                            showSnackBar('Please provide a valid email Address');
                            return;

                          }
                          if(passwordController.text.length  < 8){
                            showSnackBar('Please provide atleast 8 characters ');
                            return;

                          }
                          login();

                        },

                      ),





                    ],
                  ),
                ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);

                    },
                    child: Text('Don\'t have an Account, Sign up here')
                ),



              ],
            ),
          ),
        ),
      ),





    );




  }
}

class TaxiButton1 extends StatelessWidget {
  const TaxiButton1({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: (){

      },

      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25)
      ),



      color: BrandColors.colorGreen,
      textColor: Colors.white,
      child: Container(
        height: 50,
        child: Center(
          child: Text(
              'LOGIN',
              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold')
          ),
        ),
      ),



    );
  }
}