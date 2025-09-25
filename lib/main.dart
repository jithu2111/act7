import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeModel = ThemeModel();
  await themeModel.loadTheme();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MoodModel()),
        ChangeNotifierProvider.value(value: themeModel),
      ],
      child: MyApp(),
    ),
  );
}
// Mood Model - The "Brain" of our app
class MoodModel with ChangeNotifier {
  String _currentMood = 'Happy.png';
  String _currentMoodName = 'Happy';
  final Map<String, int> _moodCounts = {
    'Happy': 1,
    'Sad': 0,
    'Excited': 0,
  };
  final List<String> _moodHistory = ['Happy']; // Start with Happy as initial mood
  
  String get currentMood => _currentMood;
  String get currentMoodName => _currentMoodName;
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
    _currentMoodName = 'Happy';
    _moodCounts['Happy'] = _moodCounts['Happy']! + 1;
    _addToHistory('Happy');
    notifyListeners();
  }
  
  void setSad() {
    _currentMood = 'Sad.png';
    _currentMoodName = 'Sad';
    _moodCounts['Sad'] = _moodCounts['Sad']! + 1;
    _addToHistory('Sad');
    notifyListeners();
  }
  
  void setExcited() {
    _currentMood = 'Excited.png';
    _currentMoodName = 'Excited';
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

// Theme Data Classes
enum ThemeType { defaultTheme, darkTheme, pastelTheme }

class AppThemeData {
  final Color happyColor;
  final Color sadColor; 
  final Color excitedColor;
  final Color cardColor;
  final Color textColor;
  final Color backgroundColor;
  final String name;
  
  AppThemeData({
    required this.happyColor,
    required this.sadColor,
    required this.excitedColor,
    required this.cardColor,
    required this.textColor,
    required this.backgroundColor,
    required this.name,
  });
}

// Theme Model - Manages app themes
class ThemeModel with ChangeNotifier {
  ThemeType _currentTheme = ThemeType.defaultTheme;
  
  final Map<ThemeType, AppThemeData> _themes = {
    ThemeType.defaultTheme: AppThemeData(
      name: 'Default',
      happyColor: Colors.yellow,
      sadColor: Colors.blue,
      excitedColor: Colors.orange,
      cardColor: Colors.white,
      textColor: Colors.black,
      backgroundColor: Colors.grey[50]!,
    ),
    ThemeType.darkTheme: AppThemeData(
      name: 'Dark',
      happyColor: Colors.amber[600]!,
      sadColor: Colors.indigo[400]!,
      excitedColor: Colors.deepOrange[400]!,
      cardColor: Colors.grey[800]!,
      textColor: Colors.white,
      backgroundColor: Colors.grey[900]!,
    ),
    ThemeType.pastelTheme: AppThemeData(
      name: 'Pastel',
      happyColor: Colors.yellow[200]!,
      sadColor: Colors.blue[200]!,
      excitedColor: Colors.orange[200]!,
      cardColor: Colors.pink[50]!,
      textColor: Colors.grey[800]!,
      backgroundColor: Colors.purple[50]!,
    ),
  };
  
  ThemeType get currentTheme => _currentTheme;
  AppThemeData get themeData => _themes[_currentTheme]!;
  List<ThemeType> get availableThemes => _themes.keys.toList();
  
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme_index') ?? 0;
      _currentTheme = ThemeType.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // Handle error silently, keep default theme
    }
  }
  
  Future<void> setTheme(ThemeType theme) async {
    _currentTheme = theme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_index', theme.index);
    } catch (e) {
      // Handle error silently
    }
  }
  
  Color getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return themeData.happyColor;
      case 'Sad':
        return themeData.sadColor;
      case 'Excited':
        return themeData.excitedColor;
      default:
        return themeData.happyColor;
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
    return Consumer2<MoodModel, ThemeModel>(
      builder: (context, moodModel, themeModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Mood Toggle Challenge'),
            backgroundColor: themeModel.getMoodColor(moodModel.currentMoodName),
          ),
          backgroundColor: themeModel.themeData.backgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How are you feeling?', 
                    style: TextStyle(
                      fontSize: 24,
                      color: themeModel.themeData.textColor,
                    ),
                  ),
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
                  ThemeSelector(),
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
    return Consumer2<MoodModel, ThemeModel>(
      builder: (context, moodModel, themeModel, child) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: themeModel.themeData.cardColor,
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
                  color: themeModel.themeData.textColor,
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(child: _buildCounterItem(context, '😊', 'Happy', moodModel.moodCounts['Happy']!)),
                  Flexible(child: _buildCounterItem(context, '😢', 'Sad', moodModel.moodCounts['Sad']!)),
                  Flexible(child: _buildCounterItem(context, '🎉', 'Excited', moodModel.moodCounts['Excited']!)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterItem(BuildContext context, String emoji, String mood, int count) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 5),
        Text(
          mood,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w500,
            color: themeModel.themeData.textColor,
          ),
        ),
        SizedBox(height: 3),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: themeModel.themeData.textColor,
          ),
        ),
      ],
    );
  }
}

// Widget that displays mood history
class MoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodModel, ThemeModel>(
      builder: (context, moodModel, themeModel, child) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: themeModel.themeData.cardColor,
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
                  color: themeModel.themeData.textColor,
                ),
              ),
              SizedBox(height: 12),
              _buildHistoryContent(context, moodModel.moodHistory),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryContent(BuildContext context, List<String> history) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    if (history.isEmpty) {
      return Text(
        'No history yet',
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: themeModel.themeData.textColor,
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (int i = 0; i < history.length && i < 3; i++)
          _buildHistoryItem(context, history[i], i + 1),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, String mood, int position) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    String emoji = mood == 'Happy' ? '😊' : 
                   mood == 'Sad' ? '😢' : '🎉';
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeModel.getMoodColor(mood).withOpacity(0.3),
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
            color: themeModel.themeData.textColor,
          ),
        ),
      ],
    );
  }
}

// Theme Selector Widget
class ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: themeModel.themeData.cardColor,
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
                'Theme Selector',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeModel.themeData.textColor,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (ThemeType theme in themeModel.availableThemes)
                    _buildThemeButton(context, themeModel, theme),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(BuildContext context, ThemeModel themeModel, ThemeType theme) {
    // Create a temporary ThemeModel instance to access the specific theme data
    final tempModel = ThemeModel();
    tempModel._currentTheme = theme;
    final themeData = tempModel.themeData;
    final isSelected = themeModel.currentTheme == theme;
    
    return GestureDetector(
      onTap: () {
        themeModel.setTheme(theme);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: themeData.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: themeData.happyColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: themeData.sadColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: themeData.excitedColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              themeData.name,
              style: TextStyle(
                fontSize: 10,
                color: themeData.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}