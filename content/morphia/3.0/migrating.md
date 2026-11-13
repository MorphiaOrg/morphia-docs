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
Morphia version; with Maven it updates the `morphia-core` dependency in your pom for you. Moving off 2.5's deprecated APIs first
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
| `datastore.aggregate("collection")`                                   | `datastore.aggregate(Document.class, aggregationOptions().collection("collection"))` |
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
| `UpdateReturnType`    | `Update<T> result = query.update(..).execute()`             | `UpdateResult result = query.update(..)`                                    |

In 3.0, `Query` no longer takes a `FindOptions` when you run it: pass the options to `Datastore.find(Class, FindOptions)` instead.
`QueryFindOptions` moves them only when the call is chained from that `find()` call. For one held in a variable or passed in from
elsewhere, move the options yourself.

`UpdateExecute` and `UpdateReturnType` handle the `update(..).execute()` and `modify(..).execute()` chains. An `Update` or `Modify`
held in a variable, and code that uses the legacy `UpdateOperations` API, need the manual changes described in
[Legacy APIs](#legacy-query-update-and-aggregation-apis).

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

<!-- MorphiaOrg/morphia#4481: legacy criteria query API, legacy update and modify API, pre-2.0 aggregation pipeline -->

### Options, keys, geo types and annotations

<!-- MorphiaOrg/morphia#4482: options getters, Key/AdvancedDatastore/InsertOptions, geo types, annotations -->

### Extension SPI and internal constructors

<!-- MorphiaOrg/morphia#4483: extension SPI changes, constructors that are now internal -->

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
