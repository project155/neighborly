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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
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

    // Define theme colors using PdfColor.
    final primaryColor = PdfColor.fromInt(0xFF093C53); // ARGB(255, 9,60,83)
    final secondaryColor = PdfColor.fromInt(0xFF0073A8); // ARGB(255, 0,115,168)
    final backgroundColor = PdfColor.fromInt(0xFFF0F2FF); // ARGB(255,240,242,255)

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];

          // Header.
          widgets.add(
            pw.Container(
              width: double.infinity,
              height: 50,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.bottomCenter,
                  end: pw.Alignment.topCenter,
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Reports PDF Generator',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          // Page Title.
          widgets.add(
            pw.Text(
              'All Reports Data',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          // List of reports.
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
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  color: backgroundColor,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Title: $title',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor)),
                    pw.SizedBox(height: 5),
                    pw.Text('Category: $category',
                        style: pw.TextStyle(color: primaryColor)),
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
          return widgets;
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Generate a PDF for a specific category.
  Future<void> generatePdfByCategory(String categoryFilter) async {
    final data = await fetchData();
    final filteredData =
        data.where((report) => report['category'] == categoryFilter).toList();
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromInt(0xFF093C53);
    final secondaryColor = PdfColor.fromInt(0xFF0073A8);
    final backgroundColor = PdfColor.fromInt(0xFFF0F2FF);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];

          // Header.
          widgets.add(
            pw.Container(
              width: double.infinity,
              height: 50,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.bottomCenter,
                  end: pw.Alignment.topCenter,
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(
                child: pw.Text(
                  '$categoryFilter Reports',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

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
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                decoration: pw.BoxDecoration(
                  color: backgroundColor,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Title: $title',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor)),
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
            widgets.add(
              pw.Text('No reports found for $categoryFilter.'),
            );
          }
          return widgets;
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Helper widget to build a card with an icon.
  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Color.fromARGB(255, 9, 60, 83)),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 242, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Reports PDF Generator',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildCard(context, 'All', Icons.picture_as_pdf, () => generatePdf()),
            _buildCard(context, 'Flood', Icons.opacity, () => generatePdfByCategory('flood')),
            _buildCard(context, 'Drought', Icons.wb_sunny, () => generatePdfByCategory('Drought')),
            _buildCard(context, 'Landslide', Icons.terrain, () => generatePdfByCategory('Landslide')),
            _buildCard(context, 'Fire', Icons.local_fire_department, () => generatePdfByCategory('Fire')),
            _buildCard(context, 'Sexual Abuse', Icons.report, () => generatePdfByCategory('Sexual Abuse')),
            _buildCard(context, 'Narcotics', Icons.medication, () => generatePdfByCategory('Narcotics')),
            _buildCard(context, 'Road Incidents', Icons.traffic, () => generatePdfByCategory('Road Incidents')),
            _buildCard(context, 'Eco Hazard', Icons.eco, () => generatePdfByCategory('Eco Hazard')),
            _buildCard(context, 'Alcohol', Icons.local_bar, () => generatePdfByCategory('Alcohol')),
            _buildCard(context, 'Animal Abuse', Icons.pets, () => generatePdfByCategory('Animal Abuse')),
            _buildCard(context, 'Bribery', Icons.money, () => generatePdfByCategory('Bribery')),
            _buildCard(context, 'Food Safety', Icons.restaurant, () => generatePdfByCategory('Food Safety')),
            _buildCard(context, 'Hygiene', Icons.clean_hands, () => generatePdfByCategory('Hygiene Issues')),
            _buildCard(context, 'Infrastructure', Icons.build, () => generatePdfByCategory('Infrastructure Issues')),
            _buildCard(context, 'Transportation', Icons.directions_car, () => generatePdfByCategory('Transportation')),
            _buildCard(context, 'Theft', Icons.security_rounded, () => generatePdfByCategory('Theft')),
            _buildCard(context, 'Child Abuse', Icons.child_care, () => generatePdfByCategory('Child Abuse')),
          ],
        ),
      ),
    );
  }
}
