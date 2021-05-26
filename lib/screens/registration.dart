
import 'package:connectivity/connectivity.dart';
import 'package:driver/globalvariable.dart';
import 'package:driver/screens/vehicleinfo.dart';
import 'package:driver/widgets/ProgressDialog.dart';
import 'package:driver/widgets/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../brand_colors.dart';
import 'loginpage.dart';
import 'mainpage.dart';




class RegistrationPage extends StatefulWidget {

  static const String id ='register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);


  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Registering  you in',),

    );



    final UserCredential1  = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text ,
      password: passwordController.text,

    ).catchError((ex){
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }
    ));

    Navigator.pop(context);

    if (UserCredential1 != null) {
      DatabaseReference newUserRef = FirebaseDatabase.instance.reference()
          .child('drivers/${UserCredential1.user.uid}');
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,


      };

      newUserRef.set(userMap);

      currentFirebaseUser = UserCredential1.user;
      Navigator.pushNamedAndRemoveUntil(context, VehicleInfoPage.id, (route) => false);


    }
    Navigator.pushNamedAndRemoveUntil(context, VehicleInfoPage.id, (route) => false);




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

                Text('Create a Driver\'s Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),

                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'FullName',
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
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
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
                        title: 'REGISTER',
                        color: BrandColors.colorOrange,
                        onPressed: () async {

                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet');
                            return;
                          }

                          if(fullNameController.text.length  < 3){
                            showSnackBar('Please provide a valid fullname');
                            return;

                          }

                          if(phoneController.text.length  < 10){
                            showSnackBar('Please provide a valid phone number');
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


                          registerUser();


                        },

                      ),


                      FlatButton(
                          onPressed: (){
                            Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                          },
                          child: Text('Already have a Rider Account? Logged in')

                      ),




                    ],
                  ),
                ),



              ],
            ),
          ),
        ),
      ),





    );




  }
}