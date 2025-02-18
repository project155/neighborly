import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class PickLocationPage extends StatefulWidget {
  @override
  _PickLocationPageState createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  // Default location (San Francisco) until we get the current position.
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled. You might show an error message.
      return;
    }

    // Check for permission; request if not granted.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    // Get the current position.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });

    // Move the camera to the current location if the map is ready.
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Location")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Once the map is created, animate to the current location if available.
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(_selectedLocation),
              );
            },
            // As the camera moves, update the selected location to the center of the map.
            onCameraMove: (CameraPosition position) {
              setState(() {
                _selectedLocation = position.target;
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Centered pin icon indicating the selected location.
          IgnorePointer(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),
          // Display the selected coordinates at the bottom of the map.
          Positioned(
            bottom: 100,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          // Return the selected location when the user confirms.
          Navigator.pop(context, _selectedLocation);
        },
      ),
    );
  }
}
