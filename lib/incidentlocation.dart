import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationPage extends StatefulWidget {
  @override
  _PickLocationPageState createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
      ),
    );
  }
}
