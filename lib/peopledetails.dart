import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeopleDetailPage extends StatelessWidget {
  final String campId;
  PeopleDetailPage({required this.campId});

  @override
  Widget build(BuildContext context) {
    CollectionReference peopleRef = FirebaseFirestore.instance
        .collection('camps')
        .doc(campId)
        .collection('people');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
            title: const Text(
              'People in Camp',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: peopleRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(fontFamily: 'proxima'),
              ),
            );
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final peopleDocs = snapshot.data!.docs;
          if (peopleDocs.isEmpty) {
            return Center(
              child: Text(
                "No people found in this camp.",
                style: const TextStyle(fontFamily: 'proxima'),
              ),
            );
          }
          return ListView.builder(
            itemCount: peopleDocs.length,
            itemBuilder: (context, index) {
              var personData = peopleDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  personData['name'],
                  style: const TextStyle(
                    fontFamily: 'proxima',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Age: ${personData['age']} | ${personData['additionalInfo']}",
                  style: const TextStyle(
                    fontFamily: 'proxima',
                    fontSize: 14,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
