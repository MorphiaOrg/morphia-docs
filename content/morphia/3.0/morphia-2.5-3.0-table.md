---
title: "API Changes: Morphia 2.5 to 3.0"
weight: 220
group: "Upgrading"
---

<!--
Document maintenance instructions:
Compare the public, user-facing API changes between Morphia 2.5 and 3.0. Document what these public facing API elements are.
Place the summary introduction and key observations at the top, followed by per-class tables.
Each table row shows only methods that changed — a filled 2.5 column with a blank 3.0 column
means the method was removed; a blank 2.5 column with a filled 3.0 column means it was added;
both columns filled with differing content means the signature or modifiers changed.
Do not include rows where both columns are identical (unchanged methods).
-->

## Introduction

This page compares the public API of Morphia 2.5.3 with 3.0. It lists the types 3.0 removes and adds, and, for each class in both
versions, the public methods that were removed, added or changed. For what to do about these changes, see the
[migration guide](../migrating/). Most of the removals are handled by its upgrade recipe or covered by its manual sections.

How this comparison was made:

- It compares the compiled `morphia-core` 2.5.3 jar with the 3.0 `morphia-core` and `morphia-annotations` jars.
- Only public types and public methods count. Anything marked `@MorphiaInternal`, and anything in an `internal` package, is left
  out, so an element that is now internal shows up as removed.
- The codec packages, `dev.morphia.aggregation.codecs` and `dev.morphia.mapping.codec`, are left out. They hold Morphia's encoding
  machinery rather than API that applications call.
- Signatures use erased types. Types are shown by simple name, except where the simple name is shared by more than one type.
- Each class is compared on the methods it declares. A method that a class now inherits instead of declaring, such as
  `CountOptions.getMaxTime(TimeUnit)` from the driver's `CountOptions`, shows up as removed even though it can still be called.
- A row with both columns filled pairs a removed method with an added one of the same name. That happens when the parameter types
  match exactly and only the return type or modifiers changed, or when it's the only overload with that number of parameters.

## Key observations

**Aggregation:** `Aggregation`'s stage-named methods (`match()`, `group()`, and so on) are gone. Stages are built with their
factories and passed to `pipeline(..)`, and results come from `iterator()` or `toList()`. The 2.x stage factories (`Group.of()`,
`Match.on()`, and so on) are replaced by factories named after the stage, and stage and expression constructors are now internal.
Most expression factories now take `Object` instead of `Expression`, so field names and plain values can be passed directly.

**Queries and updates:** `Query`'s criteria methods, `execute()`, `find()`, `keys()`, and the methods that took a `FindOptions`
are gone. Options go to `Datastore.find(Class, FindOptions)`. `update(..)` and `modify(..)` now run the operation and return
its result instead of an `Update` or `Modify`.

**Datastore:** the legacy query, update and aggregation entry points, and the overloads taking `InsertOptions`, `Iterable` or
`WriteConcern`, are gone. `aggregate(..)` gains overloads that take a target type and `AggregationOptions`.

**Options:** the getters on Morphia's options classes are gone or internal. The options classes are builders.

