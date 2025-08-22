import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryPage extends StatelessWidget {
  final List<String> imageUrls = [
    _getImageUrl('fruits'),
    _getImageUrl('vegetables'),
    _getImageUrl('root vegetables'),
    _getImageUrl('bread'),
    _getImageUrl('dairy'),
    _getImageUrl('eggs'),
  ];

  GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          padding: const EdgeInsets.all(8.0),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      imageUrl: imageUrls[index],
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _getImageUrl(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return 'https://nurserylive.com/cdn/shop/articles/assortment-of-colorful-ripe-tropical-fruits-top-royalty-free-image-995518546-1564092355-816049.jpg?v=1679747958';
      case 'vegetables':
        return 'https://cdn.britannica.com/17/196817-159-9E487F15/vegetables.jpg';
      case 'root vegetables':
        return 'https://cdn-prod.medicalnewstoday.com/content/images/articles/280/280579/potatoes-can-be-healthful.jpg';
      case 'bread':
        return 'https://static01.nyt.com/images/2024/10/08/multimedia/13EATrex-LD-briocherex-blfk/13EATrex-LD-briocherex-blfk-jumbo.jpg';
      case 'dairy':
        return 'https://www.dairyfoods.com/ext/resources/DF/2024/Nov/GettyImages-2150650373.jpg?1734040205';
      case 'eggs':
        return 'https://i0.wp.com/post.healthline.com/wp-content/uploads/2020/05/eggs-counter-1296x728-header.jpg?w=1155&h=1528';
      default:
        return 'https://via.placeholder.com/150';
    }
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title:
            const Text('Image Preview', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
