import 'package:flutter/material.dart';
import 'package:neighborly/UserSelectionPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neighborly/firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized(); 
   // Ensures proper initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 
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

