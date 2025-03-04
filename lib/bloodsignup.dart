import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class BloodDonationFormPage extends StatefulWidget {
  const BloodDonationFormPage({Key? key}) : super(key: key);

  @override
  _BloodDonationFormPageState createState() => _BloodDonationFormPageState();
}

class _BloodDonationFormPageState extends State<BloodDonationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _lastDonationController = TextEditingController();
  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  Position? _currentLocation;
  LatLng? _selectedLatLng;
  bool _isSubmitting = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = position;
      _selectedLatLng ??= LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('blood_donors').add({
        'name': _nameController.text,
        'contact': _contactController.text,
        'blood_group': _selectedBloodGroup,
        'last_donation': _lastDonationDate != null
            ? DateFormat('yyyy-MM-dd').format(_lastDonationDate!)
            : null,
        'preferred_location': _selectedLatLng != null
            ? {
                'latitude': _selectedLatLng!.latitude,
                'longitude': _selectedLatLng!.longitude,
              }
            : null,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blood donation sign-up successful!')),
      );

      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blood Donation Sign-Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Contact Number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your contact number' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  hintText: 'Select Blood Group',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _bloodGroups
                    .map((group) => DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                validator: (value) => value == null ? 'Please select your blood group' : null,
              ),
              SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.calendar_today, color: Colors.redAccent),
                title: Text(_lastDonationDate == null
                    ? 'Select Last Donation Date'
                    : DateFormat('yyyy-MM-dd').format(_lastDonationDate!)),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => _lastDonationDate = picked);
                },
              ),
              SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.location_on, color: Colors.redAccent),
                title: Text(
                  _currentLocation == null
                      ? 'Fetch Current Location'
                      : 'Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
                ),
                onTap: _getCurrentLocation,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(
                        'Sign Up as a Donor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
