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
  
  String get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;
  Map<String, int> get moodCounts => _moodCounts;
  
  void setHappy() {
    _currentMood = 'Happy.png';
    _backgroundColor = Colors.yellow;
    _moodCounts['Happy'] = _moodCounts['Happy']! + 1;
    notifyListeners();
  }
  
  void setSad() {
    _currentMood = 'Sad.png';
    _backgroundColor = Colors.blue;
    _moodCounts['Sad'] = _moodCounts['Sad']! + 1;
    notifyListeners();
  }
  
  void setExcited() {
    _currentMood = 'Excited.png';
    _backgroundColor = Colors.orange;
    _moodCounts['Excited'] = _moodCounts['Excited']! + 1;
    notifyListeners();
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('How are you feeling?', style: TextStyle(fontSize:
                24)),
                SizedBox(height: 30),
                MoodDisplay(),
                SizedBox(height: 50),
                MoodButtons(),
                SizedBox(height: 30),
                MoodCounter(),
              ],
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
    return Row(
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
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
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