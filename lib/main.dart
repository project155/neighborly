import 'package:flutter/material.dart';
import 'package:neighborly/UserSelectionPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neighborly/Volunteerhome.dart';
import 'package:neighborly/admin.dart';
import 'package:neighborly/authority.dart';
import 'package:neighborly/firebase_options.dart';
import 'package:neighborly/userhome.dart';
import 'package:neighborly/add_camp_page.dart'; // Import your add camp page
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? role;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensures proper initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  OneSignal.shared.setAppId("fbc4fb6f-8bc9-4219-b9b1-f3fc3221d58e");
  OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
    // Handle permission changes
  });
  
  print('oooooo');
  
  SharedPreferences pref = await SharedPreferences.getInstance();
  role = pref.getString('role');
  print(role);
  
  OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    print('llllll');
    String? userId = changes.to.userId;
    if (userId != null) {
      // Save this userId to your server or database
      print("OneSignal User ID: $userId");
    }
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    print(getScreen());
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: getScreen(),
      // Register additional routes here
      routes: {
        '/addCamp': (context) => AddCampPage(),
      },
    );
  }
}

Widget getScreen() {
  switch(role) {
    case 'user':
      return Userhome();
    case 'volunteer':
      return VolunteerHome();
    case 'authority':
      print('nnnn');
      return AuthorityHome();
    case 'admin':
      return AdminHome();
    default:
      return UserSelectionPage();
  }
}
