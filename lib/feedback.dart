import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      // Fetch the current user.
      final user = _auth.currentUser;
      String uid = user?.uid ?? "";
      
      // Check if displayName is provided, if not fallback to email or a default.
      String name = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
          ? user.displayName!
          : (user?.email ?? "Anonymous");
      String email = user?.email ?? "No email provided";

      // Save feedback in the "feedbacks" collection in Firestore.
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': uid,
        'name': name,
        'email': email,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );
      _feedbackController.clear();
      setState(() {
        _rating = 3.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire page in a Theme widget that applies the Proxima font to the text theme.
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'proxima'),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: AppBar(
              centerTitle: true,
              title: Text(
                'Give Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
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
              leading: IconButton(
                icon: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Star rating widget.
              Text(
                'Rate your experience',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontFamily: 'proxima'),
              ),
              SizedBox(height: 16.0),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: const Color.fromARGB(255, 9, 60, 83),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 24.0),
              // Feedback text field.
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your feedback here...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              // Submit button.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 9, 60, 83),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
