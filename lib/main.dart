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
  
  String get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;
  
  void setHappy() {
    _currentMood = 'Happy.png';
    _backgroundColor = Colors.yellow;
    notifyListeners();
  }
  
  void setSad() {
    _currentMood = 'Sad.png';
    _backgroundColor = Colors.blue;
    notifyListeners();
  }
  
  void setExcited() {
    _currentMood = 'Excited.png';
    _backgroundColor = Colors.orange;
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