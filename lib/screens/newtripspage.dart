import 'dart:async';

import 'package:driver/brand_colors.dart';
import 'package:driver/globalvariable.dart';
import 'package:driver/helpers/helpermethods.dart';
import 'package:driver/helpers/mapkithelper.dart';
import 'package:driver/helpers/rideDetails.dart';
import 'package:driver/widgets/CollectPaymentDialog.dart';
import 'package:driver/widgets/ProgressDialog.dart';
import 'package:driver/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class NewTripsPage extends StatefulWidget {

  final RideDetails rideDetails;
  NewTripsPage({this.rideDetails});
  @override
  _NewTripsPageState createState() => _NewTripsPageState();
}

class _NewTripsPageState extends State<NewTripsPage> {


  GoogleMapController RidemapController;
  Completer <GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;
  List<LatLng> polylineCoordinates = [];
  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();

  PolylinePoints polylinePoints = PolylinePoints();
  Position myPosition;
  String status ='accepted';
  String durationString = '';
  bool isRequestingDirection = false;
  String buttonTitle = 'ARRIVED';
  Timer timer;

  int durationCounter = 0;


  Color buttonColor = BrandColors.colorGreen;



  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  BitmapDescriptor movingMarkerIcon;


  void createMarker(){
    if(movingMarkerIcon == null){

      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2,2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'images/car_android.png'
      ).then((icon){
        movingMarkerIcon = icon;
      });
    }
  }










  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }
  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print(' could not launch $command');
    }
  }






  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingBottom),            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            trafficEnabled: true,
            initialCameraPosition: googlePlex,
            circles: _circles,
            markers: _markers,
            polylines: _polyLines,

            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              RidemapController = controller;
              mapPaddingBottom = 360;
              var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.rideDetails.location;

              getlocationUpdates();
              await getDirection(currentLatLng, pickupLatLng);
            setState(() {
              mapPaddingBottom = 360;

            });
            },



    ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration:  BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  )
                ],


              ),
              height: 380,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      durationString,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Brand-Bold',
                        color: BrandColors.colorAccentPurple
                      ),
                    ),



                    SizedBox(height: 5 ,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget> [
                        Expanded(child: Text(widget.rideDetails.riderName, style: TextStyle(fontSize: 22, fontFamily: 'Brand-bold'),)),
                        Padding(
                            padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: new Icon(Icons.phone),
                            onPressed: (){
                              customLaunch('tel:${widget.rideDetails.riderPhone}');

                            },

                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5 ,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget> [
                        Expanded(child: Text('Pick-Up Address - ', style: TextStyle(fontSize: 16),)),
                      ],
                    ),


                    SizedBox(height: 10,),


                    Row(
                      children: <Widget>[
                        Image.asset('images/pickicon.png', height: 16, width: 16,),
                        SizedBox(width: 18,),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.pickup_address,
                              style: TextStyle(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      ],
                    ),


                    SizedBox(height: 5 ,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget> [
                        Expanded(child: Text('Destination Address - ', style: TextStyle(fontSize: 16),)),
                      ],
                    ),

                    SizedBox(height: 10,),

                    Row(
                      children: <Widget>[
                        Image.asset('images/desticon.png', height: 16, width: 16,),
                        SizedBox(width: 18,),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.destination_address,
                              style: TextStyle(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5 ,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget> [
                        Expanded(child: Text('Phone Number - ', style: TextStyle(fontSize: 16),)),
                      ],
                    ),

                    SizedBox(height: 5,),
                    Row(
                      children: <Widget>[

                        Expanded(

                          child: Row(
                            children: [

                                IconButton(
                                  icon: new Icon(Icons.phone_android),
                                  onPressed: (){
                                    customLaunch('tel:${widget.rideDetails.riderPhone}');

                                  },

                              ),

                              Container(
                                child: Text(
                                  widget.rideDetails.riderPhone,
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 20,),



                    TaxiButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPressed: () async {

                        if(status == 'accepted'){

                          status = 'arrived';
                          rideRef.child('status').set(('arrived'));

                          setState(() {
                            buttonTitle = 'START TRIP';
                            buttonColor = BrandColors.colorAccentPurple;
                          });

                          HelperMethods.showProgressDialog(context);

                          await getDirection(widget.rideDetails.location, widget.rideDetails.destination);

                          Navigator.pop(context);
                        }
                        else if(status == 'arrived'){
                          status = 'ontrip';
                          rideRef.child('status').set('ontrip');

                          setState(() {
                            buttonTitle = 'END TRIP';
                            buttonColor = Colors.red[900];
                          });

                          startTimer();
                        }
                        else if(status == 'ontrip'){
                         endTrip();
                      }

                      },

                    )










                  ],
                ),
              ),

            ),
          )







        ],
      ),
    );
  }

  void acceptTrip(){
    String rideID = widget.rideDetails.rideID;
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');

    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    rideRef.child('car_details').set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };

    rideRef.child('driver_location').set(locationMap);
    DatabaseReference historyRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/history/$rideID');
    historyRef.set(true);


  }

  void getlocationUpdates(){
    LatLng oldPos = LatLng(0,0);
    ridePositionStream = geoLocator.getPositionStream(locationOptions).listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      
      var rotation = MapKitHelper.getMarkerRotation(oldPos.latitude, oldPos.longitude, pos.latitude, pos.longitude);

      Marker movingMaker = Marker(
          markerId: MarkerId('moving'),
          position: pos,
          icon: movingMarkerIcon,
          rotation: rotation,
          infoWindow: InfoWindow(title: 'Current Location')
      );

      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        RidemapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMaker);
      });

      oldPos = pos;
      updateTripDetails();
      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);





    });
  }

  void updateTripDetails() async{

    if(!isRequestingDirection){

      isRequestingDirection = true;

      if(myPosition == null){
        return;
      }

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      if(status == 'accepted'){
        destinationLatLng = widget.rideDetails.location;
      }
      else{
        destinationLatLng = widget.rideDetails.destination;
      }

      var directionDetails = await HelperMethods.getDirectionDetails(positionLatLng, destinationLatLng);

      if(directionDetails != null){

        print(directionDetails.durationText);

        setState(() {
          durationString = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;

    }

  }

  Future<void> getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async{


    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please wait',),

    );



    var thisDetails =  await HelperMethods.getDirectionDetails(pickupLatLng, destinationLatLng);



    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if(results.isNotEmpty){

      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));

      });
    }
     _polyLines.clear();

    setState(() {

      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255,95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        geodesic: true,

      );

      _polyLines.add(polyline);

    });

    LatLngBounds bounds;

    if(pickupLatLng.latitude > destinationLatLng.latitude && pickupLatLng.longitude > destinationLatLng.longitude)
    {
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);


    }
    else if (pickupLatLng.longitude > destinationLatLng.longitude)
    {
      bounds = LatLngBounds(
        southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude,pickupLatLng.longitude),
      );

    }
    else if (pickupLatLng.latitude > destinationLatLng.latitude)
    {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),

      );
    }
    else {
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);


    }
    RidemapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);

    });
    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });




  }

  void startTimer(){
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {

    timer.cancel();

    HelperMethods.showProgressDialog(context);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionDetails = await HelperMethods.getDirectionDetails(widget.rideDetails.location, currentLatLng);

    Navigator.pop(context);

    int fares = HelperMethods.estimateFares(directionDetails, durationCounter);

    rideRef.child('fares').set(fares.toString());

    rideRef.child('status').set('ended');

    ridePositionStream.cancel();


    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectPayment(
          paymentMethod: widget.rideDetails.payment_method,
          fares: fares,
        )
    );

    topUpEarnings(fares);



  }

  void topUpEarnings(int fares){

    DatabaseReference earningsRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/earnings');
    earningsRef.once().then((DataSnapshot snapshot) {

      if(snapshot.value != null){

        double oldEarnings = double.parse(snapshot.value.toString());

        double adjustedEarnings = (fares.toDouble() * 0.85) + oldEarnings;

        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }
      else{
        double adjustedEarnings = (fares.toDouble() * 0.85);
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }

    });
  }


}
