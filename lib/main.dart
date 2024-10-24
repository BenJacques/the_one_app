import 'dart:math';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'The One App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.

          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 34.0),
                child: FilledButton.tonal(
                  onPressed: onPressed,
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
              // const Text(
              //   'You have pushed the button this many times:',
              // ),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headlineMedium,
              // ),
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
      print('Check Answer Disabled');
      return null;
    }
    else {
      print('Check Answer Enabled');
      return onCheckAnswerPressed;
    }
  }

  void resetGame() {
    setState(() {
      _quote = '';
      _character = '';
      _answer = '';
      _numCorrect = 0;
      _numTotal = 0;
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
        _answer = 'Incorrect. The right answer was $_character.';
        print('Incorrect');
        _checkAnswerEnabled = false;
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
    var percent = (_numCorrect / _numTotal) * 100;
    var formattedPercent = percent.toStringAsFixed(2);
    return '$_numCorrect / $_numTotal ($formattedPercent%)';
  }
}
