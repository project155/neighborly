import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:neighborly/firebase_options.dart';

Future<void> sendNotificationToDevice(String title, String body) async {
  print('notification');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const String oneSignalRestApiKey =
      'os_v2_app_7pcpw34lzfbbtonr6p6deiovrzrzhbuaz2vedcm4xij5u3ehnastqac756wft7ja3lo3f2mucz52p5hmpj5ckh7vdzywtmeoojc3wti';
  const String oneSignalAppId = 'fbc4fb6f-8bc9-4219-b9b1-f3fc3221d58e';
  var playId = ['9b9136a2-5f7e-4970-a5c7-3fffbd748eab'];
  // final addedData = await FirebaseFirestore.instance
  //     .collection('playerid')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //     .get();
  //     print('--------------------');
  //     print(addedData);
  // final addedContacts = addedData.data();
  // if(addedContacts==null){
  //   return;
  // }
  // final contactList = addedContacts['contactList'] as List<dynamic>;
  // // Iterate over the contactList
  // for (var contact in contactList) {
  //   if (contact is Map<String, dynamic>) {
  //     playId.add(contact['playerid']);
  //   }
  // }
  // Get the current position
  // Position position = await Geolocator.getCurrentPosition(
  //   desiredAccuracy: LocationAccuracy.high,
  // );
  // Use the position data in your notification
  var url = Uri.parse('https://api.onesignal.com/notifications?c=push');
  var notificationData = {
    "app_id": oneSignalAppId,
    "headings": {"en": title},
    "contents": {"en": body},
    "target_channel": "push",
    "include_player_ids": playId,
    // "data": {
    //   "latitude": position.latitude,
    //   "longitude": position.longitude,
    // }
  };
  var headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "Basic $oneSignalRestApiKey",
  };
  try {
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notificationData),
    );
    if (response.statusCode == 200) {
      print("Notification Sent Successfully!");
      print(response.body);
    } else {
      print("Failed to send notification: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
}
