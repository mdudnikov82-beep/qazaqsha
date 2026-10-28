import '../../data/database/app_database.dart';

sealed class Question {
  const Question();

  /// Words whose spaced-repetition state this question affects.
  List<Word> get words;
}

/// Shows a new word before it is quizzed. Not scored.
class IntroCard extends Question {
  const IntroCard(this.word);

  final Word word;

  @override
  List<Word> get words => [word];
}

/// Pick the translation out of four options.
class ChoiceQuestion extends Question {
  const ChoiceQuestion({
    required this.word,
    required this.fromRussian,
    required this.options,
    required this.correctIndex,
  });

  final Word word;

  /// true: prompt in Russian, options in Kazakh.
  final bool fromRussian;
  final List<String> options;
  final int correctIndex;

  String get prompt => fromRussian ? word.ru : word.kk;
  String get answer => options[correctIndex];

  @override
  List<Word> get words => [word];
}

/// Type the Kazakh word for a Russian prompt.
class TypeQuestion extends Question {
  const TypeQuestion(this.word);

  final Word word;

  @override
  List<Word> get words => [word];
}

/// Connect Russian and Kazakh words into pairs.
class MatchQuestion extends Question {
  const MatchQuestion(this.pairs);

  final List<Word> pairs;

  @override
  List<Word> get words => pairs;
}

/// Build the Kazakh sentence for a Russian one from shuffled word tiles.
/// [tiles] holds the sentence's words plus a few extra ones.
class SentenceQuestion extends Question {
  const SentenceQuestion({required this.sentence, required this.tiles});

  final Sentence sentence;
  final List<String> tiles;

  /// Sentences train phrases, not single dictionary words.
  @override
  List<Word> get words => const [];
}

/// XP for a correctly answered question.
int xpFor(Question q) => switch (q) {
  IntroCard() => 0,
  ChoiceQuestion() => 10,
  TypeQuestion() => 15,
  MatchQuestion() => 20,
  SentenceQuestion() => 20,
};
