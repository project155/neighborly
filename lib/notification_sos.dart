import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> Notification_sos(List<String> userIds, String message,String title) async {
  final String oneSignalAppId = "fbc4fb6f-8bc9-4219-b9b1-f3fc3221d58e";
  final String oneSignalRestApiKey = "os_v2_app_7pcpw34lzfbbtonr6p6deiovrzrzhbuaz2vedcm4xij5u3ehnas3btm5nnkwpr24422citbojuwg54abyr5wr25zhyurhhveuwyqfzq";

  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $oneSignalRestApiKey',
    },
    body: jsonEncode(<String, dynamic>{
      'app_id': oneSignalAppId,
      'include_player_ids':userIds,
      
       "headings": {"en": title},
      'contents': {'en': message},
      "android_channel_id":"810fdd04-d606-47b3-9278-01681fad2819",
      "sound": "sos_sound", 
   
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
