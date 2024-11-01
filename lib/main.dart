
import 'package:flutter/material.dart';
import 'api_interface.dart';
import 'quote.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

  static const List<String> _characterList = [
    'Gollum',
    'Frodo Baggins',
    'Samwise Gamgee',
    'Aragorn II Elessar',
    'Gandalf',
    'Gimli',
    'Legolas',
    'Boromir',
    'Meriadoc Brandybuck',
    'Peregrin Took',
    'Saruman',
    'Treebeard',
  ];

  final _api = TheOneApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Center(

          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34.0),
                child: FilledButton.tonal(
                  onPressed: getGetQuoteLogic(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.textsms),
                      Text('Get Quote'),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    _quote,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              const Divider(
                height: 50,
                thickness: 3,
                color: Colors.teal,
              ),
              const Text('Select who said this:'),
              DropdownButton<String>(
                hint: const Text('Select a character'),
                value: _selectedCharacter,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCharacter = newValue;
                  });
                },
                items: _characterList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34.0),
                child: FilledButton.tonal(
                  onPressed: getCheckAnswerLogic(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.check),
                      Text('Check Answer'),
                    ],
                  ),
                ),
              ),
              Text(
                _answer,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                getScore(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetGame,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Function()? getCheckAnswerLogic() {
    if (_quote == '' || !_checkAnswerEnabled) {
      return null;
    }
    else {
      return onCheckAnswerPressed;
    }
  }

  Function()? getGetQuoteLogic() {
    if (_getQuoteEnabled) {
      return onPressed;
    }
    else {
      return null;
    }
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

  void onEditingComplete() {
    print('Editing complete');
  }

  void onCheckAnswerPressed() {
    print('Check Answer Pressed');
    setState(() {
      _numTotal++;
      if (_character == _selectedCharacter) {
        _numCorrect++;
        _answer = 'Correct!';
        _checkAnswerEnabled = false;
        print('Correct');
      } else {
        _numStrikes++;
        _answer = 'Incorrect. The right answer was $_character. You have $_numStrikes strikes.';
        print('Incorrect');
        _checkAnswerEnabled = false;
        if (_numStrikes >= 3) {
          _answer = 'Incorrect. The right answer was $_character. You have $_numStrikes strikes.';
          _getQuoteEnabled = false;
        }
      }
    });
  }

  void onPressed() {
    setState(() {
      // Disable button while waiting for response
      _quote = 'Loading...';
    });
    print('Pressed');
    String character = _selectedCharacter ?? '';
    if (character == 'Random') {
      character = '';
    }
    if (_character != '') {
      character = _character;
    }
    _api.getQuoteFromCharacterList(_characterList).onError((error, stackTrace) {
      print('Error getting quote: $error');
      return CharacterQuote(quote: 'Error getting quote', character: 'Error');
    }).then((value) {
      setState(() {
        _character = value.character.toString();
        _quote = value.quote.toString();
        _checkAnswerEnabled = true;
      });
    });

    // _api.get('/quote').then((value) {
    //   setState(() {
    //     _quote = value;
    //   });
    // });
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
