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
  String _name = '';
  int _age = 0;
  String _additionalInfo = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Reference to the top-level "people" collection.
      CollectionReference people = FirebaseFirestore.instance.collection('people');

      // Add person to the top-level collection with a reference to the campId.
      await people.add({
        'campId': widget.campId,
        'name': _name,
        'age': _age,
        'additionalInfo': _additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update peopleCount in the camp document.
      DocumentReference campRef =
          FirebaseFirestore.instance.collection('camps').doc(widget.campId);
      DocumentSnapshot campSnapshot = await campRef.get();
      int currentCount = campSnapshot.get('peopleCount') ?? 0;
      await campRef.update({'peopleCount': currentCount + 1});

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Person'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter age';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _age = int.parse(value!),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Additional Info'),
                maxLines: 2,
                onSaved: (value) => _additionalInfo = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Person'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
