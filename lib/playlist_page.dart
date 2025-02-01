import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the first video controller
    _controller = YoutubePlayerController(
      initialVideoId: 'VIDEO_ID_1', // Replace with an actual YouTube video ID
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmAssistX Playlists'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildVideoCard(' 5 Smart Irrigation Systems for Modern Day Farming  ',
              'Ulf8E1XnhgI'), // Replace with actual YouTube video ID
          _buildVideoCard('smart farming sensors',
              'vK6FGJnasno'), // Replace with actual YouTube video ID
          _buildVideoCard('What is Smart Agriculture?',
              '8Cda6QTnfbY'), // Replace with actual YouTube video ID
          // Add more videos as needed
        ],
      ),
    );
  }

  Widget _buildVideoCard(String title, String videoId) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontSize: 18)),
          ),
          YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            ),
            showVideoProgressIndicator: true,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
