import 'dart:ui';
// import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:farm_assistx/Inventory/warehouse_management_screen.dart';
import 'package:farm_assistx/ClimateAIApp.dart';
import 'package:farm_assistx/distribution_screen.dart';
import 'events.dart';
import 'package:farm_assistx/playlist_page.dart';
import 'package:farm_assistx/trivia.dart';
import 'package:flutter/material.dart';
// GoogleFonts used within AppTheme
import 'src/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DurgaPujaApp.dart';
import 'payment_page.dart';
import 'gallery_page.dart';
import 'initial_page.dart';
import 'splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:farm_assistx/Inventory/inventory_provider.dart';
import 'weather/weather_screen.dart'; // Import the HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryProvider(),
      child: MaterialApp(
        title: 'ClimateAI FarmAssist',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const BallBounceIndex(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToInitialPage();
  }

  _navigateToInitialPage() async {
    // Delay for 3 seconds (or however long you want the splash screen to display)
    await Future.delayed(const Duration(seconds: 3), () {});

    // Navigate to the initial page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InitialPage(title: 'ClimateAI FarmAssist'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'ClimateAI FarmAssist',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FadeInDown(
          child: Text(
            'Climate Dashboard',
            style: Theme.of(context).textTheme.displayMedium,
            selectionColor: Colors.lightBlue,
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Replace with your background image asset
              fit: BoxFit.cover,
            ),
          ),
          // Blurred Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElasticIn(
                    child: Text(
                      'Welcome to ClimateAI FarmAssist!',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: Text(
                      'Empowering farmers to adapt to climate change with AI-powered insights, sustainable practices, and a climate-focused marketplace.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon:
                          const Icon(Icons.eco, color: Colors.white),
                      label: const Text(
                        'Climate Initiatives',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.nature, color: Colors.white),
                      label: const Text(
                        'Sustainable Products',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GalleryPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Climate Action Features',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🌍 Climate Resilience Tools',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Access AI-powered insights to adapt your farming practices to changing climate conditions.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '🌱 Sustainable Farming Practices',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Learn water conservation, organic farming, and eco-friendly techniques to reduce your carbon footprint.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'About ClimateAI FarmAssist',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 600, child: DurgaPujaApp()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return const AnimatedDrawer();
  }
}

class AnimatedDrawer extends StatefulWidget {
  const AnimatedDrawer({super.key});

  @override
  _AnimatedDrawerState createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final List<Color> _colors = [
    Colors.green.shade700,
    Colors.teal.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _colors[0], end: _colors[1]),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _colors[1], end: _colors[0]),
        weight: 1.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorAnimation.value!,
                  _colorAnimation.value!.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drawer Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(
                          'assets/logo.png', // Replace with your logo image asset
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'ClimateAI FarmAssist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Drawer Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.home,
                        title: 'Home',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.video_collection,
                        title: 'Climate Resources',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PlaylistsPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.nature,
                        title: 'Sustainable Products',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GalleryPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.eco,
                        title: 'Climate-Smart Toolkit',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TriviaPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.volunteer_activism,
                        title: 'Climate Initiatives',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PaymentPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.info,
                        title: 'About Us',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutUsPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.calendar_month,
                        title: 'Climate Events',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventsPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.smart_toy,
                        title: 'Climate AI Assistant',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ClimateAIApp()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.map,
                        title: 'Distribution Map',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DistributionScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.cloud,
                        title: 'Climate & Weather',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WeatherScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.inventory_2,
                        title: 'Inventory',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WarehouseManagementScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Footer
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Built for Climate Action 🌍💚',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightGreenAccent, size: 28),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Overview
            Text(
              'Our Mission: AI for Climate Change',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'ClimateAI FarmAssist is a comprehensive platform that combines artificial intelligence with climate science to help farmers adapt to the challenges of climate change. We provide real-time climate insights, sustainable farming practices, and connect farmers with climate-focused organizations and resources.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Climate Focus
            Text(
              'Climate Change & Agriculture',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.thermostat, color: Colors.orange),
              title: const Text('Rising Temperatures'),
              subtitle: const Text(
                  'Our AI helps farmers adapt crop selection and timing to changing temperature patterns.'),
            ),
            ListTile(
              leading: Icon(Icons.water_drop, color: Colors.blue.shade700),
              title: const Text('Water Scarcity'),
              subtitle: const Text(
                  'Smart irrigation planning and water conservation techniques for sustainable farming.'),
            ),
            ListTile(
              leading: const Icon(Icons.storm, color: Colors.grey),
              title: const Text('Extreme Weather Events'),
              subtitle: const Text(
                  'Early warning systems and preparedness strategies for droughts, floods, and storms.'),
            ),
            ListTile(
              leading: Icon(Icons.eco, color: Colors.green.shade700),
              title: const Text('Carbon Footprint Reduction'),
              subtitle: const Text(
                  'Tools to measure and reduce agricultural emissions through sustainable practices.'),
            ),
            const SizedBox(height: 20),

            // Key Features
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.teal),
              title: Text('Climate AI Assistant'),
              subtitle: Text(
                  'AI-powered chatbot providing personalized climate insights and farming recommendations.'),
            ),
            const ListTile(
              leading: Icon(Icons.cloud, color: Colors.blueGrey),
              title: Text('Climate & Weather Monitoring'),
              subtitle: Text(
                  'Real-time weather data and long-term climate trend analysis for informed decision-making.'),
            ),
            const ListTile(
              leading: Icon(Icons.agriculture, color: Colors.brown),
              title: Text('Phenological Tracking'),
              subtitle: Text(
                  'Monitor crop growth stages and receive climate-specific recommendations.'),
            ),
            const ListTile(
              leading: Icon(Icons.volunteer_activism, color: Colors.green),
              title: Text('Climate Initiative Marketplace'),
              subtitle: Text(
                  'Connect with organizations offering funding, resources, and support for sustainable practices.'),
            ),
            const ListTile(
              leading: Icon(Icons.nature, color: Colors.lightGreen),
              title: Text('Sustainable Product Catalog'),
              subtitle: Text(
                  'Browse eco-friendly farming inputs and climate-smart agricultural products.'),
            ),
            const ListTile(
              leading: Icon(Icons.calculate, color: Colors.amber),
              title: Text('Climate-Smart Toolkit'),
              subtitle: Text(
                  'Calculators and planners optimized for sustainable, water-efficient farming.'),
            ),

            const SizedBox(height: 20),

            // Benefits for Farmers
            Text(
              'Benefits for Farmers',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.shield, color: Colors.green),
              title: Text('Climate Resilience'),
              subtitle: Text(
                  'Build resilience against unpredictable weather patterns and climate extremes.'),
            ),
            const ListTile(
              leading: Icon(Icons.insights, color: Colors.blue),
              title: Text('AI-Powered Insights'),
              subtitle: Text(
                  'Make data-driven decisions with personalized climate and crop recommendations.'),
            ),
            const ListTile(
              leading: Icon(Icons.savings, color: Colors.amber),
              title: Text('Access Climate Funding'),
              subtitle: Text(
                  'Connect with grants, subsidies, and carbon credit programs for sustainable practices.'),
            ),
            const ListTile(
              leading: Icon(Icons.water, color: Colors.lightBlue),
              title: Text('Water Conservation'),
              subtitle: Text(
                  'Optimize irrigation and reduce water usage with smart planning tools.'),
            ),

            const SizedBox(height: 20),

            // Benefits for Customers
            Text(
              'Benefits for Customers',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.eco, color: Colors.green),
              title: Text('Sustainable Choices'),
              subtitle: Text(
                  'Access to sustainably produced, climate-friendly food options.'),
            ),
            const ListTile(
              leading: Icon(Icons.visibility, color: Colors.teal),
              title: Text('Environmental Transparency'),
              subtitle: Text(
                  'Know the environmental impact and sustainable journey of your food.'),
            ),
            const ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('Support Climate Action'),
              subtitle: Text(
                  'Directly contribute to farmer climate adaptation and sustainable agriculture.'),
            ),

            const SizedBox(height: 20),

            // Tech Stack
            Text(
              'Tech Stack',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              '1. Flutter & Dart\n'
              '2. Google Generative AI (Gemini) for Climate Insights\n'
              '3. OpenStreetMap & Apple Maps\n'
              '4. Real-time Weather & Climate APIs\n'
              '5. Machine Learning for Climate Predictions\n'
              '6. Shared Preferences & Local Storage\n'
              '7. Secure Payment Integration',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    '🌍 Built for Climate Action',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Together, we can help farmers adapt to climate change and build a more sustainable agricultural future.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