**Removed packages:** `dev.morphia.geo` (use the driver's GeoJSON types), the pre-2.0 aggregation pipeline, the criteria query
API, `Key`, and `MapperOptions` are all gone.

## Removed types

These 2.5 types have no public counterpart of the same name in 3.0. Where a type with the same simple name exists in another package, it is listed; its API may differ.

| 2.5 type | 3.0 type with the same name |
|---|---|
| `dev.morphia.AbstractEntityInterceptor` (class) |  |
| `dev.morphia.AdvancedDatastore` (interface) |  |
| `dev.morphia.EntityInterceptor` (interface) |  |
| `dev.morphia.FindAndModifyOptions` (class) |  |
| `dev.morphia.InsertOptions` (class) |  |
| `dev.morphia.Key` (class) |  |
| `dev.morphia.aggregation.Accumulator` (class) |  |
| `dev.morphia.aggregation.AggregationPipeline` (interface) |  |
| `dev.morphia.aggregation.AggregationPipelineImpl` (class) |  |
| `dev.morphia.aggregation.GeoNear` (class) | `dev.morphia.aggregation.stages.GeoNear` |
| `dev.morphia.aggregation.GeoNear.GeoNearBuilder` (class) |  |
| `dev.morphia.aggregation.Group` (class) | `dev.morphia.aggregation.stages.Group` |
| `dev.morphia.aggregation.Projection` (class) | `dev.morphia.aggregation.stages.Projection`, `dev.morphia.query.Projection` |
| `dev.morphia.aggregation.expressions.BooleanExpressions.LogicalExpression` (class) | `dev.morphia.aggregation.expressions.impls.LogicalExpression` |
| `dev.morphia.aggregation.expressions.DateExpressions.DateExpression` (class) |  |
| `dev.morphia.aggregation.expressions.ObjectExpressions.MergeObjects` (class) | `dev.morphia.aggregation.expressions.impls.MergeObjects` |
| `dev.morphia.aggregation.expressions.impls.Accumulator` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ArrayExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ArrayFilterExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ArrayLiteral` (class) |  |
| `dev.morphia.aggregation.expressions.impls.EndResultsExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ExpMovingAvg` (class) |  |
| `dev.morphia.aggregation.expressions.impls.FieldHolder` (interface) |  |
| `dev.morphia.aggregation.expressions.impls.Fields` (class) |  |
| `dev.morphia.aggregation.expressions.impls.FunctionExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.LiteralExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.MathExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.MetaExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.NRankedResultsExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.RankedResultsExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ReduceExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ReplaceExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.SetFieldExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.ShiftExpression` (class) |  |
| `dev.morphia.aggregation.expressions.impls.UnsetFieldExpression` (class) |  |
| `dev.morphia.annotations.Converters` (@interface) |  |
| `dev.morphia.annotations.Embedded` (@interface) |  |
| `dev.morphia.annotations.Handler` (@interface) |  |
| `dev.morphia.annotations.NotSaved` (@interface) |  |
| `dev.morphia.annotations.experimental.Constructor` (@interface) |  |
| `dev.morphia.config.ManualMorphiaConfig` (class) |  |
| `dev.morphia.geo.CoordinateReferenceSystem` (abstract class) |  |
| `dev.morphia.geo.CoordinateReferenceSystemType` (enum) |  |
| `dev.morphia.geo.GeoJson` (class) |  |
| `dev.morphia.geo.GeoJsonType` (enum) |  |
| `dev.morphia.geo.Geometry` (interface) |  |
| `dev.morphia.geo.GeometryCollection` (class) |  |
| `dev.morphia.geo.LineString` (class) |  |
| `dev.morphia.geo.MultiLineString` (class) |  |
| `dev.morphia.geo.MultiPoint` (class) |  |
| `dev.morphia.geo.MultiPolygon` (class) |  |
| `dev.morphia.geo.NamedCoordinateReferenceSystem` (class) |  |
| `dev.morphia.geo.NamedCoordinateReferenceSystemConverter` (class) |  |
| `dev.morphia.geo.Point` (class) |  |
| `dev.morphia.geo.PointBuilder` (class) |  |
| `dev.morphia.geo.Polygon` (class) |  |
| `dev.morphia.mapping.InstanceCreatorFactory` (interface) |  |
| `dev.morphia.mapping.MapperOptions` (class) |  |
| `dev.morphia.mapping.MapperOptions.Builder` (class) |  |
| `dev.morphia.mapping.MapperOptions.PropertyDiscovery` (enum) | `dev.morphia.mapping.PropertyDiscovery` |
| `dev.morphia.mapping.experimental.MorphiaReference` (abstract class) |  |
| `dev.morphia.mapping.experimental.MorphiaReferenceCodec` (class) |  |
| `dev.morphia.mapping.lifecycle.OnEntityListenerAdapter` (class) |  |
| `dev.morphia.mapping.validation.classrules.EntityAndEmbed` (class) |  |
| `dev.morphia.mapping.validation.classrules.EntityOrEmbed` (class) |  |
| `dev.morphia.mapping.validation.classrules.MultipleId` (class) |  |
| `dev.morphia.query.AbstractCriteria` (abstract class) |  |
| `dev.morphia.query.AbstractQueryFactory` (abstract class) |  |
| `dev.morphia.query.BucketAutoOptions` (class) |  |
| `dev.morphia.query.BucketAutoOptions.Granularity` (enum) |  |
| `dev.morphia.query.BucketAutoOptions.OutputOperation` (class) |  |
| `dev.morphia.query.BucketOptions` (class) |  |
| `dev.morphia.query.BucketOptions.OutputOperation` (class) |  |
| `dev.morphia.query.CriteriaContainer` (interface) |  |
| `dev.morphia.query.CriteriaJoin` (enum) |  |
| `dev.morphia.query.DefaultQueryFactory` (class) |  |
| `dev.morphia.query.FieldEnd` (interface) |  |
| `dev.morphia.query.FilterOperator` (enum) |  |
| `dev.morphia.query.LegacyQueryFactory` (class) |  |
| `dev.morphia.query.Meta.MetaDataKeyword` (enum) |  |
| `dev.morphia.query.Modify` (class) |  |
| `dev.morphia.query.QueryFactory` (interface) |  |
| `dev.morphia.query.Shape` (class) |  |
| `dev.morphia.query.Update` (class) |  |
| `dev.morphia.query.UpdateOperations` (interface) |  |
| `dev.morphia.query.Updates` (interface) |  |
| `dev.morphia.query.WhereCriteria` (class) |  |
| `dev.morphia.query.filters.LogicalFilter` (class) |  |
| `dev.morphia.query.updates.AddToSetOperator` (class) |  |
| `dev.morphia.utils.IndexDirection` (enum) | `dev.morphia.mapping.IndexDirection` |
| `dev.morphia.utils.IndexType` (enum) | `dev.morphia.mapping.IndexType` |

## Added types

| 3.0 type | Kind |
|---|---|
| `dev.morphia.DocumentNotFoundException` | class |
| `dev.morphia.PostLoadDocumentListener` | interface |
| `dev.morphia.PostLoadListener` | interface |
| `dev.morphia.PostPersistDocumentListener` | interface |
| `dev.morphia.PostPersistListener` | interface |
| `dev.morphia.PreLoadListener` | interface |
| `dev.morphia.PrePersistListener` | interface |
| `dev.morphia.aggregation.expressions.MetadataKeyword` | enum |
| `dev.morphia.aggregation.expressions.impls.CountExpression` | class |
| `dev.morphia.aggregation.expressions.impls.FilterExpression` | class |
| `dev.morphia.aggregation.expressions.impls.GetFieldExpression` | class |
| `dev.morphia.aggregation.expressions.impls.LogicalExpression` | class |
| `dev.morphia.aggregation.expressions.impls.MedianExpression` | class |
| `dev.morphia.aggregation.expressions.impls.MergeObjects` | class |
| `dev.morphia.aggregation.expressions.impls.PercentileExpression` | class |
| `dev.morphia.aggregation.stages.Count` | class |
| `dev.morphia.config.MorphiaPropertyAnnotationProvider` | class |
| `dev.morphia.mapping.IndexDirection` | enum |
| `dev.morphia.mapping.IndexType` | enum |
| `dev.morphia.mapping.MapperType` | enum |
| `dev.morphia.mapping.PropertyDiscovery` | enum |
| `dev.morphia.mapping.conventions.MappingConvention` | interface |
| `dev.morphia.mapping.discriminator.ClassNameDiscriminator` | class |
| `dev.morphia.mapping.discriminator.LowerClassNameDiscriminator` | class |
| `dev.morphia.mapping.discriminator.LowerSimpleNameDiscriminator` | class |
| `dev.morphia.mapping.discriminator.SimpleNameDiscriminator` | class |
| `dev.morphia.mapping.strategy.Title` | class |
| `dev.morphia.mapping.validation.classrules.EntityOrExternal` | class |
| `dev.morphia.query.filters.CommentFilter` | class |
| `dev.morphia.query.updates.PushOperator` | class |
| `dev.morphia.query.updates.UpdateOperator` | class |

## Method changes by class

### dev.morphia.Datastore

| 2.5 | 3.0 |
|---|---|
| `Aggregation aggregate(Class)` | `default Aggregation aggregate(Class)` |
| `Aggregation aggregate(String)` | `default Aggregation aggregate(AggregationOptions)` |
|  | `default Aggregation aggregate(Class, AggregationOptions)` |
|  | `default Aggregation aggregate(Class, Class)` |
|  | `Aggregation aggregate(Class, Class, AggregationOptions)` |
| `AggregationPipeline createAggregation(Class)` |  |
| `default Query createQuery(Class)` |  |
| `default UpdateOperations createUpdateOperations(Class)` |  |
| `default DeleteResult delete(Query)` |  |
| `default DeleteResult delete(Query, DeleteOptions)` |  |
| `void enableDocumentValidation()` |  |
| `void ensureCaps()` |  |
| `void ensureIndexes()` |  |
| `default Query find(String, Class)` |  |
|  | `Query find(Class, Document, FindOptions)` |
| `default Object findAndDelete(Query)` |  |
| `default Object findAndDelete(Query, FindAndModifyOptions)` |  |
| `default Object findAndModify(Query, UpdateOperations)` |  |
| `default Object findAndModify(Query, UpdateOperations, FindAndModifyOptions)` |  |
| `default void merge(Object, WriteConcern)` |  |
| `default List save(Iterable)` |  |
| `default Object save(Object, InsertOptions)` |  |
| `default List save(Iterable, InsertOptions)` |  |
| `default UpdateResult update(Query, UpdateOperations)` |  |
| `default UpdateResult update(Query, UpdateOperations, UpdateOptions)` |  |

### dev.morphia.DeleteOptions

| 2.5 | 3.0 |
|---|---|
| `String collection()` |  |
| `boolean isMulti()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.EntityListener

| 2.5 | 3.0 |
|---|---|
| `boolean hasAnnotation(Class)` |  |
| `default void postLoad(Object, Document, Datastore)` |  |
| `default void postLoad(Object, Document, Mapper)` |  |
| `default void postPersist(Object, Document, Datastore)` |  |
| `default void postPersist(Object, Document, Mapper)` |  |
| `default void preLoad(Object, Document, Datastore)` |  |
| `default void preLoad(Object, Document, Mapper)` |  |
| `default void prePersist(Object, Document, Datastore)` |  |
| `default void prePersist(Object, Document, Mapper)` |  |

### dev.morphia.InsertManyOptions

| 2.5 | 3.0 |
|---|---|
| `Boolean bypassDocumentValidation()` |  |
| `String collection()` |  |
| `Boolean getBypassDocumentValidation()` |  |
| `com.mongodb.client.model.InsertManyOptions getOptions()` |  |
| `boolean isOrdered()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.InsertOneOptions

| 2.5 | 3.0 |
|---|---|
| `Boolean getBypassDocumentValidation()` |  |
| `com.mongodb.client.model.InsertOneOptions getOptions()` |  |
| `boolean unsetMissing()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.Morphia

| 2.5 | 3.0 |
|---|---|
| `static Datastore createDatastore(String)` |  |
| `static Datastore createDatastore(MongoClient, String)` |  |
| `static Datastore createDatastore(String, MapperOptions)` |  |
| `static Datastore createDatastore(MongoClient, String, MapperOptions)` |  |

### dev.morphia.UpdateOptions

| 2.5 | 3.0 |
|---|---|
| `String collection()` |  |
| `boolean isMulti()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.aggregation.Aggregation

| 2.5 | 3.0 |
|---|---|
| `Aggregation addFields(AddFields)` |  |
| `Aggregation autoBucket(AutoBucket)` |  |
| `Aggregation bucket(Bucket)` |  |
| `Aggregation changeStream()` |  |
| `Aggregation changeStream(ChangeStream)` |  |
| `Aggregation collStats(CollectionStats)` |  |
| `Aggregation count(String)` |  |
| `Aggregation currentOp(CurrentOp)` |  |
| `Aggregation densify(Densify)` |  |
| `Aggregation documents(DocumentExpression[])` |  |
| `MorphiaCursor execute(Class)` |  |
| `MorphiaCursor execute(Class, AggregationOptions)` |  |
| `Aggregation facet(Facet)` |  |
| `Aggregation fill(Fill)` |  |
| `Aggregation geoNear(dev.morphia.aggregation.stages.GeoNear)` |  |
| `Aggregation graphLookup(GraphLookup)` |  |
| `Aggregation group(dev.morphia.aggregation.stages.Group)` |  |
| `Aggregation indexStats()` |  |
|  | `MorphiaCursor iterator()` |
| `Aggregation limit(long)` |  |
| `Aggregation lookup(Lookup)` |  |
| `Aggregation match(Filter[])` |  |
| `void merge(Merge)` |  |
| `void merge(Merge, AggregationOptions)` |  |
| `void out(Out)` |  |
| `void out(Out, AggregationOptions)` |  |
|  | `default Aggregation pipeline(List)` |
|  | `Aggregation pipeline(Stage[])` |
| `Aggregation planCacheStats()` |  |
| `Aggregation project(dev.morphia.aggregation.stages.Projection)` |  |
| `Aggregation redact(Redact)` |  |
| `Aggregation replaceRoot(ReplaceRoot)` |  |
| `Aggregation replaceWith(ReplaceWith)` |  |
| `Aggregation sample(long)` |  |
| `default Aggregation set(AddFields)` |  |
| `Aggregation set(Set)` |  |
| `Aggregation setWindowFields(SetWindowFields)` |  |
| `Aggregation skip(long)` |  |
| `Aggregation sort(dev.morphia.aggregation.stages.Sort)` |  |
| `Aggregation sortByCount(Expression)` |  |
|  | `default List toList()` |
| `Aggregation unionWith(Class, Stage, Stage[])` |  |
| `Aggregation unionWith(String, Stage, Stage[])` |  |
| `Aggregation unset(Unset)` |  |
| `Aggregation unwind(Unwind)` |  |

### dev.morphia.aggregation.AggregationOptions

| 2.5 | 3.0 |
|---|---|
| `AggregationOptions()` |  |
|  | `static AggregationOptions aggregationOptions()` |
| `boolean allowDiskUse()` |  |
| `int batchSize()` |  |
| `boolean bypassDocumentValidation()` |  |
| `com.mongodb.client.model.Collation collation()` |  |
| `String collection()` |  |
|  | `AggregationOptions comment(String)` |
| `Document hint()` |  |
|  | `AggregationOptions hint(Document)` |
|  | `AggregationOptions let(Document)` |
|  | `AggregationOptions maxAwaitTime(long, TimeUnit)` |
| `long maxTime(TimeUnit)` |  |
|  | `AggregationOptions maxTime(long, TimeUnit)` |
| `long maxTimeMS()` |  |
| `ReadConcern readConcern()` |  |
| `ReadPreference readPreference()` |  |
|  | `AggregationOptions timeoutMode(TimeoutMode)` |
| `String toString()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.aggregation.expressions.AccumulatorExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression addToSet(Expression)` | `static Expression addToSet(Object)` |
| `static Expression avg(Expression, Expression[])` | `static Expression avg(Object, Object[])` |
| `static Expression bottom(Expression, dev.morphia.query.Sort[])` | `static Expression bottom(Object, dev.morphia.query.Sort[])` |
| `static Expression bottomN(Expression, Expression, dev.morphia.query.Sort[])` | `static Expression bottomN(Object, Object, dev.morphia.query.Sort[])` |
|  | `static Expression count()` |
| `static Expression first(Expression)` | `static Expression first(Object)` |
| `static Expression firstN(Expression, Expression)` | `static Expression firstN(Object, Object)` |
| `static Expression function(String, Expression[])` | `static Expression function(String, Object[])` |
| `static Expression last(Expression)` | `static Expression last(Object)` |
| `static Expression lastN(Expression, Expression)` | `static Expression lastN(Object, Object)` |
| `static Expression max(Expression)` |  |
|  | `static Expression max(Object, Object[])` |
| `static Expression maxN(Expression, Expression)` | `static Expression maxN(Object, Object)` |
| `static Expression min(Expression)` |  |
|  | `static Expression min(Object, Object[])` |
| `static Expression minN(Expression, Expression)` | `static Expression minN(Object, Object)` |
| `static Expression push(Expression)` | `static Expression push(Object)` |
| `static Expression stdDevPop(Expression, Expression[])` |  |
| `static Expression stdDevSamp(Expression, Expression[])` |  |
| `static Expression sum(Expression, Expression[])` | `static Expression sum(Object, Object[])` |
| `static Expression top(Expression, dev.morphia.query.Sort[])` | `static Expression top(Object, dev.morphia.query.Sort[])` |
| `static Expression topN(Expression, Expression, dev.morphia.query.Sort[])` | `static Expression topN(Object, Object, dev.morphia.query.Sort[])` |

### dev.morphia.aggregation.expressions.ArrayExpressions

| 2.5 | 3.0 |
|---|---|
| `static ArrayExpression array(Expression[])` |  |
| `static ArrayExpression array(Object[])` | `static Expression array(Object[])` |
| `static Expression arrayToObject(Expression)` | `static Expression arrayToObject(Object)` |
| `static Expression concatArrays(Expression, Expression)` | `static Expression concatArrays(Object, Object[])` |
| `static Expression elementAt(Expression, Expression)` | `static Expression elementAt(Object, Object)` |
| `static ArrayFilterExpression filter(Expression, Expression)` | `static FilterExpression filter(Expression, Expression)` |
| `static Expression in(Expression, Expression)` | `static Expression in(Object, Object)` |
| `static Expression indexOfArray(Expression, Expression)` | `static ArrayIndexExpression indexOfArray(Object, Object)` |
| `static Expression isArray(Expression)` | `static Expression isArray(Object)` |
| `static MapExpression map(Expression, Expression)` | `static MapExpression map(Object, Object)` |
| `static Expression objectToArray(Expression)` | `static Expression objectToArray(Object)` |
|  | `static RangeExpression range(Object, Object)` |
| `static Expression reduce(Expression, Expression, Expression)` | `static Expression reduce(Object, Object, Object)` |
| `static Expression reverseArray(Expression)` | `static Expression reverseArray(Object)` |
| `static Expression size(Expression)` | `static Expression size(Object)` |
| `static Expression slice(Expression, int)` | `static Expression slice(Object, int)` |
| `static Expression sortArray(Expression, dev.morphia.query.Sort[])` | `static Expression sortArray(Object, dev.morphia.query.Sort[])` |
| `static ZipExpression zip(Expression[])` | `static ZipExpression zip(Object[])` |

### dev.morphia.aggregation.expressions.BooleanExpressions

| 2.5 | 3.0 |
|---|---|
| `static dev.morphia.aggregation.expressions.BooleanExpressions.LogicalExpression and()` | `static dev.morphia.aggregation.expressions.impls.LogicalExpression and()` |
| `static dev.morphia.aggregation.expressions.BooleanExpressions.LogicalExpression and(Expression, Expression[])` | `static dev.morphia.aggregation.expressions.impls.LogicalExpression and(Object, Object[])` |
| `static Expression not(Expression)` | `static Expression not(Object)` |
| `static dev.morphia.aggregation.expressions.BooleanExpressions.LogicalExpression or()` | `static dev.morphia.aggregation.expressions.impls.LogicalExpression or()` |
| `static dev.morphia.aggregation.expressions.BooleanExpressions.LogicalExpression or(Expression, Expression[])` | `static dev.morphia.aggregation.expressions.impls.LogicalExpression or(Object, Object[])` |

### dev.morphia.aggregation.expressions.ComparisonExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression cmp(Expression, Expression)` | `static Expression cmp(Object, Object)` |
| `static Expression eq(Expression, Expression)` | `static Expression eq(Object, Object)` |
| `static Expression gt(Expression, Expression)` | `static Expression gt(Object, Object)` |
| `static Expression gte(Expression, Expression)` | `static Expression gte(Object, Object)` |
| `static Expression lt(Expression, Expression)` | `static Expression lt(Object, Object)` |
| `static Expression lte(Expression, Expression)` | `static Expression lte(Object, Object)` |
| `static Expression ne(Expression, Expression)` | `static Expression ne(Object, Object)` |

### dev.morphia.aggregation.expressions.ConditionalExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression condition(Expression, Expression, Expression)` | `static Expression condition(Object, Object, Object)` |

### dev.morphia.aggregation.expressions.DataSizeExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression binarySize(Expression)` | `static Expression binarySize(Object)` |
| `static Expression bsonSize(Expression)` | `static Expression bsonSize(Object)` |

### dev.morphia.aggregation.expressions.DateExpressions

| 2.5 | 3.0 |
|---|---|
| `static DateDeltaExpression dateAdd(Expression, long, TimeUnit)` | `static DateDeltaExpression dateAdd(Object, long, TimeUnit)` |
| `static DateDiffExpression dateDiff(Expression, Expression, TimeUnit)` | `static DateDiffExpression dateDiff(Object, Object, TimeUnit)` |
| `static DateDeltaExpression dateSubtract(Expression, long, TimeUnit)` | `static DateDeltaExpression dateSubtract(Object, long, TimeUnit)` |
| `static DateToParts dateToParts(Expression)` | `static DateToParts dateToParts(Object)` |
| `static DateTruncExpression dateTrunc(Expression, TimeUnit)` | `static DateTruncExpression dateTrunc(Object, TimeUnit)` |
| `static DateExpressions.DateExpression dayOfMonth(Expression)` | `static Expression dayOfMonth(Object)` |
| `static DateExpressions.DateExpression dayOfWeek(Expression)` | `static Expression dayOfWeek(Object)` |
| `static DateExpressions.DateExpression dayOfYear(Expression)` | `static Expression dayOfYear(Object)` |
| `static DateExpressions.DateExpression hour(Expression)` | `static Expression hour(Object)` |
| `static IsoDates isoDayOfWeek(Expression)` | `static IsoDates isoDayOfWeek(Object)` |
| `static IsoDates isoWeek(Expression)` | `static IsoDates isoWeek(Object)` |
| `static IsoDates isoWeekYear(Expression)` | `static IsoDates isoWeekYear(Object)` |
| `static DateExpressions.DateExpression milliseconds(Expression)` | `static Expression milliseconds(Object)` |
| `static DateExpressions.DateExpression minute(Expression)` | `static Expression minute(Object)` |
| `static DateExpressions.DateExpression month(Expression)` | `static Expression month(Object)` |
| `static DateExpressions.DateExpression second(Expression)` | `static Expression second(Object)` |
| `static DateExpressions.DateExpression toDate(Expression)` | `static Expression toDate(Object)` |
| `static Expression tsIncrement(Expression)` | `static Expression tsIncrement(Object)` |
| `static Expression tsSecond(Expression)` | `static Expression tsSecond(Object)` |
| `static DateExpressions.DateExpression week(Expression)` | `static Expression week(Object)` |
| `static DateExpressions.DateExpression year(Expression)` | `static Expression year(Object)` |

### dev.morphia.aggregation.expressions.Expressions

| 2.5 | 3.0 |
|---|---|
| `static DocumentExpression document(String, Expression)` | `static DocumentExpression document(String, Object)` |
| `static Expression field(String)` |  |
|  | `static FilterExpression filter(Object, Object)` |
|  | `static MetaExpression meta(MetadataKeyword)` |
| `static DocumentExpression of()` |  |
| `static ValueExpression value(Object)` |  |
|  | `static Expression wrap(Object)` |
|  | `static List wrap(Object[])` |
|  | `static List wrap(List)` |
|  | `static List wrap(Object, Object[])` |

### dev.morphia.aggregation.expressions.MathExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression abs(Expression)` | `static Expression abs(Object)` |
| `static MathExpression add(Expression, Expression[])` | `static Expression add(Object, Object[])` |
|  | `static Expression bitAnd(Object, Object)` |
|  | `static Expression bitNot(Object)` |
|  | `static Expression bitOr(Object, Object)` |
|  | `static Expression bitXor(Object, Object)` |
| `static Expression ceil(Expression)` | `static Expression ceil(Object)` |
| `static Expression divide(Expression, Expression)` | `static Expression divide(Object, Object)` |
| `static Expression exp(Expression)` | `static Expression exp(Object)` |
| `static Expression floor(Expression)` | `static Expression floor(Object)` |
| `static Expression ln(Expression)` | `static Expression ln(Object)` |
| `static Expression log(Expression, Expression)` | `static Expression log(Object, Object)` |
| `static Expression log10(Expression)` | `static Expression log10(Object)` |
|  | `static Expression median(Object)` |
| `static Expression mod(Expression, Expression)` | `static Expression mod(Object, Object)` |
| `static Expression multiply(Expression, Expression[])` | `static Expression multiply(Object, Object[])` |
|  | `static Expression percentile(Object, List)` |
|  | `static Expression percentile(List, List)` |
| `static Expression pow(Expression, Expression)` | `static Expression pow(Object, Object)` |
| `static Expression round(Expression, Expression)` | `static Expression round(Object, Object)` |
| `static Expression sqrt(Expression)` | `static Expression sqrt(Object)` |
| `static Expression subtract(Expression, Expression)` | `static Expression subtract(Object, Object)` |
|  | `static Expression trunc(Object)` |
| `static Expression trunc(Expression, Expression)` | `static Expression trunc(Object, Object)` |

### dev.morphia.aggregation.expressions.Miscellaneous

| 2.5 | 3.0 |
|---|---|
| `static Expression getField(Expression)` | `static GetFieldExpression getField(Object)` |
| `static Expression getField(String)` | `static GetFieldExpression getField(String)` |
| `static Expression setField(Expression, Object, Expression)` |  |
|  | `static Expression setField(Object, Object, Object)` |
| `static Expression setField(String, Object, Expression)` |  |
| `static Expression unsetField(Expression, Object)` |  |
|  | `static Expression unsetField(Object, Object)` |
| `static Expression unsetField(String, Object)` |  |

### dev.morphia.aggregation.expressions.ObjectExpressions

| 2.5 | 3.0 |
|---|---|
| `static dev.morphia.aggregation.expressions.ObjectExpressions.MergeObjects mergeObjects()` | `static dev.morphia.aggregation.expressions.impls.MergeObjects mergeObjects()` |

### dev.morphia.aggregation.expressions.SetExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression allElementsTrue(Expression, Expression[])` | `static Expression allElementsTrue(Object, Object[])` |
| `static Expression anyElementTrue(Expression, Expression[])` | `static Expression anyElementTrue(Object, Object[])` |
| `static Expression setDifference(Expression, Expression)` | `static Expression setDifference(Object, Object)` |
| `static Expression setEquals(Expression, Expression[])` | `static Expression setEquals(Object, Object[])` |
| `static Expression setIntersection(Expression, Expression[])` | `static Expression setIntersection(Object, Object[])` |
| `static Expression setIsSubset(Expression, Expression)` | `static Expression setIsSubset(Object, Object)` |
| `static Expression setUnion(Expression, Expression[])` | `static Expression setUnion(Object, Object[])` |

### dev.morphia.aggregation.expressions.StringExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression concat(Expression, Expression[])` | `static Expression concat(Object, Object[])` |
| `static IndexExpression indexOfBytes(Expression, Expression)` | `static IndexExpression indexOfBytes(Object, Object)` |
| `static IndexExpression indexOfCP(Expression, Expression)` | `static IndexExpression indexOfCP(Object, Object)` |
| `static TrimExpression ltrim(Expression)` | `static TrimExpression ltrim(Object)` |
| `static RegexExpression regexFind(Expression)` | `static RegexExpression regexFind(Object)` |
| `static RegexExpression regexFindAll(Expression)` | `static RegexExpression regexFindAll(Object)` |
| `static RegexExpression regexMatch(Expression)` | `static RegexExpression regexMatch(Object)` |
| `static Expression replaceAll(Expression, Expression, Expression)` | `static Expression replaceAll(Object, Object, Object)` |
| `static Expression replaceOne(Expression, Expression, Expression)` | `static Expression replaceOne(Object, Object, Object)` |
| `static TrimExpression rtrim(Expression)` | `static TrimExpression rtrim(Object)` |
| `static Expression split(Expression, Expression)` | `static Expression split(Object, Object)` |
| `static Expression strLenBytes(Expression)` | `static Expression strLenBytes(Object)` |
| `static Expression strLenCP(Expression)` | `static Expression strLenCP(Object)` |
| `static Expression strcasecmp(Expression, Expression)` | `static Expression strcasecmp(Object, Object)` |
| `static Expression substr(Expression, int, int)` |  |
| `static Expression substrBytes(Expression, int, int)` |  |
|  | `static Expression substrBytes(Object, int, int)` |
|  | `static Expression substrBytes(Object, Object, Object)` |
| `static Expression substrCP(Expression, int, int)` | `static Expression substrCP(Object, Object, Object)` |
| `static Expression toLower(Expression)` | `static Expression toLower(Object)` |
| `static Expression toString(Expression)` | `static Expression toString(Object)` |
| `static Expression toUpper(Expression)` | `static Expression toUpper(Object)` |
| `static TrimExpression trim(Expression)` | `static TrimExpression trim(Object)` |

### dev.morphia.aggregation.expressions.TrigonometryExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression acos(Expression)` | `static Expression acos(Object)` |
| `static Expression acosh(Expression)` | `static Expression acosh(Object)` |
| `static Expression asin(Expression)` | `static Expression asin(Object)` |
| `static Expression asinh(Expression)` | `static Expression asinh(Object)` |
| `static Expression atan(Expression)` | `static Expression atan(Object)` |
| `static Expression atan2(Expression, Expression)` | `static Expression atan2(Object, Object)` |
| `static Expression atanh(Expression)` | `static Expression atanh(Object)` |
| `static Expression cos(Expression)` | `static Expression cos(Object)` |
| `static Expression cosh(Expression)` | `static Expression cosh(Object)` |
| `static Expression degreesToRadians(Expression)` | `static Expression degreesToRadians(Object)` |
| `static Expression radiansToDegrees(Expression)` | `static Expression radiansToDegrees(Object)` |
| `static Expression sin(Expression)` | `static Expression sin(Object)` |
| `static Expression sinh(Expression)` | `static Expression sinh(Object)` |
| `static Expression tan(Expression)` | `static Expression tan(Object)` |
| `static Expression tanh(Expression)` | `static Expression tanh(Object)` |

### dev.morphia.aggregation.expressions.TypeExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression convert(Expression, ConvertType)` | `static ConvertExpression convert(Object, ConvertType)` |
| `static Expression isNumber(Expression)` | `static Expression isNumber(Object)` |
| `static Expression toBool(Expression)` | `static Expression toBool(Object)` |
| `static Expression toDate(Expression)` | `static Expression toDate(Object)` |
| `static Expression toDecimal(Expression)` | `static Expression toDecimal(Object)` |
| `static Expression toDouble(Expression)` | `static Expression toDouble(Object)` |
| `static Expression toInt(Expression)` | `static Expression toInt(Object)` |
| `static Expression toLong(Expression)` | `static Expression toLong(Object)` |
| `static Expression toObjectId(Expression)` | `static Expression toObjectId(Object)` |
| `static Expression toString(Expression)` | `static Expression toString(Object)` |
|  | `static Expression toUuid(Object)` |
| `static Expression type(Expression)` | `static Expression type(Object)` |

### dev.morphia.aggregation.expressions.WindowExpressions

| 2.5 | 3.0 |
|---|---|
| `static Expression covariancePop(Expression, Expression)` | `static Expression covariancePop(Object, Object)` |
| `static Expression covarianceSamp(Expression, Expression)` | `static Expression covarianceSamp(Object, Object)` |
| `static CalculusExpression derivative(Expression)` | `static CalculusExpression derivative(Object)` |
| `static Expression expMovingAvg(Expression, int)` |  |
|  | `static Expression expMovingAvg(Object, double)` |
|  | `static Expression expMovingAvg(Object, int)` |
| `static CalculusExpression integral(Expression)` | `static CalculusExpression integral(Object)` |
| `static Expression linearFill(Expression)` | `static Expression linearFill(Object)` |
| `static Expression locf(Expression)` | `static Expression locf(Object)` |
|  | `static Expression shift(Object, long)` |
| `static ShiftExpression shift(Expression, long, Expression)` | `static Expression shift(Object, long, Object)` |
| `static Expression stdDevPop(Expression, Expression[])` | `static Expression stdDevPop(Object, Object[])` |
| `static Expression stdDevSamp(Expression, Expression[])` | `static Expression stdDevSamp(Object, Object[])` |

### dev.morphia.aggregation.expressions.impls.AccumulatorExpression

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.ArrayIndexExpression

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.CalculusExpression

| 2.5 | 3.0 |
|---|---|
| `CalculusExpression(String, Expression)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.ConvertExpression

| 2.5 | 3.0 |
|---|---|
| `ConvertExpression(Expression, ConvertType)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `ConvertExpression onError(Expression)` | `ConvertExpression onError(Object)` |
| `ConvertExpression onNull(Expression)` | `ConvertExpression onNull(Object)` |

### dev.morphia.aggregation.expressions.impls.ConvertType

| 2.5 | 3.0 |
|---|---|
| `int getIdentifier()` |  |

### dev.morphia.aggregation.expressions.impls.DateDeltaExpression

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateDeltaExpression timezone(Expression)` | `DateDeltaExpression timezone(Object)` |

### dev.morphia.aggregation.expressions.impls.DateDiffExpression

| 2.5 | 3.0 |
|---|---|
| `DateDiffExpression(Expression, Expression, TimeUnit)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.DateFromParts

| 2.5 | 3.0 |
|---|---|
| `DateFromParts()` |  |
| `DateFromParts day(Expression)` |  |
| `DateFromParts day(int)` |  |
|  | `DateFromParts day(Object)` |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateFromParts hour(Expression)` |  |
| `DateFromParts hour(int)` |  |
|  | `DateFromParts hour(Object)` |
| `DateFromParts isoDayOfWeek(Expression)` |  |
| `DateFromParts isoDayOfWeek(int)` |  |
|  | `DateFromParts isoDayOfWeek(Object)` |
| `DateFromParts isoWeek(Expression)` |  |
| `DateFromParts isoWeek(int)` |  |
|  | `DateFromParts isoWeek(Object)` |
| `DateFromParts isoWeekYear(Expression)` |  |
| `DateFromParts isoWeekYear(int)` |  |
|  | `DateFromParts isoWeekYear(Object)` |
| `DateFromParts millisecond(Expression)` |  |
| `DateFromParts millisecond(int)` |  |
|  | `DateFromParts millisecond(Object)` |
| `DateFromParts minute(Expression)` |  |
| `DateFromParts minute(int)` |  |
|  | `DateFromParts minute(Object)` |
| `DateFromParts month(Expression)` |  |
| `DateFromParts month(int)` |  |
|  | `DateFromParts month(Object)` |
| `DateFromParts second(Expression)` |  |
| `DateFromParts second(int)` |  |
|  | `DateFromParts second(Object)` |
| `DateFromParts timezone(Expression)` |  |
|  | `DateFromParts timezone(Object)` |
| `DateFromParts timezone(String)` |  |
| `DateFromParts year(Expression)` |  |
| `DateFromParts year(int)` |  |
|  | `DateFromParts year(Object)` |

### dev.morphia.aggregation.expressions.impls.DateFromString

| 2.5 | 3.0 |
|---|---|
| `DateFromString()` |  |
| `DateFromString dateString(Expression)` |  |
|  | `DateFromString dateString(Object)` |
| `DateFromString dateString(String)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateFromString format(Expression)` |  |
|  | `DateFromString format(Object)` |
| `DateFromString format(String)` |  |
| `DateFromString onError(Expression)` |  |
|  | `DateFromString onError(Object)` |
| `DateFromString onError(String)` |  |
| `DateFromString onNull(Expression)` |  |
|  | `DateFromString onNull(Object)` |
| `DateFromString onNull(String)` |  |
| `DateFromString timeZone(Expression)` |  |
|  | `DateFromString timeZone(Object)` |
| `DateFromString timeZone(String)` |  |

### dev.morphia.aggregation.expressions.impls.DateToParts

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateToParts timezone(Expression)` | `DateToParts timezone(Object)` |

### dev.morphia.aggregation.expressions.impls.DateToString

| 2.5 | 3.0 |
|---|---|
| `DateToString()` |  |
| `DateToString date(Expression)` |  |
|  | `DateToString date(Object)` |
| `DateToString date(String)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateToString format(Expression)` |  |
|  | `DateToString format(Object)` |
| `DateToString format(String)` |  |
| `DateToString onNull(Expression)` |  |
|  | `DateToString onNull(Object)` |
| `DateToString onNull(String)` |  |
| `DateToString timeZone(Expression)` |  |
|  | `DateToString timeZone(Object)` |
| `DateToString timeZone(String)` |  |

### dev.morphia.aggregation.expressions.impls.DateTruncExpression

| 2.5 | 3.0 |
|---|---|
| `DateTruncExpression(Expression, TimeUnit)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `DateTruncExpression timezone(Expression)` | `DateTruncExpression timezone(Object)` |

### dev.morphia.aggregation.expressions.impls.DocumentExpression

| 2.5 | 3.0 |
|---|---|
| `DocumentExpression()` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `void encode(String, Datastore, BsonWriter, EncoderContext)` |  |
| `DocumentExpression field(String, Expression)` | `DocumentExpression field(String, Object)` |

### dev.morphia.aggregation.expressions.impls.Expression

| 2.5 | 3.0 |
|---|---|
| `Expression(String)` |  |
| `String toString()` |  |

### dev.morphia.aggregation.expressions.impls.IfNull

| 2.5 | 3.0 |
|---|---|
| `IfNull()` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `IfNull field(String, Expression)` | `IfNull field(String, Object)` |
| `DocumentExpression getDocument()` |  |
| `Expression getReplacement()` |  |
| `Expression getTarget()` |  |
|  | `List input()` |
|  | `IfNull input(Object, Object[])` |
| `IfNull replacement(Expression)` | `IfNull replacement(Object)` |
| `IfNull target(Expression)` | `IfNull target(Object)` |

### dev.morphia.aggregation.expressions.impls.IndexExpression

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.IsoDates

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `IsoDates timezone(Expression)` | `IsoDates timezone(Object)` |

### dev.morphia.aggregation.expressions.impls.LetExpression

| 2.5 | 3.0 |
|---|---|
| `LetExpression(Expression)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.MapExpression

| 2.5 | 3.0 |
|---|---|
| `MapExpression(Expression, Expression)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.Push

| 2.5 | 3.0 |
|---|---|
| `Push()` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `Push field(String, Expression)` | `Push field(String, Object)` |
| `Push single(Expression)` | `Push single(Object)` |

### dev.morphia.aggregation.expressions.impls.RangeExpression

| 2.5 | 3.0 |
|---|---|
| `RangeExpression(int, int)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.RegexExpression

| 2.5 | 3.0 |
|---|---|
| `RegexExpression(String, Expression)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.SliceExpression

| 2.5 | 3.0 |
|---|---|
| `SliceExpression(Expression, int)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.SwitchExpression

| 2.5 | 3.0 |
|---|---|
| `SwitchExpression branch(Expression, Expression)` | `SwitchExpression branch(Object, Object)` |
| `SwitchExpression defaultCase(Expression)` | `SwitchExpression defaultCase(Object)` |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.TrimExpression

| 2.5 | 3.0 |
|---|---|
| `TrimExpression(String, Expression)` |  |
| `TrimExpression chars(Expression)` | `TrimExpression chars(String)` |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.expressions.impls.ValueExpression

| 2.5 | 3.0 |
|---|---|
| `ValueExpression(Object)` |  |
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
| `String toString()` |  |

### dev.morphia.aggregation.expressions.impls.ZipExpression

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.aggregation.stages.AddFields

| 2.5 | 3.0 |
|---|---|
| `AddFields field(String, Expression)` | `AddFields field(String, Object)` |
| `static AddFields of()` |  |

### dev.morphia.aggregation.stages.AutoBucket

| 2.5 | 3.0 |
|---|---|
| `AutoBucket groupBy(Expression)` | `AutoBucket groupBy(Object)` |
| `static AutoBucket of()` |  |

### dev.morphia.aggregation.stages.Bucket

| 2.5 | 3.0 |
|---|---|
| `Bucket boundaries(Expression[])` | `Bucket boundaries(Object[])` |
| `Bucket groupBy(Expression)` | `Bucket groupBy(Object)` |
| `static Bucket of()` |  |

### dev.morphia.aggregation.stages.ChangeStream

| 2.5 | 3.0 |
|---|---|
| `String toString()` |  |

### dev.morphia.aggregation.stages.CollectionStats

| 2.5 | 3.0 |
|---|---|
| `static CollectionStats with()` |  |

### dev.morphia.aggregation.stages.CurrentOp

| 2.5 | 3.0 |
|---|---|
| `static CurrentOp of()` |  |

### dev.morphia.aggregation.stages.Facet

| 2.5 | 3.0 |
|---|---|
| `static Facet of()` |  |

### dev.morphia.aggregation.stages.Fill

| 2.5 | 3.0 |
|---|---|
| `Fill field(String, ValueExpression)` | `Fill field(String, Object)` |

### dev.morphia.aggregation.stages.GeoNear

| 2.5 | 3.0 |
|---|---|
|  | `static dev.morphia.aggregation.stages.GeoNear geoNear(String)` |
| `static dev.morphia.aggregation.stages.GeoNear to(com.mongodb.client.model.geojson.Point)` |  |
| `static dev.morphia.aggregation.stages.GeoNear to(double[])` |  |

### dev.morphia.aggregation.stages.GraphLookup

| 2.5 | 3.0 |
|---|---|
| `GraphLookup(Class)` |  |
| `GraphLookup(String)` |  |
| `static GraphLookup from(Class)` |  |
| `static GraphLookup from(String)` |  |
| `GraphLookup startWith(Expression)` | `GraphLookup startWith(Object)` |

### dev.morphia.aggregation.stages.Group

| 2.5 | 3.0 |
|---|---|
| `dev.morphia.aggregation.stages.Group field(String, Expression)` | `dev.morphia.aggregation.stages.Group field(String, Object)` |
| `static Group.GroupId id(Expression)` |  |
|  | `static Group.GroupId id(Object)` |
| `static Group.GroupId id(String)` |  |
| `static dev.morphia.aggregation.stages.Group of()` |  |
| `static dev.morphia.aggregation.stages.Group of(Group.GroupId)` |  |

### dev.morphia.aggregation.stages.Group.GroupId

| 2.5 | 3.0 |
|---|---|
| `Group.GroupId field(String, Expression)` | `Group.GroupId field(String, Object)` |

### dev.morphia.aggregation.stages.IndexStats

| 2.5 | 3.0 |
|---|---|
| `static IndexStats of()` |  |

### dev.morphia.aggregation.stages.Limit

| 2.5 | 3.0 |
|---|---|
| `static Limit of(long)` |  |

### dev.morphia.aggregation.stages.Lookup

| 2.5 | 3.0 |
|---|---|
| `static Lookup from(Class)` |  |
| `static Lookup from(String)` |  |
| `Lookup let(String, Expression)` | `Lookup let(String, Object)` |

### dev.morphia.aggregation.stages.Match

| 2.5 | 3.0 |
|---|---|
| `static Match on(Filter[])` |  |

### dev.morphia.aggregation.stages.Merge

| 2.5 | 3.0 |
|---|---|
| `static Merge into(Class)` |  |
| `static Merge into(String)` |  |
| `static Merge into(String, String)` |  |
|  | `static Merge merge(Class)` |
|  | `static Merge merge(String)` |
|  | `static Merge merge(String, String)` |
|  | `Merge whenMatched(Stage[])` |

### dev.morphia.aggregation.stages.Out

| 2.5 | 3.0 |
|---|---|
|  | `static Out out(Class)` |
|  | `static Out out(String)` |
| `static Out to(Class)` |  |
| `static Out to(String)` |  |

### dev.morphia.aggregation.stages.PlanCacheStats

| 2.5 | 3.0 |
|---|---|
| `static PlanCacheStats of()` |  |

### dev.morphia.aggregation.stages.Projection

| 2.5 | 3.0 |
|---|---|
| `dev.morphia.aggregation.stages.Projection include(String, Expression)` | `dev.morphia.aggregation.stages.Projection include(String, Object)` |
| `static dev.morphia.aggregation.stages.Projection of()` |  |

### dev.morphia.aggregation.stages.Redact

| 2.5 | 3.0 |
|---|---|
| `static Redact on(Expression)` |  |

### dev.morphia.aggregation.stages.ReplaceRoot

| 2.5 | 3.0 |
|---|---|
| `static ReplaceRoot replaceRoot(Expression)` | `static ReplaceRoot replaceRoot(Object)` |
| `static ReplaceRoot with()` |  |
| `static ReplaceRoot with(Expression)` |  |

### dev.morphia.aggregation.stages.ReplaceWith

| 2.5 | 3.0 |
|---|---|
| `ReplaceWith field(String, Expression)` | `ReplaceWith field(String, Object)` |
| `static ReplaceWith replaceWith(Expression)` | `static ReplaceWith replaceWith(Object)` |
| `static ReplaceWith with()` |  |
| `static ReplaceWith with(Expression)` |  |

### dev.morphia.aggregation.stages.Sample

| 2.5 | 3.0 |
|---|---|
| `static Sample of(long)` |  |

### dev.morphia.aggregation.stages.Set

| 2.5 | 3.0 |
|---|---|
| `Set field(String, Expression)` | `Set field(String, Object)` |

### dev.morphia.aggregation.stages.SetWindowFields

| 2.5 | 3.0 |
|---|---|
| `SetWindowFields partitionBy(Expression)` | `SetWindowFields partitionBy(Object)` |

### dev.morphia.aggregation.stages.Skip

| 2.5 | 3.0 |
|---|---|
| `static Skip of(long)` |  |

### dev.morphia.aggregation.stages.Sort

| 2.5 | 3.0 |
|---|---|
| `static dev.morphia.aggregation.stages.Sort on()` |  |

### dev.morphia.aggregation.stages.SortByCount

| 2.5 | 3.0 |
|---|---|
| `static SortByCount on(Expression)` |  |
| `static SortByCount sortByCount(Expression)` | `static SortByCount sortByCount(Object)` |

### dev.morphia.aggregation.stages.UnionWith

| 2.5 | 3.0 |
|---|---|
|  | `static Stage unionWith(Stage[])` |
|  | `static Stage unionWith(Class, Stage[])` |
|  | `static Stage unionWith(String, Stage[])` |

### dev.morphia.aggregation.stages.Unset

| 2.5 | 3.0 |
|---|---|
| `static Unset fields(String, String[])` |  |

### dev.morphia.aggregation.stages.Unwind

| 2.5 | 3.0 |
|---|---|
| `static Unwind on(String)` |  |

### dev.morphia.annotations.Field

| 2.5 | 3.0 |
|---|---|
| `dev.morphia.utils.IndexType type()` | `dev.morphia.mapping.IndexType type()` |

### dev.morphia.annotations.Indexed

| 2.5 | 3.0 |
|---|---|
| `dev.morphia.utils.IndexDirection value()` | `dev.morphia.mapping.IndexDirection value()` |

### dev.morphia.config.MorphiaConfig

| 2.5 | 3.0 |
|---|---|
|  | `Integer decodeSessionCacheSize()` |
|  | `default MorphiaConfig decodeSessionCacheSize(Integer)` |
|  | `Optional listeners()` |
|  | `default MorphiaConfig listeners(List)` |
|  | `MapperType mapper()` |
|  | `default MorphiaConfig mapper(MapperType)` |
| `dev.morphia.mapping.MapperOptions.PropertyDiscovery propertyDiscovery()` | `dev.morphia.mapping.PropertyDiscovery propertyDiscovery()` |
| `default MorphiaConfig propertyDiscovery(dev.morphia.mapping.MapperOptions.PropertyDiscovery)` | `default MorphiaConfig propertyDiscovery(dev.morphia.mapping.PropertyDiscovery)` |
|  | `default String toConfigFormat(boolean)` |
| `UuidRepresentation uuidRepresentation()` |  |
| `default MorphiaConfig uuidRepresentation(UuidRepresentation)` |  |

### dev.morphia.mapping.DiscriminatorFunction

| 2.5 | 3.0 |
|---|---|
| `void apply(EntityModelBuilder)` |  |
|  | `String apply(Class, String)` |
|  | `abstract String compute(Class)` |

### dev.morphia.mapping.NamingStrategy

| 2.5 | 3.0 |
|---|---|
|  | `static NamingStrategy title()` |

### dev.morphia.mapping.conventions.MorphiaConvention

| 2.5 | 3.0 |
|---|---|
| `void apply(Mapper, EntityModelBuilder)` |  |

### dev.morphia.query.ArraySlice

| 2.5 | 3.0 |
|---|---|
| `ArraySlice(int)` |  |
| `ArraySlice(int, int)` |  |
| `Integer getLimit()` |  |
| `Integer getSkip()` |  |
|  | `static ArraySlice limit(int)` |
|  | `ArraySlice skip(int)` |

### dev.morphia.query.CountOptions

| 2.5 | 3.0 |
|---|---|
| `String collection()` |  |
| `long getMaxTime(TimeUnit)` |  |
| `ReadConcern readConcern()` |  |
| `ReadPreference readPreference()` |  |

### dev.morphia.query.FindAndDeleteOptions

| 2.5 | 3.0 |
|---|---|
| `String collection()` |  |
| `WriteConcern writeConcern()` |  |

### dev.morphia.query.FindOptions

| 2.5 | 3.0 |
|---|---|
| `String collection()` |  |
| `FindOptions copy()` |  |
| `boolean equals(Object)` |  |
| `Boolean getAllowDiskUse()` |  |
| `int getBatchSize()` |  |
| `com.mongodb.client.model.Collation getCollation()` |  |
| `String getComment()` |  |
| `CursorType getCursorType()` |  |
| `Document getHint()` |  |
| `int getLimit()` |  |
| `Document getMax()` |  |
| `long getMaxAwaitTime(TimeUnit)` |  |
| `long getMaxTime(TimeUnit)` |  |
| `Document getMin()` |  |
| `int getSkip()` |  |
| `Document getSort()` |  |
| `int hashCode()` |  |
| `FindOptions hint(DBObject)` |  |
| `boolean isNoCursorTimeout()` |  |
| `boolean isOplogReplay()` |  |
| `boolean isPartial()` |  |
| `boolean isReturnKey()` |  |
| `boolean isShowRecordId()` |  |
| `FindOptions max(DBObject)` |  |
| `FindOptions min(DBObject)` |  |
| `dev.morphia.query.Projection projection()` |  |
| `ReadConcern readConcern()` |  |
| `ReadPreference readPreference()` |  |
| `String toString()` |  |

### dev.morphia.query.Meta

| 2.5 | 3.0 |
|---|---|
| `Meta(Meta.MetaDataKeyword)` |  |
| `Meta(Meta.MetaDataKeyword, String)` |  |
| `Meta(String, String)` |  |
| `String getField()` |  |
| `static Meta textScore()` |  |

### dev.morphia.query.MorphiaCursor

| 2.5 | 3.0 |
|---|---|
| `MorphiaCursor(MongoCursor)` |  |

### dev.morphia.query.Query

| 2.5 | 3.0 |
|---|---|
| `default CriteriaContainer and(Criteria[])` |  |
| `default FieldEnd criteria(String)` |  |
| `default MorphiaCursor execute()` |  |
| `default MorphiaCursor execute(FindOptions)` |  |
| `default Map explain(FindOptions)` |  |
| `Map explain(FindOptions, ExplainVerbosity)` |  |
| `default FieldEnd field(String)` |  |
| `default Query filter(Filter[])` | `Query filter(Filter[])` |
| `default Query filter(String, Object)` |  |
| `default MorphiaCursor find()` |  |
| `default MorphiaCursor find(FindOptions)` |  |
| `Object first(FindOptions)` |  |
| `MorphiaCursor iterator()` | `MorphiaCursor iterator()` |
| `MorphiaCursor iterator(FindOptions)` |  |
| `MorphiaKeyCursor keys()` |  |
| `MorphiaKeyCursor keys(FindOptions)` |  |
| `default Object modify(ModifyOptions, UpdateOperator[])` |  |
| `Modify modify(UpdateOperator, UpdateOperator[])` | `default Object modify(UpdateOperator, UpdateOperator[])` |
|  | `Object modify(ModifyOptions, UpdateOperator, UpdateOperator[])` |
| `default CriteriaContainer or(Criteria[])` |  |
| `default Query retrieveKnownFields()` |  |
| `Query search(String)` |  |
| `Query search(String, String)` |  |
| `default Stream stream()` | `Stream stream()` |
| `default Stream stream(FindOptions)` |  |
| `default UpdateResult update(Stage[])` |  |
|  | `default UpdateResult update(UpdateOperator[])` |
| `default Update update(List)` |  |
| `default UpdateResult update(UpdateOptions, Stage[])` |  |
| `default UpdateResult update(UpdateOptions, UpdateOperator[])` | `UpdateResult update(UpdateOptions, UpdateOperator[])` |
|  | `default UpdateResult update(Stage, Stage[])` |
| `Update update(UpdateOperator, UpdateOperator[])` |  |
|  | `UpdateResult update(UpdateOptions, Stage, Stage[])` |

### dev.morphia.query.Sort

| 2.5 | 3.0 |
|---|---|
| `String getField()` |  |
| `int getOrder()` |  |

### dev.morphia.query.filters.Filter

| 2.5 | 3.0 |
|---|---|
| `String toString()` |  |

### dev.morphia.query.filters.Filters

| 2.5 | 3.0 |
|---|---|
| `static LogicalFilter and(Filter[])` | `static Filter and(Filter[])` |
| `static Filter bitsAllClear(String, int)` |  |
| `static Filter bitsAllClear(String, int[])` |  |
|  | `static Filter bitsAllClear(String, Object)` |
| `static Filter bitsAllSet(String, int)` |  |
| `static Filter bitsAllSet(String, int[])` |  |
|  | `static Filter bitsAllSet(String, Object)` |
|  | `static Filter comment(String)` |
| `static Filter comment(String, Object)` |  |
|  | `static Filter elemMatch(Filter[])` |
|  | `static Filter gt(Object)` |
|  | `static Filter gte(Object)` |
|  | `static Filter in(Iterable)` |
| `static Filter jsonSchema(String, Object)` |  |
|  | `static Filter lt(Object)` |
|  | `static Filter lte(Object)` |
|  | `static Filter mod(String, double, double)` |
| `static LogicalFilter nor(Filter[])` | `static Filter nor(Filter[])` |
| `static LogicalFilter or(Filter[])` | `static Filter or(Filter[])` |
| `static RegexFilter regex(String)` |  |
| `static Filter type(String, Type)` | `static Filter type(String, Type[])` |

### dev.morphia.query.filters.RegexFilter

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |
|  | `Pattern pattern()` |
| `RegexFilter pattern(String)` |  |
| `RegexFilter pattern(Pattern)` |  |

### dev.morphia.query.filters.TextSearchFilter

| 2.5 | 3.0 |
|---|---|
| `void encode(Datastore, BsonWriter, EncoderContext)` |  |

### dev.morphia.query.updates.CurrentDateOperator

| 2.5 | 3.0 |
|---|---|
| `OperationTarget toTarget(PathTarget)` |  |

### dev.morphia.query.updates.UpdateOperators

| 2.5 | 3.0 |
|---|---|
| `static AddToSetOperator addToSet(String, Object)` | `static UpdateOperator addToSet(String, Object)` |
| `static AddToSetOperator addToSet(String, List)` | `static UpdateOperator addToSet(String, List)` |
|  | `static UpdateOperator bit(String, Number)` |
| `static UpdateOperator pull(String, Filter)` | `static UpdateOperator pull(String, Filter[])` |
| `static UpdateOperator unset(String)` |  |
|  | `static UpdateOperator unset(String, String[])` |

