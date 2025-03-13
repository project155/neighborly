import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Ensure a user is signed in or use your auth flow.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // For demonstration, change the role as needed.
  final String userRole = "Authority"; // or "User"
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Contacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmergencyContactsPageWrapper(userRole: userRole),
    );
  }
}

/// Retrieves the user's role from Firestore (if stored), otherwise uses the provided role.
class EmergencyContactsPageWrapper extends StatelessWidget {
  final String userRole;
  const EmergencyContactsPageWrapper({Key? key, required this.userRole})
      : super(key: key);

  Future<String> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists &&
          (doc.data() as Map<String, dynamic>)['role'] != null) {
        return (doc.data() as Map<String, dynamic>)['role'] as String;
      }
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        String role = snapshot.data ?? userRole;
        return EmergencyContactsPage(userRole: role);
      },
    );
  }
}

class EmergencyContactsPage extends StatefulWidget {
  final String userRole;
  const EmergencyContactsPage({Key? key, required this.userRole})
      : super(key: key);

  @override
  _EmergencyContactsPageState createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  // Launch the phone dialer.
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  // Shows a dialog for adding or editing a contact.
  void _showContactDialog({String? docId, String? currentDepartment, String? currentPhone}) {
    final bool isEditing = docId != null;
    final TextEditingController departmentController =
        TextEditingController(text: isEditing ? currentDepartment : '');
    final TextEditingController phoneController =
        TextEditingController(text: isEditing ? currentPhone : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: departmentController,
                decoration: InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String dept = departmentController.text.trim();
                String phone = phoneController.text.trim();
                if (dept.isNotEmpty && phone.isNotEmpty) {
                  if (isEditing) {
                    FirebaseFirestore.instance
                        .collection('EmergencyContacts')
                        .doc(docId!)
                        .update({'department': dept, 'phone': phone});
                  } else {
                    FirebaseFirestore.instance.collection('contacts').add({
                      'department': dept,
                      'phone': phone,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _addContact() {
    _showContactDialog();
  }

  void _editContact(String docId, String currentDepartment, String currentPhone) {
    _showContactDialog(
      docId: docId,
      currentDepartment: currentDepartment,
      currentPhone: currentPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthority = widget.userRole == "Authority";
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
              'Emergency Contacts',
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
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('EmergencyContacts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No contacts available"));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              String department = data['department'] ?? 'N/A';
              String phone = data['phone'] ?? 'N/A';
              return ListTile(
                title: Text(department, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(phone),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.call, color: Colors.blue),
                      onPressed: () => _makeCall(phone),
                    ),
                    if (isAuthority)
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black54),
                        onPressed: () => _editContact(doc.id, department, phone),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAuthority
          ? Container(
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
                  onPressed: _addContact,
                ),
              ),
            )
          : null,
    );
  }
}
