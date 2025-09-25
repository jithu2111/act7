import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodModel(),
      child: MyApp(),
    ),
  );
}
// Mood Model - The "Brain" of our app
class MoodModel with ChangeNotifier {
  String _currentMood = 'Happy.png';
  Color _backgroundColor = Colors.yellow;
  Map<String, int> _moodCounts = {
    'Happy': 1,
    'Sad': 0,
    'Excited': 0,
  };
  List<String> _moodHistory = ['Happy']; // Start with Happy as initial mood
  
  String get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;
  Map<String, int> get moodCounts => _moodCounts;
  List<String> get moodHistory => _moodHistory;
  
  void _addToHistory(String mood) {
    _moodHistory.insert(0, mood); // Add to beginning (most recent first)
    if (_moodHistory.length > 3) {
      _moodHistory.removeAt(3); // Keep only last 3 items
    }
  }
  
  void setHappy() {
    _currentMood = 'Happy.png';
    _backgroundColor = Colors.yellow;
    _moodCounts['Happy'] = _moodCounts['Happy']! + 1;
    _addToHistory('Happy');
    notifyListeners();
  }
  
  void setSad() {
    _currentMood = 'Sad.png';
    _backgroundColor = Colors.blue;
    _moodCounts['Sad'] = _moodCounts['Sad']! + 1;
    _addToHistory('Sad');
    notifyListeners();
  }
  
  void setExcited() {
    _currentMood = 'Excited.png';
    _backgroundColor = Colors.orange;
    _moodCounts['Excited'] = _moodCounts['Excited']! + 1;
    _addToHistory('Excited');
    notifyListeners();
  }
  
  void setRandomMood() {
    final random = Random();
    final randomNumber = random.nextInt(3); // Generate 0, 1, or 2
    
    switch (randomNumber) {
      case 0:
        setHappy();
        break;
      case 1:
        setSad();
        break;
      case 2:
        setExcited();
        break;
    }
  }
}
// Main App Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Toggle Challenge',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Mood Toggle Challenge')),
          backgroundColor: moodModel.backgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('How are you feeling?', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  MoodDisplay(),
                  SizedBox(height: 30),
                  MoodButtons(),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: MoodCounter()),
                      SizedBox(width: 10),
                      Expanded(child: MoodHistory()),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// Widget that displays the current mood
class MoodDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Container(
          width: 200,
          height: 200,
          child: Image.asset(
            moodModel.currentMood,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
// Widget with buttons to change the mood
class MoodButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setHappy();
              },
              child: Text('😊 Happy'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setSad();
              },
              child: Text('😢 Sad'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setExcited();
              },
              child: Text('🎉 Excited'),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pink, Colors.orange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Provider.of<MoodModel>(context, listen: false).setRandomMood();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              '🤪 Random Mood',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget that displays mood counters
class MoodCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Mood Counter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCounterItem('😊', 'Happy', moodModel.moodCounts['Happy']!),
                  _buildCounterItem('😢', 'Sad', moodModel.moodCounts['Sad']!),
                  _buildCounterItem('🎉', 'Excited', moodModel.moodCounts['Excited']!),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterItem(String emoji, String mood, int count) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 5),
        Text(
          mood,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 3),
        Text(
          '$count',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Widget that displays mood history
class MoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Recent Moods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              _buildHistoryContent(moodModel.moodHistory),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryContent(List<String> history) {
    if (history.isEmpty) {
      return Text(
        'No history yet',
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (int i = 0; i < history.length && i < 3; i++)
          _buildHistoryItem(history[i], i + 1),
      ],
    );
  }

  Widget _buildHistoryItem(String mood, int position) {
    String emoji = mood == 'Happy' ? '😊' : 
                   mood == 'Sad' ? '😢' : '🎉';
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: position == 1 ? Colors.green[100] : 
                   position == 2 ? Colors.blue[100] : Colors.orange[100],
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '#$position',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}