import 'package:flutter/material.dart';
import 'package:neighborly/loginuser.dart'; // Import the login user page for navigation

class SexualIssuesReportsPage extends StatefulWidget {
  @override
  _SexualIssuesReportsPageState createState() =>
      _SexualIssuesReportsPageState();
}

class _SexualIssuesReportsPageState extends State<SexualIssuesReportsPage> {
  // List of sample reports (this would usually be fetched from your backend)
  List<Map<String, String>> reports = [
    {
      "title": "Harassment Incident at Park",
      "location": "Central Park",
      "category": "Harassment",
      "timestamp": "2024-12-17 10:30 AM",
      "imageUrl": "https://example.com/sample-image.jpg",
      "description": "A harassment incident was reported at Central Park, where a person was harassed by an individual in the vicinity."
    },
    {
      "title": "Assault Near School",
      "location": "Riverdale School",
      "category": "Assault",
      "timestamp": "2024-12-15 08:00 AM",
      "imageUrl": "https://www.pdfgear.com/pdf-converter/img/how-to-convert-jpg-to-pdf-on-mac-1.png",
      "description": "An assault occurred near Riverdale School, and the authorities are currently investigating the situation."
    },
    // Add more sample reports as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sexual Issues Reports'),
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          var report = reports[index];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image at the top of the report
                Image.network(
                  report["imageUrl"]!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    report["title"]!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${report["location"]} | ${report["timestamp"]} | Category: ${report["category"]}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    report["description"]!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Like'),
                      SizedBox(width: 20),
                      Icon(Icons.comment_outlined, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Comment'),
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}
