import 'package:flutter/material.dart';
import 'package:the_one_app/character_lists.dart';
import 'api_interface.dart';
import 'quote.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: getGetQuoteLogic(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.textsms),
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.teal.shade700,
                        ),
                  ),
                ),
              ),
              const Divider(
                height: 40,
                thickness: 2,
                color: Colors.teal,
              ),
              const Text(
                'Select who said this:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                hint: const Text('Select a character'),
                value: _selectedCharacter,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCharacter = newValue;
                  });
                },
                items: getCharacterList()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: getCheckAnswerLogic(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetGame,
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Function()? getCheckAnswerLogic() {
    if (_quote == '' || !_checkAnswerEnabled) {
      return null;
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
    return CharacterLists().getCharacterList(_difficulty);
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
    setState(() {
      _numTotal++;
      if (_character == _selectedCharacter) {
        _numCorrect++;
        _answer = 'Correct!';
        _checkAnswerEnabled = false;
      } else {
        _numStrikes++;
        _answer =
            'Incorrect. The right answer was $_character. You have $_numStrikes strikes.';
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
      return 'Game Over. Final Score: $_numCorrect';
    }
    return 'Current Score: $_numCorrect';
  }
}
