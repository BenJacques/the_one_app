enum Difficulty { easy, medium, hard }

class CharacterLists {
  static const List<String> easy = [
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

  static const List<String> medium = [
    'Galadriel',
    'Elrond',
    'Thranduil',
    'Bilbo Baggins',
    'Bard the Bowman',
    'Balin',
    'Bifur',
    'Bombur',
    'Dwalin',
    'Fili',
    'Kili',
    'Oin',
    'Ori',
    'Radagast',
    'Thror',
    'Thrain',
    'Tom Bombadil',
  ];

  static const List<String> hard = [
    'Arwen',
    'Beren',
    'Boromir',
    'Celeborn',
    'Denethor II',
    'Eomer',
    'Eowyn',
    'Faramir',
    'Finduilas',
    'Gil-galad',
    'Glorfindel',
    'Haldir',
    'Imrahil',
    'Ioreth',
    'Luthien',
    'Morwen',
    'Nienna',
    'Nienor',
    'Theoden',
    'Thorin Oakenshield',
    'Turgon',
    'Ugluk',
  ];

  

  List<String> getCharacterList(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return easy;
      case Difficulty.medium:
        return medium;
      case Difficulty.hard:
        return hard;
      default:
        return easy;
    }
  }

  
}