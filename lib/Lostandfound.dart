import 'package:flutter/material.dart';
import 'package:neighborly/lost.dart';
import 'package:neighborly/found.dart'; // Import your FoundItemsPage.
import 'package:neighborly/lostandfoundreport.dart'; // Existing import for your report page.

class LostAndFoundPage extends StatelessWidget {
  const LostAndFoundPage({Key? key}) : super(key: key);

  // Navigate to the list page (lost or found) based on the selection.
  void _navigateToList(BuildContext context, bool isLost) {
    if (isLost) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LostItemsPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoundItemsPage()),
      );
    }
  }
  
  // Navigate to the form page for posting an item.
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
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button.
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Centered title.
            const Text(
              "Lost & Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // An empty widget to balance the row.
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // Build a card for the given category.
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
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
                    children: [
                      // Lost Items card.
                      _buildCategoryCard(
                        context: context,
                        title: "Lost Items",
                        icon: Icons.search_off,
                        onTap: () => _navigateToList(context, true),
                      ),
                      // Found Items card.
                      _buildCategoryCard(
                        context: context,
                        title: "Found Items",
                        icon: Icons.check_circle_outline,
                        onTap: () => _navigateToList(context, false),
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
        backgroundColor: Colors.blue,
        onPressed: () {
          // Navigate to the creation page directly.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateLostFoundItemPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
