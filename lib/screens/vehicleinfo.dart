import 'package:connectivity/connectivity.dart';
import 'package:driver/brand_colors.dart';
import 'package:driver/screens/loginpage.dart';
import 'package:driver/screens/registration.dart';
import 'package:driver/globalvariable.dart';
import 'package:driver/widgets/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mainpage.dart';

class VehicleInfoPage extends StatefulWidget {
  static const String id = 'vehicleinfo';

  @override
  _VehicleInfoPageState createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  var carModelController = TextEditingController();

  var carColorController = TextEditingController();


  var plateNumberController = TextEditingController();

  void updateProfile(context)  {

    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

      Map map = {
        'car_color': carColorController.text,
        'car_model': carModelController.text,
        'plate_number': plateNumberController.text,
      };
      driverRef.set(map);
      Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
    }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(


            children: <Widget>[

              SizedBox(height: 20,),
              Image.asset('images/logo3.png', height: 220.0, width: 220.0,),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10,),

                   Text ('Enter Vehicle details', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),),
                   SizedBox(height: 25,),

                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,

                        )
                      ),
                      style: TextStyle(fontSize: 14.0),


                    ),
                    SizedBox(height: 10,),


                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car Color',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,

                          )
                      ),
                      style: TextStyle(fontSize: 14.0),


                    ),
                    SizedBox(height: 10,),


                    TextField(
                      controller: plateNumberController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Plate Number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,

                          )
                      ),
                      style: TextStyle(fontSize: 14.0),


                    ),
                    SizedBox(height: 40.0,),

                    TaxiButton(
                      color: BrandColors.colorOrange,
                      title: 'PROCEED',
                      onPressed: ()async {

                    var connectivityResult = await Connectivity().checkConnectivity();
                    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){showSnackBar('No Internet');
                    return;
                    }


                        if(carModelController.text.length  < 3){
                          showSnackBar('Please provide a valid car model');
                          return;

                        }

                        if(carColorController.text.length  < 3){
                          showSnackBar('Please provide a valid car color');
                          return;

                        }
                        if(plateNumberController.text.length < 3) {
                          showSnackBar('Please provide a valid plate number');
                          return;

                        }
                        updateProfile(context);

                      },
                    )


                  ],

                ),
              ),



            ],
            
          ),
        ),
      ),
    );
  }
}
