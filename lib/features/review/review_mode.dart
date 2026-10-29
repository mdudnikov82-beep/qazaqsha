/// Which words a review session takes.
enum ReviewMode {
  /// Words whose spaced-repetition date has come.
  due,

  /// Words with the most mistakes.
  hard,
  favorites,

  /// Any studied words, for extra practice when nothing is due.
  random;

  static ReviewMode parse(String? name) => ReviewMode.values.firstWhere(
    (m) => m.name == name,
    orElse: () => ReviewMode.due,
  );
}

/// Words per review session.
const reviewSessionSize = 10;
