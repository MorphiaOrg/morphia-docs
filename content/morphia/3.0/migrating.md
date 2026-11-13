---
title: "Migration"
weight: 210
group: "Upgrading"
---

## Migrating to 3.0

Most of the move to 3.0 is handled by an [OpenRewrite](https://docs.openrewrite.org/) recipe, `dev.morphia.UpgradeToMorphia30`,
shipped in the `dev.morphia.morphia:morphia-rewrite` artifact. Run it first, review the diff, and then work through the manual steps
in the rest of this page for whatever still doesn't compile. The 3.0 API also has a [class-by-class summary](../morphia-2.5-3.0-table/)
of what changed.

### Running the upgrade recipe

Commit your work before running the recipe so you can review what it changed. With Maven, you can run it without editing your
pom:

```shell
mvn -U org.openrewrite.maven:rewrite-maven-plugin:run \
    -Drewrite.recipeArtifactCoordinates=dev.morphia.morphia:morphia-rewrite:3.0.0 \
    -Drewrite.activeRecipes=dev.morphia.UpgradeToMorphia30
```

Or add the plugin to your pom, with `morphia-rewrite` as a plugin dependency, and run `mvn rewrite:run`:

```xml
<plugin>
    <groupId>org.openrewrite.maven</groupId>
    <artifactId>rewrite-maven-plugin</artifactId>
    <version><!-- the current rewrite-maven-plugin release --></version>
    <configuration>
        <activeRecipes>
            <recipe>dev.morphia.UpgradeToMorphia30</recipe>
        </activeRecipes>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>dev.morphia.morphia</groupId>
            <artifactId>morphia-rewrite</artifactId>
            <version>3.0.0</version>
        </dependency>
    </dependencies>
</plugin>
```

Use `mvn rewrite:dryRun` instead to write the changes to a patch file under `target/rewrite` without touching your sources. With
Gradle, apply the `org.openrewrite.rewrite` plugin, add `rewrite("dev.morphia.morphia:morphia-rewrite:3.0.0")` to your dependencies,
set `activeRecipe("dev.morphia.UpgradeToMorphia30")` in the `rewrite` block, and run `gradle rewriteRun`.

The recipe needs your code to compile against Morphia 2.5 so that it can see the types it's rewriting. Run it before you change the
Morphia version: with Maven, the recipe then updates the `morphia-core` dependency in your pom to 3.0 for you. Moving off 2.5's deprecated APIs first
leaves less for the recipe, and you, to handle.

The recipe:

- rewrites aggregations, queries and updates to the 3.0 forms, described [below](#what-the-recipe-changes)
- converts `MapperOptions` to `MorphiaConfig` and `Morphia.createDatastore(client, "database")` to
  `createDatastore(client, MorphiaConfig.load().database("database"))` (see [MapperOptions removed](#mapperoptions-removed))
- migrates entity listeners to the per-event interfaces (see [Entity listeners](#entity-listeners))
- removes calls to `Datastore` methods that 3.0 no longer has, and moves types that changed packages

It can't restructure code that used the APIs 3.0 removes without a one-to-one replacement. Those are covered in the manual sections
that follow.

### What the recipe changes

#### Aggregations

Aggregations in 3.0 are built by passing stages to `pipeline(Stage...)` and run with `iterator()` or `toList()`. The recipe's
`PipelineRewriteRecipes` and `UnwrapFieldExpressions` groups make these changes:

| 2.5                                                                   | 3.0                                                                           |
|-----------------------------------------------------------------------|-------------------------------------------------------------------------------|
| A stage-named method, such as `aggregation.match(..)` or `group(..)` | The stage passed to `pipeline(..)`, such as `pipeline(match(..), group(..))` |
| `aggregation.out(Out.to("coll"))`                                     | `pipeline(Out.out("coll"))`                                                   |
| `aggregation.merge(Merge.into(..))`                                   | `pipeline(Merge.merge(..))`                                                   |
| `aggregation.execute(Target.class)`                                   | `datastore.aggregate(Source.class, Target.class)` ... `.iterator()`           |
| `aggregation.execute(Target.class, options)`                          | The options passed to `datastore.aggregate(..)`, then `.iterator()`           |
| `datastore.aggregate("collection")`                                   | `datastore.aggregate(Document.class, AggregationOptions.aggregationOptions().collection("collection"))` |
| `new AggregationOptions()`                                            | `AggregationOptions.aggregationOptions()`                                     |
| `Expressions.field("$qty")`, `Expressions.value(250)`                 | `"$qty"`, `250`: stages and expressions accept field names and values directly |
| `Expressions.of()`                                                    | `Expressions.document()`                                                      |

For example:

```java
// 2.5
List<Document> list = datastore.aggregate(Sale.class)
    .match(eq("store", "downtown"))
    .sort(sort().ascending("item"))
    .execute(Document.class)
    .toList();

// 3.0
List<Document> list = datastore.aggregate(Sale.class, Document.class)
    .pipeline(
        match(eq("store", "downtown")),
        sort().ascending("item"))
    .iterator()
    .toList();
```

#### Queries and updates

| Recipe                | 2.5                                                         | 3.0                                                                         |
|-----------------------|-------------------------------------------------------------|-----------------------------------------------------------------------------|
| `RenameMethod`        | `datastore.createQuery(Type.class)`                         | `datastore.find(Type.class)`                                                |
| `QueryFindOptions`    | `datastore.find(Type.class)...first(options)`, or `iterator(options)` or `stream(options)` | `datastore.find(Type.class, options)...first()`, and so on |
| `ArraySliceMigration` | `new ArraySlice(limit)`, `new ArraySlice(skip, limit)`      | `ArraySlice.limit(limit)`, `ArraySlice.limit(limit).skip(skip)`             |
| `LogicalFilterAdd`    | `or().add(a).add(b)`, and the same for `and()` and `nor()`  | `or(a, b)`                                                                  |
| `RegexPatternMerge`   | `regex("field").pattern("p")`                               | `regex("field", "p")`                                                       |
| `UpdateExecute`       | `query.update(ops...).execute()`, `.execute(options)`       | `query.update(ops...)`, `query.update(options, ops...)`                     |
| `UpdateExecute`       | `query.modify(ops...).execute()`, `.execute(options)`       | `query.modify(ops...)`, `query.modify(options, ops...)`                     |
| `UpdateReturnType`    | `Update<T> update = query.update(..)`                       | `UpdateResult update = query.update(..)`                                    |

In 3.0, `Query` no longer takes a `FindOptions` when you run it: pass the options to `Datastore.find(Class, FindOptions)` instead.
`QueryFindOptions` moves them only when the call is chained from that `find()` call. For one held in a variable or passed in from
elsewhere, move the options yourself.

`UpdateExecute` handles the `update(..).execute()` and `modify(..).execute()` chains, and `UpdateReturnType` changes variables
declared as `Update<T>` to `UpdateResult`, since `query.update(..)` now runs the update itself. Check any `Update` or `Modify` held
in a variable by hand: the update now runs where the variable is assigned, not where `execute()` was called. Code that uses the
legacy `UpdateOperations` API needs the manual changes described in [Legacy APIs](#legacy-query-update-and-aggregation-apis).

#### Removed `Datastore` methods

`enableDocumentValidation()`, `ensureCaps()` and `ensureIndexes()` were deprecated in 2.4 and are gone in 3.0. Morphia applies document
validation, capped collections and indexes itself when the datastore is created, for the entities it maps at that point, if the
matching setting is on. All three are off by default:

| 2.5 call                               | 3.0 setting                                                                       |
|----------------------------------------|-----------------------------------------------------------------------------------|
| `datastore.enableDocumentValidation()` | `morphia.apply-document-validations=true`, or `MorphiaConfig.applyDocumentValidations(true)` |
| `datastore.ensureCaps()`               | `morphia.apply-caps=true`, or `MorphiaConfig.applyCaps(true)`                     |
| `datastore.ensureIndexes()`            | `morphia.apply-indexes=true`, or `MorphiaConfig.applyIndexes(true)`               |

The recipe removes calls to `enableDocumentValidation()` and `ensureIndexes()`; remove calls to `ensureCaps()` by hand. Removing the
call doesn't turn the setting on, so if you relied on any of these, set it in your [configuration](../configuration/).

#### Moved and renamed types

| 2.5                                          | 3.0                                       |
|----------------------------------------------|-------------------------------------------|
| `dev.morphia.DatastoreImpl`                  | `dev.morphia.MorphiaDatastore`            |
| `dev.morphia.utils.IndexDirection`           | `dev.morphia.mapping.IndexDirection`      |
| `dev.morphia.utils.IndexType`                | `dev.morphia.mapping.IndexType`           |
| `dev.morphia.mapping.MapperOptions.PropertyDiscovery` | `dev.morphia.mapping.PropertyDiscovery` |
| `dev.morphia.query.internal.MorphiaCursor`   | `dev.morphia.query.MorphiaCursor`         |
| `dev.morphia.EntityInterceptor`              | `dev.morphia.EntityListener`              |

#### `@Embedded` removed

`@Embedded` was deprecated in 2.2 and is gone in 3.0: use `@Entity` on every mapped type. A type that's only stored inside other
entities is an `@Entity` with no `@Id` field. The recipe removes `@Embedded` annotations, but it doesn't add `@Entity`, so add it to
any type that had only `@Embedded`, and move any `useDiscriminator`, `discriminator` or `discriminatorKey` values from `@Embedded` to
`@Entity`. Morphia can't map a type that has neither `@Entity` nor `@ExternalEntity`.

```java
// 2.5
@Embedded
public class Address { ... }

// 3.0
@Entity
public class Address { ... }
```

### MapperOptions removed

`MapperOptions` and its `Builder` have been removed in 3.0.  The replacement is `MorphiaConfig`, which was introduced in 2.4 as the
preferred configuration API.  `MorphiaConfig` is immutable and supports both file-based configuration via
`META-INF/morphia-config.properties` and programmatic configuration.  See the [configuration section](../configuration/) for details.

`UpgradeToMorphia30` converts `MapperOptions` usages to `MorphiaConfig`. To run only that step, use the
`dev.morphia.rewrite.recipes.config.MorphiaConfigMigration` recipe from the same `morphia-rewrite` artifact.

### Entity listeners

`EntityListener` is now an empty marker interface. Each life cycle event has its own listener interface, and a listener implements the
ones for the events it handles. `hasAnnotation()` is gone: implementing an event's interface is what makes a listener handle it.

| 2.x `EntityListener` method                         | 3.0 interface                                                                     |
|-----------------------------------------------------|-----------------------------------------------------------------------------------|
| `prePersist(T entity, Document document, Datastore)` | `PrePersistListener<T>`: `prePersist(T entity, Datastore)`                       |
| `postPersist(T entity, Document document, Datastore)` | `PostPersistListener<T>`, or `PostPersistDocumentListener<T>` to keep the `Document` |
| `preLoad(T entity, Document document, Datastore)`    | `PreLoadListener<T>`: unchanged                                                  |
| `postLoad(T entity, Document document, Datastore)`   | `PostLoadListener<T>`, or `PostLoadDocumentListener<T>` to keep the `Document`     |

`Mapper.addInterceptor()` has been removed, along with `Mapper.getListeners()` and `Mapper.hasListeners()`. List global listeners in
the `morphia.listeners` setting, or pass them to `MorphiaConfig.listeners(...)`, instead. Listeners are now fixed when the datastore is
created. See [Life Cycle Methods](../life-cycle-methods/) for details.

The `dev.morphia.UpgradeToMorphia30` recipe migrates `EntityListener` implementations to the new interfaces, choosing
`PostPersistDocumentListener` or `PostLoadDocumentListener` for a `postPersist` or `postLoad` that uses its `Document`. It removes
`hasAnnotation()` overrides and updates calls to the migrated methods. It marks what it can't migrate for you to finish by hand:

- each `addInterceptor()` call
- a `prePersist` that uses its `Document`, which was always empty: to change what's saved, use a `PostPersistDocumentListener`
- a method that uses the old `Mapper` parameter: use `datastore.getMapper()`
- an override that uses the `Document` when the method it overrides migrates without it
- an anonymous listener that handles more than one event, since it can implement only one interface
- calls it can't update, such as one that would drop a `Document` argument that does something, and calls to `hasAnnotation()`

Calls to `getListeners()` and `hasListeners()` aren't marked and will fail to compile.

Annotated life cycle methods, such as a `@PostLoad` method, are now allowed only on the entity itself. An `@EntityListeners` class
implements the event's interface instead, and Morphia rejects one that still has annotated methods when the entity is mapped. The
`UpgradeToMorphia30` recipe migrates these classes: it adds the interface for each event, removes the annotations, and has the
interface's method call the annotated methods, passing the entity, the `Document` and the `Datastore` they took. A method that already
has the interface's signature becomes the interface's method. It chooses the `Document` variant of an interface when a `postPersist`
or `postLoad` method takes the `Document`. It marks a class for you to finish by hand when:

- it extends a class that has annotated methods, or a class that is itself a listener
- a method would clash with one the class has or inherits, such as an inherited `postLoad`
- an annotated method throws a checked exception, takes a type the entity can't be passed as, or is generic in the entity
- a `@PrePersist` method uses its `Document`
- the class handles unrelated entity types, inherits `EntityListener` raw or with another type, or already uses the other interface
  for an event
- a type the new methods name, such as `Document` or `Datastore`, would be ambiguous in the file

The order of `@PreLoad` listeners has changed for entities created through a constructor, such as records. They now run after the
entity's properties are decoded, just before its `@PostLoad` listeners, because the instance can't exist any earlier.

### Legacy query, update and aggregation APIs

3.0 removes the query, update and aggregation APIs that 2.0 replaced. They were deprecated throughout 2.x, and the recipe can't
convert them because the replacements are shaped differently, so they need restructuring by hand. Code that already avoids 2.5's
deprecation warnings doesn't use any of them.

#### Criteria queries

The fluent criteria API (`field()`, `criteria()`, `and()`, `or()` and the string form of `filter()`) is gone. Build queries from
`dev.morphia.query.filters.Filters` and pass them to `filter(Filter...)`. Filters passed to one `filter()` call, or to several calls,
are combined with `$and`.

```java
// 2.5
Query<Hotel> query = datastore.find(Hotel.class);
query.field("stars").greaterThanOrEq(4);
query.or(
    query.criteria("city").equal("Paris"),
    query.criteria("city").equal("London"));
query.filter("price <", 300);

// 3.0
Query<Hotel> query = datastore.find(Hotel.class)
    .filter(gte("stars", 4),
        or(eq("city", "Paris"), eq("city", "London")),
        lt("price", 300));
```

| 2.5                                                         | 3.0                                                                      |
|-------------------------------------------------------------|--------------------------------------------------------------------------|
| `field(f)` / `criteria(f)` + `equal(v)`, `notEqual(v)`      | `eq(f, v)`, `ne(f, v)`                                                   |
| `greaterThan`, `greaterThanOrEq`, `lessThan`, `lessThanOrEq` | `gt`, `gte`, `lt`, `lte`                                                |
| `exists()`, `doesNotExist()`                                | `exists(f)`, `exists(f).not()`                                           |
| `in(v)`, `hasAnyOf(v)`; `notIn(v)`, `hasNoneOf(v)`          | `in(f, v)`; `nin(f, v)`                                                  |
| `hasAllOf(v)`, `hasThisOne(v)`, `sizeEq(n)`                 | `all(f, v)`, `eq(f, v)`, `size(f, n)`                                    |
| `mod(d, r)`, `type(t)`, `elemMatch(..)`                     | `mod(f, d, r)`, `type(f, t)`, `elemMatch(f, filters...)`                 |
| `startsWith`, `endsWith`, `contains` and their `IgnoreCase` forms | `regex(f, pattern)`, with `.caseInsensitive()` for the `IgnoreCase` forms |
| `near`, `nearSphere`, `within`, `intersects`                | `near`, `nearSphere`, `geoWithin`, `geoIntersects`                       |
| `and(criteria...)`, `or(criteria...)`                       | `and(filters...)`, `or(filters...)`                                      |
| `filter("field op", value)`                                 | the matching `Filters` method                                            |
| `where(js)` (`WhereCriteria`)                               | `where(js)`                                                              |
| `search(text)`, `search(text, language)`                    | `filter(text(text))`, `filter(text(text).language(language))`            |

See [Query Filters](../query-filters/) for the full list. These types are gone with the criteria API: `FieldEnd`, `Criteria`,
`CriteriaContainer`, `CriteriaJoin`, `FilterOperator`, `WhereCriteria`, `AbstractCriteria`, `LegacyQueryFactory`,
`AbstractQueryFactory` and `LegacyQueryCodec`.

`QueryFactory` and `DefaultQueryFactory` are now internal, and custom query factories are no longer supported. Remove any
`morphia.query-factory` setting or `queryFactory(..)` call that names your own factory. `MorphiaConfig.legacy()` still applies the
legacy mapping settings, but it no longer switches queries to the legacy API.

#### Running queries and reading ids

| 2.5                                  | 3.0                                                                                  |
|--------------------------------------|--------------------------------------------------------------------------------------|
| `query.find()`, `query.find(options)` | `query.iterator()`; pass the options to `datastore.find(Type.class, options)`       |
| `query.retrieveKnownFields()`        | `datastore.find(Type.class, new FindOptions().projection().knownFields())`           |
| `query.keys()`, `query.keys(options)` | a query that projects only `_id`, reading the id from each entity                   |

```java
// 2.5
List<Key<Hotel>> keys = datastore.find(Hotel.class).filter(eq("city", "Paris")).keys().toList();

// 3.0
List<ObjectId> ids = datastore.find(Hotel.class, new FindOptions().projection().include("_id"))
    .filter(eq("city", "Paris"))
    .stream()
    .map(Hotel::getId)
    .toList();
```

`Key` itself is gone in 3.0; see [Options, keys, geo types and annotations](#options-keys-geo-types-and-annotations).

#### Updates and find-and-modify

`UpdateOperations`, `Datastore.createUpdateOperations()` and `Datastore.update()` are gone, along with the `Update` and `Modify`
types that `query.update(..)` and `query.modify(..)` returned in 2.x, and `Updates`. Build the update from
`dev.morphia.query.updates.UpdateOperators` and pass it to `query.update(..)`, which runs it and returns the driver's
`UpdateResult`.

**The default changed from updating every matching document to updating one.** `Datastore.update(query, operations)` updated
every document the query matched. `query.update(..)` updates only the first, so pass `new UpdateOptions().multi(true)` to keep the
old behavior.

```java
// 2.5
UpdateOperations<Hotel> ops = datastore.createUpdateOperations(Hotel.class)
    .inc("stars")
    .set("lastUpdated", now);
datastore.update(datastore.find(Hotel.class).filter(eq("city", "Paris")), ops);

// 3.0
datastore.find(Hotel.class)
    .filter(eq("city", "Paris"))
    .update(new UpdateOptions().multi(true), inc("stars"), set("lastUpdated", now));
```

| 2.5 `UpdateOperations` method              | 3.0 `UpdateOperators` method        |
|--------------------------------------------|-------------------------------------|
| `set`, `setOnInsert`, `unset`              | `set`, `setOnInsert`, `unset`       |
| `inc`, `dec`, `max`, `min`                 | `inc`, `dec`, `max`, `min`          |
| `push`, `addToSet`                         | `push`, `addToSet`                  |
| `removeFirst(f)`, `removeLast(f)`          | `pop(f).removeFirst()`, `pop(f)`    |
| `removeAll(f, value)`                      | `pull(f, value)`, or `pullAll(f, values)` for a list |
| `disableValidation()`, `enableValidation()` | `query.disableValidation()`, `query.enableValidation()` |

| 2.5                                                   | 3.0                                                                         |
|-------------------------------------------------------|-----------------------------------------------------------------------------|
| `datastore.update(query, ops[, options])`             | `query.update([options,] operators...)`                                     |
| `datastore.findAndModify(query, ops[, options])`      | `query.modify([options,] operators...)`                                     |
| `datastore.findAndDelete(query[, options])`           | `query.findAndDelete([new FindAndDeleteOptions()...])`                      |
| `query.update(..).execute([options])`, `query.modify(..).execute([options])` | `query.update([options,] ..)`, `query.modify([options,] ..)` |

`query.modify(..)` returns the document as it was before the update unless you ask for the new one. `datastore.findAndModify(query,
ops)` returned the updated document, so pass `new ModifyOptions().returnDocument(ReturnDocument.AFTER)` to keep that. The 2.x
`FindAndModifyOptions` maps to `ModifyOptions` for `modify()`, and to `FindAndDeleteOptions` for `findAndDelete()`.

The recipe's `UpdateExecute` step only rewrites `update(..).execute(..)` and `modify(..).execute(..)` written as one chain, and
`UpdateReturnType` retypes variables declared as `Update<T>`. Neither touches code built on `UpdateOperations`, which needs these
changes by hand, and an `Update` or `Modify` held in a variable needs checking because the update now runs where it's assigned.

#### The pre-2.0 aggregation pipeline

`Datastore.createAggregation()`, `AggregationPipeline` and `AggregationPipelineImpl` are gone. Start the aggregation with
`datastore.aggregate(..)` and pass the stages to `pipeline(..)`. The old builders in `dev.morphia.aggregation` and
`dev.morphia.query` have replacements in `dev.morphia.aggregation.stages`, but their APIs differ, so each use has to be rewritten:

| 2.5                                                                   | 3.0                                                                           |
|-----------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `createAggregation(Type.class)`                                       | `aggregate(Type.class)`, or `aggregate(Type.class, Target.class)`             |
| `match(query)`                                                        | `match(filters...)`                                                           |
| `group(..)` with `dev.morphia.aggregation.Group` and `Accumulator`    | `Group.group(id("$field")).field(name, accumulator)`, with `AccumulatorExpressions`; field references in 3.0 expressions start with `$` |
| `project(..)` with `dev.morphia.aggregation.Projection`               | `Projection.project().include(..)`, `exclude(..)`, `suppressId()`             |
| `geoNear(..)` with `dev.morphia.aggregation.GeoNear` and `GeoNearBuilder` | `GeoNear.geoNear(point)` and its setters                                  |
| `bucket(field, boundaries[, BucketOptions])`                          | `Bucket.bucket().groupBy("$field").boundaries(..).defaultValue(..).outputField(..)` |
| `bucketAuto(field, count[, BucketAutoOptions])`                       | `AutoBucket.autoBucket().groupBy("$field").buckets(count).granularity(..).outputField(..)` |
| `BucketAutoOptions.Granularity`                                       | the driver's `com.mongodb.client.model.BucketGranularity`                    |
| `lookup(from, localField, foreignField, as)`                          | `Lookup.lookup(from).localField(..).foreignField(..).as(..)`                  |
| `limit`, `skip`, `sample`, `sort`, `sortByCount`, `unwind`            | the `stages` factory of the same name, such as `limit(n)` or `unwind(field)` |
| `aggregate(Target.class[, options])`                                  | `aggregate(Type.class, Target.class[, options])` ... `.iterator()`            |
| `out(..)`                                                             | an `Out.out(..)` stage at the end of the pipeline, which runs it              |

```java
// 2.5
Iterator<Author> authors = datastore.createAggregation(Book.class)
    .group("author", grouping("books", push("title")))
    .aggregate(Author.class);

// 3.0
Iterator<Author> authors = datastore.aggregate(Book.class, Author.class)
    .pipeline(group(id("$author"))
        .field("books", push("$title")))
    .iterator();
```

See [Aggregations](../aggregations/) and [Aggregation Stages](../aggregation-stages/) for each stage's API.

### Options, keys, geo types and annotations

#### Options getters

Morphia's options classes are builders in 3.0: you set values on them and pass them in, but you can't read the values back. These
getters were deprecated in 2.5 and are gone:

| Class               | Removed                                                                                               |
|---------------------|-------------------------------------------------------------------------------------------------------|
| `FindOptions`       | `getAllowDiskUse()`, `getBatchSize()`, `getCollation()`, `getComment()`, `getCursorType()`, `getHint()`, `getLimit()`, `getMax()`, `getMaxAwaitTime()`, `getMaxTime()`, `getMin()`, `getSkip()`, `getSort()`, `isNoCursorTimeout()`, `isOplogReplay()`, `isPartial()`, `isReturnKey()`, `isShowRecordId()` |
| `DeleteOptions`     | `isMulti()`                                                                                           |
| `UpdateOptions`     | `isMulti()`                                                                                           |
| `InsertManyOptions` | `getBypassDocumentValidation()`, `getOptions()`, `isOrdered()`                                        |
| `InsertOneOptions`  | `getBypassDocumentValidation()`, `getOptions()`                                                       |

There are no public replacements. The accessors that remain, such as `UpdateOptions.multi()`, `FindOptions.copy()` and
`InsertOneOptions.writeConcern()` with no arguments, are marked `@MorphiaInternal` and may change without notice. If your code needs
a value back, such as a page size it set on a `FindOptions`, keep it in a variable of your own.

`CountOptions`, `DeleteOptions`, `UpdateOptions` and `ModifyOptions` still extend the driver's options classes, so the getters they
inherit still compile. For example, `CountOptions.getMaxTime(TimeUnit)` now comes from the driver's `CountOptions`.

#### Keys, `AdvancedDatastore` and `InsertOptions`

`Key` and `KeyCodec` are gone. A `Key<T>` was stored as a DBRef (`$ref` and `$id`). Depending on what you used it for:

- to refer to another entity, make the field that entity's type and annotate it with `@Reference`, which also stores a DBRef unless
  you set `idOnly = true`. See [References](../references/).
- to hold or pass around an id, use the id's own type, such as `ObjectId`.
- to read ids from a query, project `_id` as shown in [Running queries and reading ids](#running-queries-and-reading-ids).

`AdvancedDatastore` is gone. Use `Datastore`:

| 2.5 `AdvancedDatastore`                    | 3.0                                                                                    |
|--------------------------------------------|----------------------------------------------------------------------------------------|
| `createQuery(Type.class, document)`        | `find(Type.class, document)`                                                           |
| `createAggregation(collection, Type.class)` | `aggregate(Type.class, AggregationOptions.aggregationOptions().collection(collection))` |
| `createUpdateOperations(Type.class, dbObject)` | build the update with `UpdateOperators`, see [Updates and find-and-modify](#updates-and-find-and-modify) |
| `createRef(Type.class, id)`, `createRef(entity)` | the driver's `new DBRef(collection, id)`, or an `@Reference` field                |
| `insert(entity, InsertOptions)`, `insert(list, InsertOptions)` | `insert(entity, InsertOneOptions)`, `insert(list, InsertManyOptions)`  |
| `queryByExample(collection, example)`      | `queryByExample(example)`, which queries the example's own collection                  |

`InsertOptions` is gone. Use `InsertOneOptions` when saving or inserting one entity and `InsertManyOptions` for a list. Both have
`writeConcern(..)` and `bypassDocumentValidation(..)`, and `InsertManyOptions` has `ordered(..)`. `save(Iterable, InsertOptions)`
becomes `save(List, InsertManyOptions)`, so copy an `Iterable` that isn't a `List` into one first.

#### Listeners and codecs

`AbstractEntityInterceptor` is gone. Its no-op methods moved to the interface in 2.x, and the per-event listener interfaces replace it
in 3.0. The recipe's `EntityInterceptor` to `EntityListener` change doesn't reach classes that extend `AbstractEntityInterceptor`,
so change them by hand: drop the `extends` and implement the interface for each event the class handles, as described in
[Entity listeners](#entity-listeners).

```java
// 2.5
public class AuditListener extends AbstractEntityInterceptor {
    @Override
    public void prePersist(Object entity, Document document, Datastore datastore) { ... }
}

// 3.0
public class AuditListener implements PrePersistListener<Object> {
    @Override
    public void prePersist(Object entity, Datastore datastore) { ... }
}
```

`MorphiaMapCodecProvider` is gone. Morphia encodes `Map` properties itself, so remove any reference to it.

#### Geo types

Everything in `dev.morphia.geo` is gone, along with `dev.morphia.query.Shape`. These were deprecated in 2.0 in favor of the driver's
GeoJSON types in `com.mongodb.client.model.geojson`, which the 3.0 filters and the `GeoNear` stage take. Changing the imports isn't
enough: the driver types are built with constructors and `Position`s rather than Morphia's factories, and a `Position` takes the
longitude first.

```java
// 2.5
import dev.morphia.geo.Point;
import static dev.morphia.geo.PointBuilder.pointBuilder;

Point paris = pointBuilder().latitude(48.8566).longitude(2.3522).build();

// 3.0
import com.mongodb.client.model.geojson.Point;
import com.mongodb.client.model.geojson.Position;

Point paris = new Point(new Position(2.3522, 48.8566));   // longitude, latitude
```

| 2.5                                                         | 3.0                                                                                |
|-------------------------------------------------------------|------------------------------------------------------------------------------------|
| `PointBuilder` (`latitude(..)`, `longitude(..)`)            | `new Point(new Position(longitude, latitude))`                                     |
| `GeoJson.lineString(points...)`                             | `new LineString(positions)`                                                        |
| `GeoJson.polygon(points...)`, `polygon(exterior, interiors...)` | `new Polygon(positions)`, `new Polygon(new PolygonCoordinates(exterior, holes...))` |
| `GeoJson.multiPoint(..)`, `multiLineString(..)`, `multiPolygon(..)` | `new MultiPoint(..)`, `new MultiLineString(..)`, `new MultiPolygon(..)`    |
| `GeoJson.geometryCollection(..)`, `Geometry`                | `new GeometryCollection(..)`, `Geometry`                                           |
| `CoordinateReferenceSystem`, `NamedCoordinateReferenceSystem` | the driver classes of the same names                                            |
| `Point.getLatitude()`, `getLongitude()`                     | `point.getPosition().getValues().get(1)`, `.get(0)`                                |
| `Shape.box(..)`, `center(..)`, `centerSphere(..)`, `polygon(..)` | `Filters.box(field, ..)`, `center(field, ..)`, `centerSphere(field, ..)`, `polygon(field, ..)` |

On 2.5, `Point.convert()` returns the equivalent driver `Point`, so you can switch call sites over before you upgrade.

#### Annotations

| 2.5                               | 3.0                                                                                       |
|-----------------------------------|-------------------------------------------------------------------------------------------|
| `@Embedded`                       | `@Entity` with no `@Id`; see [`@Embedded` removed](#embedded-removed)                     |
| `@NotSaved`                       | `@LoadOnly`                                                                               |
| `@experimental.Constructor`       | nothing: remove it. See [Constructors](../mapping/#constructors) for how Morphia picks one |
| `@Converters`, `@Handler`         | no replacement. Register a codec provider instead: see [User-defined Codecs](../configuration/#user-defined-codecs) and [Property Codecs](../configuration/#property-codecs) |

### Extension SPI and internal constructors

This section only matters if you constructed Morphia's stage, expression or filter classes directly, or extended Morphia's
internals. Code that builds pipelines and queries through the static factories isn't affected.

#### Use the static factories instead of constructors

The public constructors of every aggregation stage, and of most classes in `dev.morphia.aggregation.expressions.impls`, are now
internal. Create them with their static factories instead:

| 2.5                                                    | 3.0                                                                      |
|--------------------------------------------------------|--------------------------------------------------------------------------|
| `new Group()`, `new Match()`, `new Sort()`, and the other classes in `dev.morphia.aggregation.stages` | the stage's factory: `Group.group()`, `Match.match(..)`, `Sort.sort()`, `Unwind.unwind(..)`, and so on |
| `new Group.GroupId()`                                  | `Group.id()`, `Group.id(..)`                                             |
| `new Densify.Range(..)`                                | `Densify.Range.bounded(..)`, `full(..)`, `partition(..)`                 |
| `new DateToString()`, `new IfNull()`, and the other `expressions.impls` classes | the factory in the matching `*Expressions` class, such as `DateExpressions.dateToString()` or `ConditionalExpressions.ifNull()` |
| `new dev.morphia.query.Sort(..)`                       | `Sort.ascending(field)`, `Sort.descending(field)`, `naturalAscending()`, `naturalDescending()` |
| `new TextSearchFilter(..)`                             | `Filters.text(..)`                                                       |
| `new CurrentDateOperator(..)`                          | `UpdateOperators.currentDate(field)`                                     |
| `new MorphiaCursor(..)`                                | `query.iterator()`, or `aggregation.iterator()`                          |

Subclassing `Stage` to add a custom stage is no longer supported, since its constructor is internal too.

These accessors are also now internal: `ArraySlice.getLimit()` and `getSkip()`, `dev.morphia.query.Sort.getField()` and `getOrder()`,
and `RegexFilter.pattern()`. Pass the pattern to `Filters.regex(field, pattern)` instead. `ArrayExpressions.array(Expression...)` is
gone; `array(Object...)` remains, returns an `Expression`, and is marked `@MorphiaExperimental`.

#### Custom filters, expressions and conventions

Encoding moved out of the filter and expression classes into codecs that Morphia registers itself. As a result:

- `encode()` is gone from the `expressions.impls` classes that had it, such as `DateToString`, `IfNull` and `SwitchExpression`, and
  from `RegexFilter` and `TextSearchFilter`.
- `Filter.writeNamedValue()` and `writeUnnamedValue()` are gone, and `Filter.getValue()`, `setValue()` and `path()` are internal.
- Getters that only served encoding are gone: `CurrentDateOperator.toTarget()`, `CurrentDateOperator.TypeSpecification.toTarget()`,
  `IfNull.getDocument()`, `getReplacement()` and `getTarget()`, and `ConvertType.getIdentifier()`. `DateToParts.timezone(Expression)`
  is replaced by `timezone(Object)`.
- These `expressions.impls` types are now internal: `Accumulator`, `ArrayExpression`, `ArrayLiteral`, `EndResultsExpression`,
  `ExpMovingAvg`, `FieldHolder`, `Fields`, `FunctionExpression`, `LiteralExpression`, `MathExpression`, `MetaExpression`,
  `NRankedResultsExpression`, `RankedResultsExpression`, `ReduceExpression`, `ReplaceExpression`, `SetFieldExpression`,
  `ShiftExpression`, `UnsetFieldExpression` and `ValueExpression`.

There's no supported way to plug in your own filter or expression encoding. If you subclassed a filter or expression to change what
it writes, build the same query with `Filters.expr(..)` and the expression factories, or pass a native `Document` query to
`datastore.find(Type.class, document)`.

`MorphiaConvention.apply(Mapper, EntityModelBuilder)` is gone. `MorphiaConvention` now extends `MappingConvention<EntityModel>`, so a
convention implements `apply(Mapper, EntityModel)` and works on the finished model. Register conventions with `ServiceLoader`, in
`META-INF/services/dev.morphia.mapping.conventions.MorphiaConvention`. `MapperOptions.Builder.addConvention()` went away with
`MapperOptions`.

#### Mapping internals

`InstanceCreatorFactory` and `MappingValidator` are now internal. The `EntityAndEmbed`, `EntityOrEmbed` and `MultipleId` class rules,
`ValidationExtension.hasAnnotation()` and `OnEntityListenerAdapter` are gone, with no replacement.

## Migrating to 2.5
Morphia 2.5 is primarily a driver upgrade.  Changes in the driver are incompatible with the 2.4 driver and so Morphia 2.5 requires a
driver version of 5.x or greater.  If you need a 4.x driver for some reason, you can use Morphia 2.4.x.  The 2.5.x series can only
support 5.x and greater.  In preparation for 3.0, deprecations will be incrementally made in the 2.5.x line with replacements where
feasible.  Updating away from these deprecations will make the transition to 3.0 much smoother.  In the cases where the replacements can
not feasibly be provided, migration scripts will be available as part of the 3.0 release to help reduce the impact of such changes.  Bug
fixes will continue to be made on the 2.4.x series and 2.5.x as necessary but the primary focus remains on 3.x.

## Migrating to 2.4

### Configuration
Morphia 2.4 introduces file-based configuration instead of the programmatic configuration currently in use.  The file
should live in your build's resources folder and be named `META-INF/morphia-config.properties`.  More information can be found in
[configuration section](../configuration/).  This new approach is optional but in order to aid in your migration to the new
configuration file, you can manually generate that content by calling
`MapperOptions#toConfigFormat(String database, boolean showComplete)` on your instance.  This will return a `String` which can be copied
in to your configuration file.

`MorphiaConfig` is the programmatic option that replaces the `MapperOptions` class.  This class is a builder for the configuration and
works the same way as the `MapperOptions.Builder` class.  This class is immutable which allows for safe sharing between `Datastore`
instances should you need to do so.  If you create a `META-INF/morphia-config.properties` file, you can load that configuration using
`MorphiaConfig#load()` which will return a `MorphiaConfig` instance configured according to the contents of that file.

### Deprecations
    "Man Plans and God Laughs."
        -- old Yiddish adage

The 2.4.0 release, and any subsequent patch releases, will be the last of the 2.x releases as attention is turned toward a major 3.0
release.  Consequently, now is the time to replace any uses of deprecated elements with their recommended replacements.  Should you find
a deprecated element without a documented replacement, please file [an issue](https://github.com/MorphiaOrg/morphia/issues).  There are a
handful of deprecations that currently have no replacement but are deprecated to serve as a bit of heads up that, e.g., the return type is
shifting and that it will need attention after the upgrade to 3.0.

## Migrating to 2.3

### Experimental packages

To address various issues in older APIs, some new packages were introduced under an `experimental` subpackage.  These packages have had
sufficient time to bake and are being promoted out of experimental status in 2.3.  Unfortunately, there isn't a feasible, non-breaking
way to do this so upgrading to 2.3 is a mild breaking change.  The good news is that these breaks can be fixed by doing a global
removal of `.experimental`.  This should fix all the cases where Morphia has promoted these packages.

There are, however, two options being provided that might help with this process.  As always, make sure to commit any of your changes before using an external tool to mass update your code.  And, of course, examine the changes afterward to ensure no breakages.

#### OpenRewrite

The first tool is [openrewrite](https://github.com/openrewrite).  This is a powerful, general purpose tool for updates and migrations of
all sorts.  In our case, it's primarily just removing the `experimental` segment out of a few packages.  To use this script, download the
[script](https://github.com/MorphiaOrg/morphia/blob/master/upgrading/UpgradeFrom22to23.yml) and save it as `rewrite.yml` in the root of
your project.  Once that is done, run the following command:

```shell
mvn org.openrewrite.maven:rewrite-maven-plugin:4.37.0:runNoFork -DactiveRecipes=dev.morphia.UpgradeFrom22to23
```

This script will update the packages to reflect their new names.  It will also update your pom to the latest Morphia version for you
if that has not been updated yet.

#### jbang

Alternately, if you have [jbang](https://www.jbang.dev/) installed, you can run a script to do this work for you.  It's a little more brute
force than the openrewrite approach (it's literally just doing string replacements) but might be necessary in some cases.  If you're a
kotlin user, you'll want to use this approach as openrewrite does not currently support kotlin source files.  To run this script, use the
following command:

```shell
jbang https://github.com/MorphiaOrg/morphia/blob/master/upgrading/UpgradeFrom22to23.kt
```

You will likely be asked to specify the level of trust you have for this script and the MorphiaOrg github organization.  Choose whichever
level you're comfortable with.

Whichever path you choose, even if that's manually doing the updates yourself, make sure to examine the diffs and run your tests to make
sure nothing was broken.  Though these approaches have both been tested on a number of projects, user code and project structures can be
wildly different and some unhandled corner cases might arise.

{{< admonition type="note" title="Note" >}}
In the future such "experimental" items, the ones that need a little time to "bake" and get real world usage and feedback, will be marked
with `@MorphiaExperimental` and javadoc'd as experimental.  When you see these items, they are intended to be used and any usability
issues should be reported so that things can get massaged into, or replaced with, better forms.
{{< /admonition >}}

### Legacy Configuration

As part of the modernization of mapping configuration introduced in 2.0, a `legacy()` option was added to `MapperOptions` to preconfigure
the mapping options to reflect the pre-2.0 configuration style.  Part of the modernization of 2.0 also included how querying is done.
The `legacy()` method mentioned above also configured this legacy querying style.  As of 3.0, this `legacy()` option, and the querying
API associated with it, will go away.

However, it will still be possible to configure your application with the old settings, you will just have to be explicit about it.  To
update to this new configuration approach, rather than using `MappingOptions.legacy().build()` as you have perhaps been doing, simply
replace it with something like the following:

```java
    MapperOptions.builder()
        .discriminatorKey("className")
        .discriminator(DiscriminatorFunction.className())
        .collectionNaming(NamingStrategy.identity())
        .propertyNaming(NamingStrategy.identity())
```

This will preserve the older mappings used by your data while enabling the modern query API implementation.  Some users will have
date/time data stored under an older storage scheme.  Those users will also want to include the following option:

```java
    .dateStorage(DateStorage.SYSTEM_DEFAULT)
```

## Migrating to 2.0

### Versioning

Versioned updates now throw `VersionMismatchException` instead of `ConcurrentModification` exception.
This allows for more targeted catches.
For historical reasons, this new exception extends `ConcurrentModification` so that any existing catch clauses will continue to work.
However, applications should be updated to catch the new exception.
A future release will change the parent type of
`VersionMismatchException` to `RuntimeException` instead.
See [this discussion](https://github.com/MorphiaOrg/morphia/issues/982) for more details.

### Kotlin Support

Kotlin classes have worked with Morphia for years now but certain Kotlin features have started to cause problems as folks have started trying to use them in their applications.
To this end a new module has been introduced, `morphia-kotlin`, to specifically focus on these cases.
Chances are good that you won't need this module but in some cases this new module can help.
See the
[reference guide](../kotlin/) for more details.

### Nullability

The API is now explicitly decorated with `@NonNull` and `@Nullable` annotations to indicate which parameters and return values support null references.
Your IDE should give you in place hints when you run afoul of these annotations and guide you to properly handling null values.
