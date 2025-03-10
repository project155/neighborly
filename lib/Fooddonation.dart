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
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class FoodDonationPage extends StatefulWidget {
  @override
  _FoodDonationPageState createState() => _FoodDonationPageState();
}

class _FoodDonationPageState extends State<FoodDonationPage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for various fields.
  final _foodNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _contactController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _donatorNameController = TextEditingController(); // Donator's name.

  String? _selectedFoodType;
  DateTime? _expiryDate;
  TimeOfDay? _expiryTimeOfDay;
  
  // Using dropdown menu for food preference.
  String? _foodPreference; // "Veg" or "Non-Veg"

  // For pickup location.
  LatLng? _selectedLatLng;

  // For images.
  List<XFile> _images = [];

  // Food type dropdown options.
  final List<String> _foodTypes = [
    "Cooked",
    "Packaged",
    "Fresh Produce",
    "Other"
  ];

  // Options for food preference.
  final List<String> _foodPreferences = ["Veg", "Non-Veg"];

  @override
  void initState() {
    super.initState();
    // Set default food preference.
    _foodPreference = _foodPreferences[0];
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
  
  List<String> extractPlayerIds(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((data) =>
            data.containsKey('playerid') &&
            data['playerid'] != null &&
            data['playerid'].toString().trim().isNotEmpty)
        .map((data) => data['playerid'] as String)
        .toList();
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      // Upload images to Cloudinary.
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        for (XFile image in _images) {
          String? url = await getClodinaryUrl(image.path);
          if (url != null) imageUrls.add(url);
        }
      }

      // Add the donation document to Firestore.
      await FirebaseFirestore.instance.collection('food_donations').add({
        'category': 'Food Donation',
        'foodType': _selectedFoodType,
        'foodName': _foodNameController.text,
        'donatorName': _donatorNameController.text,
        'description': _descriptionController.text,
        'quantity': _quantityController.text,
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
        'orderStatus': 'Pending',
        'foodPreference': _foodPreference,
      });
      
      QuerySnapshot volunteersSnapshot =
          await FirebaseFirestore.instance.collection('volunteers').get();
      List<String> volunteerPlayerIds = extractPlayerIds(volunteersSnapshot);

      sendNotificationToSpecificUsers(
          volunteerPlayerIds,
          'New Food Donation',
          'A new food donation is available!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food donation submitted successfully!')),
      );

      // Reset form fields and return to landing page.
      setState(() {
        _showForm = false;
        _foodNameController.clear();
        _descriptionController.clear();
        _quantityController.clear();
        _contactController.clear();
        _instructionsController.clear();
        _donatorNameController.clear();
        _selectedFoodType = null;
        _expiryDate = null;
        _expiryTimeOfDay = null;
        _images = [];
        _foodPreference = _foodPreferences[0];
        _selectedLatLng = null;
      });
    }
  }

  // Build a status indicator widget.
  Widget _buildStatusIndicator(String status) {
    IconData icon;
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted':
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;
      case 'volunteer on the way':
        icon = Icons.directions_walk;
        color = Colors.orange;
        break;
      case 'order picked up':
        icon = Icons.delivery_dining;
        color = Colors.purple;
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // InputDecoration that accepts any Widget as prefixIcon.
  InputDecoration _buildInputDecoration(String hint, {required Widget prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Build the donation form.
  Widget _buildDonationForm() {
    return Padding(
      key: ValueKey('DonationForm'),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Food Type dropdown.
            DropdownButtonFormField<String>(
              value: _selectedFoodType,
              decoration: _buildInputDecoration(
                'Select Food Type',
                prefixIcon: Icon(Icons.fastfood, color: Color.fromARGB(255, 9, 60, 83)),
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
            // Food Name.
            TextFormField(
              controller: _foodNameController,
              decoration: _buildInputDecoration(
                'Enter Food Name',
                prefixIcon: Icon(Icons.restaurant_menu, color: Color.fromARGB(255, 9, 60, 83)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter food name' : null,
            ),
            SizedBox(height: 12),
            // Donator Name.
            TextFormField(
              controller: _donatorNameController,
              decoration: _buildInputDecoration(
                'Enter Your Name',
                prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 9, 60, 83)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            SizedBox(height: 12),
            // Phone Number.
            TextFormField(
              controller: _contactController,
              decoration: _buildInputDecoration(
                'Enter Phone Number',
                prefixIcon: Icon(Icons.phone, color: Color.fromARGB(255, 9, 60, 83)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter contact info' : null,
            ),
            SizedBox(height: 12),
            // Food Preference dropdown.
            DropdownButtonFormField<String>(
              value: _foodPreference,
              decoration: _buildInputDecoration(
                'Select Food Preference',
                prefixIcon: Icon(Icons.restaurant, color: Color.fromARGB(255, 9, 60, 83)),
              ),
              items: _foodPreferences
                  .map((pref) => DropdownMenuItem<String>(
                        value: pref,
                        child: Text(pref),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _foodPreference = value),
              validator: (value) =>
                  value == null ? 'Please select a food preference' : null,
            ),
            SizedBox(height: 12),
            // Description with offset icon.
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _buildInputDecoration(
                'Enter Description',
                prefixIcon: Transform.translate(
                  offset: Offset(0, -5),
                  child: Icon(Icons.description, color: Color.fromARGB(255, 9, 60, 83)),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please provide a description' : null,
            ),
            SizedBox(height: 12),
            // Quantity.
            TextFormField(
              controller: _quantityController,
              decoration: _buildInputDecoration(
                'Enter Quantity (e.g., 20 meals)',
                prefixIcon: Icon(Icons.confirmation_number, color: Color.fromARGB(255, 9, 60, 83)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter quantity' : null,
            ),
            SizedBox(height: 12),
            // Expiry Date.
            ListTile(
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.calendar_today, color: Color.fromARGB(255, 9, 60, 83)),
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
            // Expiry Time.
            ListTile(
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.access_time, color: Color.fromARGB(255, 9, 60, 83)),
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
            // Pickup Location picker.
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
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Color.fromARGB(255, 9, 60, 83), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedLatLng != null
                            ? 'Pickup Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                            : "Pickup Location",
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
            // Special Instructions.
            TextFormField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: _buildInputDecoration(
                'Enter Special Instructions (optional)',
                prefixIcon: Icon(Icons.notes, color: Color.fromARGB(255, 9, 60, 83)),
              ),
            ),
            SizedBox(height: 12),
            // Image Upload Button.
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
            // Submit Donation Button.
            ElevatedButton(
              onPressed: _submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 9, 60, 83),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Text(
                'Submit Donation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the landing page to display current donation uploads.
  Widget _buildLandingPage() {
    return Padding(
      key: ValueKey('LandingPage'),
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_donations')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No food donations found.\nTap the + button to add a new donation.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(snapshot.data!.docs[index]);
            },
          );
        },
      ),
    );
  }

  // Build a card for each donation.
  Widget _buildDonationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String expiryDateStr = data['expiryDate'] ?? '';
    String expiryTimeStr = data['expiryTime'] ?? '';
    String pickupLocationStr = '';
    if (data['pickupLocation'] != null) {
      var loc = data['pickupLocation'];
      pickupLocationStr =
          '(${(loc['latitude'] as double).toStringAsFixed(4)}, ${(loc['longitude'] as double).toStringAsFixed(4)})';
    }
    List<dynamic> imageUrls = data['imageUrls'] ?? [];
    String orderStatus = data['orderStatus'] ?? 'Pending';

    // Change card background if order is completed.
    Color cardBackgroundColor = orderStatus.toLowerCase() == 'completed'
        ? Colors.green.shade50
        : Colors.white;

    return Card(
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display images if available.
            imageUrls.isNotEmpty
                ? Container(
                    height: 100,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            Text('Food Type: ${data['foodType'] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Food Name: ${data['foodName'] ?? ''}', style: TextStyle(fontSize: 15)),
            SizedBox(height: 4),
            Text('Description: ${data['description'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Quantity: ${data['quantity'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Expiry Date: $expiryDateStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Expiry Time: $expiryTimeStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Pickup Location: $pickupLocationStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('Contact: ${data['contact'] ?? ''}', style: TextStyle(fontSize: 14)),
                ),
                Expanded(
                  child: Text('Donator: ${data['donatorName'] ?? ''}', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text('Instructions: ${data['instructions'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            _buildStatusIndicator(orderStatus),
            SizedBox(height: 8),
            orderStatus.toLowerCase() == 'completed'
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Order Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
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
            title: Text(
              'Food Donation',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (_showForm) {
                  setState(() {
                    _showForm = false;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
      // AnimatedSwitcher for smooth transition between form and landing page.
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _showForm ? _buildDonationForm() : _buildLandingPage(),
      ),
      // Custom Floating Action Button with a rounded rectangle shape.
      floatingActionButton: _showForm
          ? null
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF093C53),
                    Color(0xFF0075A8),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(FluentIcons.add_20_regular, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
