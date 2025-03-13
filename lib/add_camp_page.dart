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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please pick a location")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Relief Camp'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Camp Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter camp name' : null,
                onSaved: (value) => _campName = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                onSaved: (value) => _address = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _contactNumber = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Camp Description/Facilities'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Capacity (Number of People)'),
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
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickLocation,
                    child: Text("Pick Location"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Image Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Upload Images", style: TextStyle(fontSize: 16)),
                  ElevatedButton(
                    onPressed: _pickImages,
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
                          .map((img) => Image.file(
                                img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    )
                  : Text("No images selected"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Relief Camp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
