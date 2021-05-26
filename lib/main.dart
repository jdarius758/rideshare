import 'package:driver/dataprovider.dart';
import 'package:driver/globalvariable.dart';
import 'package:driver/screens/loginpage.dart';
import 'package:driver/screens/mainpage.dart';
import 'package:driver/screens/registration.dart';
import 'package:driver/screens/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'globalvariable.dart';
import 'globalvariable.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ?  FirebaseOptions(
     googleAppID:'1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
      gcmSenderID: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : FirebaseOptions(
      googleAppID:'1:367466122428:android:b8c8be16501ec2939354b9',
      apiKey: 'AIzaSyD9DzpWHBEc0lhuahFGzDKI_EaR4PCIBSI',
      databaseURL:'firebase_url": "https://ride-share-8cb05-default-rtdb.firebaseio.com',

    ),

  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',

          primarySwatch: Colors.blue,

          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: (FirebaseAuth.instance.currentUser == null) ? LoginPage.id :  MainPage.id,

        routes: {
          MainPage.id: (context) => MainPage(),
          RegistrationPage.id: (context) =>  RegistrationPage(),
          VehicleInfoPage.id: (context) => VehicleInfoPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),
    );
  }
}
