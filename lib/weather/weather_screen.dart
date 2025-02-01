import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'air_quality_data.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'theme_provider.dart';
import 'api_page.dart'; // Add your API page here

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Changed length to 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality '),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Weather Map'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Air Quality Data'),
            Tab(
                icon: Icon(Icons.api),
                text: 'API Page'), // Added tab for API page
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Prevent tab swipe conflicts
        children: [
          WeatherMap(),
          AirQualityData(),
          ApiPage(), // Added ApiPage here
        ],
      ),
    );
  }
}

class WeatherMap extends StatefulWidget {
  const WeatherMap({super.key});

  @override
  _WeatherMapState createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap> {
  late final WebViewController _controller;
  final String url =
      'https://www.msn.com/en-in/weather/maps/airquality/in-Thane,Maharashtra?loc=eyJhIjoiS29wYXJraGFpcmFuZSBHYW9uIFJvYWQiLCJsIjoiVGhhbmUiLCJyIjoiTWFoYXJhc2h0cmEiLCJjIjoiSW5kaWEiLCJpIjoiSU4iLCJnIjoiZW4taW4iLCJ4IjoiNzMuMDAwMDk0NzA4MTQ3NiIsInkiOiIxOS4xMDU4MDExODExOTM4In0%3D&weadegreetype=C&ocid=msedgdhp&cvid=32c6a528ff0d4ad196c7eae82d7ab3de&zoom=8';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setAllowsInlineMediaPlayback(true)
      ..enableZoom(true) // Enable zooming
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}

extension on WebViewController {
  setAllowsInlineMediaPlayback(bool bool) {}
}
