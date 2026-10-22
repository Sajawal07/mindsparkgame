class ScienceFact {
  const ScienceFact({
    required this.statement,
    required this.isTrue,
  });

  final String statement;
  final bool isTrue;
}

abstract final class ScienceFactData {
  static const facts = [
    ScienceFact(
      statement: 'Light travels faster than sound.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'The human body has four lungs.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Water boils at 100°C at sea level.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Diamonds are made of carbon.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'The Sun is a planet.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'DNA stands for Deoxyribonucleic Acid.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Mars is the largest planet in our solar system.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Photosynthesis converts sunlight into energy.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Sound can travel through a vacuum.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'The chemical symbol for gold is Au.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Bacteria are always harmful to humans.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Neurons are cells in the nervous system.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Ice is less dense than liquid water.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'The Moon produces its own light.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Oxygen is essential for human respiration.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Metals are generally good conductors of electricity.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Humans use only 10% of their brain.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Venus is the hottest planet in our solar system.',
      isTrue: true,
    ),
    ScienceFact(
      statement: 'Atoms are the smallest unit of all matter.',
      isTrue: false,
    ),
    ScienceFact(
      statement: 'Gravity pulls objects toward Earth.',
      isTrue: true,
    ),
  ];
}
