class CharacterQuote {
  String? quote;
  String? character;

  CharacterQuote({this.quote, this.character});

  factory CharacterQuote.fromJson(Map<String, dynamic> json) {
    return CharacterQuote(
      quote: json['quote'],
      character: json['character'],
    );
  }

  @override
  String toString() {
    return '$character: $quote';
  }
}
