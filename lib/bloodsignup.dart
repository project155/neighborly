import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Still imported if needed elsewhere.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // No longer used for location selection.
import 'package:intl/intl.dart'; // Import intl for date formatting

class BloodDonationFormPage extends StatefulWidget {
  BloodDonationFormPage({Key? key}) : super(key: key);

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
  bool _isSubmitting = false;
  
  // List of blood groups.
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  // List of Kerala districts.
  final List<String> _districts = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod'
  ];

  // Selected preferred district.
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    // Removed location fetching as it's replaced by a dropdown.
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
        // Save the preferred district.
        'preferred_location': _selectedDistrict,
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
      // Updated AppBar with Lost & Found theme.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text(
              'Blood Donation Sign-Up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'proxima',
              ),
            ),
            centerTitle: true,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
              // Name field.
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: TextStyle(fontFamily: 'proxima'),
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
              // Contact field.
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Contact Number',
                  hintStyle: TextStyle(fontFamily: 'proxima'),
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
              // Blood Group Dropdown.
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  hintText: 'Select Blood Group',
                  hintStyle: TextStyle(fontFamily: 'proxima'),
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
                          child: Text(group, style: TextStyle(fontFamily: 'proxima')),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
                validator: (value) =>
                    value == null ? 'Please select your blood group' : null,
              ),
              SizedBox(height: 12),
              // Last Donation Date picker.
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: Icon(Icons.calendar_today, color: Color.fromARGB(255, 9, 60, 83)),
                title: Text(
                  _lastDonationDate == null
                      ? 'Select Last Donation Date'
                      : DateFormat('yyyy-MM-dd').format(_lastDonationDate!),
                  style: TextStyle(fontFamily: 'proxima'),
                ),
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
              // Preferred District dropdown.
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: InputDecoration(
                  hintText: 'Select Preferred District',
                  hintStyle: TextStyle(fontFamily: 'proxima'),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _districts
                    .map((district) => DropdownMenuItem<String>(
                          value: district,
                          child: Text(district, style: TextStyle(fontFamily: 'proxima')),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDistrict = value),
                validator: (value) =>
                    value == null ? 'Please select your preferred district' : null,
              ),
              SizedBox(height: 12),
              // Submit button.
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
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
                        'Sign Up as a Donor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontFamily: 'proxima',
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
