import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reports PDF Generator',
      home: GenerateReports(),
    );
  }
}

class GenerateReports extends StatelessWidget {
  // Fetch data from the "reports" collection.
  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('reports')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  // Optional: Fetch image bytes from a URL.
  Future<Uint8List?> fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return null;
  }

  // Generate a PDF containing all reports.
  Future<void> generatePdf() async {
    final data = await fetchData();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          widgets.add(pw.Text('All Reports Data',
              style: pw.TextStyle(fontSize: 24)));
          widgets.add(pw.SizedBox(height: 20));

          // Iterate through each report document.
          for (var report in data) {
            final title = report['title'] ?? 'No Title';
            final category = report['category'] ?? 'No Category';
            final date = report['date'] ?? 'No Date';
            final description = report['description'] ?? 'No Description';
            final imageUrls = report['imageUrl'] as List<dynamic>? ?? [];
            final location = report['location'] as Map<String, dynamic>? ?? {};
            final latitude = location['latitude']?.toString() ?? 'N/A';
            final longitude = location['longitude']?.toString() ?? 'N/A';
            final time = report['time'] ?? 'No Time';
            final timestamp = report['timestamp']?.toString() ?? 'No Timestamp';
            final urgency = report['urgency'] ?? 'No Urgency';
            final userId = report['userId'] ?? 'No UserId';

            widgets.add(
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Title: $title',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Category: $category'),
                    pw.Text('Date: $date'),
                    pw.Text('Time: $time'),
                    pw.Text('Timestamp: $timestamp'),
                    pw.Text('Urgency: $urgency'),
                    pw.Text('User ID: $userId'),
                    pw.SizedBox(height: 5),
                    pw.Text('Description: $description'),
                    pw.SizedBox(height: 5),
                    pw.Text('Location: Latitude: $latitude, Longitude: $longitude'),
                  ],
                ),
              ),
            );

            // Optionally include the first image URL.
            if (imageUrls.isNotEmpty && imageUrls[0] is String) {
              widgets.add(
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text('Image URL: ${imageUrls[0]}'),
                ),
              );
            }
            widgets.add(pw.Divider());
          }
          return widgets;
        },
      ),
    );

    // Save and preview the PDF file.
    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Generate a PDF for a specific category.
  Future<void> generatePdfByCategory(String categoryFilter) async {
    final data = await fetchData();
    // Filter reports by the given category.
    final filteredData =
        data.where((report) => report['category'] == categoryFilter).toList();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          widgets.add(pw.Text('$categoryFilter Reports',
              style: pw.TextStyle(fontSize: 24)));
          widgets.add(pw.SizedBox(height: 20));

          // Iterate through each filtered report.
          for (var report in filteredData) {
            final title = report['title'] ?? 'No Title';
            final date = report['date'] ?? 'No Date';
            final description = report['description'] ?? 'No Description';
            final imageUrls = report['imageUrl'] as List<dynamic>? ?? [];
            final location = report['location'] as Map<String, dynamic>? ?? {};
            final latitude = location['latitude']?.toString() ?? 'N/A';
            final longitude = location['longitude']?.toString() ?? 'N/A';
            final time = report['time'] ?? 'No Time';
            final timestamp = report['timestamp']?.toString() ?? 'No Timestamp';
            final urgency = report['urgency'] ?? 'No Urgency';
            final userId = report['userId'] ?? 'No UserId';

            widgets.add(
              pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Title: $title',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Date: $date'),
                    pw.Text('Time: $time'),
                    pw.Text('Timestamp: $timestamp'),
                    pw.Text('Urgency: $urgency'),
                    pw.Text('User ID: $userId'),
                    pw.SizedBox(height: 5),
                    pw.Text('Description: $description'),
                    pw.SizedBox(height: 5),
                    pw.Text('Location: Latitude: $latitude, Longitude: $longitude'),
                  ],
                ),
              ),
            );

            if (imageUrls.isNotEmpty && imageUrls[0] is String) {
              widgets.add(
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text('Image URL: ${imageUrls[0]}'),
                ),
              );
            }
            widgets.add(pw.Divider());
          }
          if (filteredData.isEmpty) {
            widgets.add(pw.Text('No reports found for $categoryFilter.'));
          }
          return widgets;
        },
      ),
    );

    // Save and preview the PDF file.
    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Helper widget to build a card for each option.
  Widget _buildCard(BuildContext context, String title, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports PDF Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
           _buildCard(
  context,
  'Generate All Reports PDF',
  () => generatePdf(),
),
_buildCard(
  context,
  'Generate Flood Reports PDF',
  () => generatePdfByCategory('flood'),
),
_buildCard(
  context,
  'Generate Drought Reports PDF',
  () => generatePdfByCategory('Drought'),
),
_buildCard(
  context,
  'Generate Landslide Reports PDF',
  () => generatePdfByCategory('Landslide'),
),
_buildCard(
  context,
  'Generate Fire Reports PDF',
  () => generatePdfByCategory('Fire'),
),
_buildCard(
  context,
  'Generate Sexual Abuse Reports PDF',
  () => generatePdfByCategory('Sexual Abuse'),
),
_buildCard(
  context,
  'Generate Narcotics Reports PDF',
  () => generatePdfByCategory('Narcotics'),
),
_buildCard(
  context,
  'Generate Road Incidents Reports PDF',
  () => generatePdfByCategory('Road Incidents'),
),
_buildCard(
  context,
  'Generate Eco Hazard Reports PDF',
  () => generatePdfByCategory('Eco Hazard'),
),
_buildCard(
  context,
  'Generate Alcohol Reports PDF',
  () => generatePdfByCategory('Alcohol'),
),
_buildCard(
  context,
  'Generate Animal Abuse Reports PDF',
  () => generatePdfByCategory('Animal Abuse'),
),
_buildCard(
  context,
  'Generate Bribery Reports PDF',
  () => generatePdfByCategory('Bribery'),
),
_buildCard(
  context,
  'Generate Food Safety Reports PDF',
  () => generatePdfByCategory('Food Safety'),
),
_buildCard(
  context,
  'Generate Hygiene Issues Reports PDF',
  () => generatePdfByCategory('Hygiene Issues'),
),
_buildCard(
  context,
  'Generate Infrastructure Issues Reports PDF',
  () => generatePdfByCategory('Infrastructure Issues'),
),
_buildCard(
  context,
  'Generate Transportation Reports PDF',
  () => generatePdfByCategory('Transportation'),
),
_buildCard(
  context,
  'Generate Theft Reports PDF',
  () => generatePdfByCategory('Theft'),
),
_buildCard(
  context,
  'Generate Child Abuse Reports PDF',
  () => generatePdfByCategory('Child Abuse'),
),

          ],
        ),
      ),
    );
  }
}
