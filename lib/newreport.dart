import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class CreateReportPage extends StatefulWidget {
  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _urgencyLevel;
  DateTime? _dateTime;
  TimeOfDay? _timeOfDay;
  Position? _location;
  XFile? _image;

  final List<String> _categories = [
    'Accident',
    'Theft',
    'Road Issue',
    'Hygiene Issue',
    'Sexual Harassment',
    'Public Hazards',
  ];

  final List<String> _urgencyLevels = ['Low', 'Medium', 'High'];

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
    _location = position;
  });
}


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await getClodinaryUrl(_image!.path);
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'category': _selectedCategory,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _dateTime?.toIso8601String(),
        'time': _timeOfDay != null ? _timeOfDay!.format(context) : null,
        'location': _location != null
            ? {'latitude': _location!.latitude, 'longitude': _location!.longitude}
            : null,
        'urgency': _urgencyLevel,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
        _urgencyLevel = null;
        _dateTime = null;
        _timeOfDay = null;
        _location = null;
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(
    'Create Report',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blueAccent, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Custom back button
    onPressed: () {
      Navigator.of(context).pop(); // Navigate back
    },
  ),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
            DropdownButtonFormField<String>(
  value: _selectedCategory,
  decoration: InputDecoration(
    hintText: 'Select Category',
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(Icons.category), // Add an icon here
  ),
  items: _categories.map((category) => DropdownMenuItem<String>(
    value: category,
    child: Text(category),
  )).toList(),
  onChanged: (value) => setState(() => _selectedCategory = value),
  validator: (value) => value == null ? 'Please select a category' : null,
),
              SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _urgencyLevel,
                decoration: InputDecoration(hintText: 'Select Urgency Level', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                items: _urgencyLevels.map((level) => DropdownMenuItem<String>(value: level, child: Text(level))).toList(),
                onChanged: (value) => setState(() => _urgencyLevel = value),
                validator: (value) => value == null ? 'Please select urgency level' : null,
              ),

              SizedBox(height: 12),

              TextFormField(controller: _titleController, decoration: InputDecoration(hintText: 'Enter Title', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null),

              SizedBox(height: 12),

              TextFormField(controller: _descriptionController, maxLines: 4, decoration: InputDecoration(hintText: 'Enter Description', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)), validator: (value) => value == null || value.isEmpty ? 'Please provide a description' : null),

              SizedBox(height: 12),

              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.lock_clock_rounded, color: Colors.blueAccent),
                title: Text(_dateTime == null ? 'Select Date' : '${_dateTime!.toLocal()}'.split(' ')[0]),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
                  if (picked != null) setState(() => _dateTime = picked);
                },
              ),

              SizedBox(height: 12),

              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.location_on, color: Colors.blueAccent),
                title: Text(_timeOfDay == null ? 'Select Time' : _timeOfDay!.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked != null) setState(() => _timeOfDay = picked);
                },
              ),
              SizedBox(height: 12),
               ListTile(
  tileColor: Colors.grey[200],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  leading: Icon(Icons.location_on, color: Colors.blueAccent), // Add an icon here
  title: Text(
    _location == null
        ? 'Fetch Current Location'
        : 'Location: ${_location!.latitude}, ${_location!.longitude}',
  ),
  onTap: _getCurrentLocation, // Fetch location when tapped
),
              SizedBox(height: 12),

             ElevatedButton(
  onPressed: _pickImage,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent, // Button background color
    foregroundColor: Colors.white, // Text and icon color
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Rounded corners
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.image, size: 20), // Add an icon
      SizedBox(width: 8), // Space between icon and text
      Text('Attach Image'),
    ],
  ),
),

              SizedBox(height: 12),

              ElevatedButton(onPressed: _submitReport, child: Text('Submit Report')),
            ],
          ),
        ),
      ),
    );
  }
}
