import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BloodRequestFormPage extends StatefulWidget {
  const BloodRequestFormPage({Key? key}) : super(key: key);

  @override
  _BloodRequestFormPageState createState() => _BloodRequestFormPageState();
}

class _BloodRequestFormPageState extends State<BloodRequestFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields.
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _bystanderNameController = TextEditingController();
  final _bystanderContactController = TextEditingController();
  final _bloodUnitController = TextEditingController();
  final _hospitalNameController = TextEditingController();

  // Dropdown selections.
  String? _selectedBloodGroup;
  String? _selectedDistrict;

  // Date and time of blood request.
  DateTime? _selectedDateTime;

  bool _isSubmitting = false;

  // List of blood groups.
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  // List of districts.
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

  // Submits the form data to Firestore.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select date and time")),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('blood_requests').add({
        'patient_name': _patientNameController.text,
        'hospital': _hospitalController.text,
        'bystander_name': _bystanderNameController.text,
        'bystander_contact': _bystanderContactController.text,
        'blood_group': _selectedBloodGroup,
        'blood_unit': _bloodUnitController.text,
        'date_time': DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!),
        'district': _selectedDistrict,
        'hospital_name': _hospitalNameController.text,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Blood request submitted successfully!")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Opens date and time pickers to select a DateTime.
  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 242, 255),
      appBar: AppBar(
        title: Text(
          'Blood Request Form',
          style: TextStyle(
            fontFamily: 'proxima',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 9, 60, 83),
                Color.fromARGB(255, 0, 115, 168)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
              // Patient Name.
              TextFormField(
                controller: _patientNameController,
                decoration: InputDecoration(
                  hintText: 'Patient Name',
                  prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter patient name' : null,
              ),
              SizedBox(height: 12),
              // Hospital.
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  hintText: 'Hospital',
                  prefixIcon: Icon(Icons.local_hospital, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter hospital details' : null,
              ),
              SizedBox(height: 12),
              // Bystander Name.
              TextFormField(
                controller: _bystanderNameController,
                decoration: InputDecoration(
                  hintText: 'Bystander Name',
                  prefixIcon: Icon(Icons.person_outline, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter bystander name' : null,
              ),
              SizedBox(height: 12),
              // Bystander Contact.
              TextFormField(
                controller: _bystanderContactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Bystander Contact',
                  prefixIcon: Icon(Icons.phone, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter bystander contact' : null,
              ),
              SizedBox(height: 12),
              // Blood Group dropdown.
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  hintText: 'Select Blood Group',
                  prefixIcon: Icon(Icons.bloodtype, color: Color.fromARGB(255, 9, 60, 83)),
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
                validator: (value) =>
                    value == null ? 'Please select blood group' : null,
              ),
              SizedBox(height: 12),
              // Blood Unit.
              TextFormField(
                controller: _bloodUnitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Blood Unit',
                  prefixIcon: Icon(Icons.opacity, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter blood unit' : null,
              ),
              SizedBox(height: 12),
              // Date and Time picker.
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.calendar_today, color: Color.fromARGB(255, 9, 60, 83)),
                title: Text(
                  _selectedDateTime == null
                      ? 'Select Date and Time'
                      : DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!),
                ),
                onTap: _selectDateTime,
              ),
              SizedBox(height: 12),
              // District dropdown.
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: InputDecoration(
                  hintText: 'Select District',
                  prefixIcon: Icon(Icons.location_on, color: Color.fromARGB(255, 9, 60, 83)),
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
                          child: Text(district),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDistrict = value),
                validator: (value) =>
                    value == null ? 'Please select district' : null,
              ),
              SizedBox(height: 12),
              // Hospital Name.
              TextFormField(
                controller: _hospitalNameController,
                decoration: InputDecoration(
                  hintText: 'Hospital Name',
                  prefixIcon: Icon(Icons.account_balance, color: Color.fromARGB(255, 9, 60, 83)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter hospital name' : null,
              ),
              SizedBox(height: 20),
              // Submit Button.
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
                        'Submit Blood Request',
                        style: TextStyle(
                          fontFamily: 'proxima',
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
