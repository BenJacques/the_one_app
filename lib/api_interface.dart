import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'quote.dart';

abstract class ApiInterface {
  Future<List<String>> getBooks();
  Future<List<String>> getCharacters();
  Future<List<String>> getMovies();
  Future<CharacterQuote> getRandomQuote(String character);
}

class MockTheOneApi implements ApiInterface {

  @override
  Future<List<String>> getBooks() {
    return Future(() => [
          'The Fellowship of the Ring',
          'The Two Towers',
          'The Return of the King'
        ]);
  }

  @override
  Future<List<String>> getCharacters() {
    return Future(() => [
          'Frodo',
          'Sam',
          'Gandalf',
          'Aragorn',
          'Legolas',
          'Gimli',
          'Boromir',
          'Merry',
          'Pippin'
        ]);
  }

  @override
  Future<List<String>> getMovies() {
    return Future(() => [
          'The Fellowship of the Ring',
          'The Two Towers',
          'The Return of the King'
        ]);
  }


  @override
  Future<CharacterQuote> getRandomQuote(String character) {
    return Future(
        () => CharacterQuote(quote: 'Fly, you fools!', character: 'Gandalf'));
  }
}

class TheOneApi implements ApiInterface {
  final String baseUrl = 'https://the-one-api.dev/v2/';

  // Get creds from environment variables
  final String? apiKey = Platform.environment['THE_ONE_API_KEY'];

  Map<String, String?> characterMap = {};

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');

    // Add the API key to the headers
    var headers = {'Authorization': 'Bearer $apiKey'};

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      return jsonDecode(responseString);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded. Wait a couple of minutes and try again.');
    } else {
      throw Exception('Failed to fetch data. Error code: ${response.statusCode}');
    }
  }

  @override
  Future<List<String>> getBooks() async {
    List<String> books = [];
    await get('book').then((value) {
      print(value['docs']);
      for (var item in value['docs']) {
        print(item);
        books.add(item['name']);
      }
    });
    return books;
  }

  @override
  Future<List<String>> getCharacters() async {
    List<String> characters = [];
    await get('character').then((value) {
      for (var item in value['docs']) {
        characters.add(item['name']);
      }
    });
    return characters;
  }

  @override
  Future<List<String>> getMovies() async {
    List<String> movies = [];
    await get('book').then((value) {
      for (var item in value['docs']) {
        movies.add(item['name']);
      }
    });
    return movies;
  }

  Future<List<CharacterQuote>> getQuotes() async {
    List<CharacterQuote> quotes = [];
    await get('quote').then((value) async {
      print(value['docs']);
      for (var item in value['docs']) {
        print(item);
        quotes.add(CharacterQuote(
          quote: item['dialog'],
          character: await getCharacterById(item['character']),
        ));
      }
    });
    return quotes;
  }

  Future<CharacterQuote> getQuoteFromCharacterList(List<String> characters){
    var character = characters[Random().nextInt(characters.length)];
    return getRandomQuote(character);
  }

  @override
  Future<CharacterQuote> getRandomQuote(String character) async {
    //5cd99d4bde30eff6ebccfe9e <-- Gollum
    CharacterQuote quote = CharacterQuote(quote: '', character: '');
    if (character == '') {
      await get('quote?limit=100').then((value) async {
        print(value['docs']);
        var numQuotes = value['docs'].length;
        var randomIndex = Random().nextInt(numQuotes);
        var randomQuote = value['docs'][randomIndex];
        if (randomQuote['dialog'] == '' || randomQuote['dialog'] == null) {
          // If the quote is empty, get another random quote
          randomIndex = Random().nextInt(numQuotes);
          randomQuote = value['docs'][randomIndex];
        }
        var character = await getCharacterById(randomQuote['character']);
        quote = CharacterQuote(
          quote: randomQuote['dialog'],
          character: character,
        );
      });
    } else {
      var characterId = await getCharacterIdByName(character);
      var query = 'character/$characterId/quote';
      await get(query).then((value) {
        print(value['docs']);
        var numQuotes = value['docs'].length;
        var randomIndex = Random().nextInt(numQuotes);
        var randomQuote = value['docs'][randomIndex];
        if (randomQuote['dialog'] == '' || randomQuote['dialog'] == null) {
          // If the quote is empty, get another random quote
          randomIndex = Random().nextInt(numQuotes);
          randomQuote = value['docs'][randomIndex];
        }
        quote = CharacterQuote(
          quote: randomQuote['dialog'],
          character: character,
        );
      });
    }
    
    return quote;
  }

  Future<String> getCharacterById(String id) {
    return get('character/$id').then((value) {
      return value['docs'][0]['name'];
    });
  }

Future<String> getCharacterIdByName(String name) {
    if (characterMap.containsKey(name)) {
      print('Character ID for $name already cached');
      return Future.value(characterMap[name]);
    }
    return get('character?name=$name').then((value) {
      print('Character ID for $name not cached');
      String characterId = value['docs'][0]['_id'];
      characterMap[name] = characterId;
      print('Character ID for $name: $characterId');
      return characterId;
    });
  }

}
