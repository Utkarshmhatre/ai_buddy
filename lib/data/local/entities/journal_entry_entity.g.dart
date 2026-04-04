// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJournalEntryEntityCollection on Isar {
  IsarCollection<JournalEntryEntity> get journalEntryEntitys =>
      this.collection();
}

const JournalEntryEntitySchema = CollectionSchema(
  name: r'JournalEntryEntity',
  id: -1787000506116722074,
  properties: {
    r'aiAnalysis': PropertySchema(
      id: 0,
      name: r'aiAnalysis',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dayOfWeek': PropertySchema(
      id: 3,
      name: r'dayOfWeek',
      type: IsarType.long,
    ),
    r'derivedMoodScore': PropertySchema(
      id: 4,
      name: r'derivedMoodScore',
      type: IsarType.long,
    ),
    r'emotions': PropertySchema(
      id: 5,
      name: r'emotions',
      type: IsarType.stringList,
    ),
    r'emotionsJson': PropertySchema(
      id: 6,
      name: r'emotionsJson',
      type: IsarType.string,
    ),
    r'entryId': PropertySchema(
      id: 7,
      name: r'entryId',
      type: IsarType.string,
    ),
    r'entryType': PropertySchema(
      id: 8,
      name: r'entryType',
      type: IsarType.string,
    ),
    r'hasAiAnalysis': PropertySchema(
      id: 9,
      name: r'hasAiAnalysis',
      type: IsarType.bool,
    ),
    r'hourOfDay': PropertySchema(
      id: 10,
      name: r'hourOfDay',
      type: IsarType.long,
    ),
    r'isEncrypted': PropertySchema(
      id: 11,
      name: r'isEncrypted',
      type: IsarType.bool,
    ),
    r'linkedMoodEntryId': PropertySchema(
      id: 12,
      name: r'linkedMoodEntryId',
      type: IsarType.string,
    ),
    r'prompt': PropertySchema(
      id: 13,
      name: r'prompt',
      type: IsarType.string,
    ),
    r'richTextDelta': PropertySchema(
      id: 14,
      name: r'richTextDelta',
      type: IsarType.string,
    ),
    r'themes': PropertySchema(
      id: 15,
      name: r'themes',
      type: IsarType.stringList,
    ),
    r'themesJson': PropertySchema(
      id: 16,
      name: r'themesJson',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'wordCount': PropertySchema(
      id: 18,
      name: r'wordCount',
      type: IsarType.long,
    ),
    r'writingDurationSeconds': PropertySchema(
      id: 19,
      name: r'writingDurationSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _journalEntryEntityEstimateSize,
  serialize: _journalEntryEntitySerialize,
  deserialize: _journalEntryEntityDeserialize,
  deserializeProp: _journalEntryEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'entryId': IndexSchema(
      id: 3733379884318738402,
      name: r'entryId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'entryType': IndexSchema(
      id: -3885772953174845098,
      name: r'entryType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'dayOfWeek': IndexSchema(
      id: -5516657708462385134,
      name: r'dayOfWeek',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dayOfWeek',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'hourOfDay': IndexSchema(
      id: 5889796711003268711,
      name: r'hourOfDay',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hourOfDay',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _journalEntryEntityGetId,
  getLinks: _journalEntryEntityGetLinks,
  attach: _journalEntryEntityAttach,
  version: '3.1.0+1',
);

int _journalEntryEntityEstimateSize(
  JournalEntryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiAnalysis;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.content.length * 3;
  {
    final list = object.emotions;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.emotionsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.entryId.length * 3;
  bytesCount += 3 + object.entryType.length * 3;
  {
    final value = object.linkedMoodEntryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.prompt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.richTextDelta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.themes;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.themesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _journalEntryEntitySerialize(
  JournalEntryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiAnalysis);
  writer.writeString(offsets[1], object.content);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.dayOfWeek);
  writer.writeLong(offsets[4], object.derivedMoodScore);
  writer.writeStringList(offsets[5], object.emotions);
  writer.writeString(offsets[6], object.emotionsJson);
  writer.writeString(offsets[7], object.entryId);
  writer.writeString(offsets[8], object.entryType);
  writer.writeBool(offsets[9], object.hasAiAnalysis);
  writer.writeLong(offsets[10], object.hourOfDay);
  writer.writeBool(offsets[11], object.isEncrypted);
  writer.writeString(offsets[12], object.linkedMoodEntryId);
  writer.writeString(offsets[13], object.prompt);
  writer.writeString(offsets[14], object.richTextDelta);
  writer.writeStringList(offsets[15], object.themes);
  writer.writeString(offsets[16], object.themesJson);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeLong(offsets[18], object.wordCount);
  writer.writeLong(offsets[19], object.writingDurationSeconds);
}

JournalEntryEntity _journalEntryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JournalEntryEntity();
  object.aiAnalysis = reader.readStringOrNull(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.dayOfWeek = reader.readLong(offsets[3]);
  object.derivedMoodScore = reader.readLongOrNull(offsets[4]);
  object.emotions = reader.readStringList(offsets[5]);
  object.emotionsJson = reader.readStringOrNull(offsets[6]);
  object.entryId = reader.readString(offsets[7]);
  object.entryType = reader.readString(offsets[8]);
  object.hasAiAnalysis = reader.readBool(offsets[9]);
  object.hourOfDay = reader.readLong(offsets[10]);
  object.id = id;
  object.isEncrypted = reader.readBool(offsets[11]);
  object.linkedMoodEntryId = reader.readStringOrNull(offsets[12]);
  object.prompt = reader.readStringOrNull(offsets[13]);
  object.richTextDelta = reader.readStringOrNull(offsets[14]);
  object.themes = reader.readStringList(offsets[15]);
  object.themesJson = reader.readStringOrNull(offsets[16]);
  object.updatedAt = reader.readDateTime(offsets[17]);
  object.wordCount = reader.readLong(offsets[18]);
  object.writingDurationSeconds = reader.readLongOrNull(offsets[19]);
  return object;
}

P _journalEntryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringList(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _journalEntryEntityGetId(JournalEntryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _journalEntryEntityGetLinks(
    JournalEntryEntity object) {
  return [];
}

void _journalEntryEntityAttach(
    IsarCollection<dynamic> col, Id id, JournalEntryEntity object) {
  object.id = id;
}

extension JournalEntryEntityByIndex on IsarCollection<JournalEntryEntity> {
  Future<JournalEntryEntity?> getByEntryId(String entryId) {
    return getByIndex(r'entryId', [entryId]);
  }

  JournalEntryEntity? getByEntryIdSync(String entryId) {
    return getByIndexSync(r'entryId', [entryId]);
  }

  Future<bool> deleteByEntryId(String entryId) {
    return deleteByIndex(r'entryId', [entryId]);
  }

  bool deleteByEntryIdSync(String entryId) {
    return deleteByIndexSync(r'entryId', [entryId]);
  }

  Future<List<JournalEntryEntity?>> getAllByEntryId(
      List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'entryId', values);
  }

  List<JournalEntryEntity?> getAllByEntryIdSync(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entryId', values);
  }

  Future<int> deleteAllByEntryId(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entryId', values);
  }

  int deleteAllByEntryIdSync(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entryId', values);
  }

  Future<Id> putByEntryId(JournalEntryEntity object) {
    return putByIndex(r'entryId', object);
  }

  Id putByEntryIdSync(JournalEntryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'entryId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntryId(List<JournalEntryEntity> objects) {
    return putAllByIndex(r'entryId', objects);
  }

  List<Id> putAllByEntryIdSync(List<JournalEntryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entryId', objects, saveLinks: saveLinks);
  }
}

extension JournalEntryEntityQueryWhereSort
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QWhere> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhere>
      anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhere>
      anyDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dayOfWeek'),
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhere>
      anyHourOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hourOfDay'),
      );
    });
  }
}

extension JournalEntryEntityQueryWhere
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QWhereClause> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      entryIdEqualTo(String entryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entryId',
        value: [entryId],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      entryIdNotEqualTo(String entryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryId',
              lower: [],
              upper: [entryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryId',
              lower: [entryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryId',
              lower: [entryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryId',
              lower: [],
              upper: [entryId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      entryTypeEqualTo(String entryType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entryType',
        value: [entryType],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      entryTypeNotEqualTo(String entryType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryType',
              lower: [],
              upper: [entryType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryType',
              lower: [entryType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryType',
              lower: [entryType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryType',
              lower: [],
              upper: [entryType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      dayOfWeekEqualTo(int dayOfWeek) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dayOfWeek',
        value: [dayOfWeek],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      dayOfWeekNotEqualTo(int dayOfWeek) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayOfWeek',
              lower: [],
              upper: [dayOfWeek],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayOfWeek',
              lower: [dayOfWeek],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayOfWeek',
              lower: [dayOfWeek],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dayOfWeek',
              lower: [],
              upper: [dayOfWeek],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      dayOfWeekGreaterThan(
    int dayOfWeek, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dayOfWeek',
        lower: [dayOfWeek],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      dayOfWeekLessThan(
    int dayOfWeek, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dayOfWeek',
        lower: [],
        upper: [dayOfWeek],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      dayOfWeekBetween(
    int lowerDayOfWeek,
    int upperDayOfWeek, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dayOfWeek',
        lower: [lowerDayOfWeek],
        includeLower: includeLower,
        upper: [upperDayOfWeek],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      hourOfDayEqualTo(int hourOfDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hourOfDay',
        value: [hourOfDay],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      hourOfDayNotEqualTo(int hourOfDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hourOfDay',
              lower: [],
              upper: [hourOfDay],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hourOfDay',
              lower: [hourOfDay],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hourOfDay',
              lower: [hourOfDay],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hourOfDay',
              lower: [],
              upper: [hourOfDay],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      hourOfDayGreaterThan(
    int hourOfDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hourOfDay',
        lower: [hourOfDay],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      hourOfDayLessThan(
    int hourOfDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hourOfDay',
        lower: [],
        upper: [hourOfDay],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterWhereClause>
      hourOfDayBetween(
    int lowerHourOfDay,
    int upperHourOfDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hourOfDay',
        lower: [lowerHourOfDay],
        includeLower: includeLower,
        upper: [upperHourOfDay],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension JournalEntryEntityQueryFilter
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QFilterCondition> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiAnalysis',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiAnalysis',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiAnalysis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiAnalysis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysis',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      aiAnalysisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiAnalysis',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      dayOfWeekEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      dayOfWeekGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      dayOfWeekLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      dayOfWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'derivedMoodScore',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'derivedMoodScore',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'derivedMoodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'derivedMoodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'derivedMoodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      derivedMoodScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'derivedMoodScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emotions',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emotions',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emotions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emotions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emotions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotions',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emotions',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emotionsJson',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emotionsJson',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emotionsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emotionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emotionsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      emotionsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emotionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryId',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entryId',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entryType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entryType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryType',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      entryTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entryType',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      hasAiAnalysisEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasAiAnalysis',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      hourOfDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hourOfDay',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      hourOfDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hourOfDay',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      hourOfDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hourOfDay',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      hourOfDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hourOfDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      isEncryptedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEncrypted',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedMoodEntryId',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedMoodEntryId',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedMoodEntryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedMoodEntryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedMoodEntryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedMoodEntryId',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      linkedMoodEntryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedMoodEntryId',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prompt',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prompt',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prompt',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      promptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prompt',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'richTextDelta',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'richTextDelta',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'richTextDelta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'richTextDelta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'richTextDelta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'richTextDelta',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      richTextDeltaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'richTextDelta',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'themes',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'themes',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themes',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themes',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'themesJson',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'themesJson',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      themesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      wordCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      wordCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      wordCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      wordCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'writingDurationSeconds',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'writingDurationSeconds',
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'writingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'writingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'writingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterFilterCondition>
      writingDurationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'writingDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension JournalEntryEntityQueryObject
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QFilterCondition> {}

extension JournalEntryEntityQueryLinks
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QFilterCondition> {}

extension JournalEntryEntityQuerySortBy
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QSortBy> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByDerivedMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'derivedMoodScore', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByDerivedMoodScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'derivedMoodScore', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEmotionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotionsJson', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEmotionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotionsJson', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEntryType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryType', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByEntryTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryType', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByHasAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByHasAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByHourOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourOfDay', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByHourOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourOfDay', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByIsEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByLinkedMoodEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoodEntryId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByLinkedMoodEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoodEntryId', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prompt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prompt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByRichTextDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richTextDelta', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByRichTextDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richTextDelta', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByThemesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themesJson', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByThemesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themesJson', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByWritingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writingDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      sortByWritingDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writingDurationSeconds', Sort.desc);
    });
  }
}

extension JournalEntryEntityQuerySortThenBy
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QSortThenBy> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByDerivedMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'derivedMoodScore', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByDerivedMoodScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'derivedMoodScore', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEmotionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotionsJson', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEmotionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotionsJson', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEntryType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryType', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByEntryTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryType', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByHasAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByHasAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasAiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByHourOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourOfDay', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByHourOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourOfDay', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByIsEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByLinkedMoodEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoodEntryId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByLinkedMoodEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoodEntryId', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prompt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prompt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByRichTextDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richTextDelta', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByRichTextDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richTextDelta', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByThemesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themesJson', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByThemesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themesJson', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByWritingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writingDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QAfterSortBy>
      thenByWritingDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writingDurationSeconds', Sort.desc);
    });
  }
}

extension JournalEntryEntityQueryWhereDistinct
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct> {
  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByAiAnalysis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiAnalysis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayOfWeek');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByDerivedMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'derivedMoodScore');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByEmotions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emotions');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByEmotionsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emotionsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByEntryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByEntryType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByHasAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasAiAnalysis');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByHourOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hourOfDay');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEncrypted');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByLinkedMoodEntryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedMoodEntryId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByPrompt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prompt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByRichTextDelta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'richTextDelta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByThemes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themes');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByThemesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordCount');
    });
  }

  QueryBuilder<JournalEntryEntity, JournalEntryEntity, QDistinct>
      distinctByWritingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'writingDurationSeconds');
    });
  }
}

extension JournalEntryEntityQueryProperty
    on QueryBuilder<JournalEntryEntity, JournalEntryEntity, QQueryProperty> {
  QueryBuilder<JournalEntryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations>
      aiAnalysisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiAnalysis');
    });
  }

  QueryBuilder<JournalEntryEntity, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<JournalEntryEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<JournalEntryEntity, int, QQueryOperations> dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayOfWeek');
    });
  }

  QueryBuilder<JournalEntryEntity, int?, QQueryOperations>
      derivedMoodScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'derivedMoodScore');
    });
  }

  QueryBuilder<JournalEntryEntity, List<String>?, QQueryOperations>
      emotionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emotions');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations>
      emotionsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emotionsJson');
    });
  }

  QueryBuilder<JournalEntryEntity, String, QQueryOperations> entryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryId');
    });
  }

  QueryBuilder<JournalEntryEntity, String, QQueryOperations>
      entryTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryType');
    });
  }

  QueryBuilder<JournalEntryEntity, bool, QQueryOperations>
      hasAiAnalysisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasAiAnalysis');
    });
  }

  QueryBuilder<JournalEntryEntity, int, QQueryOperations> hourOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hourOfDay');
    });
  }

  QueryBuilder<JournalEntryEntity, bool, QQueryOperations>
      isEncryptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEncrypted');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations>
      linkedMoodEntryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedMoodEntryId');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations> promptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prompt');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations>
      richTextDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'richTextDelta');
    });
  }

  QueryBuilder<JournalEntryEntity, List<String>?, QQueryOperations>
      themesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themes');
    });
  }

  QueryBuilder<JournalEntryEntity, String?, QQueryOperations>
      themesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themesJson');
    });
  }

  QueryBuilder<JournalEntryEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<JournalEntryEntity, int, QQueryOperations> wordCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordCount');
    });
  }

  QueryBuilder<JournalEntryEntity, int?, QQueryOperations>
      writingDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'writingDurationSeconds');
    });
  }
}
