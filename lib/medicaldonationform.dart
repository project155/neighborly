import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:intl/intl.dart';
import 'package:neighborly/incidentlocation.dart';
// Import your location picker page.
// import 'package:your_project/pick_location_page.dart';

/// Function to upload an image to Cloudinary and get its secure URL.
Future<String?> getCloudinaryUrl(String image) async {
  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dkwnu8zei', // Your Cloudinary cloud name.
    apiKey: '298339343829723', // Your Cloudinary API key.
    apiSecret: 'T9q3BURXE2-Rj6Uv4Dk9bSzd7rY', // Your Cloudinary API secret.
  );

  final response = await cloudinary.upload(
    file: image,
    resourceType: CloudinaryResourceType.image,
  );
  return response.secureUrl;
}

class AddDonationPage extends StatefulWidget {
  const AddDonationPage({Key? key}) : super(key: key);

  @override
  _AddDonationPageState createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Equipment details controllers.
  final _equipmentController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Contact information controllers.
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  // List of donation category options.
  final List<String> _categories = [
    'Wheelchair',
    'Oxygen Cylinder',
    'Hospital Bed',
    'Surgical Equipment',
    'Diagnostic Equipment',
  ];
  String? _selectedCategory;

  // For location: use a map picker to set the location.
  LatLng? _selectedLatLng;

  // For images.
  List<XFile> _images = [];

  bool _isSubmitting = false;

  // Launch image picker to allow multiple image attachments.
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles;
      });
    }
  }

  // Launch the map-based location picker.
  Future<void> _pickLocation() async {
    // Navigate to your location picker page.
    // The page should return a LatLng when a location is selected.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickLocationPage(), // Your location picker page
      ),
    );
    if (result != null && result is LatLng) {
      setState(() {
        _selectedLatLng = result;
      });
    }
  }

  // Submit donation details to Firestore in the "donationRequests" collection.
  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isSubmitting = true;
      });

      // Upload images to Cloudinary and collect the URLs.
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        for (XFile image in _images) {
          String? url = await getCloudinaryUrl(image.path);
          if (url != null) {
            imageUrls.add(url);
          }
        }
      }

      await FirebaseFirestore.instance.collection('MedicalCharity').add({
        'title': _equipmentController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'location': _selectedLatLng != null
            ? {
                'latitude': _selectedLatLng!.latitude,
                'longitude': _selectedLatLng!.longitude,
              }
            : null,
        'imageUrl': imageUrls,
        'contact': {
          'name': _contactNameController.text,
          'phone': _contactPhoneController.text,
          'email': _contactEmailController.text,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Donation submitted successfully!")),
      );
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _equipmentController.dispose();
    _descriptionController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a string to display the selected location.
    String locationText = _selectedLatLng != null
        ? 'Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
        : 'Select Location on Map';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 242, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text(
              'Add Donation',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Equipment Name Field.
              TextFormField(
                controller: _equipmentController,
                decoration: InputDecoration(
                  hintText: 'Enter Equipment Name',
                  prefixIcon: Icon(Icons.medical_services, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter equipment name'
                    : null,
              ),
              SizedBox(height: 12),
              // Description Field.
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  prefixIcon: Transform.translate(
                    offset: Offset(0, -23),
                    child: Icon(Icons.description, color: Color.fromARGB(255, 9, 60, 83)),
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please provide a description'
                    : null,
              ),
              SizedBox(height: 12),
              // Category Dropdown.
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select Category',
                  prefixIcon: Icon(Icons.category, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 12),
              // Contact Information: Name.
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Contact Name',
                  prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter contact name'
                    : null,
              ),
              SizedBox(height: 12),
              // Contact Information: Phone.
              TextFormField(
                controller: _contactPhoneController,
                decoration: InputDecoration(
                  hintText: 'Enter Contact Phone',
                  prefixIcon: Icon(Icons.phone, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter contact phone'
                    : null,
              ),
              SizedBox(height: 12),
              // Contact Information: Email.
              TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(
                  hintText: 'Enter Contact Email',
                  prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              // Map-based Location Picker.
              InkWell(
                onTap: _pickLocation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_history, color: Color.fromARGB(255, 9, 60, 83), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locationText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedLatLng != null ? Colors.black : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Attach Images Button.
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 9, 60, 83),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              // Preview attached images.
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
              // Submit Donation Button.
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 9, 60, 83),
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
