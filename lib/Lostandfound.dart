import 'package:flutter/material.dart';

class LostAndFoundPage extends StatelessWidget {
  const LostAndFoundPage({Key? key}) : super(key: key);

  // Navigate to the list page (lost or found) based on the selection.
  void _navigateToList(BuildContext context, bool isLost) {
    // Replace with your navigation code, e.g.,
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ItemsListPage(isLost: isLost)));
  }

  // Navigate to the form page for posting a lost/found item.
  void _navigateToForm(BuildContext context, bool isLost) {
    // Replace with your navigation code, e.g.,
    // Navigator.push(context, MaterialPageRoute(builder: (_) => PostItemFormPage(isLost: isLost)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Choose a category:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Lost Items button
                ElevatedButton(
                  onPressed: () => _navigateToList(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.search_off, size: 40, color: Colors.teal),
                      SizedBox(height: 8),
                      Text("Lost Items", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                // Found Items button
                ElevatedButton(
                  onPressed: () => _navigateToList(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 40, color: Colors.teal),
                      SizedBox(height: 8),
                      Text("Found Items", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // For demonstration, we assume a lost item form.
          _navigateToForm(context, true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
