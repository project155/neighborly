import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateReportPage extends StatefulWidget {
  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime _dateTime = DateTime.now();
  Position? _location;
  XFile? _image;
  String? _urgencyLevel;

  final List<String> _categories = [
    'Accident',
    'Theft',
    'Road Issue',
    'Hygiene Issue',
    'Sexual Harassment',
    'Public Hazards',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _location = position;
      });
    } else {
      setState(() {
        _location = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      }
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      print('Report Submitted: $_selectedCategory, ${_titleController.text}, ${_descriptionController.text}, $_dateTime, $_location, $_urgencyLevel');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(15),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 15),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              textAlign: textAlign,
              decoration: InputDecoration.collapsed(hintText: hintText),
              validator: validator,
              onChanged: (value) {
                setState(() {
                  _formKey.currentState?.validate();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Report'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Dropdown
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(15),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.blueAccent),
                    SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration.collapsed(hintText: 'Select Category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(value: category, child: Text(category));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Title Input
              _buildTextField(
                icon: Icons.title,
                hintText: 'Enter Title',
                controller: _titleController,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),

              // Description Input
              _buildTextField(
                icon: Icons.description,
                hintText: 'Enter Description',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Please provide a description' : null,
              ),

              // Date Picker
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(5),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.blueAccent),
                    SizedBox(width: 15),
                    Expanded(
                      child: ListTile(
                        title: Text('Date', textAlign: TextAlign.left),
                        subtitle: Text('${_dateTime.toLocal()}', textAlign: TextAlign.left),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _dateTime) {
                            setState(() {
                              _dateTime = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                _dateTime.hour,
                                _dateTime.minute,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Time Picker
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(5),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blueAccent),
                    SizedBox(width: 15),
                    Expanded(
                      child: ListTile(
                        title: Text('Time', textAlign: TextAlign.left),
                        subtitle: Text('${_dateTime.hour}:${_dateTime.minute}', textAlign: TextAlign.left),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_dateTime),
                          );
                          if (picked != null) {
                            setState(() {
                              _dateTime = DateTime(
                                _dateTime.year,
                                _dateTime.month,
                                _dateTime.day,
                                picked.hour,
                                picked.minute,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Location Display
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(5),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blueAccent),
                    SizedBox(width: 15),
                    Expanded(
                      child: ListTile(
                        title: Text('Location', textAlign: TextAlign.left),
                        subtitle: _location != null
                            ? Text('Lat: ${_location!.latitude}, Lon: ${_location!.longitude}', textAlign: TextAlign.left)
                            : Text('Fetching location...', textAlign: TextAlign.left),
                      ),
                    ),
                  ],
                ),
              ),

              // Attachments (Photo) - Container as Button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  padding: EdgeInsets.all(15),
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 200, 200, 200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Attach Photo',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_image != null) Text('Image selected: ${_image!.name}'),

              // Urgency Level Dropdown
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(15),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.blueAccent),
                    SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _urgencyLevel,
                        hint: Text('Select Urgency Level'),
                        decoration: InputDecoration.collapsed(hintText: 'Select Urgency Level'),
                        items: ['Low', 'Medium', 'High'].map((level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _urgencyLevel = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: _submitReport,
                  child: Text('Submit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
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
