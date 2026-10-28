import 'dart:math';

import '../../data/database/tables.dart';

/// Leitner-style spaced repetition. Box N waits [reviewIntervals][N].
const reviewIntervals = [
  Duration.zero,
  Duration(days: 1),
  Duration(days: 3),
  Duration(days: 7),
  Duration(days: 16),
  Duration(days: 35),
];

/// From this box on a word counts as learned.
const learnedBox = 3;

class SrsStep {
  const SrsStep(this.box, this.nextReviewAt, this.status);

  final int box;
  final DateTime nextReviewAt;
  final LearningStatus status;
}

/// Next state of a word after a session where it was answered
/// [correct]ly (every time) or not.
SrsStep scheduleReview({
  required int box,
  required bool correct,
  required DateTime now,
}) {
  final next = correct ? min(box + 1, reviewIntervals.length - 1) : 0;
  return SrsStep(
    next,
    now.add(reviewIntervals[next]),
    next >= learnedBox ? LearningStatus.learned : LearningStatus.learning,
  );
}
