import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:neighborly/incidentlocation.dart';
import 'package:neighborly/notification.dart';
import 'package:permission_handler/permission_handler.dart';

class FoodDonationPage extends StatefulWidget {
  @override
  _FoodDonationPageState createState() => _FoodDonationPageState();
}

class _FoodDonationPageState extends State<FoodDonationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for various fields
  final _foodNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _contactController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedFoodType;
  DateTime? _expiryDate;
  TimeOfDay? _expiryTimeOfDay;

  // For location
  Position? _currentLocation;
  LatLng? _selectedLatLng;

  // For images
  List<XFile> _images = [];

  // Food type dropdown options
  final List<String> _foodTypes = [
    "Cooked",
    "Packaged",
    "Fresh Produce",
    "Other"
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
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = position;
      _selectedLatLng ??= LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles;
      });
    }
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        for (XFile image in _images) {
          String? url = await getClodinaryUrl(image.path);
          if (url != null) imageUrls.add(url);
        }
      }

      await FirebaseFirestore.instance.collection('food_donations').add({
        'category': 'Food Donation',
        'foodType': _selectedFoodType,
        'foodName': _foodNameController.text,
        'description': _descriptionController.text,
        'quantity': _quantityController.text,
        'servingSize': _servingSizeController.text,
        'expiryDate': _expiryDate?.toIso8601String(),
        'expiryTime': _expiryTimeOfDay != null ? _expiryTimeOfDay!.format(context) : null,
        'pickupLocation': _selectedLatLng != null
            ? {
                'latitude': _selectedLatLng!.latitude,
                'longitude': _selectedLatLng!.longitude,
              }
            : null,
        'contact': _contactController.text,
        'instructions': _instructionsController.text,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });

      sendNotificationToDevice('New Food Donation', 'A new food donation is available!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food donation submitted successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String locationText = _selectedLatLng != null
        ? 'Pickup Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
        : 'No location selected';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Donation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Food Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedFoodType,
                decoration: InputDecoration(
                  hintText: 'Select Food Type',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                items: _foodTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedFoodType = value),
                validator: (value) =>
                    value == null ? 'Please select a food type' : null,
              ),
              SizedBox(height: 12),
              // Food Name
              TextFormField(
                controller: _foodNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Food Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter food name' : null,
              ),
              SizedBox(height: 12),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please provide a description' : null,
              ),
              SizedBox(height: 12),
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: 'Enter Quantity (e.g., 20 meals)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter quantity' : null,
              ),
              SizedBox(height: 12),
              // Serving Size (optional)
              TextFormField(
                controller: _servingSizeController,
                decoration: InputDecoration(
                  hintText: 'Enter Serving Size (optional)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 12),
              // Expiry Date
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text(_expiryDate == null
                    ? 'Select Expiry Date'
                    : '${_expiryDate!.toLocal()}'.split(' ')[0]),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => _expiryDate = picked);
                },
              ),
              SizedBox(height: 12),
              // Expiry Time
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.access_time, color: Colors.green),
                title: Text(_expiryTimeOfDay == null
                    ? 'Select Expiry Time'
                    : _expiryTimeOfDay!.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _expiryTimeOfDay = picked);
                },
              ),
              SizedBox(height: 12),
              // Current Location (fetch)
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text(
                  _currentLocation == null
                      ? 'Fetch Current Location'
                      : 'Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
                ),
                onTap: _getCurrentLocation,
              ),
              SizedBox(height: 12),
              // Pickup Location picker
              InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PickLocationPage()),
                  );
                  if (result != null && result is LatLng) {
                    setState(() {
                      _selectedLatLng = result;
                    });
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_history,
                          color: Colors.green, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedLatLng != null
                              ? 'Pickup Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                              : "Pickup Location",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedLatLng != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey, size: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Contact Information
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  hintText: 'Enter Contact Information',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter contact info' : null,
              ),
              SizedBox(height: 12),
              // Special Instructions (optional)
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter Special Instructions (optional)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 12),
              // Image Upload Button
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 20),
                    SizedBox(width: 8),
                    Text('Attach Images'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              if (_images.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_images[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Submit Donation',
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
