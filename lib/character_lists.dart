enum Difficulty { easy, medium, hard }

class CharacterLists {
  static const List<String> easy = [
    'Aragorn II Elessar',
    'Boromir',
    'Frodo Baggins',
    'Gandalf',
    'Gimli',
    'Gollum',
    'Legolas',
    'Meriadoc Brandybuck',
    'Peregrin Took',
    'Samwise Gamgee',
    'Saruman',
    'Treebeard',
  ];

  static const List<String> medium = [
    'Balin',
    'Bard the Bowman',
    'Bilbo Baggins',
    'Bifur',
    'Bombur',
    'Dwalin',
    'Elrond',
    'Fili',
    'Galadriel',
    'Kili',
    'Oin',
    'Ori',
    'Radagast',
    'Thrain',
    'Thranduil',
    'Thror',
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