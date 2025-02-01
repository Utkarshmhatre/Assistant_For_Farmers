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
            altColor: Color(0xFF4259B2),
            title: "Start Your Day with FarmAssistX",
            subtitle:
                'Begin your morning by connecting with farmers and selecting fresh produce for the day.',
          ),
          ContentCard(
              color: 'Yellow',
              altColor: Color(0xFF904E93),
              title: "Manage Your Orders Efficiently",
              subtitle:
                  'In the afternoon, place orders effortlessly and track your transactions in real-time.'),
          ContentCard(
            color: 'Blue',
            altColor: Color(0xFFFFB138),
            title: "End Your Day with Order Tracking",
            subtitle:
                'Conclude your day by monitoring the delivery status of your orders and providing feedback.',
          ),
        ],
      ),
    );
  }
}
