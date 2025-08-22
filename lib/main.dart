import 'dart:ui';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:farm_assistx/Inventory/warehouse_management_screen.dart';
import 'package:farm_assistx/ai_chatbot_screen.dart';
import 'package:farm_assistx/distribution_screen.dart';
import 'package:farm_assistx/events.dart';
import 'package:farm_assistx/playlist_page.dart';
import 'package:farm_assistx/trivia.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: 'FarmAssistX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme.copyWith(
                  displayLarge: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  displayMedium: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  bodyLarge: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
          ),
        ),
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
          builder: (context) => const InitialPage(
                title: 'abc',
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FarmAssistX',
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
            'FarmAssistX Dashboard',
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
                      'Welcome to FarmAssistX!',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    child: Text(
                      'FarmAssistX connects farmers with customers, ensuring fair prices and high-quality produce directly from the source.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text(
                        'Place an Order',
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
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.photo_album, color: Colors.white),
                      label: const Text(
                        'View Products',
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
                          'Upcoming Features',
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
                                '1. Community Services',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Join us for community service days to support local farmers and improve agricultural practices.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '2. Agricultural Workshops',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Participate in workshops to learn about sustainable farming and innovative agricultural techniques.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'FarmAssistX Information',
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
    Colors.deepPurple,
    Colors.purpleAccent,
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
                          'FarmAssistX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
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
                        title: 'Playlists',
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
                        icon: Icons.video_collection,
                        title: 'Products',
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
                        icon: Icons.monetization_on,
                        title: 'Payments',
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
                        icon: Icons.event,
                        title: 'Events Page',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EventsPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.event,
                        title: 'Ai Chatbot',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AIChatbotScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.event,
                        title: 'Map',
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
                        icon: Icons.event,
                        title: 'Weather',
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
                        icon: Icons.event,
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
                    'Created by HackMates with love ❤️',
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
      leading: Icon(icon, color: Colors.purpleAccent, size: 28),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Overview
            Text(
              'App Overview',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'FarmConnect is a mobile-based marketplace that directly connects farmers with customers, eliminating intermediaries and ensuring fair prices for both parties. The app aims to revolutionize the agricultural supply chain, promoting transparency, efficiency, and sustainability.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Key Features
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Farmer Profiles'),
              subtitle: Text(
                  'Farmers can create profiles showcasing their produce, pricing, and location.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Product Catalog'),
              subtitle: Text(
                  'A comprehensive catalog of fresh produce, allowing customers to browse and select products.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Ordering and Payment'),
              subtitle: Text(
                  'Customers can place orders and make payments directly through the app.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Real-time Tracking'),
              subtitle: Text(
                  'Customers can track the status of their orders, from harvesting to delivery.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Rating and Review'),
              subtitle: Text(
                  'Customers can rate and review farmers, promoting accountability and quality.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('Push Notifications'),
              subtitle: Text(
                  'Farmers receive notifications for new orders, and customers receive updates on order status.'),
            ),
            const ListTile(
              leading: Icon(Icons.star, color: Colors.purpleAccent),
              title: Text('GPS-enabled Delivery'),
              subtitle: Text(
                  'Farmers can opt for GPS-enabled delivery, ensuring efficient and timely delivery.'),
            ),

            const SizedBox(height: 20),

            // Benefits for Farmers
            Text(
              'Benefits for Farmers',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.healing, color: Colors.purpleAccent),
              title: Text('Increased Profitability'),
              subtitle: Text(
                  'By eliminating intermediaries, farmers can earn higher profits.'),
            ),
            const ListTile(
              leading: Icon(Icons.expand, color: Colors.purpleAccent),
              title: Text('Improved Market Access'),
              subtitle: Text(
                  'Farmers can reach a wider customer base, reducing dependence on local markets.'),
            ),
            const ListTile(
              leading: Icon(Icons.feedback, color: Colors.purpleAccent),
              title: Text('Real-time Feedback'),
              subtitle: Text(
                  'Farmers receive feedback from customers, helping them improve quality and services.'),
            ),
            const ListTile(
              leading: Icon(Icons.inventory, color: Colors.purpleAccent),
              title: Text('Easy Inventory Management'),
              subtitle: Text(
                  'With the help of optimization tools to manage inventory efficiently.'),
            ),
            const ListTile(
              leading: Icon(Icons.route, color: Colors.purpleAccent),
              title: Text('Route Optimization'),
              subtitle: Text(
                  'Optimizing delivery routes makes the delivery process seamless and efficient.'),
            ),
            const ListTile(
              leading: Icon(Icons.cloud, color: Colors.purpleAccent),
              title: Text('Special Weather Mapping'),
              subtitle: Text(
                  'Algorithms support delivery optimization based on food types and weather conditions.'),
            ),

            const SizedBox(height: 20),

            // Benefits for Customers
            Text(
              'Benefits for Customers',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.eco, color: Colors.purpleAccent),
              title: Text('Fresh and Quality Produce'),
              subtitle: Text(
                  'Customers can purchase fresh, high-quality produce directly from farmers.'),
            ),
            const ListTile(
              leading: Icon(Icons.price_change, color: Colors.purpleAccent),
              title: Text('Competitive Pricing'),
              subtitle: Text(
                  'Customers can enjoy competitive pricing, as farmers set their own prices.'),
            ),
            const ListTile(
              leading: Icon(Icons.visibility, color: Colors.purpleAccent),
              title: Text('Transparency and Accountability'),
              subtitle: Text(
                  'Customers can track orders and provide feedback, promoting transparency and accountability.'),
            ),

            const SizedBox(height: 20),

            // Tech Stack
            Text(
              'Tech Stack',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              '1. Flutter\n'
              '2. Open Streets and Apple Map\n'
              '3. Dart\n'
              '4. Gradle\n'
              '5. Local Storage Shared Preferences & 12 Packages\n'
              '6. Machine Learning with Random Forest and more\n'
              '7. AI Support and Ultra Navigation',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Created by HackMates with love ❤️',
              style: Theme.of(context).textTheme.displayMedium,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
