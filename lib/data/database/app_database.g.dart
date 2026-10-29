// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleRuMeta = const VerificationMeta(
    'titleRu',
  );
  @override
  late final GeneratedColumn<String> titleRu = GeneratedColumn<String>(
    'title_ru',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleKkMeta = const VerificationMeta(
    'titleKk',
  );
  @override
  late final GeneratedColumn<String> titleKk = GeneratedColumn<String>(
    'title_kk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, titleRu, titleKk, icon, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title_ru')) {
      context.handle(
        _titleRuMeta,
        titleRu.isAcceptableOrUnknown(data['title_ru']!, _titleRuMeta),
      );
    } else if (isInserting) {
      context.missing(_titleRuMeta);
    }
    if (data.containsKey('title_kk')) {
      context.handle(
        _titleKkMeta,
        titleKk.isAcceptableOrUnknown(data['title_kk']!, _titleKkMeta),
      );
    } else if (isInserting) {
      context.missing(_titleKkMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      titleRu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_ru'],
      )!,
      titleKk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_kk'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String titleRu;
  final String titleKk;

  /// Material icon name, mapped to IconData in the UI.
  final String icon;
  final int sortOrder;
  const Category({
    required this.id,
    required this.titleRu,
    required this.titleKk,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title_ru'] = Variable<String>(titleRu);
    map['title_kk'] = Variable<String>(titleKk);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      titleRu: Value(titleRu),
      titleKk: Value(titleKk),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      titleRu: serializer.fromJson<String>(json['titleRu']),
      titleKk: serializer.fromJson<String>(json['titleKk']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titleRu': serializer.toJson<String>(titleRu),
      'titleKk': serializer.toJson<String>(titleKk),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({
    String? id,
    String? titleRu,
    String? titleKk,
    String? icon,
    int? sortOrder,
  }) => Category(
    id: id ?? this.id,
    titleRu: titleRu ?? this.titleRu,
    titleKk: titleKk ?? this.titleKk,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      titleRu: data.titleRu.present ? data.titleRu.value : this.titleRu,
      titleKk: data.titleKk.present ? data.titleKk.value : this.titleKk,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('titleRu: $titleRu, ')
          ..write('titleKk: $titleKk, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titleRu, titleKk, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.titleRu == this.titleRu &&
          other.titleKk == this.titleKk &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> titleRu;
  final Value<String> titleKk;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.titleRu = const Value.absent(),
    this.titleKk = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String titleRu,
    required String titleKk,
    required String icon,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       titleRu = Value(titleRu),
       titleKk = Value(titleKk),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? titleRu,
    Expression<String>? titleKk,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleRu != null) 'title_ru': titleRu,
      if (titleKk != null) 'title_kk': titleKk,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? titleRu,
    Value<String>? titleKk,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      titleRu: titleRu ?? this.titleRu,
      titleKk: titleKk ?? this.titleKk,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titleRu.present) {
      map['title_ru'] = Variable<String>(titleRu.value);
    }
    if (titleKk.present) {
      map['title_kk'] = Variable<String>(titleKk.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('titleRu: $titleRu, ')
          ..write('titleKk: $titleKk, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _ruMeta = const VerificationMeta('ru');
  @override
  late final GeneratedColumn<String> ru = GeneratedColumn<String>(
    'ru',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kkMeta = const VerificationMeta('kk');
  @override
  late final GeneratedColumn<String> kk = GeneratedColumn<String>(
    'kk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    ru,
    kk,
    note,
    sortOrder,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('ru')) {
      context.handle(_ruMeta, ru.isAcceptableOrUnknown(data['ru']!, _ruMeta));
    } else if (isInserting) {
      context.missing(_ruMeta);
    }
    if (data.containsKey('kk')) {
      context.handle(_kkMeta, kk.isAcceptableOrUnknown(data['kk']!, _kkMeta));
    } else if (isInserting) {
      context.missing(_kkMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ru, kk},
  ];
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      ru: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ru'],
      )!,
      kk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kk'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String categoryId;
  final String ru;
  final String kk;

  /// Usage hint, e.g. who says this form.
  final String? note;
  final int sortOrder;

  /// Lowercased "ru kk" with ё→е. SQLite's LIKE only folds ASCII case,
  /// so search runs against this column instead of ru/kk.
  final String searchText;
  const Word({
    required this.id,
    required this.categoryId,
    required this.ru,
    required this.kk,
    this.note,
    required this.sortOrder,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['ru'] = Variable<String>(ru);
    map['kk'] = Variable<String>(kk);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      ru: Value(ru),
      kk: Value(kk),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
      searchText: Value(searchText),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      ru: serializer.fromJson<String>(json['ru']),
      kk: serializer.fromJson<String>(json['kk']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'ru': serializer.toJson<String>(ru),
      'kk': serializer.toJson<String>(kk),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  Word copyWith({
    int? id,
    String? categoryId,
    String? ru,
    String? kk,
    Value<String?> note = const Value.absent(),
    int? sortOrder,
    String? searchText,
  }) => Word(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    ru: ru ?? this.ru,
    kk: kk ?? this.kk,
    note: note.present ? note.value : this.note,
    sortOrder: sortOrder ?? this.sortOrder,
    searchText: searchText ?? this.searchText,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      ru: data.ru.present ? data.ru.value : this.ru,
      kk: data.kk.present ? data.kk.value : this.kk,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('ru: $ru, ')
          ..write('kk: $kk, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, ru, kk, note, sortOrder, searchText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.ru == this.ru &&
          other.kk == this.kk &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder &&
          other.searchText == this.searchText);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> categoryId;
  final Value<String> ru;
  final Value<String> kk;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<String> searchText;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.ru = const Value.absent(),
    this.kk = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.searchText = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String categoryId,
    required String ru,
    required String kk,
    this.note = const Value.absent(),
    required int sortOrder,
    required String searchText,
  }) : categoryId = Value(categoryId),
       ru = Value(ru),
       kk = Value(kk),
       sortOrder = Value(sortOrder),
       searchText = Value(searchText);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? categoryId,
    Expression<String>? ru,
    Expression<String>? kk,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<String>? searchText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (ru != null) 'ru': ru,
      if (kk != null) 'kk': kk,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (searchText != null) 'search_text': searchText,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? categoryId,
    Value<String>? ru,
    Value<String>? kk,
    Value<String?>? note,
    Value<int>? sortOrder,
    Value<String>? searchText,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      ru: ru ?? this.ru,
      kk: kk ?? this.kk,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (ru.present) {
      map['ru'] = Variable<String>(ru.value);
    }
    if (kk.present) {
      map['kk'] = Variable<String>(kk.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('ru: $ru, ')
          ..write('kk: $kk, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }
}

class $SentencesTable extends Sentences
    with TableInfo<$SentencesTable, Sentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _ruMeta = const VerificationMeta('ru');
  @override
  late final GeneratedColumn<String> ru = GeneratedColumn<String>(
    'ru',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kkMeta = const VerificationMeta('kk');
  @override
  late final GeneratedColumn<String> kk = GeneratedColumn<String>(
    'kk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, ru, kk];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sentence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('ru')) {
      context.handle(_ruMeta, ru.isAcceptableOrUnknown(data['ru']!, _ruMeta));
    } else if (isInserting) {
      context.missing(_ruMeta);
    }
    if (data.containsKey('kk')) {
      context.handle(_kkMeta, kk.isAcceptableOrUnknown(data['kk']!, _kkMeta));
    } else if (isInserting) {
      context.missing(_kkMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sentence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      ru: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ru'],
      )!,
      kk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kk'],
      )!,
    );
  }

  @override
  $SentencesTable createAlias(String alias) {
    return $SentencesTable(attachedDatabase, alias);
  }
}

class Sentence extends DataClass implements Insertable<Sentence> {
  final int id;
  final String? categoryId;
  final String ru;
  final String kk;
  const Sentence({
    required this.id,
    this.categoryId,
    required this.ru,
    required this.kk,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['ru'] = Variable<String>(ru);
    map['kk'] = Variable<String>(kk);
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      ru: Value(ru),
      kk: Value(kk),
    );
  }

  factory Sentence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sentence(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      ru: serializer.fromJson<String>(json['ru']),
      kk: serializer.fromJson<String>(json['kk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<String?>(categoryId),
      'ru': serializer.toJson<String>(ru),
      'kk': serializer.toJson<String>(kk),
    };
  }

  Sentence copyWith({
    int? id,
    Value<String?> categoryId = const Value.absent(),
    String? ru,
    String? kk,
  }) => Sentence(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    ru: ru ?? this.ru,
    kk: kk ?? this.kk,
  );
  Sentence copyWithCompanion(SentencesCompanion data) {
    return Sentence(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      ru: data.ru.present ? data.ru.value : this.ru,
      kk: data.kk.present ? data.kk.value : this.kk,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sentence(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('ru: $ru, ')
          ..write('kk: $kk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, ru, kk);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sentence &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.ru == this.ru &&
          other.kk == this.kk);
}

class SentencesCompanion extends UpdateCompanion<Sentence> {
  final Value<int> id;
  final Value<String?> categoryId;
  final Value<String> ru;
  final Value<String> kk;
  const SentencesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.ru = const Value.absent(),
    this.kk = const Value.absent(),
  });
  SentencesCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String ru,
    required String kk,
  }) : ru = Value(ru),
       kk = Value(kk);
  static Insertable<Sentence> custom({
    Expression<int>? id,
    Expression<String>? categoryId,
    Expression<String>? ru,
    Expression<String>? kk,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (ru != null) 'ru': ru,
      if (kk != null) 'kk': kk,
    });
  }

  SentencesCompanion copyWith({
    Value<int>? id,
    Value<String?>? categoryId,
    Value<String>? ru,
    Value<String>? kk,
  }) {
    return SentencesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      ru: ru ?? this.ru,
      kk: kk ?? this.kk,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (ru.present) {
      map['ru'] = Variable<String>(ru.value);
    }
    if (kk.present) {
      map['kk'] = Variable<String>(kk.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('ru: $ru, ')
          ..write('kk: $kk')
          ..write(')'))
        .toString();
  }
}

class $WordProgressTable extends WordProgress
    with TableInfo<$WordProgressTable, WordProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LearningStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<LearningStatus>($WordProgressTable.$converterstatus);
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    wordId,
    status,
    correctCount,
    wrongCount,
    lastSeenAt,
    nextReviewAt,
    isFavorite,
    box,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  WordProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordProgressData(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      status: $WordProgressTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
    );
  }

  @override
  $WordProgressTable createAlias(String alias) {
    return $WordProgressTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LearningStatus, int, int> $converterstatus =
      const EnumIndexConverter<LearningStatus>(LearningStatus.values);
}

class WordProgressData extends DataClass
    implements Insertable<WordProgressData> {
  final int wordId;
  final LearningStatus status;
  final int correctCount;
  final int wrongCount;
  final DateTime? lastSeenAt;
  final DateTime? nextReviewAt;
  final bool isFavorite;

  /// Spaced-repetition box (Leitner): 0 = just failed, higher = longer gap.
  final int box;
  const WordProgressData({
    required this.wordId,
    required this.status,
    required this.correctCount,
    required this.wrongCount,
    this.lastSeenAt,
    this.nextReviewAt,
    required this.isFavorite,
    required this.box,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    {
      map['status'] = Variable<int>(
        $WordProgressTable.$converterstatus.toSql(status),
      );
    }
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['box'] = Variable<int>(box);
    return map;
  }

  WordProgressCompanion toCompanion(bool nullToAbsent) {
    return WordProgressCompanion(
      wordId: Value(wordId),
      status: Value(status),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      isFavorite: Value(isFavorite),
      box: Value(box),
    );
  }

  factory WordProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordProgressData(
      wordId: serializer.fromJson<int>(json['wordId']),
      status: $WordProgressTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      box: serializer.fromJson<int>(json['box']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'status': serializer.toJson<int>(
        $WordProgressTable.$converterstatus.toJson(status),
      ),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'box': serializer.toJson<int>(box),
    };
  }

  WordProgressData copyWith({
    int? wordId,
    LearningStatus? status,
    int? correctCount,
    int? wrongCount,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> nextReviewAt = const Value.absent(),
    bool? isFavorite,
    int? box,
  }) => WordProgressData(
    wordId: wordId ?? this.wordId,
    status: status ?? this.status,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    isFavorite: isFavorite ?? this.isFavorite,
    box: box ?? this.box,
  );
  WordProgressData copyWithCompanion(WordProgressCompanion data) {
    return WordProgressData(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      status: data.status.present ? data.status.value : this.status,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      box: data.box.present ? data.box.value : this.box,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordProgressData(')
          ..write('wordId: $wordId, ')
          ..write('status: $status, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('box: $box')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    wordId,
    status,
    correctCount,
    wrongCount,
    lastSeenAt,
    nextReviewAt,
    isFavorite,
    box,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordProgressData &&
          other.wordId == this.wordId &&
          other.status == this.status &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.lastSeenAt == this.lastSeenAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.isFavorite == this.isFavorite &&
          other.box == this.box);
}

class WordProgressCompanion extends UpdateCompanion<WordProgressData> {
  final Value<int> wordId;
  final Value<LearningStatus> status;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> nextReviewAt;
  final Value<bool> isFavorite;
  final Value<int> box;
  const WordProgressCompanion({
    this.wordId = const Value.absent(),
    this.status = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.box = const Value.absent(),
  });
  WordProgressCompanion.insert({
    this.wordId = const Value.absent(),
    this.status = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.box = const Value.absent(),
  });
  static Insertable<WordProgressData> custom({
    Expression<int>? wordId,
    Expression<int>? status,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? nextReviewAt,
    Expression<bool>? isFavorite,
    Expression<int>? box,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (status != null) 'status': status,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (box != null) 'box': box,
    });
  }

  WordProgressCompanion copyWith({
    Value<int>? wordId,
    Value<LearningStatus>? status,
    Value<int>? correctCount,
    Value<int>? wrongCount,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? nextReviewAt,
    Value<bool>? isFavorite,
    Value<int>? box,
  }) {
    return WordProgressCompanion(
      wordId: wordId ?? this.wordId,
      status: status ?? this.status,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      isFavorite: isFavorite ?? this.isFavorite,
      box: box ?? this.box,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $WordProgressTable.$converterstatus.toSql(status.value),
      );
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordProgressCompanion(')
          ..write('wordId: $wordId, ')
          ..write('status: $status, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('box: $box')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDate =
      GeneratedColumn<DateTime>(
        'last_active_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dailyGoalXpMeta = const VerificationMeta(
    'dailyGoalXp',
  );
  @override
  late final GeneratedColumn<int> dailyGoalXp = GeneratedColumn<int>(
    'daily_goal_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _dailyXpMeta = const VerificationMeta(
    'dailyXp',
  );
  @override
  late final GeneratedColumn<int> dailyXp = GeneratedColumn<int>(
    'daily_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyXpDateMeta = const VerificationMeta(
    'dailyXpDate',
  );
  @override
  late final GeneratedColumn<DateTime> dailyXpDate = GeneratedColumn<DateTime>(
    'daily_xp_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quizzesCompletedMeta = const VerificationMeta(
    'quizzesCompleted',
  );
  @override
  late final GeneratedColumn<int> quizzesCompleted = GeneratedColumn<int>(
    'quizzes_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answersCorrectMeta = const VerificationMeta(
    'answersCorrect',
  );
  @override
  late final GeneratedColumn<int> answersCorrect = GeneratedColumn<int>(
    'answers_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answersTotalMeta = const VerificationMeta(
    'answersTotal',
  );
  @override
  late final GeneratedColumn<int> answersTotal = GeneratedColumn<int>(
    'answers_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppThemeMode, int> themeMode =
      GeneratedColumn<int>(
        'theme_mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<AppThemeMode>($UserStatsTable.$converterthemeMode);
  static const VerificationMeta _studySecondsMeta = const VerificationMeta(
    'studySeconds',
  );
  @override
  late final GeneratedColumn<int> studySeconds = GeneratedColumn<int>(
    'study_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(19 * 60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    xp,
    streakDays,
    lastActiveDate,
    dailyGoalXp,
    dailyXp,
    dailyXpDate,
    quizzesCompleted,
    answersCorrect,
    answersTotal,
    themeMode,
    studySeconds,
    onboardingDone,
    bestStreak,
    userName,
    hapticsEnabled,
    reminderEnabled,
    reminderMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal_xp')) {
      context.handle(
        _dailyGoalXpMeta,
        dailyGoalXp.isAcceptableOrUnknown(
          data['daily_goal_xp']!,
          _dailyGoalXpMeta,
        ),
      );
    }
    if (data.containsKey('daily_xp')) {
      context.handle(
        _dailyXpMeta,
        dailyXp.isAcceptableOrUnknown(data['daily_xp']!, _dailyXpMeta),
      );
    }
    if (data.containsKey('daily_xp_date')) {
      context.handle(
        _dailyXpDateMeta,
        dailyXpDate.isAcceptableOrUnknown(
          data['daily_xp_date']!,
          _dailyXpDateMeta,
        ),
      );
    }
    if (data.containsKey('quizzes_completed')) {
      context.handle(
        _quizzesCompletedMeta,
        quizzesCompleted.isAcceptableOrUnknown(
          data['quizzes_completed']!,
          _quizzesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('answers_correct')) {
      context.handle(
        _answersCorrectMeta,
        answersCorrect.isAcceptableOrUnknown(
          data['answers_correct']!,
          _answersCorrectMeta,
        ),
      );
    }
    if (data.containsKey('answers_total')) {
      context.handle(
        _answersTotalMeta,
        answersTotal.isAcceptableOrUnknown(
          data['answers_total']!,
          _answersTotalMeta,
        ),
      );
    }
    if (data.containsKey('study_seconds')) {
      context.handle(
        _studySecondsMeta,
        studySeconds.isAcceptableOrUnknown(
          data['study_seconds']!,
          _studySecondsMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_date'],
      ),
      dailyGoalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_xp'],
      )!,
      dailyXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_xp'],
      )!,
      dailyXpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}daily_xp_date'],
      ),
      quizzesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quizzes_completed'],
      )!,
      answersCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answers_correct'],
      )!,
      answersTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answers_total'],
      )!,
      themeMode: $UserStatsTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      studySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_seconds'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      )!,
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppThemeMode, int, int> $converterthemeMode =
      const EnumIndexConverter<AppThemeMode>(AppThemeMode.values);
}

class UserStat extends DataClass implements Insertable<UserStat> {
  final int id;
  final int xp;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int dailyGoalXp;

  /// XP earned on [dailyXpDate]; reset when a new day starts.
  final int dailyXp;
  final DateTime? dailyXpDate;
  final int quizzesCompleted;
  final int answersCorrect;
  final int answersTotal;
  final AppThemeMode themeMode;

  /// Time spent in lessons, reviews and exams.
  final int studySeconds;

  /// The welcome flow was finished or skipped.
  final bool onboardingDone;

  /// Longest streak ever reached.
  final int bestStreak;

  /// How the app greets the user; null = not set.
  final String? userName;
  final bool hapticsEnabled;
  final bool reminderEnabled;

  /// Daily reminder time, minutes after midnight (19:00 by default).
  final int reminderMinutes;
  const UserStat({
    required this.id,
    required this.xp,
    required this.streakDays,
    this.lastActiveDate,
    required this.dailyGoalXp,
    required this.dailyXp,
    this.dailyXpDate,
    required this.quizzesCompleted,
    required this.answersCorrect,
    required this.answersTotal,
    required this.themeMode,
    required this.studySeconds,
    required this.onboardingDone,
    required this.bestStreak,
    this.userName,
    required this.hapticsEnabled,
    required this.reminderEnabled,
    required this.reminderMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['xp'] = Variable<int>(xp);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate);
    }
    map['daily_goal_xp'] = Variable<int>(dailyGoalXp);
    map['daily_xp'] = Variable<int>(dailyXp);
    if (!nullToAbsent || dailyXpDate != null) {
      map['daily_xp_date'] = Variable<DateTime>(dailyXpDate);
    }
    map['quizzes_completed'] = Variable<int>(quizzesCompleted);
    map['answers_correct'] = Variable<int>(answersCorrect);
    map['answers_total'] = Variable<int>(answersTotal);
    {
      map['theme_mode'] = Variable<int>(
        $UserStatsTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['study_seconds'] = Variable<int>(studySeconds);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['best_streak'] = Variable<int>(bestStreak);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_minutes'] = Variable<int>(reminderMinutes);
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      id: Value(id),
      xp: Value(xp),
      streakDays: Value(streakDays),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
      dailyGoalXp: Value(dailyGoalXp),
      dailyXp: Value(dailyXp),
      dailyXpDate: dailyXpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyXpDate),
      quizzesCompleted: Value(quizzesCompleted),
      answersCorrect: Value(answersCorrect),
      answersTotal: Value(answersTotal),
      themeMode: Value(themeMode),
      studySeconds: Value(studySeconds),
      onboardingDone: Value(onboardingDone),
      bestStreak: Value(bestStreak),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      hapticsEnabled: Value(hapticsEnabled),
      reminderEnabled: Value(reminderEnabled),
      reminderMinutes: Value(reminderMinutes),
    );
  }

  factory UserStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStat(
      id: serializer.fromJson<int>(json['id']),
      xp: serializer.fromJson<int>(json['xp']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastActiveDate: serializer.fromJson<DateTime?>(json['lastActiveDate']),
      dailyGoalXp: serializer.fromJson<int>(json['dailyGoalXp']),
      dailyXp: serializer.fromJson<int>(json['dailyXp']),
      dailyXpDate: serializer.fromJson<DateTime?>(json['dailyXpDate']),
      quizzesCompleted: serializer.fromJson<int>(json['quizzesCompleted']),
      answersCorrect: serializer.fromJson<int>(json['answersCorrect']),
      answersTotal: serializer.fromJson<int>(json['answersTotal']),
      themeMode: $UserStatsTable.$converterthemeMode.fromJson(
        serializer.fromJson<int>(json['themeMode']),
      ),
      studySeconds: serializer.fromJson<int>(json['studySeconds']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      userName: serializer.fromJson<String?>(json['userName']),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderMinutes: serializer.fromJson<int>(json['reminderMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'xp': serializer.toJson<int>(xp),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastActiveDate': serializer.toJson<DateTime?>(lastActiveDate),
      'dailyGoalXp': serializer.toJson<int>(dailyGoalXp),
      'dailyXp': serializer.toJson<int>(dailyXp),
      'dailyXpDate': serializer.toJson<DateTime?>(dailyXpDate),
      'quizzesCompleted': serializer.toJson<int>(quizzesCompleted),
      'answersCorrect': serializer.toJson<int>(answersCorrect),
      'answersTotal': serializer.toJson<int>(answersTotal),
      'themeMode': serializer.toJson<int>(
        $UserStatsTable.$converterthemeMode.toJson(themeMode),
      ),
      'studySeconds': serializer.toJson<int>(studySeconds),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'userName': serializer.toJson<String?>(userName),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderMinutes': serializer.toJson<int>(reminderMinutes),
    };
  }

  UserStat copyWith({
    int? id,
    int? xp,
    int? streakDays,
    Value<DateTime?> lastActiveDate = const Value.absent(),
    int? dailyGoalXp,
    int? dailyXp,
    Value<DateTime?> dailyXpDate = const Value.absent(),
    int? quizzesCompleted,
    int? answersCorrect,
    int? answersTotal,
    AppThemeMode? themeMode,
    int? studySeconds,
    bool? onboardingDone,
    int? bestStreak,
    Value<String?> userName = const Value.absent(),
    bool? hapticsEnabled,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) => UserStat(
    id: id ?? this.id,
    xp: xp ?? this.xp,
    streakDays: streakDays ?? this.streakDays,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
    dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
    dailyXp: dailyXp ?? this.dailyXp,
    dailyXpDate: dailyXpDate.present ? dailyXpDate.value : this.dailyXpDate,
    quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
    answersCorrect: answersCorrect ?? this.answersCorrect,
    answersTotal: answersTotal ?? this.answersTotal,
    themeMode: themeMode ?? this.themeMode,
    studySeconds: studySeconds ?? this.studySeconds,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    bestStreak: bestStreak ?? this.bestStreak,
    userName: userName.present ? userName.value : this.userName,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
  );
  UserStat copyWithCompanion(UserStatsCompanion data) {
    return UserStat(
      id: data.id.present ? data.id.value : this.id,
      xp: data.xp.present ? data.xp.value : this.xp,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
      dailyGoalXp: data.dailyGoalXp.present
          ? data.dailyGoalXp.value
          : this.dailyGoalXp,
      dailyXp: data.dailyXp.present ? data.dailyXp.value : this.dailyXp,
      dailyXpDate: data.dailyXpDate.present
          ? data.dailyXpDate.value
          : this.dailyXpDate,
      quizzesCompleted: data.quizzesCompleted.present
          ? data.quizzesCompleted.value
          : this.quizzesCompleted,
      answersCorrect: data.answersCorrect.present
          ? data.answersCorrect.value
          : this.answersCorrect,
      answersTotal: data.answersTotal.present
          ? data.answersTotal.value
          : this.answersTotal,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      studySeconds: data.studySeconds.present
          ? data.studySeconds.value
          : this.studySeconds,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      userName: data.userName.present ? data.userName.value : this.userName,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStat(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('dailyGoalXp: $dailyGoalXp, ')
          ..write('dailyXp: $dailyXp, ')
          ..write('dailyXpDate: $dailyXpDate, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('answersCorrect: $answersCorrect, ')
          ..write('answersTotal: $answersTotal, ')
          ..write('themeMode: $themeMode, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('userName: $userName, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutes: $reminderMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    xp,
    streakDays,
    lastActiveDate,
    dailyGoalXp,
    dailyXp,
    dailyXpDate,
    quizzesCompleted,
    answersCorrect,
    answersTotal,
    themeMode,
    studySeconds,
    onboardingDone,
    bestStreak,
    userName,
    hapticsEnabled,
    reminderEnabled,
    reminderMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStat &&
          other.id == this.id &&
          other.xp == this.xp &&
          other.streakDays == this.streakDays &&
          other.lastActiveDate == this.lastActiveDate &&
          other.dailyGoalXp == this.dailyGoalXp &&
          other.dailyXp == this.dailyXp &&
          other.dailyXpDate == this.dailyXpDate &&
          other.quizzesCompleted == this.quizzesCompleted &&
          other.answersCorrect == this.answersCorrect &&
          other.answersTotal == this.answersTotal &&
          other.themeMode == this.themeMode &&
          other.studySeconds == this.studySeconds &&
          other.onboardingDone == this.onboardingDone &&
          other.bestStreak == this.bestStreak &&
          other.userName == this.userName &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderMinutes == this.reminderMinutes);
}

class UserStatsCompanion extends UpdateCompanion<UserStat> {
  final Value<int> id;
  final Value<int> xp;
  final Value<int> streakDays;
  final Value<DateTime?> lastActiveDate;
  final Value<int> dailyGoalXp;
  final Value<int> dailyXp;
  final Value<DateTime?> dailyXpDate;
  final Value<int> quizzesCompleted;
  final Value<int> answersCorrect;
  final Value<int> answersTotal;
  final Value<AppThemeMode> themeMode;
  final Value<int> studySeconds;
  final Value<bool> onboardingDone;
  final Value<int> bestStreak;
  final Value<String?> userName;
  final Value<bool> hapticsEnabled;
  final Value<bool> reminderEnabled;
  final Value<int> reminderMinutes;
  const UserStatsCompanion({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.dailyGoalXp = const Value.absent(),
    this.dailyXp = const Value.absent(),
    this.dailyXpDate = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.answersCorrect = const Value.absent(),
    this.answersTotal = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.userName = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
  });
  UserStatsCompanion.insert({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.dailyGoalXp = const Value.absent(),
    this.dailyXp = const Value.absent(),
    this.dailyXpDate = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.answersCorrect = const Value.absent(),
    this.answersTotal = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.userName = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
  });
  static Insertable<UserStat> custom({
    Expression<int>? id,
    Expression<int>? xp,
    Expression<int>? streakDays,
    Expression<DateTime>? lastActiveDate,
    Expression<int>? dailyGoalXp,
    Expression<int>? dailyXp,
    Expression<DateTime>? dailyXpDate,
    Expression<int>? quizzesCompleted,
    Expression<int>? answersCorrect,
    Expression<int>? answersTotal,
    Expression<int>? themeMode,
    Expression<int>? studySeconds,
    Expression<bool>? onboardingDone,
    Expression<int>? bestStreak,
    Expression<String>? userName,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (xp != null) 'xp': xp,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
      if (dailyGoalXp != null) 'daily_goal_xp': dailyGoalXp,
      if (dailyXp != null) 'daily_xp': dailyXp,
      if (dailyXpDate != null) 'daily_xp_date': dailyXpDate,
      if (quizzesCompleted != null) 'quizzes_completed': quizzesCompleted,
      if (answersCorrect != null) 'answers_correct': answersCorrect,
      if (answersTotal != null) 'answers_total': answersTotal,
      if (themeMode != null) 'theme_mode': themeMode,
      if (studySeconds != null) 'study_seconds': studySeconds,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (userName != null) 'user_name': userName,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
    });
  }

  UserStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? xp,
    Value<int>? streakDays,
    Value<DateTime?>? lastActiveDate,
    Value<int>? dailyGoalXp,
    Value<int>? dailyXp,
    Value<DateTime?>? dailyXpDate,
    Value<int>? quizzesCompleted,
    Value<int>? answersCorrect,
    Value<int>? answersTotal,
    Value<AppThemeMode>? themeMode,
    Value<int>? studySeconds,
    Value<bool>? onboardingDone,
    Value<int>? bestStreak,
    Value<String?>? userName,
    Value<bool>? hapticsEnabled,
    Value<bool>? reminderEnabled,
    Value<int>? reminderMinutes,
  }) {
    return UserStatsCompanion(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      dailyXp: dailyXp ?? this.dailyXp,
      dailyXpDate: dailyXpDate ?? this.dailyXpDate,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      answersCorrect: answersCorrect ?? this.answersCorrect,
      answersTotal: answersTotal ?? this.answersTotal,
      themeMode: themeMode ?? this.themeMode,
      studySeconds: studySeconds ?? this.studySeconds,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      bestStreak: bestStreak ?? this.bestStreak,
      userName: userName ?? this.userName,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate.value);
    }
    if (dailyGoalXp.present) {
      map['daily_goal_xp'] = Variable<int>(dailyGoalXp.value);
    }
    if (dailyXp.present) {
      map['daily_xp'] = Variable<int>(dailyXp.value);
    }
    if (dailyXpDate.present) {
      map['daily_xp_date'] = Variable<DateTime>(dailyXpDate.value);
    }
    if (quizzesCompleted.present) {
      map['quizzes_completed'] = Variable<int>(quizzesCompleted.value);
    }
    if (answersCorrect.present) {
      map['answers_correct'] = Variable<int>(answersCorrect.value);
    }
    if (answersTotal.present) {
      map['answers_total'] = Variable<int>(answersTotal.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<int>(
        $UserStatsTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (studySeconds.present) {
      map['study_seconds'] = Variable<int>(studySeconds.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('dailyGoalXp: $dailyGoalXp, ')
          ..write('dailyXp: $dailyXp, ')
          ..write('dailyXpDate: $dailyXpDate, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('answersCorrect: $answersCorrect, ')
          ..write('answersTotal: $answersTotal, ')
          ..write('themeMode: $themeMode, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('userName: $userName, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutes: $reminderMinutes')
          ..write(')'))
        .toString();
  }
}

class $UnlockedAchievementsTable extends UnlockedAchievements
    with TableInfo<$UnlockedAchievementsTable, UnlockedAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnlockedAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unlocked_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnlockedAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnlockedAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnlockedAchievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $UnlockedAchievementsTable createAlias(String alias) {
    return $UnlockedAchievementsTable(attachedDatabase, alias);
  }
}

class UnlockedAchievement extends DataClass
    implements Insertable<UnlockedAchievement> {
  final String id;
  final DateTime unlockedAt;
  const UnlockedAchievement({required this.id, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  UnlockedAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UnlockedAchievementsCompanion(
      id: Value(id),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UnlockedAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnlockedAchievement(
      id: serializer.fromJson<String>(json['id']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  UnlockedAchievement copyWith({String? id, DateTime? unlockedAt}) =>
      UnlockedAchievement(
        id: id ?? this.id,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  UnlockedAchievement copyWithCompanion(UnlockedAchievementsCompanion data) {
    return UnlockedAchievement(
      id: data.id.present ? data.id.value : this.id,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievement(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnlockedAchievement &&
          other.id == this.id &&
          other.unlockedAt == this.unlockedAt);
}

class UnlockedAchievementsCompanion
    extends UpdateCompanion<UnlockedAchievement> {
  final Value<String> id;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const UnlockedAchievementsCompanion({
    this.id = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnlockedAchievementsCompanion.insert({
    required String id,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unlockedAt = Value(unlockedAt);
  static Insertable<UnlockedAchievement> custom({
    Expression<String>? id,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnlockedAchievementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return UnlockedAchievementsCompanion(
      id: id ?? this.id,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _lessonIndexMeta = const VerificationMeta(
    'lessonIndex',
  );
  @override
  late final GeneratedColumn<int> lessonIndex = GeneratedColumn<int>(
    'lesson_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    categoryId,
    lessonIndex,
    bestScore,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('lesson_index')) {
      context.handle(
        _lessonIndexMeta,
        lessonIndex.isAcceptableOrUnknown(
          data['lesson_index']!,
          _lessonIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lessonIndexMeta);
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_bestScoreMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId, lessonIndex};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      lessonIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_index'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressData extends DataClass
    implements Insertable<LessonProgressData> {
  final String categoryId;
  final int lessonIndex;

  /// Best result in percent of correct answers.
  final int bestScore;
  final DateTime completedAt;
  const LessonProgressData({
    required this.categoryId,
    required this.lessonIndex,
    required this.bestScore,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['lesson_index'] = Variable<int>(lessonIndex);
    map['best_score'] = Variable<int>(bestScore);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      categoryId: Value(categoryId),
      lessonIndex: Value(lessonIndex),
      bestScore: Value(bestScore),
      completedAt: Value(completedAt),
    );
  }

  factory LessonProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      lessonIndex: serializer.fromJson<int>(json['lessonIndex']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'lessonIndex': serializer.toJson<int>(lessonIndex),
      'bestScore': serializer.toJson<int>(bestScore),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LessonProgressData copyWith({
    String? categoryId,
    int? lessonIndex,
    int? bestScore,
    DateTime? completedAt,
  }) => LessonProgressData(
    categoryId: categoryId ?? this.categoryId,
    lessonIndex: lessonIndex ?? this.lessonIndex,
    bestScore: bestScore ?? this.bestScore,
    completedAt: completedAt ?? this.completedAt,
  );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      lessonIndex: data.lessonIndex.present
          ? data.lessonIndex.value
          : this.lessonIndex,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('categoryId: $categoryId, ')
          ..write('lessonIndex: $lessonIndex, ')
          ..write('bestScore: $bestScore, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(categoryId, lessonIndex, bestScore, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.categoryId == this.categoryId &&
          other.lessonIndex == this.lessonIndex &&
          other.bestScore == this.bestScore &&
          other.completedAt == this.completedAt);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<String> categoryId;
  final Value<int> lessonIndex;
  final Value<int> bestScore;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.categoryId = const Value.absent(),
    this.lessonIndex = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String categoryId,
    required int lessonIndex,
    required int bestScore,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       lessonIndex = Value(lessonIndex),
       bestScore = Value(bestScore),
       completedAt = Value(completedAt);
  static Insertable<LessonProgressData> custom({
    Expression<String>? categoryId,
    Expression<int>? lessonIndex,
    Expression<int>? bestScore,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (lessonIndex != null) 'lesson_index': lessonIndex,
      if (bestScore != null) 'best_score': bestScore,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith({
    Value<String>? categoryId,
    Value<int>? lessonIndex,
    Value<int>? bestScore,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressCompanion(
      categoryId: categoryId ?? this.categoryId,
      lessonIndex: lessonIndex ?? this.lessonIndex,
      bestScore: bestScore ?? this.bestScore,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (lessonIndex.present) {
      map['lesson_index'] = Variable<int>(lessonIndex.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('lessonIndex: $lessonIndex, ')
          ..write('bestScore: $bestScore, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamProgressTable extends ExamProgress
    with TableInfo<$ExamProgressTable, ExamProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passedAtMeta = const VerificationMeta(
    'passedAt',
  );
  @override
  late final GeneratedColumn<DateTime> passedAt = GeneratedColumn<DateTime>(
    'passed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [sectionId, bestScore, passedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_bestScoreMeta);
    }
    if (data.containsKey('passed_at')) {
      context.handle(
        _passedAtMeta,
        passedAt.isAcceptableOrUnknown(data['passed_at']!, _passedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sectionId};
  @override
  ExamProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamProgressData(
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      passedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}passed_at'],
      ),
    );
  }

  @override
  $ExamProgressTable createAlias(String alias) {
    return $ExamProgressTable(attachedDatabase, alias);
  }
}

class ExamProgressData extends DataClass
    implements Insertable<ExamProgressData> {
  final String sectionId;
  final int bestScore;
  final DateTime? passedAt;
  const ExamProgressData({
    required this.sectionId,
    required this.bestScore,
    this.passedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['section_id'] = Variable<String>(sectionId);
    map['best_score'] = Variable<int>(bestScore);
    if (!nullToAbsent || passedAt != null) {
      map['passed_at'] = Variable<DateTime>(passedAt);
    }
    return map;
  }

  ExamProgressCompanion toCompanion(bool nullToAbsent) {
    return ExamProgressCompanion(
      sectionId: Value(sectionId),
      bestScore: Value(bestScore),
      passedAt: passedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(passedAt),
    );
  }

  factory ExamProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamProgressData(
      sectionId: serializer.fromJson<String>(json['sectionId']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      passedAt: serializer.fromJson<DateTime?>(json['passedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sectionId': serializer.toJson<String>(sectionId),
      'bestScore': serializer.toJson<int>(bestScore),
      'passedAt': serializer.toJson<DateTime?>(passedAt),
    };
  }

  ExamProgressData copyWith({
    String? sectionId,
    int? bestScore,
    Value<DateTime?> passedAt = const Value.absent(),
  }) => ExamProgressData(
    sectionId: sectionId ?? this.sectionId,
    bestScore: bestScore ?? this.bestScore,
    passedAt: passedAt.present ? passedAt.value : this.passedAt,
  );
  ExamProgressData copyWithCompanion(ExamProgressCompanion data) {
    return ExamProgressData(
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      passedAt: data.passedAt.present ? data.passedAt.value : this.passedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamProgressData(')
          ..write('sectionId: $sectionId, ')
          ..write('bestScore: $bestScore, ')
          ..write('passedAt: $passedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sectionId, bestScore, passedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamProgressData &&
          other.sectionId == this.sectionId &&
          other.bestScore == this.bestScore &&
          other.passedAt == this.passedAt);
}

class ExamProgressCompanion extends UpdateCompanion<ExamProgressData> {
  final Value<String> sectionId;
  final Value<int> bestScore;
  final Value<DateTime?> passedAt;
  final Value<int> rowid;
  const ExamProgressCompanion({
    this.sectionId = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.passedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamProgressCompanion.insert({
    required String sectionId,
    required int bestScore,
    this.passedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sectionId = Value(sectionId),
       bestScore = Value(bestScore);
  static Insertable<ExamProgressData> custom({
    Expression<String>? sectionId,
    Expression<int>? bestScore,
    Expression<DateTime>? passedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sectionId != null) 'section_id': sectionId,
      if (bestScore != null) 'best_score': bestScore,
      if (passedAt != null) 'passed_at': passedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamProgressCompanion copyWith({
    Value<String>? sectionId,
    Value<int>? bestScore,
    Value<DateTime?>? passedAt,
    Value<int>? rowid,
  }) {
    return ExamProgressCompanion(
      sectionId: sectionId ?? this.sectionId,
      bestScore: bestScore ?? this.bestScore,
      passedAt: passedAt ?? this.passedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (passedAt.present) {
      map['passed_at'] = Variable<DateTime>(passedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamProgressCompanion(')
          ..write('sectionId: $sectionId, ')
          ..write('bestScore: $bestScore, ')
          ..write('passedAt: $passedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyActivityTable extends DailyActivity
    with TableInfo<$DailyActivityTable, DailyActivityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyActivityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionsMeta = const VerificationMeta(
    'sessions',
  );
  @override
  late final GeneratedColumn<int> sessions = GeneratedColumn<int>(
    'sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, xp, seconds, sessions];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_activity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyActivityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('sessions')) {
      context.handle(
        _sessionsMeta,
        sessions.isAcceptableOrUnknown(data['sessions']!, _sessionsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyActivityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyActivityData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
      sessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions'],
      )!,
    );
  }

  @override
  $DailyActivityTable createAlias(String alias) {
    return $DailyActivityTable(attachedDatabase, alias);
  }
}

class DailyActivityData extends DataClass
    implements Insertable<DailyActivityData> {
  /// The day as a UTC date (see dayOf), so DST never splits a day.
  final DateTime day;
  final int xp;
  final int seconds;
  final int sessions;
  const DailyActivityData({
    required this.day,
    required this.xp,
    required this.seconds,
    required this.sessions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['xp'] = Variable<int>(xp);
    map['seconds'] = Variable<int>(seconds);
    map['sessions'] = Variable<int>(sessions);
    return map;
  }

  DailyActivityCompanion toCompanion(bool nullToAbsent) {
    return DailyActivityCompanion(
      day: Value(day),
      xp: Value(xp),
      seconds: Value(seconds),
      sessions: Value(sessions),
    );
  }

  factory DailyActivityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyActivityData(
      day: serializer.fromJson<DateTime>(json['day']),
      xp: serializer.fromJson<int>(json['xp']),
      seconds: serializer.fromJson<int>(json['seconds']),
      sessions: serializer.fromJson<int>(json['sessions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'xp': serializer.toJson<int>(xp),
      'seconds': serializer.toJson<int>(seconds),
      'sessions': serializer.toJson<int>(sessions),
    };
  }

  DailyActivityData copyWith({
    DateTime? day,
    int? xp,
    int? seconds,
    int? sessions,
  }) => DailyActivityData(
    day: day ?? this.day,
    xp: xp ?? this.xp,
    seconds: seconds ?? this.seconds,
    sessions: sessions ?? this.sessions,
  );
  DailyActivityData copyWithCompanion(DailyActivityCompanion data) {
    return DailyActivityData(
      day: data.day.present ? data.day.value : this.day,
      xp: data.xp.present ? data.xp.value : this.xp,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      sessions: data.sessions.present ? data.sessions.value : this.sessions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityData(')
          ..write('day: $day, ')
          ..write('xp: $xp, ')
          ..write('seconds: $seconds, ')
          ..write('sessions: $sessions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, xp, seconds, sessions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyActivityData &&
          other.day == this.day &&
          other.xp == this.xp &&
          other.seconds == this.seconds &&
          other.sessions == this.sessions);
}

class DailyActivityCompanion extends UpdateCompanion<DailyActivityData> {
  final Value<DateTime> day;
  final Value<int> xp;
  final Value<int> seconds;
  final Value<int> sessions;
  final Value<int> rowid;
  const DailyActivityCompanion({
    this.day = const Value.absent(),
    this.xp = const Value.absent(),
    this.seconds = const Value.absent(),
    this.sessions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActivityCompanion.insert({
    required DateTime day,
    this.xp = const Value.absent(),
    this.seconds = const Value.absent(),
    this.sessions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<DailyActivityData> custom({
    Expression<DateTime>? day,
    Expression<int>? xp,
    Expression<int>? seconds,
    Expression<int>? sessions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (xp != null) 'xp': xp,
      if (seconds != null) 'seconds': seconds,
      if (sessions != null) 'sessions': sessions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActivityCompanion copyWith({
    Value<DateTime>? day,
    Value<int>? xp,
    Value<int>? seconds,
    Value<int>? sessions,
    Value<int>? rowid,
  }) {
    return DailyActivityCompanion(
      day: day ?? this.day,
      xp: xp ?? this.xp,
      seconds: seconds ?? this.seconds,
      sessions: sessions ?? this.sessions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (sessions.present) {
      map['sessions'] = Variable<int>(sessions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityCompanion(')
          ..write('day: $day, ')
          ..write('xp: $xp, ')
          ..write('seconds: $seconds, ')
          ..write('sessions: $sessions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  late final $WordProgressTable wordProgress = $WordProgressTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  late final $UnlockedAchievementsTable unlockedAchievements =
      $UnlockedAchievementsTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  late final $ExamProgressTable examProgress = $ExamProgressTable(this);
  late final $DailyActivityTable dailyActivity = $DailyActivityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    words,
    sentences,
    wordProgress,
    userStats,
    unlockedAchievements,
    lessonProgress,
    examProgress,
    dailyActivity,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String titleRu,
  required String titleKk,
  required String icon,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> titleRu,
  Value<String> titleKk,
  Value<String> icon,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: 'categories__id__words__category_id',
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SentencesTable, List<Sentence>>
  _sentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentences,
    aliasName: 'categories__id__sentences__category_id',
  );

  $$SentencesTableProcessedTableManager get sentencesRefs {
    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LessonProgressTable, List<LessonProgressData>>
  _lessonProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lessonProgress,
    aliasName: 'categories__id__lesson_progress__category_id',
  );

  $$LessonProgressTableProcessedTableManager get lessonProgressRefs {
    final manager = $$LessonProgressTableTableManager(
      $_db,
      $_db.lessonProgress,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lessonProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleRu => $composableBuilder(
    column: $table.titleRu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleKk => $composableBuilder(
    column: $table.titleKk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sentencesRefs(
    Expression<bool> Function($$SentencesTableFilterComposer f) f,
  ) {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonProgressRefs(
    Expression<bool> Function($$LessonProgressTableFilterComposer f) f,
  ) {
    final $$LessonProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonProgress,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonProgressTableFilterComposer(
            $db: $db,
            $table: $db.lessonProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleRu => $composableBuilder(
    column: $table.titleRu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleKk => $composableBuilder(
    column: $table.titleKk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleRu =>
      $composableBuilder(column: $table.titleRu, builder: (column) => column);

  GeneratedColumn<String> get titleKk =>
      $composableBuilder(column: $table.titleKk, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sentencesRefs<T extends Object>(
    Expression<T> Function($$SentencesTableAnnotationComposer a) f,
  ) {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lessonProgressRefs<T extends Object>(
    Expression<T> Function($$LessonProgressTableAnnotationComposer a) f,
  ) {
    final $$LessonProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonProgress,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.lessonProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool wordsRefs,
            bool sentencesRefs,
            bool lessonProgressRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> titleRu = const Value.absent(),
                Value<String> titleKk = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                titleRu: titleRu,
                titleKk: titleKk,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String titleRu,
                required String titleKk,
                required String icon,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                titleRu: titleRu,
                titleKk: titleKk,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordsRefs = false,
                sentencesRefs = false,
                lessonProgressRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordsRefs) db.words,
                    if (sentencesRefs) db.sentences,
                    if (lessonProgressRefs) db.lessonProgress,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordsRefs)
                        await $_getPrefetchedDataByColumns<
                          Category,
                          $CategoriesTable,
                          Word,
                          $WordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._wordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).wordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (sentencesRefs)
                        await $_getPrefetchedDataByColumns<
                          Category,
                          $CategoriesTable,
                          Sentence,
                          $SentencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._sentencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).sentencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (lessonProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Category,
                          $CategoriesTable,
                          LessonProgressData,
                          $LessonProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._lessonProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).lessonProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool wordsRefs,
        bool sentencesRefs,
        bool lessonProgressRefs,
      })
    >;
typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String categoryId,
  required String ru,
  required String kk,
  Value<String?> note,
  required int sortOrder,
  required String searchText,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> categoryId,
  Value<String> ru,
  Value<String> kk,
  Value<String?> note,
  Value<int> sortOrder,
  Value<String> searchText,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('words__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WordProgressTable, List<WordProgressData>>
  _wordProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordProgress,
    aliasName: 'words__id__word_progress__word_id',
  );

  $$WordProgressTableProcessedTableManager get wordProgressRefs {
    final manager = $$WordProgressTableTableManager(
      $_db,
      $_db.wordProgress,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ru => $composableBuilder(
    column: $table.ru,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kk => $composableBuilder(
    column: $table.kk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> wordProgressRefs(
    Expression<bool> Function($$WordProgressTableFilterComposer f) f,
  ) {
    final $$WordProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordProgress,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordProgressTableFilterComposer(
            $db: $db,
            $table: $db.wordProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ru => $composableBuilder(
    column: $table.ru,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kk => $composableBuilder(
    column: $table.kk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ru =>
      $composableBuilder(column: $table.ru, builder: (column) => column);

  GeneratedColumn<String> get kk =>
      $composableBuilder(column: $table.kk, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> wordProgressRefs<T extends Object>(
    Expression<T> Function($$WordProgressTableAnnotationComposer a) f,
  ) {
    final $$WordProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordProgress,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.wordProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool categoryId, bool wordProgressRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> ru = const Value.absent(),
                Value<String> kk = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> searchText = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                categoryId: categoryId,
                ru: ru,
                kk: kk,
                note: note,
                sortOrder: sortOrder,
                searchText: searchText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String categoryId,
                required String ru,
                required String kk,
                Value<String?> note = const Value.absent(),
                required int sortOrder,
                required String searchText,
              }) => WordsCompanion.insert(
                id: id,
                categoryId: categoryId,
                ru: ru,
                kk: kk,
                note: note,
                sortOrder: sortOrder,
                searchText: searchText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, Word>(table),
                  $$WordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, wordProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordProgressRefs) db.wordProgress,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$WordsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$WordsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Word,
                          $WordsTable,
                          WordProgressData,
                          $WordProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'word_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool categoryId, bool wordProgressRefs})
    >;
typedef $$SentencesTableCreateCompanionBuilder = SentencesCompanion Function({
  Value<int> id,
  Value<String?> categoryId,
  required String ru,
  required String kk,
});
typedef $$SentencesTableUpdateCompanionBuilder = SentencesCompanion Function({
  Value<int> id,
  Value<String?> categoryId,
  Value<String> ru,
  Value<String> kk,
});

final class $$SentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SentencesTable, Sentence> {
  $$SentencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('sentences__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ru => $composableBuilder(
    column: $table.ru,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kk => $composableBuilder(
    column: $table.kk,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ru => $composableBuilder(
    column: $table.ru,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kk => $composableBuilder(
    column: $table.kk,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ru =>
      $composableBuilder(column: $table.ru, builder: (column) => column);

  GeneratedColumn<String> get kk =>
      $composableBuilder(column: $table.kk, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencesTable,
          Sentence,
          $$SentencesTableFilterComposer,
          $$SentencesTableOrderingComposer,
          $$SentencesTableAnnotationComposer,
          $$SentencesTableCreateCompanionBuilder,
          $$SentencesTableUpdateCompanionBuilder,
          (Sentence, $$SentencesTableReferences),
          Sentence,
          PrefetchHooks Function({bool categoryId})
        > {
  $$SentencesTableTableManager(_$AppDatabase db, $SentencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> ru = const Value.absent(),
                Value<String> kk = const Value.absent(),
              }) => SentencesCompanion(
                id: id,
                categoryId: categoryId,
                ru: ru,
                kk: kk,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String ru,
                required String kk,
              }) => SentencesCompanion.insert(
                id: id,
                categoryId: categoryId,
                ru: ru,
                kk: kk,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SentencesTable, Sentence>(table),
                  $$SentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$SentencesTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$SentencesTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencesTable,
      Sentence,
      $$SentencesTableFilterComposer,
      $$SentencesTableOrderingComposer,
      $$SentencesTableAnnotationComposer,
      $$SentencesTableCreateCompanionBuilder,
      $$SentencesTableUpdateCompanionBuilder,
      (Sentence, $$SentencesTableReferences),
      Sentence,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$WordProgressTableCreateCompanionBuilder =
    WordProgressCompanion Function({
      Value<int> wordId,
      Value<LearningStatus> status,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> nextReviewAt,
      Value<bool> isFavorite,
      Value<int> box,
    });
typedef $$WordProgressTableUpdateCompanionBuilder =
    WordProgressCompanion Function({
      Value<int> wordId,
      Value<LearningStatus> status,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> nextReviewAt,
      Value<bool> isFavorite,
      Value<int> box,
    });

final class $$WordProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $WordProgressTable, WordProgressData> {
  $$WordProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_progress__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordProgressTableFilterComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LearningStatus, LearningStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LearningStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordProgressTable,
          WordProgressData,
          $$WordProgressTableFilterComposer,
          $$WordProgressTableOrderingComposer,
          $$WordProgressTableAnnotationComposer,
          $$WordProgressTableCreateCompanionBuilder,
          $$WordProgressTableUpdateCompanionBuilder,
          (WordProgressData, $$WordProgressTableReferences),
          WordProgressData,
          PrefetchHooks Function({bool wordId})
        > {
  $$WordProgressTableTableManager(_$AppDatabase db, $WordProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<LearningStatus> status = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> box = const Value.absent(),
              }) => WordProgressCompanion(
                wordId: wordId,
                status: status,
                correctCount: correctCount,
                wrongCount: wrongCount,
                lastSeenAt: lastSeenAt,
                nextReviewAt: nextReviewAt,
                isFavorite: isFavorite,
                box: box,
              ),
          createCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<LearningStatus> status = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> box = const Value.absent(),
              }) => WordProgressCompanion.insert(
                wordId: wordId,
                status: status,
                correctCount: correctCount,
                wrongCount: wrongCount,
                lastSeenAt: lastSeenAt,
                nextReviewAt: nextReviewAt,
                isFavorite: isFavorite,
                box: box,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordProgressTable, WordProgressData>(table),
                  $$WordProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$WordProgressTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$WordProgressTableReferences
                            ._wordIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordProgressTable,
      WordProgressData,
      $$WordProgressTableFilterComposer,
      $$WordProgressTableOrderingComposer,
      $$WordProgressTableAnnotationComposer,
      $$WordProgressTableCreateCompanionBuilder,
      $$WordProgressTableUpdateCompanionBuilder,
      (WordProgressData, $$WordProgressTableReferences),
      WordProgressData,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$UserStatsTableCreateCompanionBuilder = UserStatsCompanion Function({
  Value<int> id,
  Value<int> xp,
  Value<int> streakDays,
  Value<DateTime?> lastActiveDate,
  Value<int> dailyGoalXp,
  Value<int> dailyXp,
  Value<DateTime?> dailyXpDate,
  Value<int> quizzesCompleted,
  Value<int> answersCorrect,
  Value<int> answersTotal,
  Value<AppThemeMode> themeMode,
  Value<int> studySeconds,
  Value<bool> onboardingDone,
  Value<int> bestStreak,
  Value<String?> userName,
  Value<bool> hapticsEnabled,
  Value<bool> reminderEnabled,
  Value<int> reminderMinutes,
});
typedef $$UserStatsTableUpdateCompanionBuilder = UserStatsCompanion Function({
  Value<int> id,
  Value<int> xp,
  Value<int> streakDays,
  Value<DateTime?> lastActiveDate,
  Value<int> dailyGoalXp,
  Value<int> dailyXp,
  Value<DateTime?> dailyXpDate,
  Value<int> quizzesCompleted,
  Value<int> answersCorrect,
  Value<int> answersTotal,
  Value<AppThemeMode> themeMode,
  Value<int> studySeconds,
  Value<bool> onboardingDone,
  Value<int> bestStreak,
  Value<String?> userName,
  Value<bool> hapticsEnabled,
  Value<bool> reminderEnabled,
  Value<int> reminderMinutes,
});

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalXp => $composableBuilder(
    column: $table.dailyGoalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyXp => $composableBuilder(
    column: $table.dailyXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dailyXpDate => $composableBuilder(
    column: $table.dailyXpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answersCorrect => $composableBuilder(
    column: $table.answersCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answersTotal => $composableBuilder(
    column: $table.answersTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppThemeMode, AppThemeMode, int>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalXp => $composableBuilder(
    column: $table.dailyGoalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyXp => $composableBuilder(
    column: $table.dailyXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dailyXpDate => $composableBuilder(
    column: $table.dailyXpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answersCorrect => $composableBuilder(
    column: $table.answersCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answersTotal => $composableBuilder(
    column: $table.answersTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalXp => $composableBuilder(
    column: $table.dailyGoalXp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyXp =>
      $composableBuilder(column: $table.dailyXp, builder: (column) => column);

  GeneratedColumn<DateTime> get dailyXpDate => $composableBuilder(
    column: $table.dailyXpDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answersCorrect => $composableBuilder(
    column: $table.answersCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answersTotal => $composableBuilder(
    column: $table.answersTotal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AppThemeMode, int> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );
}

class $$UserStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserStatsTable,
          UserStat,
          $$UserStatsTableFilterComposer,
          $$UserStatsTableOrderingComposer,
          $$UserStatsTableAnnotationComposer,
          $$UserStatsTableCreateCompanionBuilder,
          $$UserStatsTableUpdateCompanionBuilder,
          (UserStat, BaseReferences<_$AppDatabase, $UserStatsTable, UserStat>),
          UserStat,
          PrefetchHooks Function()
        > {
  $$UserStatsTableTableManager(_$AppDatabase db, $UserStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                Value<int> dailyGoalXp = const Value.absent(),
                Value<int> dailyXp = const Value.absent(),
                Value<DateTime?> dailyXpDate = const Value.absent(),
                Value<int> quizzesCompleted = const Value.absent(),
                Value<int> answersCorrect = const Value.absent(),
                Value<int> answersTotal = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
              }) => UserStatsCompanion(
                id: id,
                xp: xp,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                dailyGoalXp: dailyGoalXp,
                dailyXp: dailyXp,
                dailyXpDate: dailyXpDate,
                quizzesCompleted: quizzesCompleted,
                answersCorrect: answersCorrect,
                answersTotal: answersTotal,
                themeMode: themeMode,
                studySeconds: studySeconds,
                onboardingDone: onboardingDone,
                bestStreak: bestStreak,
                userName: userName,
                hapticsEnabled: hapticsEnabled,
                reminderEnabled: reminderEnabled,
                reminderMinutes: reminderMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                Value<int> dailyGoalXp = const Value.absent(),
                Value<int> dailyXp = const Value.absent(),
                Value<DateTime?> dailyXpDate = const Value.absent(),
                Value<int> quizzesCompleted = const Value.absent(),
                Value<int> answersCorrect = const Value.absent(),
                Value<int> answersTotal = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
              }) => UserStatsCompanion.insert(
                id: id,
                xp: xp,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                dailyGoalXp: dailyGoalXp,
                dailyXp: dailyXp,
                dailyXpDate: dailyXpDate,
                quizzesCompleted: quizzesCompleted,
                answersCorrect: answersCorrect,
                answersTotal: answersTotal,
                themeMode: themeMode,
                studySeconds: studySeconds,
                onboardingDone: onboardingDone,
                bestStreak: bestStreak,
                userName: userName,
                hapticsEnabled: hapticsEnabled,
                reminderEnabled: reminderEnabled,
                reminderMinutes: reminderMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserStatsTable, UserStat>(table),
                  BaseReferences<_$AppDatabase, $UserStatsTable, UserStat>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserStatsTable,
      UserStat,
      $$UserStatsTableFilterComposer,
      $$UserStatsTableOrderingComposer,
      $$UserStatsTableAnnotationComposer,
      $$UserStatsTableCreateCompanionBuilder,
      $$UserStatsTableUpdateCompanionBuilder,
      (UserStat, BaseReferences<_$AppDatabase, $UserStatsTable, UserStat>),
      UserStat,
      PrefetchHooks Function()
    >;
typedef $$UnlockedAchievementsTableCreateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      required String id,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$UnlockedAchievementsTableUpdateCompanionBuilder =
    UnlockedAchievementsCompanion Function({
      Value<String> id,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$UnlockedAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnlockedAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnlockedAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$UnlockedAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievement,
          $$UnlockedAchievementsTableFilterComposer,
          $$UnlockedAchievementsTableOrderingComposer,
          $$UnlockedAchievementsTableAnnotationComposer,
          $$UnlockedAchievementsTableCreateCompanionBuilder,
          $$UnlockedAchievementsTableUpdateCompanionBuilder,
          (
            UnlockedAchievement,
            BaseReferences<
              _$AppDatabase,
              $UnlockedAchievementsTable,
              UnlockedAchievement
            >,
          ),
          UnlockedAchievement,
          PrefetchHooks Function()
        > {
  $$UnlockedAchievementsTableTableManager(
    _$AppDatabase db,
    $UnlockedAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnlockedAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnlockedAchievementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnlockedAchievementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion(
                id: id,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion.insert(
                id: id,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnlockedAchievementsTable, UnlockedAchievement>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $UnlockedAchievementsTable,
                    UnlockedAchievement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnlockedAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnlockedAchievementsTable,
      UnlockedAchievement,
      $$UnlockedAchievementsTableFilterComposer,
      $$UnlockedAchievementsTableOrderingComposer,
      $$UnlockedAchievementsTableAnnotationComposer,
      $$UnlockedAchievementsTableCreateCompanionBuilder,
      $$UnlockedAchievementsTableUpdateCompanionBuilder,
      (
        UnlockedAchievement,
        BaseReferences<
          _$AppDatabase,
          $UnlockedAchievementsTable,
          UnlockedAchievement
        >,
      ),
      UnlockedAchievement,
      PrefetchHooks Function()
    >;
typedef $$LessonProgressTableCreateCompanionBuilder =
    LessonProgressCompanion Function({
      required String categoryId,
      required int lessonIndex,
      required int bestScore,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressTableUpdateCompanionBuilder =
    LessonProgressCompanion Function({
      Value<String> categoryId,
      Value<int> lessonIndex,
      Value<int> bestScore,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

final class $$LessonProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressData
        > {
  $$LessonProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('lesson_progress__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lessonIndex => $composableBuilder(
    column: $table.lessonIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lessonIndex => $composableBuilder(
    column: $table.lessonIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lessonIndex => $composableBuilder(
    column: $table.lessonIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressData,
          $$LessonProgressTableFilterComposer,
          $$LessonProgressTableOrderingComposer,
          $$LessonProgressTableAnnotationComposer,
          $$LessonProgressTableCreateCompanionBuilder,
          $$LessonProgressTableUpdateCompanionBuilder,
          (LessonProgressData, $$LessonProgressTableReferences),
          LessonProgressData,
          PrefetchHooks Function({bool categoryId})
        > {
  $$LessonProgressTableTableManager(
    _$AppDatabase db,
    $LessonProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<int> lessonIndex = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion(
                categoryId: categoryId,
                lessonIndex: lessonIndex,
                bestScore: bestScore,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required int lessonIndex,
                required int bestScore,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion.insert(
                categoryId: categoryId,
                lessonIndex: lessonIndex,
                bestScore: bestScore,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonProgressTable, LessonProgressData>(table),
                  $$LessonProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$LessonProgressTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$LessonProgressTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LessonProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTable,
      LessonProgressData,
      $$LessonProgressTableFilterComposer,
      $$LessonProgressTableOrderingComposer,
      $$LessonProgressTableAnnotationComposer,
      $$LessonProgressTableCreateCompanionBuilder,
      $$LessonProgressTableUpdateCompanionBuilder,
      (LessonProgressData, $$LessonProgressTableReferences),
      LessonProgressData,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$ExamProgressTableCreateCompanionBuilder =
    ExamProgressCompanion Function({
      required String sectionId,
      required int bestScore,
      Value<DateTime?> passedAt,
      Value<int> rowid,
    });
typedef $$ExamProgressTableUpdateCompanionBuilder =
    ExamProgressCompanion Function({
      Value<String> sectionId,
      Value<int> bestScore,
      Value<DateTime?> passedAt,
      Value<int> rowid,
    });

class $$ExamProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ExamProgressTable> {
  $$ExamProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get passedAt => $composableBuilder(
    column: $table.passedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamProgressTable> {
  $$ExamProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get passedAt => $composableBuilder(
    column: $table.passedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamProgressTable> {
  $$ExamProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<DateTime> get passedAt =>
      $composableBuilder(column: $table.passedAt, builder: (column) => column);
}

class $$ExamProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamProgressTable,
          ExamProgressData,
          $$ExamProgressTableFilterComposer,
          $$ExamProgressTableOrderingComposer,
          $$ExamProgressTableAnnotationComposer,
          $$ExamProgressTableCreateCompanionBuilder,
          $$ExamProgressTableUpdateCompanionBuilder,
          (
            ExamProgressData,
            BaseReferences<_$AppDatabase, $ExamProgressTable, ExamProgressData>,
          ),
          ExamProgressData,
          PrefetchHooks Function()
        > {
  $$ExamProgressTableTableManager(_$AppDatabase db, $ExamProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sectionId = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<DateTime?> passedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamProgressCompanion(
                sectionId: sectionId,
                bestScore: bestScore,
                passedAt: passedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sectionId,
                required int bestScore,
                Value<DateTime?> passedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamProgressCompanion.insert(
                sectionId: sectionId,
                bestScore: bestScore,
                passedAt: passedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamProgressTable, ExamProgressData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExamProgressTable,
                    ExamProgressData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamProgressTable,
      ExamProgressData,
      $$ExamProgressTableFilterComposer,
      $$ExamProgressTableOrderingComposer,
      $$ExamProgressTableAnnotationComposer,
      $$ExamProgressTableCreateCompanionBuilder,
      $$ExamProgressTableUpdateCompanionBuilder,
      (
        ExamProgressData,
        BaseReferences<_$AppDatabase, $ExamProgressTable, ExamProgressData>,
      ),
      ExamProgressData,
      PrefetchHooks Function()
    >;
typedef $$DailyActivityTableCreateCompanionBuilder =
    DailyActivityCompanion Function({
      required DateTime day,
      Value<int> xp,
      Value<int> seconds,
      Value<int> sessions,
      Value<int> rowid,
    });
typedef $$DailyActivityTableUpdateCompanionBuilder =
    DailyActivityCompanion Function({
      Value<DateTime> day,
      Value<int> xp,
      Value<int> seconds,
      Value<int> sessions,
      Value<int> rowid,
    });

class $$DailyActivityTableFilterComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyActivityTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessions => $composableBuilder(
    column: $table.sessions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyActivityTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyActivityTable> {
  $$DailyActivityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<int> get sessions =>
      $composableBuilder(column: $table.sessions, builder: (column) => column);
}

class $$DailyActivityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyActivityTable,
          DailyActivityData,
          $$DailyActivityTableFilterComposer,
          $$DailyActivityTableOrderingComposer,
          $$DailyActivityTableAnnotationComposer,
          $$DailyActivityTableCreateCompanionBuilder,
          $$DailyActivityTableUpdateCompanionBuilder,
          (
            DailyActivityData,
            BaseReferences<
              _$AppDatabase,
              $DailyActivityTable,
              DailyActivityData
            >,
          ),
          DailyActivityData,
          PrefetchHooks Function()
        > {
  $$DailyActivityTableTableManager(_$AppDatabase db, $DailyActivityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyActivityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyActivityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyActivityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> day = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> sessions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion(
                day: day,
                xp: xp,
                seconds: seconds,
                sessions: sessions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime day,
                Value<int> xp = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> sessions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion.insert(
                day: day,
                xp: xp,
                seconds: seconds,
                sessions: sessions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyActivityTable, DailyActivityData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyActivityTable,
                    DailyActivityData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyActivityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyActivityTable,
      DailyActivityData,
      $$DailyActivityTableFilterComposer,
      $$DailyActivityTableOrderingComposer,
      $$DailyActivityTableAnnotationComposer,
      $$DailyActivityTableCreateCompanionBuilder,
      $$DailyActivityTableUpdateCompanionBuilder,
      (
        DailyActivityData,
        BaseReferences<_$AppDatabase, $DailyActivityTable, DailyActivityData>,
      ),
      DailyActivityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
  $$WordProgressTableTableManager get wordProgress =>
      $$WordProgressTableTableManager(_db, _db.wordProgress);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
  $$UnlockedAchievementsTableTableManager get unlockedAchievements =>
      $$UnlockedAchievementsTableTableManager(_db, _db.unlockedAchievements);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
  $$ExamProgressTableTableManager get examProgress =>
      $$ExamProgressTableTableManager(_db, _db.examProgress);
  $$DailyActivityTableTableManager get dailyActivity =>
      $$DailyActivityTableTableManager(_db, _db.dailyActivity);
}
