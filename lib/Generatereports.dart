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
          await FirebaseFirestore.instance.collection('reports').get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports PDF Generator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: generatePdf,
                child: Text('Generate All Reports PDF'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => generatePdfByCategory('Flood'),
                child: Text('Generate Flood Reports PDF'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => generatePdfByCategory('Drought'),
                child: Text('Generate Drought Reports PDF'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => generatePdfByCategory('Landslide'),
                child: Text('Generate Landslide Reports PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
