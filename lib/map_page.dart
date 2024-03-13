import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {
  const MapPage(
      {super.key,
        required this.latitude,
        required this.longitude,
        this.myLocation});
  final void Function(double latitude, double longitude)? myLocation;

  final double latitude;
  final double longitude;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late  double updatedLatitude=widget.latitude;
  late double updatedLongitude=widget.longitude;
  late final CameraPosition placePosition = CameraPosition(
    target: LatLng(widget.latitude, widget.longitude),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
        title: Text('Your Location'),
      ),
      body: GoogleMap(markers: {Marker(markerId: MarkerId('id'),position: LatLng(updatedLatitude,updatedLongitude))},
        mapType: MapType.hybrid,
        initialCameraPosition: placePosition,
        onMapCreated: (GoogleMapController controller) {
          // _controller.complete(controller);
        },
        onTap: widget.myLocation == null
            ? null
            : (latLang) {
          setState(() {
            updatedLatitude = latLang.latitude;
            updatedLongitude = latLang.longitude;
            widget.myLocation!(updatedLatitude, updatedLongitude);
          });

        },
      ),
    );
  }
}
