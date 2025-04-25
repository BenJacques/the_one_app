import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:the_one_app/character_lists.dart';
import 'api_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The One App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber.shade900,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'The One App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _quote = '';
  String _character = '';
  String? _selectedCharacter;
  String _answer = '';
  int _numCorrect = 0;
  int _numTotal = 0;
  bool _checkAnswerEnabled = false;
  bool _getQuoteEnabled = true;
  int _numStrikes = 0;
  Difficulty _difficulty = Difficulty.easy;

  final _api = TheOneApi();

  int _currentCharacterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style:
              const TextStyle(color: Colors.white), // Ensure title is visible
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black54, // Black
              Color(0xFF1A1A1A), // Dark Gray
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          // Wrap the content in a scrollable view
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context)
                    .size
                    .height, // Ensure it fills the screen
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber[900], // Button background
                      foregroundColor: Colors.white, // Button text/icon color
                    ),
                    onPressed: getGetQuoteLogic(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.textsms, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Get Quote'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        _quote.isEmpty ? 'Press "Get Quote" to start!' : _quote,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade300, // Light text color
                            ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 40,
                    thickness: 2,
                    color: Colors.grey.shade500, // Lighter divider color
                  ),
                  const Text(
                    'Select who said this:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Light text color
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250, // Set the maximum height for the carousel
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCharacterIndex = index;
                            _selectedCharacter =
                                getCharacterList()[_currentCharacterIndex];
                          });
                        },
                      ),
                      items: imageSliders,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: _checkAnswerEnabled
                          ? Colors.amber[900] // Button background when enabled
                          : Colors.white60, // Lighter amber when disabled
                      foregroundColor: Colors.white, // Button text/icon color
                    ),
                    onPressed: getCheckAnswerLogic(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Check Answer'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _answer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _answer.contains('Correct')
                              ? Colors.green
                              : Colors.red,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getScore(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey.shade300, // Light text color
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[900], // Button background
        foregroundColor: Colors.white, // Icon color
        onPressed: resetGame,
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  late List<Widget> imageSliders;
  int _previousHighScore = 0;
  @override
  void initState() {
    super.initState();
    getSavedScore().then((value) {
      if (value > 0) {
        _previousHighScore = value;
      }
    });
    imageSliders = getCharacterList()
        .map((item) => Container(
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          getCharacterImage(item),
                          fit: BoxFit.contain,
                          width: 1000.0,
                          height: 400.0,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/unknown.png',
                            fit: BoxFit.contain,
                            width: 1000.0,
                            height: 400.0,
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
  }

  Future<int> getSavedScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('finalScore') ?? 0; // Default to 0 if no score is saved
  }

  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('finalScore', score);
  }

  Function()? getCheckAnswerLogic() {
    if (_quote == '' || !_checkAnswerEnabled) {
      return onCheckAnswerPressed;
    } else {
      return onCheckAnswerPressed;
    }
  }

  Function()? getGetQuoteLogic() {
    if (_getQuoteEnabled) {
      return onPressed;
    } else {
      return null;
    }
  }

  List<String> getCharacterList() {
    var characterList = CharacterLists().getCharacterList(_difficulty);
    // characterList.sort();
    return characterList;
  }

  String getCharacterImage(String character) {
    // Check if image file exists
    final imagePath =
        './assets/images/${character.toLowerCase().replaceAll(' ', '_')}.png';
    return imagePath;
  }

  void resetGame() {
    setState(() {
      _quote = '';
      _character = '';
      _answer = '';
      _numCorrect = 0;
      _numTotal = 0;
      _numStrikes = 0;
      _getQuoteEnabled = true;
    });
  }

  void onCheckAnswerPressed() {
    if (_checkAnswerEnabled == false) {
      return;
    }
    setState(() {
      _numTotal++;
      if (_character == _selectedCharacter) {
        _numCorrect++;
        _answer = 'Correct!';
        _checkAnswerEnabled = false;
      } else {
        _numStrikes++;
        var strikes = _numStrikes == 1 ? 'strike' : 'strikes';
        _answer =
            'Incorrect. The right answer was $_character. You have $_numStrikes $strikes.';
        _checkAnswerEnabled = false;
        if (_numStrikes >= 3) {
          _getQuoteEnabled = false;
        }
      }
    });
  }

  void onPressed() {
    setState(() {
      _quote = 'Loading...';
    });
    _api.getQuoteFromCharacterList(getCharacterList()).then((value) {
      setState(() {
        _character = value.character.toString();
        _quote = value.quote.toString();
        _checkAnswerEnabled = true;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _quote = 'Error getting quote';
      });
    });
  }

  String getScore() {
    if (_numTotal == 0) {
      return 'No questions answered yet';
    }
    if (_numStrikes >= 3) {
      if (_numCorrect > _previousHighScore) {
        saveScore(_numCorrect);
        var temp = _previousHighScore;
        _previousHighScore = _numCorrect;
        return 'Game Over. You got a new high score of $_numCorrect! Your previous high score was $temp';
      } else {
        return 'Game Over. Final Score: $_numCorrect. Your previous high score was $_previousHighScore';
      }
    }
    return 'Current Score: $_numCorrect';
  }
}
