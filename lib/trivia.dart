import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'dart:ui';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  final List<Map<String, Object>> _questions = [
    {
      'hint': 'Which tool is essential for plowing fields?',
      'options': ['Tractor', 'Hand Hoe', 'Plow', 'Irrigation Pump'],
      'answer': 'Plow',
    },
    {
      'hint': 'What is the process of watering crops called?',
      'options': ['Harvesting', 'Irrigation', 'Tilling', 'Grafting'],
      'answer': 'Irrigation',
    },
    // ...additional trivia questions...
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  String _selectedAnswer = '';
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;

  void _submitAnswer(String answer) {
    setState(() {
      if (answer == _questions[_currentQuestionIndex]['answer']) {
        _score++;
        _feedbackMessage = 'Correct!';
        _feedbackColor = Colors.green;
      } else {
        _feedbackMessage = 'Incorrect! Try again.';
        _feedbackColor = Colors.red;
      }
      _selectedAnswer = '';
    });
  }

  void _showHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hint'),
          titleTextStyle: const TextStyle(color: Colors.white),
          content: Text(_questions[_currentQuestionIndex]['hint'] as String),
          contentTextStyle: const TextStyle(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture Trivia'), // Updated title
        backgroundColor: Colors.green, // Updated color
      ),
      body: Stack(
        children: [
          // Background Animation
          const Positioned.fill(
            child: AnimatedBackground(),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Quiz Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _currentQuestionIndex < _questions.length
                ? _buildQuestion()
                : _buildResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    var currentQuestion = _questions[_currentQuestionIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentQuestion['question'] as String,
          style: const TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...(currentQuestion['options'] as List<String>).map((option) {
          return ListTile(
            title: Text(option, style: const TextStyle(color: Colors.white)),
            leading: Radio<String>(
              value: option,
              groupValue: _selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _selectedAnswer = value!;
                });
              },
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedAnswer.isEmpty
              ? null
              : () => _submitAnswer(_selectedAnswer),
          child: const Text('Submit Answer'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showHint(context),
          child: const Text('Show Hint'),
        ),
        const SizedBox(height: 20),
        Text(
          _feedbackMessage,
          style: TextStyle(fontSize: 18, color: _feedbackColor),
        ),
      ],
    );
  }

  Widget _buildResult() {
    double correctPercentage =
        _questions.isNotEmpty ? (_score / _questions.length) * 100 : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 150.0,
            lineWidth: 13.0,
            percent: correctPercentage / 100,
            center: Text(
              '$_score/${_questions.length}',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            backgroundColor: Colors.grey[300]!,
            progressColor: Colors.green,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 20),
          Text(
            'You scored $_score out of ${_questions.length}',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswer = '';
                _feedbackMessage = '';
                _feedbackColor = Colors.black;
              });
            },
            child: const Text('Restart Quiz'),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(10, (index) {
        return AnimatedPositioned(
          duration: const Duration(seconds: 5),
          left: Random().nextDouble() * MediaQuery.of(context).size.width,
          top: Random().nextDouble() * MediaQuery.of(context).size.height,
          child: AnimatedContainer(
            duration: const Duration(seconds: 5),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        );
      }),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: TriviaPage(),
  ));
}
