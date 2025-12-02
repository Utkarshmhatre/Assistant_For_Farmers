import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryPage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {
      'name': 'Organic Seeds',
      'url': _getImageUrl('organic_seeds'),
      'description': 'Climate-resilient, non-GMO seeds for sustainable farming'
    },
    {
      'name': 'Solar Irrigation',
      'url': _getImageUrl('solar_irrigation'),
      'description': 'Eco-friendly solar-powered irrigation systems'
    },
    {
      'name': 'Organic Fertilizer',
      'url': _getImageUrl('organic_fertilizer'),
      'description': 'Natural, carbon-neutral fertilizers for healthy soil'
    },
    {
      'name': 'Water Conservation',
      'url': _getImageUrl('water_conservation'),
      'description': 'Drip irrigation and water-saving technologies'
    },
    {
      'name': 'Sustainable Produce',
      'url': _getImageUrl('sustainable_produce'),
      'description': 'Locally grown, climate-friendly fruits and vegetables'
    },
    {
      'name': 'Eco-Friendly Tools',
      'url': _getImageUrl('eco_tools'),
      'description': 'Sustainable farming equipment and accessories'
    },
  ];

  GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: const Text(
          'Sustainable Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.black],
          ),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75,
          ),
          padding: const EdgeInsets.all(8.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      imageUrl: products[index]['url']!,
                      productName: products[index]['name']!,
                      description: products[index]['description']!,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                        child: CachedNetworkImage(
                          imageUrl: products[index]['url']!,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.eco, color: Colors.green, size: 50),
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            products[index]['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            products[index]['description']!,
                            style: TextStyle(
                              color: Colors.green.shade100,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _getImageUrl(String category) {
    // Note: These are placeholder images. In production, replace with actual
    // sustainable product images or use a dedicated image CDN.
    switch (category.toLowerCase()) {
      case 'organic_seeds':
        // Placeholder for organic seeds - using a fruits image as temporary placeholder
        return 'https://nurserylive.com/cdn/shop/articles/assortment-of-colorful-ripe-tropical-fruits-top-royalty-free-image-995518546-1564092355-816049.jpg?v=1679747958';
      case 'solar_irrigation':
        // Placeholder for solar irrigation equipment
        return 'https://cdn.britannica.com/17/196817-159-9E487F15/vegetables.jpg';
      case 'organic_fertilizer':
        // Placeholder for organic fertilizer products
        return 'https://cdn-prod.medicalnewstoday.com/content/images/articles/280/280579/potatoes-can-be-healthful.jpg';
      case 'water_conservation':
        // Placeholder for water conservation technology
        return 'https://static01.nyt.com/images/2024/10/08/multimedia/13EATrex-LD-briocherex-blfk/13EATrex-LD-briocherex-blfk-jumbo.jpg';
      case 'sustainable_produce':
        // Placeholder for sustainably grown produce
        return 'https://www.dairyfoods.com/ext/resources/DF/2024/Nov/GettyImages-2150650373.jpg?1734040205';
      case 'eco_tools':
        // Placeholder for eco-friendly farming tools
        return 'https://i0.wp.com/post.healthline.com/wp-content/uploads/2020/05/eggs-counter-1296x728-header.jpg?w=1155&h=1528';
      default:
        return 'https://via.placeholder.com/300x200?text=Sustainable+Product';
    }
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String description;

  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
    this.productName = 'Product',
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(productName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.eco, color: Colors.green, size: 100),
                    ),
                  ),
                ),
              ),
            ),
            if (description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.green.shade100,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.lightGreenAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Eco-Friendly • Climate-Smart • Sustainable',
                          style: TextStyle(
                            color: Colors.green.shade200,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
