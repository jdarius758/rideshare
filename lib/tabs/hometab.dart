import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:driver/brand_colors.dart';
import 'package:driver/datamodels/driver.dart';
import 'package:driver/globalvariable.dart';
import 'package:driver/helpers/helpermethods.dart';
import 'package:driver/helpers/pushnotificationservice.dart';
import 'package:driver/widgets/ConfirmSheet.dart';
import 'package:driver/widgets/NotificationDialog.dart';
import 'package:driver/widgets/ProgressDialog.dart';
import 'package:driver/widgets/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController mapController;
  Completer <GoogleMapController> _controller = Completer();



  var geolocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String AvailabilityTitle = 'Go Online';
  Color availableColor = BrandColors.colorGreen;
  bool isAvailable = false;


  void getCurrentPosition() async {

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));
  }
  void getCurrentDriverInfo() async {

    currentFirebaseUser = await FirebaseAuth.instance.currentUser();

    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print(currentDriverInfo.fullName);
      }

    });
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();


    HelperMethods.getHistoryInfo(context);


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 85),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;
            getCurrentPosition();

          },


        ),


        Container(
          height: 85,
          width: double.infinity,
          color: BrandColors.colorBackground,
        ),
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: <Widget>[
              TaxiButton(
                title: AvailabilityTitle,
                color: availableColor,
                onPressed: () async {

                  var connectivityResult = await Connectivity().checkConnectivity();
                  if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => ProgressDialog(status: 'NO INTERNET',),

                    );
                    return;
                  }



                  showModalBottomSheet
                    (
                      isDismissible: false,
                      context: context,
                      builder: (BuildContext context) => ConfirmSheet(
                        title : (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                        subtitle: (!isAvailable) ? 'You are about to receive trip request': 'you will stop receiving trip requests',
                        onPressed: (){
                          if(!isAvailable){
                            GoOnline();
                            getLocationUpdates();
                            Navigator.pop(context);
                            setState(() {
                              availableColor = BrandColors.colorPink;
                              AvailabilityTitle = 'Go OFFLINE';
                              isAvailable = true;
                            });

                          }
                          else{
                            GoOffline();
                            Navigator.pop(context);

                            setState(() {
                              availableColor = BrandColors.colorGreen;
                              AvailabilityTitle = 'Go OnLINE';
                              isAvailable = false;
                            });


                          }



                        },
                      ),


                  );

                },
              ),
            ],
          ),
        )

      ],

    );
  }

  void GoOnline() {
    Geofire.initialize('driversAvailable');
    if (currentPosition != null) {
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
    }
      tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newTrip');
      tripRequestRef.set('waiting');
      tripRequestRef.onValue.listen((event) {

      });

  }
  void GoOffline(){
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  void getLocationUpdates(){

    homeTabPositionStream = geolocator.getPositionStream(locationOptions).listen((Position position) {

      currentPosition = position;

      if (isAvailable) {
        Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));

    });


  }
}
