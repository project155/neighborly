import 'package:flutter/material.dart';
import 'package:neighborly/UserSelectionPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neighborly/firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized(); 
   // Ensures proper initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 
  // OneSignal.initialize("fbc4fb6f-8bc9-4219-b9b1-f3fc3221d58e");
  // OneSignal.Notifications.requestPermission(true);
   OneSignal.shared.setAppId("fbc4fb6f-8bc9-4219-b9b1-f3fc3221d58e");

   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  // Handle permission changes
});

print('oooooo');





OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  print('llllll');
  // Handle subscription changes
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      
      debugShowCheckedModeBanner: false,
      home:UserSelectionPage(),
    );
    
  }
}

