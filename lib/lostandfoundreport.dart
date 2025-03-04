import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neighborly/incidentlocation.dart'; // Adjust the path if necessary
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'clodinary_upload.dart'; // Import your Cloudinary helper

class CreateLostFoundItemPage extends StatefulWidget {
  final XFile? attachment; // Optional image attachment

  const CreateLostFoundItemPage({Key? key, this.attachment}) : super(key: key);

  @override
  _CreateLostFoundItemPageState createState() => _CreateLostFoundItemPageState();
}

class _CreateLostFoundItemPageState extends State<CreateLostFoundItemPage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown for lost/found type
  String? _itemType; // 'Lost' or 'Found'
  final List<String> _itemTypes = ['Lost', 'Found'];

  // Dropdown for item category
  String? _itemCategory;
  final List<String> _itemCategories = [
    'Wallet',
    'Phone',
    'Clothing',
    'Electronics',
    'Keys',
    'Other'
  ];

  // Common fields
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Contact Information Controllers
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  // Date and Time pickers
  DateTime? _dateTime;
  TimeOfDay? _timeOfDay;

  // Additional fields for lost items
  final _rewardController = TextEditingController();
  final _lastSeenController = TextEditingController();

  // Additional fields for found items
  String? _itemWhereabouts;
  final List<String> _whereaboutsOptions = [
    'With me',
    'Handed over to security',
    'At a police station'
  ];
  final _handoverMethodController = TextEditingController();

  // Location fields (current location is fetched but not shown)
  Position? _currentLocation;
  LatLng? _selectedLatLng;

  // Image picker
  List<XFile> _images = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.attachment != null) {
      _images.add(widget.attachment!);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
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

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate() || _itemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Upload images to Cloudinary using the helper function from clodinary_upload.dart
    List<String> imageUrls = [];
    for (var image in _images) {
      String? url = await getClodinaryUrl(image.path);
      if (url != null) {
        imageUrls.add(url);
      }
    }

    // Build the data to submit.
    Map<String, dynamic> data = {
      'itemType': _itemType,
      'itemCategory': _itemCategory,
      'itemName': _itemNameController.text,
      'description': _descriptionController.text,
      // Format the date to only include year, month, and day.
      'date': _dateTime != null ? DateFormat('yyyy-MM-dd').format(_dateTime!) : null,
      'time': _timeOfDay != null ? _timeOfDay!.format(context) : null,
      'imageUrls': imageUrls,
      'currentLocation': _currentLocation != null
          ? {
              'latitude': _currentLocation!.latitude,
              'longitude': _currentLocation!.longitude,
            }
          : null,
      'itemLocation': _selectedLatLng != null
          ? {
              'latitude': _selectedLatLng!.latitude,
              'longitude': _selectedLatLng!.longitude,
            }
          : null,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      // Include contact information
      'contactName': _contactNameController.text,
      'contactPhone': _contactPhoneController.text,
      'contactEmail': _contactEmailController.text,
    };

    // Include conditional fields based on item type.
    if (_itemType!.toLowerCase() == 'lost') {
      data.addAll({
        'rewardOffered': _rewardController.text,
        'lastSeenDetails': _lastSeenController.text,
      });
    } else if (_itemType!.toLowerCase() == 'found') {
      data.addAll({
        'itemWhereabouts': _itemWhereabouts,
        'preferredHandoverMethod': _handoverMethodController.text,
      });
    }

    // Store data in Firestore under "lostFoundItems" collection.
    await FirebaseFirestore.instance.collection('lostFoundItems').add(data);

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item submitted successfully!')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _dateTime = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _timeOfDay = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost & Found'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Lost/Found Dropdown
              DropdownButtonFormField<String>(
                value: _itemType,
                decoration: InputDecoration(
                  hintText: 'Select Type',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _itemTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _itemType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select item type' : null,
              ),
              SizedBox(height: 12),
              // Item Category Dropdown
              DropdownButtonFormField<String>(
                value: _itemCategory,
                decoration: InputDecoration(
                  hintText: 'Select Category',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _itemCategories
                    .map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _itemCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 12),
              // Item Name
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  hintText: 'Item Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter item name'
                    : null,
              ),
              SizedBox(height: 12),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              SizedBox(height: 12),
              // Date Picker
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text(_dateTime == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(_dateTime!)),
                onTap: _selectDate,
              ),
              SizedBox(height: 12),
              // Time Picker
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.access_time, color: Colors.blueAccent),
                title: Text(_timeOfDay == null
                    ? 'Select Time'
                    : _timeOfDay!.format(context)),
                onTap: _selectTime,
              ),
              SizedBox(height: 12),
              // Contact Information Section
              Text(
                "Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  hintText: 'Your Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your phone number'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(
                  hintText: 'Email Address (Optional)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              // Conditional fields for lost items
              if (_itemType != null && _itemType!.toLowerCase() == 'lost') ...[
                TextFormField(
                  controller: _rewardController,
                  decoration: InputDecoration(
                    hintText: 'Reward Offered (Optional)',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _lastSeenController,
                  decoration: InputDecoration(
                    hintText: 'Last Seen Details (Optional)',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12),
              ] else if (_itemType != null &&
                  _itemType!.toLowerCase() == 'found') ...[
                DropdownButtonFormField<String>(
                  value: _itemWhereabouts,
                  decoration: InputDecoration(
                    hintText: 'Where is the Item Now?',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                  items: _whereaboutsOptions
                      .map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _itemWhereabouts = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select an option' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _handoverMethodController,
                  decoration: InputDecoration(
                    hintText: 'Preferred Handover Method (Optional)',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12),
              ],
              // Item Location picker (navigates to IncidentLocationPage)
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
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map, color: Colors.blueAccent, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedLatLng != null
                              ? 'Item Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                              : 'Select Item Location from Map',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Attach Images Button
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Attach Images', style: TextStyle(color: Colors.white)),
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
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
