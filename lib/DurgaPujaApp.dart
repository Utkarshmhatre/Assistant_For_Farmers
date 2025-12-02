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
      home: const ClimateAIWebsite(), // Updated for Climate focus
    );
  }
}

class ClimateAIWebsite extends StatelessWidget { // Renamed from FarmAssistXWebsite
  const ClimateAIWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildSection(
            context,
            'ClimateAI FarmAssist: AI for Climate Change',
            'ClimateAI FarmAssist is a comprehensive platform that combines artificial intelligence with climate science to help farmers adapt to the challenges of climate change. We provide real-time climate insights, sustainable farming practices, and connect farmers with climate-focused organizations and resources.',
            'assets/images/farm_assistx_image.jpg',
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Climate Intelligence Features',
            'Our AI-powered platform provides farmers with the tools they need to make climate-smart decisions:',
            'assets/images/features_image.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'Climate AI Assistant',
            'Get personalized climate insights and farming recommendations from our AI chatbot, powered by advanced language models and climate science.',
            'assets/images/farmer_profiles.jpg',
            animationType: AnimationType.slideInRight,
          ),
          buildSection(
            context,
            'Weather & Climate Monitoring',
            'Real-time weather data and long-term climate trend analysis help you plan and adapt to changing conditions.',
            'assets/images/product_catalog.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'Sustainable Farming Practices',
            'Learn water conservation, organic farming, and eco-friendly techniques to reduce your carbon footprint and build resilience.',
            'assets/images/ordering_payment.jpg',
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Climate-Smart Planning',
            'Schedule farm operations based on weather forecasts and climate patterns. Our tools help you optimize timing for sowing, irrigation, and harvest.',
            'assets/images/real_time_tracking.jpg',
            animationType: AnimationType.slideInRight,
          ),
          buildSection(
            context,
            'Climate Initiative Marketplace',
            'Connect with organizations offering grants for sustainable practices, access eco-friendly products, and participate in carbon credit programs.',
            'assets/images/rating_review.jpg',
            animationType: AnimationType.fadeIn,
          ),
          buildSection(
            context,
            'Carbon Footprint Tracking',
            'Measure and reduce your farm\'s environmental impact with our carbon calculator and sustainability tools.',
            'assets/images/gps_delivery.jpg',
            animationType: AnimationType.slideInLeft,
          ),
          buildSection(
            context,
            'Building a Climate-Resilient Future',
            'ClimateAI FarmAssist is more than an app; it\'s a movement towards climate-resilient agriculture. Together, we can help farmers adapt to climate change while building sustainable food systems for future generations.',
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