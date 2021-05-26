import 'package:driver/helpers/helpermethods.dart';
import 'package:driver/helpers/rideDetails.dart';
import 'package:driver/screens/newtripspage.dart';
import 'package:driver/widgets/BrandDivier.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '';

import '../brand_colors.dart';
import '../globalvariable.dart';
import 'ProgressDialog.dart';
import 'TaxiButton.dart';
import 'TaxiOutlineButton.dart';


class NotificationDialog extends StatelessWidget{
  final RideDetails rideDetails;
  NotificationDialog({this.rideDetails});

  @override

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4)
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
           SizedBox(height: 30.0,),

           Image.asset('images/taxi.png', width: 100,),

            SizedBox(height: 16.0,),

             Text('NEW TRIP REQUEST', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),),

              SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(

                children: <Widget>[

                  Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),


                      Expanded(child: Container(child: Text(rideDetails.pickup_address, style: TextStyle(fontSize: 18),)))


                  ],
                ),

                      SizedBox(height: 15,),
                   Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                       Image.asset('images/desticon.png', height: 16, width: 16,),
                       SizedBox(width: 18,),

                    Expanded(child: Container(child: Text(rideDetails.destination_address, style: TextStyle(fontSize: 18),)))


                ],
             ),












              ],

              ),


              ),
            SizedBox(height: 30.0,),
            BrandDivider(),
            SizedBox(height: 8,),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 10,),

                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailablity(context);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),




          ],

          ),
      )
    );

  }

  void checkAvailablity(context){

    //show progress dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder:(BuildContext context) => ProgressDialog (status: 'Accepting request',),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newTrip');
    newRideRef.once().then((DataSnapshot snapshot){
      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideID = "";
      if(snapshot.value != null){
        thisRideID = snapshot.value.toString();
      }
      else{
        Toast.show("Ride not Found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      if (thisRideID == rideDetails.rideID){
        newRideRef.set('accepted');
        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewTripsPage(rideDetails: rideDetails,),
          ));
      }
      else if (thisRideID == 'cancelled'){
        Toast.show("Ride Cancelled", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);

      }
      else if(thisRideID == 'timeout'){
        Toast.show("Ride timeed out", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);

      }
      else{
        Toast.show("Ride not Found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }


    });


  }

}