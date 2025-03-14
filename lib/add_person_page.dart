import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPersonPage extends StatefulWidget {
  final String campId;
  AddPersonPage({required this.campId});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String additionalInfo = '';

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
              'Add Person',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: _buildInputDecoration('Name'),
                onSaved: (val) => name = val!,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter a name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Age'),
                keyboardType: TextInputType.number,
                onSaved: (val) => age = int.tryParse(val!) ?? 0,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter age' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration('Additional Info'),
                onSaved: (val) => additionalInfo = val ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
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
                child: Text('Add Person'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Reference to the people subcollection for this camp.
      CollectionReference people = FirebaseFirestore.instance
          .collection('camps')
          .doc(widget.campId)
          .collection('people');

      await people.add({
        'name': name,
        'age': age,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally update the people count in the camp document.
      DocumentReference campDoc = FirebaseFirestore.instance
          .collection('camps')
          .doc(widget.campId);
      campDoc.update({
        'peopleCount': FieldValue.increment(1),
      });

      Navigator.pop(context);
    }
  }
}
