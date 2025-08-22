import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:farm_assistx/src/config/secrets.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: Secrets.geminiApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/glow2.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _buildTextComposer(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    // Add the user's message
    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );
    setState(() {
      _messages.add(userMessage); // Add user's message at the bottom
      _isTyping = true;
    });

    // Scroll to the bottom when a new message is added
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Get the AI response after the user's message
    String response = await _getAIResponse(text);

    // Add the AI's response after the user's message
    ChatMessage aiMessage = ChatMessage(
      text: response,
      isUser: false,
    );
    setState(() {
      _isTyping = false;
      _messages.add(aiMessage); // Add AI response below the user's message
    });

    // Scroll to the bottom when the response is added
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<String> _getAIResponse(String query) async {
    try {
      // Removed food-related keyword filtering
      // Allow any query without restrictions

      // If the query is food-related, continue with the AI response generation
      final prompt = 'You are an expert. Answer the following question: $query';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Sorry, I couldn\'t generate a response.';
    } catch (e) {
      return 'Sorry, I encountered an error while processing your request: $e';
    }
  }

  void _clearChats() {
    setState(() {
      _messages.clear();
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue, // Blue border for message box
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: Text(isUser ? 'You' : 'AI'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'AI Assistant',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal, // Ensure plain text style
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
