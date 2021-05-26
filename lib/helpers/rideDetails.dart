import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
    String pickup_address;
    String destination_address;
    String payment_method;
    String rideID;
    LatLng location;
    LatLng destination;
    String RequestID;
    String riderName;
    String riderPhone;


    RideDetails(
    {
      this.destination_address,
        this.payment_method,
        this.pickup_address,
        this.rideID,
        this.destination,
      this.location,
      this.RequestID,
      this.riderName,
      this.riderPhone

        });


}