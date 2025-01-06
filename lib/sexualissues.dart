import 'package:flutter/material.dart';
//import 'package:neighborly/loginuser.dart'; // Import the login user page for navigation

class SexualIssuesReportsPage extends StatefulWidget {
  @override
  _SexualIssuesReportsPageState createState() =>
      _SexualIssuesReportsPageState();
}

class _SexualIssuesReportsPageState extends State<SexualIssuesReportsPage> {
  // List of reports fetched from the backend (this would usually be populated dynamically)
  List<Map<String, dynamic>> reports = []; // Initially empty; fetch data dynamically

  @override
  void initState() {
    super.initState();
    fetchReports(); // Fetch data when the widget initializes
  }

  // Simulated function to fetch reports from the backend
  void fetchReports() async {
    // Replace this with your actual backend call
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    setState(() {
      reports = [
        {
          "title": "Incident Reported",
          "images": [
            "https://www.pdfgear.com/pdf-converter/img/how-to-convert-jpg-to-pdf-on-mac-1.png",
            "https://via.placeholder.com/300.png/09f/fff",
            "https://via.placeholder.com/300.png/021/aaa"
          ],
          "description": "A detailed description of the incident reported by the user."
        },
        {
          "title": "Another Incident",
          "images": [
            "https://via.placeholder.com/300.png/09f/fff",
            "https://via.placeholder.com/300.png/021/aaa"
          ],
          "description": "Another description provided by the user for a different incident."
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sexual Issues Reports'),
      ),
      body: reports.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                var report = reports[index];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image slider at the top of the report using PageView
                      if (report["images"] != null && report["images"].isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: report["images"].length,
                            itemBuilder: (context, imageIndex) {
                              return Image.network(
                                report["images"][imageIndex],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          report["title"] ?? "Untitled",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          report["description"] ?? "No description available.",
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
