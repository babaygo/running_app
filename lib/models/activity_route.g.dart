// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_route.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivityRouteCollection on Isar {
  IsarCollection<ActivityRoute> get activityRoutes => this.collection();
}

const ActivityRouteSchema = CollectionSchema(
  name: r'ActivityRoute',
  id: 7171695319257089491,
  properties: {
    r'activityUuid': PropertySchema(
      id: 0,
      name: r'activityUuid',
      type: IsarType.string,
    ),
    r'points': PropertySchema(
      id: 1,
      name: r'points',
      type: IsarType.objectList,
      target: r'TrackPoint',
    )
  },
  estimateSize: _activityRouteEstimateSize,
  serialize: _activityRouteSerialize,
  deserialize: _activityRouteDeserialize,
  deserializeProp: _activityRouteDeserializeProp,
  idName: r'id',
  indexes: {
    r'activityUuid': IndexSchema(
      id: 3029946748367610537,
      name: r'activityUuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'activityUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'TrackPoint': TrackPointSchema},
  getId: _activityRouteGetId,
  getLinks: _activityRouteGetLinks,
  attach: _activityRouteAttach,
  version: '3.1.0+1',
);

int _activityRouteEstimateSize(
  ActivityRoute object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activityUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.points;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TrackPoint]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TrackPointSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _activityRouteSerialize(
  ActivityRoute object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityUuid);
  writer.writeObjectList<TrackPoint>(
    offsets[1],
    allOffsets,
    TrackPointSchema.serialize,
    object.points,
  );
}

ActivityRoute _activityRouteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivityRoute(
    activityUuid: reader.readStringOrNull(offsets[0]),
    points: reader.readObjectList<TrackPoint>(
      offsets[1],
      TrackPointSchema.deserialize,
      allOffsets,
      TrackPoint(),
    ),
  );
  object.id = id;
  return object;
}

P _activityRouteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<TrackPoint>(
        offset,
        TrackPointSchema.deserialize,
        allOffsets,
        TrackPoint(),
      )) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activityRouteGetId(ActivityRoute object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activityRouteGetLinks(ActivityRoute object) {
  return [];
}

void _activityRouteAttach(
    IsarCollection<dynamic> col, Id id, ActivityRoute object) {
  object.id = id;
}

extension ActivityRouteByIndex on IsarCollection<ActivityRoute> {
  Future<ActivityRoute?> getByActivityUuid(String? activityUuid) {
    return getByIndex(r'activityUuid', [activityUuid]);
  }

  ActivityRoute? getByActivityUuidSync(String? activityUuid) {
    return getByIndexSync(r'activityUuid', [activityUuid]);
  }

  Future<bool> deleteByActivityUuid(String? activityUuid) {
    return deleteByIndex(r'activityUuid', [activityUuid]);
  }

  bool deleteByActivityUuidSync(String? activityUuid) {
    return deleteByIndexSync(r'activityUuid', [activityUuid]);
  }

  Future<List<ActivityRoute?>> getAllByActivityUuid(
      List<String?> activityUuidValues) {
    final values = activityUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'activityUuid', values);
  }

  List<ActivityRoute?> getAllByActivityUuidSync(
      List<String?> activityUuidValues) {
    final values = activityUuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'activityUuid', values);
  }

  Future<int> deleteAllByActivityUuid(List<String?> activityUuidValues) {
    final values = activityUuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'activityUuid', values);
  }

  int deleteAllByActivityUuidSync(List<String?> activityUuidValues) {
    final values = activityUuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'activityUuid', values);
  }

  Future<Id> putByActivityUuid(ActivityRoute object) {
    return putByIndex(r'activityUuid', object);
  }

  Id putByActivityUuidSync(ActivityRoute object, {bool saveLinks = true}) {
    return putByIndexSync(r'activityUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByActivityUuid(List<ActivityRoute> objects) {
    return putAllByIndex(r'activityUuid', objects);
  }

  List<Id> putAllByActivityUuidSync(List<ActivityRoute> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'activityUuid', objects, saveLinks: saveLinks);
  }
}

extension ActivityRouteQueryWhereSort
    on QueryBuilder<ActivityRoute, ActivityRoute, QWhere> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActivityRouteQueryWhere
    on QueryBuilder<ActivityRoute, ActivityRoute, QWhereClause> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause> idBetween(
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

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause>
      activityUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activityUuid',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause>
      activityUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityUuid',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause>
      activityUuidEqualTo(String? activityUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activityUuid',
        value: [activityUuid],
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterWhereClause>
      activityUuidNotEqualTo(String? activityUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityUuid',
              lower: [],
              upper: [activityUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityUuid',
              lower: [activityUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityUuid',
              lower: [activityUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityUuid',
              lower: [],
              upper: [activityUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ActivityRouteQueryFilter
    on QueryBuilder<ActivityRoute, ActivityRoute, QFilterCondition> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityUuid',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityUuid',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      activityUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
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

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'points',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'points',
      ));
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ActivityRouteQueryObject
    on QueryBuilder<ActivityRoute, ActivityRoute, QFilterCondition> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterFilterCondition>
      pointsElement(FilterQuery<TrackPoint> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'points');
    });
  }
}

extension ActivityRouteQueryLinks
    on QueryBuilder<ActivityRoute, ActivityRoute, QFilterCondition> {}

extension ActivityRouteQuerySortBy
    on QueryBuilder<ActivityRoute, ActivityRoute, QSortBy> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy>
      sortByActivityUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityUuid', Sort.asc);
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy>
      sortByActivityUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityUuid', Sort.desc);
    });
  }
}

extension ActivityRouteQuerySortThenBy
    on QueryBuilder<ActivityRoute, ActivityRoute, QSortThenBy> {
  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy>
      thenByActivityUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityUuid', Sort.asc);
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy>
      thenByActivityUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityUuid', Sort.desc);
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityRoute, ActivityRoute, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension ActivityRouteQueryWhereDistinct
    on QueryBuilder<ActivityRoute, ActivityRoute, QDistinct> {
  QueryBuilder<ActivityRoute, ActivityRoute, QDistinct> distinctByActivityUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityUuid', caseSensitive: caseSensitive);
    });
  }
}

extension ActivityRouteQueryProperty
    on QueryBuilder<ActivityRoute, ActivityRoute, QQueryProperty> {
  QueryBuilder<ActivityRoute, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivityRoute, String?, QQueryOperations>
      activityUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityUuid');
    });
  }

  QueryBuilder<ActivityRoute, List<TrackPoint>?, QQueryOperations>
      pointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'points');
    });
  }
}
