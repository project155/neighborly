import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'incidentlocation.dart';
import 'clodinary_upload.dart'; // Cloudinary upload function

class AddCampPage extends StatefulWidget {
  @override
  _AddCampPageState createState() => _AddCampPageState();
}

class _AddCampPageState extends State<AddCampPage> {
  final _formKey = GlobalKey<FormState>();
  String _campName = '';
  String _address = '';
  String _contactNumber = '';
  String _description = '';
  int _capacity = 0;
  List<File> _images = [];
  LatLng? _selectedLocation;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PickLocationPage()),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result; // Expecting a LatLng object
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      _formKey.currentState!.save();

      // Upload images using Cloudinary
      List<String> imageUrls = [];
      for (File image in _images) {
        String? url = await getClodinaryUrl(image.path);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // Add camp data to Firestore
      CollectionReference camps =
          FirebaseFirestore.instance.collection('camps');
      await camps.add({
        'name': _campName,
        'description': _description,
        'address': _address,
        'contactNumber': _contactNumber,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'imageUrls': imageUrls,
        'peopleCount': 0,
        'capacity': _capacity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please pick a location")),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: 'proxima'),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Add Relief Camp',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: _buildInputDecoration('Camp Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter camp name' : null,
                onSaved: (value) => _campName = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Address'),
                onSaved: (value) => _address = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Contact Number'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _contactNumber = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Camp Description/Facilities'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Capacity (Number of People)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter capacity';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _capacity = int.parse(value!),
              ),
              SizedBox(height: 20),
              // Location Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedLocation == null
                          ? "No location selected"
                          : "Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}",
                      style: TextStyle(fontFamily: 'proxima', fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 9, 60, 83),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(fontFamily: 'proxima'),
                    ),
                    child: Text("Pick Location"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Image Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Upload Images", style: TextStyle(fontFamily: 'proxima', fontSize: 16)),
                  ElevatedButton(
                    onPressed: _pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 9, 60, 83),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(fontFamily: 'proxima'),
                    ),
                    child: Text("Pick Images"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _images.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images
                          .map((img) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          .toList(),
                    )
                  : Text("No images selected", style: TextStyle(fontFamily: 'proxima')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 9, 60, 83),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontFamily: 'proxima',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text('Add Relief Camp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
