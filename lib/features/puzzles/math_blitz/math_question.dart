class MathQuestion {
  const MathQuestion({
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
  });

  final String prompt;
  final int correctAnswer;
  final List<int> choices;
}
