import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AuthorityPage extends StatefulWidget {
  @override
  _AuthorityPageState createState() => _AuthorityPageState();
}

class _AuthorityPageState extends State<AuthorityPage> {
  late GoogleMapController mapController;
  
  final LatLng _initialLocation = LatLng(11.194249397596916, 75.85098108272076);
  
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _markers.add(
        Marker(
          markerId: MarkerId('initialLocation'),
          position: _initialLocation,
          infoWindow: InfoWindow(title: 'Incident Location'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authority Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialLocation,
                zoom: 15, // Adjusted zoom
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              markers: _markers,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text('Urgent Reports & SOS Alerts'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Categorized Reports & Notifications'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.update),
                  title: Text('Update Status & Incident Log'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Emergency Response Actions'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Send Alerts & Notifications'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Generate Reports & Analytics'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
