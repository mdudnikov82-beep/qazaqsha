/// Which words a review session takes.
enum ReviewMode {
  /// Words whose spaced-repetition date has come.
  due,

  /// Words with the most mistakes.
  hard,
  favorites,

  /// Any studied words, for extra practice when nothing is due.
  random,

  /// Words from the mistakes notebook.
  mistakes,

  /// A short calm session before sleep: the words that will be forgotten
  /// soonest, recognition only, no points and no timer.
  bedtime;

  static ReviewMode parse(String? name) => ReviewMode.values.firstWhere(
    (m) => m.name == name,
    orElse: () => ReviewMode.due,
  );
}

/// Words per review session.
const reviewSessionSize = 10;

/// Words in a bedtime session: two or three quiet minutes.
const bedtimeSessionSize = 6;

/// From this hour (and until [bedtimeUntil]) Home offers the bedtime review.
const bedtimeFrom = 20;
const bedtimeUntil = 4;

bool isBedtime(DateTime now) =>
    now.hour >= bedtimeFrom || now.hour < bedtimeUntil;
