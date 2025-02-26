import 'package:flutter/material.dart';

class LostAndFoundPage extends StatelessWidget {
  const LostAndFoundPage({Key? key}) : super(key: key);

  // Navigate to the list page (lost or found) based on the selection.
  void _navigateToList(BuildContext context, bool isLost) {
    // Replace with your navigation code.
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => ItemsListPage(isLost: isLost)));
  }

  // Navigate to the form page for posting a lost/found item.
  void _navigateToForm(BuildContext context, bool isLost) {
    // Replace with your navigation code.
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => PostItemFormPage(isLost: isLost)));
  }

  // Build a floating top bar similar to the one in WildfireReportPage.
  Widget _buildFloatingBar(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button.
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Centered title.
            Text(
              "Lost & Found",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            // To balance the row, we add an empty box matching the width of the IconButton.
            SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No standard AppBar; using a Stack in the body instead.
      body: Stack(
        children: [
          // Main content padded to leave room for the floating bar.
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Padding(
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
                      // Lost Items button.
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
                      // Found Items button.
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
          ),
          // The floating top bar.
          _buildFloatingBar(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // For demonstration, assume the lost item form.
          _navigateToForm(context, true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
