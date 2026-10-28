import 'dart:io';

import 'package:drift/native.dart';
import 'package:qazaqsha/data/database/app_database.dart';

/// In-memory database seeded from the real asset files.
AppDatabase testDatabase() => AppDatabase(
  executor: NativeDatabase.memory(),
  loadSeed: () => File('assets/data/dictionary.json').readAsString(),
  loadSentences: () => File('assets/data/sentences.json').readAsString(),
);
