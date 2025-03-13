import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
// You can add share_plus if you wish to include sharing functionality:
// import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Sample images to show in the carousel
  final List<String> sampleImages = [
    "https://via.placeholder.com/600x250.png?text=Photo+1",
    "https://via.placeholder.com/600x250.png?text=Photo+2",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authority Blog',
      home: BlogPage(
        title: "Exciting News from Authority",
        description:
            "We are delighted to share a wonderful update with you. This blog post is meant to keep you informed and inspired by our latest news and initiatives.",
        imageUrls: sampleImages,
      ),
    );
  }
}

class BlogPage extends StatelessWidget {
  final String title;
  final String description;
  final List<String> imageUrls;

  const BlogPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrls,
  }) : super(key: key);

  // Uncomment and customize this method if you want to add sharing functionality.
  // void _shareContent() {
  //   Share.share("$title\n\n$description");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blog"),
        actions: [
          // Example share button
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: _shareContent,
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty) ImageCarousel(imageUrls: imageUrls),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const ImageCarousel({Key? key, required this.imageUrls}) : super(key: key);

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
          items: widget.imageUrls.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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
