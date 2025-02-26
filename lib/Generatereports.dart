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
  // Initialize Firebase; ensure you've added your Firebase config files.
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reports PDF Generator',
      home: Generatereports(),
    );
  }
}

class Generatereports extends StatelessWidget {
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

  // Generate PDF from fetched data.
  Future<void> generatePdf() async {
    final data = await fetchData();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          widgets.add(pw.Text('Reports Data', style: pw.TextStyle(fontSize: 24)));
          widgets.add(pw.SizedBox(height: 20));

          // Iterate through each report document.
          for (var report in data) {
            // Extract fields with fallbacks.
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
              // To simply display the URL, uncomment below:
              widgets.add(
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text('Image URL: ${imageUrls[0]}'),
                ),
              );

              // To embed the image in the PDF, you can fetch and display it.
              // Note: Uncomment the block below to embed the image.
              /*
              final imageUrl = imageUrls[0] as String;
              final imageBytes = await fetchImageBytes(imageUrl);
              if (imageBytes != null) {
                final image = pw.MemoryImage(imageBytes);
                widgets.add(pw.Image(image, width: 200, height: 150));
              }
              */
            }
            widgets.add(pw.Divider());
          }
          return widgets;
        },
      ),
    );

    // Save the PDF file as bytes.
    final pdfBytes = await pdf.save();

    // Preview/share the PDF using the printing package.
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
        child: ElevatedButton(
          onPressed: generatePdf,
          child: Text('Generate PDF'),
        ),
      ),
    );
  }
}
