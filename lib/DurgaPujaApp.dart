import 'package:flutter/material.dart';

void main() {
  runApp(const DurgaPujaApp());
}

class DurgaPujaApp extends StatelessWidget {
  const DurgaPujaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Updated from bodyText2 to bodyMedium
        ),
      ),
      home: const FarmAssistXWebsite(), // Updated from DurgaPujaWebsite
    );
  }
}

class FarmAssistXWebsite extends StatelessWidget { // Renamed from DurgaPujaWebsite
  const FarmAssistXWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildSection(
            context,
            'FarmAssistX: Empowering Farmers and Enriching Customers',
            'FarmAssistX is a mobile-based marketplace that directly connects farmers with customers, eliminating intermediaries and ensuring fair prices for both parties. Our app revolutionizes the agricultural supply chain by promoting transparency, efficiency, and sustainability.',
            'assets/images/farm_assistx_image.jpg', // Updated image path
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Key Features of FarmAssistX',
            'FarmAssistX offers a suite of features designed to enhance the farming and shopping experience:',
            'assets/images/features_image.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'Farmer Profiles',
            'Farmers can create detailed profiles showcasing their produce, pricing, and location, enabling customers to make informed decisions.',
            'assets/images/farmer_profiles.jpg',
            animationType: AnimationType.slideInRight,
          ),
          buildSection(
            context,
            'Product Catalog',
            'Browse a comprehensive catalog of fresh produce, allowing customers to select products that meet their needs.',
            'assets/images/product_catalog.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'Ordering and Payment',
            'Place orders seamlessly and make secure payments directly through the app, ensuring a hassle-free shopping experience.',
            'assets/images/ordering_payment.jpg',
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Real-time Tracking',
            'Track the status of your orders from harvesting to delivery with our real-time tracking system.',
            'assets/images/real_time_tracking.jpg',
            animationType: AnimationType.slideInRight,
          ),
          buildSection(
            context,
            'Rating and Review',
            'Rate and review farmers to promote accountability and maintain high-quality standards.',
            'assets/images/rating_review.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'GPS-enabled Delivery',
            'Opt for GPS-enabled delivery to ensure efficient and timely delivery of your orders.',
            'assets/images/gps_delivery.jpg',
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Conclusion: Building a Sustainable Agricultural Ecosystem',
            'FarmAssistX is not just an app; it\'s a movement towards a more sustainable and transparent agricultural ecosystem. By bridging the gap between farmers and customers, we aim to empower both parties and contribute to the overall growth and prosperity of the farming community.',
            'assets/images/conclusion_farmassistx.png',
            animationType: AnimationType.slideInRight,
          ),
        ],
      ),
    );
  }

  Widget buildSection(BuildContext context, String title, String description, String imagePath,
      {AnimationType animationType = AnimationType.fadeIn}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedText(
            text: title,
            animationType: animationType,
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          ParallaxImage(imagePath: imagePath),
          const SizedBox(height: 20),
          AnimatedText(
            text: description,
            animationType: animationType,
            textStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}

enum AnimationType { fadeIn, slideInLeft, slideInRight }

class AnimatedText extends StatelessWidget {
  final String text;
  final AnimationType animationType;
  final TextStyle textStyle;

  const AnimatedText({super.key, required this.text, required this.animationType, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      transitionBuilder: (Widget child, Animation<double> animation) {
        switch (animationType) {
          case AnimationType.slideInLeft:
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0)).animate(animation),
              child: child,
            );
          case AnimationType.slideInRight:
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation),
              child: child,
            );
          case AnimationType.fadeIn:
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: textStyle,
      ),
    );
  }
}

class ParallaxImage extends StatelessWidget {
  final String imagePath;

  const ParallaxImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }
}