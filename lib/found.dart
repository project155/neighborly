import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FoundItemsPage extends StatefulWidget {
  @override
  _FoundItemsPageState createState() => _FoundItemsPageState();
}

class _FoundItemsPageState extends State<FoundItemsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleMapController _mapController;
  Set<Marker> _markers = Set();
  List<Map<String, dynamic>> _foundItems = [];
  bool _isLoading = true;
  // For debugging or admin purposes.
  bool forceShowTrashIcon = false;
  final LatLng _initialLocation =
      LatLng(11.194249397596916, 75.85098108272076);

  @override
  void initState() {
    super.initState();
    _fetchFoundItems();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _fetchFoundItems() async {
    try {
      // Get user's current position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final double userLat = position.latitude;
      final double userLng = position.longitude;
      double radiusInMeters = 10000; // e.g., 10 km

      // Fetch found items with itemType "Found"
      var snapshot = await _firestore
          .collection('lostFoundItems')
          .where('itemType', isEqualTo: 'Found')
          .orderBy('timestamp', descending: true)
          .get();

      // Convert snapshot to list and include document id.
      List<Map<String, dynamic>> allItems = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter found items based on distance using the itemLocation field.
      _foundItems = allItems.where((item) {
        if (item['itemLocation'] != null) {
          double itemLat =
              (item['itemLocation']['latitude'] ?? 0).toDouble();
          double itemLng =
              (item['itemLocation']['longitude'] ?? 0).toDouble();
          double distanceInMeters = Geolocator.distanceBetween(
              userLat, userLng, itemLat, itemLng);
          return distanceInMeters <= radiusInMeters;
        }
        return false;
      }).toList();

      // Update markers.
      _markers.clear();
      for (var item in _foundItems) {
        if (item['itemLocation'] != null) {
          double lat =
              (item['itemLocation']['latitude'] ?? 0).toDouble();
          double lng =
              (item['itemLocation']['longitude'] ?? 0).toDouble();
          _markers.add(
            Marker(
              markerId: MarkerId(item['id']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: item['itemName'] ?? "No Name",
                snippet: item['description'] ?? "No Description",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          );
        }
      }

      // Optionally center the map on the first found item's location.
      if (_markers.isNotEmpty) {
        var firstItem = _foundItems.first;
        double lat =
            (firstItem['itemLocation']['latitude'] ?? 0).toDouble();
        double lng =
            (firstItem['itemLocation']['longitude'] ?? 0).toDouble();
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(lat, lng)),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching found items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAnimatedSnackbar(String message) {
    AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: offsetAnimation,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry);
    controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      await controller.reverse();
      overlayEntry.remove();
      controller.dispose();
    });
  }

  Widget _buildFloatingAppBar() {
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
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle,
                    size: 30, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Found Items",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.black87),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: FoundItemsSearchDelegate(items: _foundItems),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmMarkReturned(String itemId) {
    // For found items, marking as returned (i.e. given back to the owner)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Mark as Returned"),
          content: Text(
              "Are you sure you want to mark this found item as returned? This will let everyone know it has been returned to its owner."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markReturned(itemId);
              },
              child:
                  Text("Mark Returned", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markReturned(String itemId) async {
    try {
      await _firestore
          .collection('lostFoundItems')
          .doc(itemId)
          .update({'isReturned': true});
      int index =
          _foundItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        setState(() {
          _foundItems[index]['isReturned'] = true;
        });
      }
      _showAnimatedSnackbar("Item marked as returned!");
    } catch (e) {
      print("Error marking item as returned: $e");
      _showAnimatedSnackbar("Failed to update status!");
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser?.uid ?? "";
    return Scaffold(
      body: Column(
        children: [
          // Map section.
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: _initialLocation, zoom: 15),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  markers: _markers,
                ),
                _buildFloatingAppBar(),
              ],
            ),
          ),
          // Found Items List.
          Expanded(
            flex: 1,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _foundItems.isEmpty
                    ? Center(child: Text("No found items available"))
                    : ListView.builder(
                        itemCount: _foundItems.length,
                        itemBuilder: (context, index) {
                          var item = _foundItems[index];
                          String itemUserId =
                              item['userId'] ?? item['uid'] ?? "none";
                          List<String> imageUrls = [];
                          if (item['imageUrls'] is List) {
                            imageUrls =
                                List<String>.from(item['imageUrls']);
                          } else if (item['imageUrls'] is String &&
                              item['imageUrls'].isNotEmpty) {
                            imageUrls = [item['imageUrls']];
                          }

                          String itemId = item['id'];
                          String itemName =
                              item['itemName'] ?? "No Name";
                          String description =
                              item['description'] ?? "No Description";
                          String category =
                              item['itemCategory'] ?? "Unknown";
                          String whereabouts =
                              item['itemWhereabouts'] ?? "";
                          String preferredHandover =
                              item['preferredHandoverMethod'] ?? "";
                          String time = item['time'] ?? "";
                          String date = item['date'] ?? "";
                          bool isReturned = item['isReturned'] == true;
                          int likes = item['likes'] ?? 0;
                          List likedBy =
                              List.from(item['likedBy'] ?? []);
                          bool isLiked = likedBy.contains(currentUserId);

                          // Change card background if the item is returned.
                          Color cardBackgroundColor =
                              isReturned ? Colors.blue.shade50 : Colors.white;

                          return InkWell(
                            onTap: () {
                              if (item['itemLocation'] != null) {
                                double lat = (item['itemLocation']
                                            ['latitude'] ??
                                        0)
                                    .toDouble();
                                double lng = (item['itemLocation']
                                            ['longitude'] ??
                                        0)
                                    .toDouble();
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                      LatLng(lat, lng), 18),
                                );
                                _mapController.showMarkerInfoWindow(
                                    MarkerId(item['id']));
                              }
                            },
                            child: Card(
                              color: cardBackgroundColor,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Display images (if available).
                                  if (imageUrls.isNotEmpty)
                                    ImageCarousel(imageUrls: imageUrls)
                                  else if (isReturned)
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(8),
                                      color: Colors.blue,
                                      child: Center(
                                        child: Text(
                                          "Item Returned",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(itemName,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        SizedBox(height: 5),
                                        Text(description,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700])),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text("Category: $category",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text("Time: $time",
                                                style: TextStyle(
                                                    color: Colors.blueAccent)),
                                          ],
                                        ),
                                        if (whereabouts.isNotEmpty)
                                          Text("Whereabouts: $whereabouts",
                                              style: TextStyle(
                                                  color: Colors.blueGrey)),
                                        if (preferredHandover.isNotEmpty)
                                          Text("Handover: $preferredHandover",
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        if (date.isNotEmpty)
                                          Text("Date: $date",
                                              style: TextStyle(
                                                  color: Colors.black87)),
                                        // Optionally, add contact information if available.
                                        if (item['contactName'] != null &&
                                            item['contactPhone'] != null)
                                          Text(
                                            "Contact: ${item['contactName']} (${item['contactPhone']})",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                          
                                        // Action buttons.
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.thumb_up
                                                    : Icons.thumb_up_alt_outlined,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                _handleLike(
                                                    itemId, isLiked);
                                                _showAnimatedSnackbar(
                                                    isLiked
                                                        ? "Like removed!"
                                                        : "Liked!");
                                              },
                                            ),
                                            Text("$likes Likes",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            IconButton(
                                              icon: Icon(Icons.comment_outlined,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _showComments(
                                                      context, itemId),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.share_outlined,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _shareReport(itemName, description),
                                            ),
                                            if ((item['userId'] ??
                                                        item['uid']) ==
                                                    currentUserId &&
                                                !isReturned)
                                              IconButton(
                                                icon: Icon(Icons.check_circle,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    _confirmMarkReturned(itemId),
                                              ),
                                            if (forceShowTrashIcon ||
                                                ((item['userId'] ??
                                                        item['uid']) ==
                                                    currentUserId))
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _confirmDelete(itemId),
                                              ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  // Blue banner at the bottom if the item is returned.
                                  isReturned
                                      ? Container(
                                          width: double.infinity,
                                          padding:
                                              EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Item Returned',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Found Item"),
          content: Text("Are you sure you want to delete this found item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(itemId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _firestore.collection('lostFoundItems').doc(itemId).delete();
      setState(() {
        _foundItems.removeWhere((item) => item['id'] == itemId);
      });
      _showAnimatedSnackbar("Found item deleted successfully!");
    } catch (e) {
      print("Error deleting found item: $e");
      _showAnimatedSnackbar("Failed to delete found item!");
    }
  }

  void _handleLike(String docId, bool isLiked) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;
    int index =
        _foundItems.indexWhere((item) => item['id'] == docId);
    if (index != -1) {
      setState(() {
        if (isLiked) {
          _foundItems[index]['likes'] =
              ((_foundItems[index]['likes'] ?? 0) as int) - 1;
          List likedBy =
              List.from(_foundItems[index]['likedBy'] ?? []);
          likedBy.remove(userId);
          _foundItems[index]['likedBy'] = likedBy;
        } else {
          _foundItems[index]['likes'] =
              ((_foundItems[index]['likes'] ?? 0) as int) + 1;
          List likedBy =
              List.from(_foundItems[index]['likedBy'] ?? []);
          likedBy.add(userId);
          _foundItems[index]['likedBy'] = likedBy;
        }
      });
    }
    _firestore.collection('lostFoundItems').doc(docId).update({
      'likes': isLiked ? FieldValue.increment(-1) : FieldValue.increment(1),
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  void _showComments(BuildContext context, String docId) {
    int itemIndex =
        _foundItems.indexWhere((item) => item['id'] == docId);
    List<dynamic> comments = itemIndex != -1
        ? List.from(_foundItems[itemIndex]['comments'] ?? [])
        : [];
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: comments.map((comment) {
                        if (comment is Map &&
                            comment.containsKey('name')) {
                          return ListTile(
                            title: Text(
                              comment['name'],
                              style:
                                  TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment['comment'] ?? ""),
                          );
                        } else {
                          return ListTile(
                              title: Text(comment.toString()));
                        }
                      }).toList(),
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                        hintText: "Add a comment..."),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        var newComment = {
                          'name': 'Anonymous',
                          'comment': text
                        };
                        setModalState(() {
                          comments.add(newComment);
                        });
                        if (itemIndex != -1) {
                          setState(() {
                            _foundItems[itemIndex]['comments'] =
                                List.from(_foundItems[itemIndex]
                                        ['comments'] ??
                                    [])
                                  ..add(newComment);
                          });
                        }
                        _firestore
                            .collection('lostFoundItems')
                            .doc(docId)
                            .update({
                          'comments': FieldValue.arrayUnion([newComment]),
                        });
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _shareReport(String itemName, String description) {
    Share.share('$itemName\n\n$description');
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  ImageCarousel({required this.imageUrls});
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.imageUrls.map((image) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FullScreenImagePage(imageUrl: image)),
                  );
                },
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == entry.key
                    ? Colors.blueAccent
                    : Colors.grey.shade400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FoundItemsSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> items;
  FoundItemsSearchDelegate({required this.items});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((item) {
      final itemName = item['itemName']?.toLowerCase() ?? '';
      return itemName.contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading:
              Icon(Icons.check_circle, color: Colors.blueAccent),
          title: Text(item['itemName'] ?? "No Name"),
          subtitle: Text(item['description'] ?? "No Description"),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FoundItemDetailPage(item: item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items.where((item) {
      final itemName = item['itemName']?.toLowerCase() ?? '';
      return itemName.contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading:
              Icon(Icons.check_circle, color: Colors.blueAccent),
          title: Text(item['itemName'] ?? "No Name"),
          onTap: () {
            query = item['itemName'] ?? "";
            showResults(context);
          },
        );
      },
    );
  }
}

class FoundItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  FoundItemDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [];
    if (item['imageUrls'] is List) {
      imageUrls = List<String>.from(item['imageUrls']);
    } else if (item['imageUrls'] is String &&
        item['imageUrls'].isNotEmpty) {
      imageUrls = [item['imageUrls']];
    }
    bool isReturned = item['isReturned'] == true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(item['itemName'] ?? "Found Item Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              Stack(
                children: [
                  ImageCarousel(imageUrls: imageUrls),
                  if (isReturned)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        color: Colors.blue,
                        child: Text(
                          "Item Returned",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                ],
              )
            else if (isReturned)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: Center(
                  child: Text(
                    "Item Returned",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['itemName'] ?? "No Name",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    item['description'] ?? "No Description",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Category: ${item['itemCategory'] ?? "Unknown"}",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (item['itemWhereabouts'] != null)
                    Text("Whereabouts: ${item['itemWhereabouts']}"),
                  if (item['preferredHandoverMethod'] != null)
                    Text("Handover Method: ${item['preferredHandoverMethod']}"),
                  if (item['time'] != null)
                    Text("Time: ${item['time']}"),
                  if (item['date'] != null)
                    Text("Date: ${item['date']}"),
                  // Display the top-level report location.
                  if (item['latitude'] != null && item['longitude'] != null)
                    Text(
                        "Report Location: (${item['latitude']}, ${item['longitude']})"),
                  // New contact information section.
                  if (item['contactName'] != null &&
                      item['contactPhone'] != null)
                    Text(
                      "Contact: ${item['contactName']} (${item['contactPhone']})",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  FullScreenImagePage({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
