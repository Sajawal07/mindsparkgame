class ScienceElement {
  const ScienceElement({
    required this.symbol,
    required this.name,
    required this.assetFileName,
    required this.category,
    required this.funFact,
    required this.difficulty,
    required this.wrongOptions,
  });

  final String symbol;
  final String name;
  final String assetFileName;
  final String category;
  final String funFact;
  final String difficulty;
  final List<String> wrongOptions;

  String get imagePath => 'assets/images/science_snap/$assetFileName';

  static const List<ScienceElement> dataset = [
    ScienceElement(
      symbol: 'H',
      name: 'Hydrogen',
      assetFileName: 'ELEM_H.png',
      category: 'Nonmetal',
      funFact: 'Hydrogen is the most abundant chemical substance in the universe.',
      difficulty: 'Easy',
      wrongOptions: ['Helium', 'Oxygen', 'Nitrogen'],
    ),
    ScienceElement(
      symbol: 'He',
      name: 'Helium',
      assetFileName: 'ELEM_HE.png',
      category: 'Noble Gas',
      funFact: 'Helium is lighter than air, which is why it makes balloons float.',
      difficulty: 'Easy',
      wrongOptions: ['Hydrogen', 'Neon', 'Argon'],
    ),
    ScienceElement(
      symbol: 'C',
      name: 'Carbon',
      assetFileName: 'ELEM_C.png',
      category: 'Nonmetal',
      funFact: 'Diamonds and graphite (in pencils) are both made entirely of carbon.',
      difficulty: 'Easy',
      wrongOptions: ['Calcium', 'Chlorine', 'Copper'],
    ),
    ScienceElement(
      symbol: 'N',
      name: 'Nitrogen',
      assetFileName: 'ELEM_N.png',
      category: 'Nonmetal',
      funFact: 'Nitrogen makes up about 78% of Earth\'s atmosphere.',
      difficulty: 'Easy',
      wrongOptions: ['Neon', 'Nickel', 'Nobelium'],
    ),
    ScienceElement(
      symbol: 'O',
      name: 'Oxygen',
      assetFileName: 'ELEM_O.png',
      category: 'Nonmetal',
      funFact: 'Liquid oxygen is actually pale blue in color.',
      difficulty: 'Easy',
      wrongOptions: ['Osmium', 'Carbon', 'Oganesson'],
    ),
    ScienceElement(
      symbol: 'Ne',
      name: 'Neon',
      assetFileName: 'ELEM_NE.png',
      category: 'Noble Gas',
      funFact: 'Neon gives a distinct reddish-orange glow when used in signs.',
      difficulty: 'Medium',
      wrongOptions: ['Nitrogen', 'Nickel', 'Niobium'],
    ),
    ScienceElement(
      symbol: 'Na',
      name: 'Sodium',
      assetFileName: 'ELEM_NA.png',
      category: 'Alkali Metal',
      funFact: 'Sodium is a highly reactive metal that explodes in water.',
      difficulty: 'Medium',
      wrongOptions: ['Sulfur', 'Scandium', 'Silicon'],
    ),
    ScienceElement(
      symbol: 'Fe',
      name: 'Iron',
      assetFileName: 'ELEM_FE.png',
      category: 'Transition Metal',
      funFact: 'Iron makes our blood red because it is part of hemoglobin.',
      difficulty: 'Medium',
      wrongOptions: ['Fluorine', 'Francium', 'Fermium'],
    ),
    ScienceElement(
      symbol: 'Cu',
      name: 'Copper',
      assetFileName: 'ELEM_CU.png',
      category: 'Transition Metal',
      funFact: 'Copper is naturally antibacterial.',
      difficulty: 'Medium',
      wrongOptions: ['Cobalt', 'Curium', 'Calcium'],
    ),
    ScienceElement(
      symbol: 'Ag',
      name: 'Silver',
      assetFileName: 'ELEM_AG.png',
      category: 'Transition Metal',
      funFact: 'Silver has the highest electrical conductivity of any element.',
      difficulty: 'Hard',
      wrongOptions: ['Gold', 'Argon', 'Aluminum'],
    ),
    ScienceElement(
      symbol: 'Au',
      name: 'Gold',
      assetFileName: 'ELEM_AU.png',
      category: 'Transition Metal',
      funFact: 'All the gold ever mined could fit into three Olympic swimming pools.',
      difficulty: 'Hard',
      wrongOptions: ['Silver', 'Actinium', 'Americium'],
    ),
    ScienceElement(
      symbol: 'U',
      name: 'Uranium',
      assetFileName: 'ELEM_U.png',
      category: 'Actinide',
      funFact: 'One pound of uranium produces as much energy as three million pounds of coal.',
      difficulty: 'Hard',
      wrongOptions: ['Ununennium', 'Uranus', 'Yttrium'],
    ),
  ];
}
