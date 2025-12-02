import 'package:flutter/material.dart';

import 'content_card.dart';
import 'gooey_carousel.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key, required this.title});

  final String title;

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GooeyCarousel(
        children: <Widget>[
          ContentCard(
            color: 'Red',
            altColor: Color(0xFF2E7D32),
            title: "AI for Climate Resilience",
            subtitle:
                'Get personalized climate insights and adapt your farming practices to changing weather patterns.',
          ),
          ContentCard(
              color: 'Yellow',
              altColor: Color(0xFF00695C),
              title: "Sustainable Farming Tools",
              subtitle:
                  'Access water conservation planners, carbon calculators, and eco-friendly farming techniques.'),
          ContentCard(
            color: 'Blue',
            altColor: Color(0xFF1565C0),
            title: "Climate Initiative Marketplace",
            subtitle:
                'Connect with climate organizations, access funding for sustainable practices, and trade in eco-friendly products.',
          ),
        ],
      ),
    );
  }
}
