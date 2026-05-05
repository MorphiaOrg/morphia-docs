---
title: "Aggregations"
weight: 140
---

The [aggregation framework](https://docs.mongodb.com/manual/aggregation) in MongoDB allows you to define a series (called a pipeline) of operations (called stages) against the data in a collection.
These pipelines can be used for analytics or they can be used to convert your data from one form to another.
This guide will not go in to the details of how aggregation works, however.
The official MongoDB [documentation](https://docs.mongodb.com/manual/aggregation) has extensive tutorials on such details.
Rather, this guide will focus on the Morphia API. The examples shown here are taken from the
[tests](https://github.com/MorphiaOrg/morphia/tree/master/core/src/test/java/dev/morphia/aggregation/AggregationTest.java) in Morphia itself. You can find the full list in the [Supported Operators](#supported-operators) section.

Writing an aggregation pipeline starts just like writing a standard query.
As with querying, we start with the `Datastore`:

```java
```
{{< include-code file="TestDocsExamples.java" tag="basic" >}}

`aggregate()` takes a `Class` literal. This lets Morphia know which collection to perform this aggregation against. Because of the transformational operations available in the aggregation [pipeline](https://docs.mongodb.com/manual/core/aggregation-pipeline), Morphia can not validate as much as it can with querying so care will need to be taken to ensure document fields actually exist when referencing them in your pipeline.

## The Pipeline

Aggregation pipelines are comprised of a series stages.
Our example here with the `group()` stage. This method is the Morphia equivalent of the
[$group](https://docs.mongodb.com/manual/reference/operator/aggregation/group/) operator. This stage, as the name suggests, groups together documents based on
various criteria. In this example, we are defining the group ID as the `author` field which will collect all the books by the author
together.

The next step defines a new field, `books` comprised of the titles of the books found in each document.  (For reference, this example is
the Morphia equivalent of an [example](https://docs.mongodb.com/manual/reference/operator/aggregation/group/#group-title-by-author) found in the aggregation tutorials.) This results in a series of documents that look like this:

```json
{ "_id" : "Homer", "books" : [ "The Odyssey", "Iliad" ] }
{ "_id" : "Dante", "books" : [ "The Banquet", "Divine Comedy", "Eclogues" ] }
```

## Executing the Pipeline

Once your pipeline is complete, you can execute it via the `execute()` method.
This method optionally takes a `Class` reference for the target type of your aggregation.
Given this type, Morphia will map each document in the results and return it.
Additionally, you can also include some options to `execute()`.
We can use the various options on the
[AggregationOptions](javadoc/dev/morphia/aggregation/AggregationOptions.html) class to configure how we want the pipeline to execute.

## $out

Depending your use case, you might not want to return the results of your aggregation but simply output them to another collection.
That's where `$out` comes in.  [$out](https://docs.mongodb.com/manual/reference/operator/aggregation/out/) is an operator that allows the results of a pipeline to be stored in to a named collection.
This collection can not be sharded or a capped collection, however. This collection, if it does not exist, will be created upon execution of the pipeline.

{{< admonition type="warning" title="Warning" >}}
Any existing data in the collection will be replaced by the output of the aggregation.
{{< /admonition >}}

An example aggregation using the `$out` stage looks like this:

```java
```
{{< include-code file="TestDocsExamples.java" tag="out" >}}

You'll note that `out()` is the final stage.  `$out` and `$merge` must be the final stage in our pipeline.  We pass a type to `out()`
that reflects the collection we want to write our output to.  Morphia will use the type-to-collection mapping you've defined when mapping
your entities to determine that collection name.  You may also pass a String with the collection name as well if the target collection
does not correspond to a mapped entity.

## $merge

[$merge](https://docs.mongodb.com/manual/reference/operator/aggregation/merge/) is a very similar option with a some major differences.
The biggest difference is that `$merge` can write to existing collections without destroying the existing documents.  `$out` would
overwrite any existing documents and replace them with the results of the pipeline.  `$merge`, however, can deposit these new results alongside existing data and update existing data.

Using `$merge` might look something like this:

```java
```
{{< include-code file="TestDocsExamples.java" tag="merge" >}}

Much like `out()` above, for `merge()` we pass in a collection information but here we are also passing in which database to find/create
the collection in. A merge is slightly more complex and so has more options to consider.
In this example, we're merging in to the `budgets` collection in the `reporting` database and merging any existing documents based on the`_id` as denoted using the `on()` method.
Because there may be existing data in the collection, we need to instruct the operation how to handle those cases.
In this example, when documents matching we're choosing to replace them and when they don't we're instructing the operation to insert the
new documents in to the collection.  Other options are defined on `com.mongodb.client.model.MergeOptions` type defined by the Java driver.

## Supported Operators
Every effort is made to provide 100% coverage of all the operators offered by MongoDB. A select handful of operators have been excluded
for reasons of suitability in Morphia.  In short, some operators just don't make sense in Morphia.  Below is listed all the currently
supported operators.  To see an example of an operator in action, click through to see the test cases for that operator.

If an operator is missing and you think it should be included, please file an [issue](https://github.com/MorphiaOrg/morphia/issues) for that operator.


| Operator | Docs |
|---|---|
| Test Examples | [$addFields](http://docs.mongodb.org/manual/reference/operator/aggregation/addFields) |
| [AddFields#addFields()](javadoc/dev/morphia/aggregation/stages/AddFields.html#addFields()) | [TestAddFields](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestAddFields.java) |
| [$bucket](http://docs.mongodb.org/manual/reference/operator/aggregation/bucket) | [Bucket#bucket()](javadoc/dev/morphia/aggregation/stages/Bucket.html#bucket()) |
| [TestBucket](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestBucket.java) | [$bucketAuto](http://docs.mongodb.org/manual/reference/operator/aggregation/bucketAuto) |
| [AutoBucket#autoBucket()](javadoc/dev/morphia/aggregation/stages/AutoBucket.html#autoBucket()) | [TestBucketAuto](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestBucketAuto.java) |
| [$changeStream](http://docs.mongodb.org/manual/reference/operator/aggregation/changeStream) | [ChangeStream#changeStream()](javadoc/dev/morphia/aggregation/stages/ChangeStream.html#changeStream()) |
| [TestChangeStream](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestChangeStream.java) | [$collStats](http://docs.mongodb.org/manual/reference/operator/aggregation/collStats) |
| [CollectionStats#collStats()](javadoc/dev/morphia/aggregation/stages/CollectionStats.html#collStats()) | [TestCollStats](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestCollStats.java) |
| [$count](http://docs.mongodb.org/manual/reference/operator/aggregation/count) | [Count#count(String)](javadoc/dev/morphia/aggregation/stages/Count.html#count(java.lang.String)) |
| [TestCount](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestCount.java) | [$currentOp](http://docs.mongodb.org/manual/reference/operator/aggregation/currentOp) |
| [CurrentOp#currentOp()](javadoc/dev/morphia/aggregation/stages/CurrentOp.html#currentOp()) | [TestCurrentOp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestCurrentOp.java) |
| [$densify](http://docs.mongodb.org/manual/reference/operator/aggregation/densify) | [Densify#densify(String,Range)](javadoc/dev/morphia/aggregation/stages/Densify.html#densify(java.lang.String,dev.morphia.aggregation.stages.Range)) |
| [TestDensify](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestDensify.java) | [$documents](http://docs.mongodb.org/manual/reference/operator/aggregation/documents) |
| [Documents#documents(DocumentExpression...)](javadoc/dev/morphia/aggregation/stages/Documents.html#documents(dev.morphia.aggregation.expressions.impls.DocumentExpression%2E%2E%2E)) | [TestDocuments](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestDocuments.java) |
| [$facet](http://docs.mongodb.org/manual/reference/operator/aggregation/facet) | [Facet#facet()](javadoc/dev/morphia/aggregation/stages/Facet.html#facet()) |
| [TestFacet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestFacet.java) | [$fill](http://docs.mongodb.org/manual/reference/operator/aggregation/fill) |
| [Fill#fill()](javadoc/dev/morphia/aggregation/stages/Fill.html#fill()) | [TestFill](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestFill.java) |
| [$geoNear](http://docs.mongodb.org/manual/reference/operator/aggregation/geoNear) | [TestGeoNear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestGeoNear.java) |
| [$graphLookup](http://docs.mongodb.org/manual/reference/operator/aggregation/graphLookup) | [TestGraphLookup](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestGraphLookup.java) |
| [$group](http://docs.mongodb.org/manual/reference/operator/aggregation/group) | [TestGroup](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestGroup.java) |
| [$indexStats](http://docs.mongodb.org/manual/reference/operator/aggregation/indexStats) | [IndexStats#indexStats()](javadoc/dev/morphia/aggregation/stages/IndexStats.html#indexStats()) |
| [TestIndexStats](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestIndexStats.java) | [$limit](http://docs.mongodb.org/manual/reference/operator/aggregation/limit) |
| [Limit#limit(long)](javadoc/dev/morphia/aggregation/stages/Limit.html#limit(long)) | [TestLimit](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestLimit.java) |
| [$lookup](http://docs.mongodb.org/manual/reference/operator/aggregation/lookup) | [TestLookup](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestLookup.java) |
| [$match](http://docs.mongodb.org/manual/reference/operator/aggregation/match) | [Match#match(Filter...)](javadoc/dev/morphia/aggregation/stages/Match.html#match(dev.morphia.query.filters.Filter%2E%2E%2E)) |
| [TestMatch](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestMatch.java) | [$planCacheStats](http://docs.mongodb.org/manual/reference/operator/aggregation/planCacheStats) |
| [PlanCacheStats#planCacheStats()](javadoc/dev/morphia/aggregation/stages/PlanCacheStats.html#planCacheStats()) | [TestPlanCacheStats](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestPlanCacheStats.java) |
| [$project](http://docs.mongodb.org/manual/reference/operator/aggregation/project) | [Projection#project()](javadoc/dev/morphia/aggregation/stages/Projection.html#project()) |
| [TestProject](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestProject.java) | [$redact](http://docs.mongodb.org/manual/reference/operator/aggregation/redact) |
| [Redact#redact(Expression)](javadoc/dev/morphia/aggregation/stages/Redact.html#redact(dev.morphia.aggregation.expressions.impls.Expression)) | [TestRedact](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestRedact.java) |
| [$replaceRoot](http://docs.mongodb.org/manual/reference/operator/aggregation/replaceRoot) | [ReplaceRoot#replaceRoot()](javadoc/dev/morphia/aggregation/stages/ReplaceRoot.html#replaceRoot()) |
| [TestReplaceRoot](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestReplaceRoot.java) | [$replaceWith](http://docs.mongodb.org/manual/reference/operator/aggregation/replaceWith) |
| [ReplaceWith#replaceWith()](javadoc/dev/morphia/aggregation/stages/ReplaceWith.html#replaceWith()) | [TestReplaceWith](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestReplaceWith.java) |
| [$sample](http://docs.mongodb.org/manual/reference/operator/aggregation/sample) | [Sample#sample(long)](javadoc/dev/morphia/aggregation/stages/Sample.html#sample(long)) |
| [TestSample](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSample.java) | [$set](http://docs.mongodb.org/manual/reference/operator/aggregation/set) |
| [Set#set()](javadoc/dev/morphia/aggregation/stages/Set.html#set()) | [TestSet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSet.java) |
| [$setWindowFields](http://docs.mongodb.org/manual/reference/operator/aggregation/setWindowFields) | [SetWindowFields#setWindowFields()](javadoc/dev/morphia/aggregation/stages/SetWindowFields.html#setWindowFields()) |
| [TestSetWindowFields](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSetWindowFields.java) | [$skip](http://docs.mongodb.org/manual/reference/operator/aggregation/skip) |
| [Skip#skip(long)](javadoc/dev/morphia/aggregation/stages/Skip.html#skip(long)) | [TestSkip](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSkip.java) |
| [$sort](http://docs.mongodb.org/manual/reference/operator/aggregation/sort) | [Sort#sort()](javadoc/dev/morphia/aggregation/stages/Sort.html#sort()) |
| [TestSort](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSort.java) | [$sortByCount](http://docs.mongodb.org/manual/reference/operator/aggregation/sortByCount) |
| [SortByCount#sortByCount(Object)](javadoc/dev/morphia/aggregation/stages/SortByCount.html#sortByCount(java.lang.Object)) | [TestSortByCount](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestSortByCount.java) |
| [$unionWith](http://docs.mongodb.org/manual/reference/operator/aggregation/unionWith) | [TestUnionWith](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestUnionWith.java) |
| [$unset](http://docs.mongodb.org/manual/reference/operator/aggregation/unset) | [Unset#unset(String,String...)](javadoc/dev/morphia/aggregation/stages/Unset.html#unset(java.lang.String,java.lang.String%2E%2E%2E)) |
| [TestUnset](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestUnset.java) | [$unwind](http://docs.mongodb.org/manual/reference/operator/aggregation/unwind) |
| [Unwind#unwind(String)](javadoc/dev/morphia/aggregation/stages/Unwind.html#unwind(java.lang.String)) | [TestUnwind](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/stages/TestUnwind.java) |



| Operator | Docs |
|---|---|
| Test Examples | [$abs](http://docs.mongodb.org/manual/reference/operator/aggregation/abs) |
| [MathExpressions#abs(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#abs(java.lang.Object)) | [TestAbs](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAbs.java) |
| [$accumulator](http://docs.mongodb.org/manual/reference/operator/aggregation/accumulator) | [AccumulatorExpressions#accumulator(String,String,List,String)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#accumulator(java.lang.String,java.lang.String,java.util.List,java.lang.String)) |
| [TestAccumulator](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAccumulator.java) | [$acos](http://docs.mongodb.org/manual/reference/operator/aggregation/acos) |
| [TrigonometryExpressions#acos(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#acos(java.lang.Object)) | [TestAcos](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAcos.java) |
| [$acosh](http://docs.mongodb.org/manual/reference/operator/aggregation/acosh) | [TrigonometryExpressions#acosh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#acosh(java.lang.Object)) |
| [TestAcosh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAcosh.java) | [$add](http://docs.mongodb.org/manual/reference/operator/aggregation/add) |
| [MathExpressions#add(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#add(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestAdd](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAdd.java) |
| [$addToSet](http://docs.mongodb.org/manual/reference/operator/aggregation/addToSet) | [AccumulatorExpressions#addToSet(Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#addToSet(java.lang.Object)) |
| [TestAddToSet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAddToSet.java) | [$allElementsTrue](http://docs.mongodb.org/manual/reference/operator/aggregation/allElementsTrue) |
| [SetExpressions#allElementsTrue(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#allElementsTrue(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestAllElementsTrue](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAllElementsTrue.java) |
| [$and](http://docs.mongodb.org/manual/reference/operator/aggregation/and) | [TestAnd](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAnd.java) |
| [$anyElementTrue](http://docs.mongodb.org/manual/reference/operator/aggregation/anyElementTrue) | [SetExpressions#anyElementTrue(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#anyElementTrue(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestAnyElementTrue](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAnyElementTrue.java) | [$arrayElemAt](http://docs.mongodb.org/manual/reference/operator/aggregation/arrayElemAt) |
| [ArrayExpressions#elementAt(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#elementAt(java.lang.Object,java.lang.Object)) | [TestArrayElemAt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestArrayElemAt.java) |
| [$arrayToObject](http://docs.mongodb.org/manual/reference/operator/aggregation/arrayToObject) | [ArrayExpressions#arrayToObject(Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#arrayToObject(java.lang.Object)) |
| [TestArrayToObject](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestArrayToObject.java) | [$asin](http://docs.mongodb.org/manual/reference/operator/aggregation/asin) |
| [TrigonometryExpressions#asin(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#asin(java.lang.Object)) | [TestAsin](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAsin.java) |
| [$asinh](http://docs.mongodb.org/manual/reference/operator/aggregation/asinh) | [TrigonometryExpressions#asinh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#asinh(java.lang.Object)) |
| [TestAsinh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAsinh.java) | [$atan](http://docs.mongodb.org/manual/reference/operator/aggregation/atan) |
| [TrigonometryExpressions#atan(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#atan(java.lang.Object)) | [TestAtan](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAtan.java) |
| [$atan2](http://docs.mongodb.org/manual/reference/operator/aggregation/atan2) | [TrigonometryExpressions#atan2(Object,Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#atan2(java.lang.Object,java.lang.Object)) |
| [TestAtan2](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAtan2.java) | [$atanh](http://docs.mongodb.org/manual/reference/operator/aggregation/atanh) |
| [TrigonometryExpressions#atanh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#atanh(java.lang.Object)) | [TestAtanh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAtanh.java) |
| [$avg](http://docs.mongodb.org/manual/reference/operator/aggregation/avg) | [AccumulatorExpressions#avg(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#avg(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestAvg](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestAvg.java) | [$binarySize](http://docs.mongodb.org/manual/reference/operator/aggregation/binarySize) |
| [DataSizeExpressions#binarySize(Object)](javadoc/dev/morphia/aggregation/expressions/DataSizeExpressions.html#binarySize(java.lang.Object)) | [TestBinarySize](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBinarySize.java) |
| [$bitAnd](http://docs.mongodb.org/manual/reference/operator/aggregation/bitAnd) | [MathExpressions#bitAnd(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#bitAnd(java.lang.Object,java.lang.Object)) |
| [TestBitAnd](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBitAnd.java) | [$bitNot](http://docs.mongodb.org/manual/reference/operator/aggregation/bitNot) |
| [MathExpressions#bitNot(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#bitNot(java.lang.Object)) | [TestBitNot](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBitNot.java) |
| [$bitOr](http://docs.mongodb.org/manual/reference/operator/aggregation/bitOr) | [MathExpressions#bitOr(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#bitOr(java.lang.Object,java.lang.Object)) |
| [TestBitOr](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBitOr.java) | [$bitXor](http://docs.mongodb.org/manual/reference/operator/aggregation/bitXor) |
| [MathExpressions#bitXor(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#bitXor(java.lang.Object,java.lang.Object)) | [TestBitXor](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBitXor.java) |
| [$bottom](http://docs.mongodb.org/manual/reference/operator/aggregation/bottom) | [AccumulatorExpressions#bottom(Object,Sort...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#bottom(java.lang.Object,dev.morphia.query.Sort%2E%2E%2E)) |
| [TestBottom](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBottom.java) | [$bottomN](http://docs.mongodb.org/manual/reference/operator/aggregation/bottomN) |
| [AccumulatorExpressions#bottomN(Object,Object,Sort...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#bottomN(java.lang.Object,java.lang.Object,dev.morphia.query.Sort%2E%2E%2E)) | [TestBottomN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBottomN.java) |
| [$bsonSize](http://docs.mongodb.org/manual/reference/operator/aggregation/bsonSize) | [DataSizeExpressions#bsonSize(Object)](javadoc/dev/morphia/aggregation/expressions/DataSizeExpressions.html#bsonSize(java.lang.Object)) |
| [TestBsonSize](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestBsonSize.java) | [$ceil](http://docs.mongodb.org/manual/reference/operator/aggregation/ceil) |
| [MathExpressions#ceil(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#ceil(java.lang.Object)) | [TestCeil](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCeil.java) |
| [$cmp](http://docs.mongodb.org/manual/reference/operator/aggregation/cmp) | [ComparisonExpressions#cmp(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#cmp(java.lang.Object,java.lang.Object)) |
| [TestCmp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCmp.java) | [$concat](http://docs.mongodb.org/manual/reference/operator/aggregation/concat) |
| [StringExpressions#concat(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#concat(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestConcat](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestConcat.java) |
| [$concatArrays](http://docs.mongodb.org/manual/reference/operator/aggregation/concatArrays) | [ArrayExpressions#concatArrays(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#concatArrays(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestConcatArrays](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestConcatArrays.java) | [$cond](http://docs.mongodb.org/manual/reference/operator/aggregation/cond) |
| [ConditionalExpressions#condition(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/ConditionalExpressions.html#condition(java.lang.Object,java.lang.Object,java.lang.Object)) | [TestCond](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCond.java) |
| [$convert](http://docs.mongodb.org/manual/reference/operator/aggregation/convert) | [TypeExpressions#convert(Object,ConvertType)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#convert(java.lang.Object,dev.morphia.aggregation.expressions.impls.ConvertType)) |
| [TestConvert](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestConvert.java) | [$cos](http://docs.mongodb.org/manual/reference/operator/aggregation/cos) |
| [TrigonometryExpressions#cos(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#cos(java.lang.Object)) | [TestCos](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCos.java) |
| [$cosh](http://docs.mongodb.org/manual/reference/operator/aggregation/cosh) | [TrigonometryExpressions#cosh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#cosh(java.lang.Object)) |
| [TestCosh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCosh.java) | [$count](http://docs.mongodb.org/manual/reference/operator/aggregation/count) |
| [AccumulatorExpressions#count()](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#count()) | [TestCount](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCount.java) |
| [$covariancePop](http://docs.mongodb.org/manual/reference/operator/aggregation/covariancePop) | [WindowExpressions#covariancePop(Object,Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#covariancePop(java.lang.Object,java.lang.Object)) |
| [TestCovariancePop](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCovariancePop.java) | [$covarianceSamp](http://docs.mongodb.org/manual/reference/operator/aggregation/covarianceSamp) |
| [WindowExpressions#covarianceSamp(Object,Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#covarianceSamp(java.lang.Object,java.lang.Object)) | [TestCovarianceSamp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestCovarianceSamp.java) |
| [$dateAdd](http://docs.mongodb.org/manual/reference/operator/aggregation/dateAdd) | [DateExpressions#dateAdd(Object,long,TimeUnit)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateAdd(java.lang.Object,long,dev.morphia.aggregation.expressions.TimeUnit)) |
| [TestDateAdd](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateAdd.java) | [$dateDiff](http://docs.mongodb.org/manual/reference/operator/aggregation/dateDiff) |
| [DateExpressions#dateDiff(Object,Object,TimeUnit)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateDiff(java.lang.Object,java.lang.Object,dev.morphia.aggregation.expressions.TimeUnit)) | [TestDateDiff](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateDiff.java) |
| [$dateFromParts](http://docs.mongodb.org/manual/reference/operator/aggregation/dateFromParts) | [DateExpressions#dateFromParts()](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateFromParts()) |
| [TestDateFromParts](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateFromParts.java) | [$dateFromString](http://docs.mongodb.org/manual/reference/operator/aggregation/dateFromString) |
| [DateExpressions#dateFromString()](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateFromString()) | [TestDateFromString](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateFromString.java) |
| [$dateSubtract](http://docs.mongodb.org/manual/reference/operator/aggregation/dateSubtract) | [DateExpressions#dateSubtract(Object,long,TimeUnit)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateSubtract(java.lang.Object,long,dev.morphia.aggregation.expressions.TimeUnit)) |
| [TestDateSubtract](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateSubtract.java) | [$dateToParts](http://docs.mongodb.org/manual/reference/operator/aggregation/dateToParts) |
| [DateExpressions#dateToParts(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateToParts(java.lang.Object)) | [TestDateToParts](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateToParts.java) |
| [$dateToString](http://docs.mongodb.org/manual/reference/operator/aggregation/dateToString) | [DateExpressions#dateToString()](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateToString()) |
| [TestDateToString](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateToString.java) | [$dateTrunc](http://docs.mongodb.org/manual/reference/operator/aggregation/dateTrunc) |
| [DateExpressions#dateTrunc(Object,TimeUnit)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dateTrunc(java.lang.Object,dev.morphia.aggregation.expressions.TimeUnit)) | [TestDateTrunc](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDateTrunc.java) |
| [$dayOfMonth](http://docs.mongodb.org/manual/reference/operator/aggregation/dayOfMonth) | [DateExpressions#dayOfMonth(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dayOfMonth(java.lang.Object)) |
| [TestDayOfMonth](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDayOfMonth.java) | [$dayOfWeek](http://docs.mongodb.org/manual/reference/operator/aggregation/dayOfWeek) |
| [DateExpressions#dayOfWeek(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dayOfWeek(java.lang.Object)) | [TestDayOfWeek](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDayOfWeek.java) |
| [$dayOfYear](http://docs.mongodb.org/manual/reference/operator/aggregation/dayOfYear) | [DateExpressions#dayOfYear(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#dayOfYear(java.lang.Object)) |
| [TestDayOfYear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDayOfYear.java) | [$degreesToRadians](http://docs.mongodb.org/manual/reference/operator/aggregation/degreesToRadians) |
| [TrigonometryExpressions#degreesToRadians(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#degreesToRadians(java.lang.Object)) | [TestDegreesToRadians](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDegreesToRadians.java) |
| [$denseRank](http://docs.mongodb.org/manual/reference/operator/aggregation/denseRank) | [WindowExpressions#denseRank()](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#denseRank()) |
| [TestDenseRank](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDenseRank.java) | [$derivative](http://docs.mongodb.org/manual/reference/operator/aggregation/derivative) |
| [WindowExpressions#derivative(Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#derivative(java.lang.Object)) | [TestDerivative](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDerivative.java) |
| [$divide](http://docs.mongodb.org/manual/reference/operator/aggregation/divide) | [MathExpressions#divide(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#divide(java.lang.Object,java.lang.Object)) |
| [TestDivide](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDivide.java) | [$documentNumber](http://docs.mongodb.org/manual/reference/operator/aggregation/documentNumber) |
| [WindowExpressions#documentNumber()](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#documentNumber()) | [TestDocumentNumber](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestDocumentNumber.java) |
| [$eq](http://docs.mongodb.org/manual/reference/operator/aggregation/eq) | [ComparisonExpressions#eq(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#eq(java.lang.Object,java.lang.Object)) |
| [TestEq](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestEq.java) | [$exp](http://docs.mongodb.org/manual/reference/operator/aggregation/exp) |
| [MathExpressions#exp(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#exp(java.lang.Object)) | [TestExp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestExp.java) |
| [$expMovingAvg](http://docs.mongodb.org/manual/reference/operator/aggregation/expMovingAvg) | [TestExpMovingAvg](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestExpMovingAvg.java) |
| [$filter](http://docs.mongodb.org/manual/reference/operator/aggregation/filter) | [TestFilter](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestFilter.java) |
| [$first](http://docs.mongodb.org/manual/reference/operator/aggregation/first) | [AccumulatorExpressions#first(Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#first(java.lang.Object)) |
| [TestFirst](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestFirst.java) | [$firstN](http://docs.mongodb.org/manual/reference/operator/aggregation/firstN) |
| [AccumulatorExpressions#firstN(Object,Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#firstN(java.lang.Object,java.lang.Object)) | [TestFirstN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestFirstN.java) |
| [$floor](http://docs.mongodb.org/manual/reference/operator/aggregation/floor) | [MathExpressions#floor(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#floor(java.lang.Object)) |
| [TestFloor](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestFloor.java) | [$function](http://docs.mongodb.org/manual/reference/operator/aggregation/function) |
| [AccumulatorExpressions#function(String,Object...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#function(java.lang.String,java.lang.Object%2E%2E%2E)) | [TestFunction](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestFunction.java) |
| [$getField](http://docs.mongodb.org/manual/reference/operator/aggregation/getField) | [TestGetField](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestGetField.java) |
| [$gt](http://docs.mongodb.org/manual/reference/operator/aggregation/gt) | [ComparisonExpressions#gt(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#gt(java.lang.Object,java.lang.Object)) |
| [TestGt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestGt.java) | [$gte](http://docs.mongodb.org/manual/reference/operator/aggregation/gte) |
| [ComparisonExpressions#gte(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#gte(java.lang.Object,java.lang.Object)) | [TestGte](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestGte.java) |
| [$hour](http://docs.mongodb.org/manual/reference/operator/aggregation/hour) | [DateExpressions#hour(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#hour(java.lang.Object)) |
| [TestHour](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestHour.java) | [$ifNull](http://docs.mongodb.org/manual/reference/operator/aggregation/ifNull) |
| [ConditionalExpressions#ifNull()](javadoc/dev/morphia/aggregation/expressions/ConditionalExpressions.html#ifNull()) | [TestIfNull](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIfNull.java) |
| [$in](http://docs.mongodb.org/manual/reference/operator/aggregation/in) | [ArrayExpressions#in(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#in(java.lang.Object,java.lang.Object)) |
| [TestIn](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIn.java) | [$indexOfArray](http://docs.mongodb.org/manual/reference/operator/aggregation/indexOfArray) |
| [ArrayExpressions#indexOfArray(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#indexOfArray(java.lang.Object,java.lang.Object)) | [TestIndexOfArray](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIndexOfArray.java) |
| [$indexOfBytes](http://docs.mongodb.org/manual/reference/operator/aggregation/indexOfBytes) | [StringExpressions#indexOfBytes(Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#indexOfBytes(java.lang.Object,java.lang.Object)) |
| [TestIndexOfBytes](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIndexOfBytes.java) | [$indexOfCP](http://docs.mongodb.org/manual/reference/operator/aggregation/indexOfCP) |
| [StringExpressions#indexOfCP(Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#indexOfCP(java.lang.Object,java.lang.Object)) | [TestIndexOfCP](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIndexOfCP.java) |
| [$integral](http://docs.mongodb.org/manual/reference/operator/aggregation/integral) | [WindowExpressions#integral(Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#integral(java.lang.Object)) |
| [TestIntegral](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIntegral.java) | [$isArray](http://docs.mongodb.org/manual/reference/operator/aggregation/isArray) |
| [ArrayExpressions#isArray(Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#isArray(java.lang.Object)) | [TestIsArray](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIsArray.java) |
| [$isNumber](http://docs.mongodb.org/manual/reference/operator/aggregation/isNumber) | [TypeExpressions#isNumber(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#isNumber(java.lang.Object)) |
| [TestIsNumber](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIsNumber.java) | [$isoDayOfWeek](http://docs.mongodb.org/manual/reference/operator/aggregation/isoDayOfWeek) |
| [DateExpressions#isoDayOfWeek(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#isoDayOfWeek(java.lang.Object)) | [TestIsoDayOfWeek](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIsoDayOfWeek.java) |
| [$isoWeek](http://docs.mongodb.org/manual/reference/operator/aggregation/isoWeek) | [DateExpressions#isoWeek(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#isoWeek(java.lang.Object)) |
| [TestIsoWeek](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIsoWeek.java) | [$isoWeekYear](http://docs.mongodb.org/manual/reference/operator/aggregation/isoWeekYear) |
| [DateExpressions#isoWeekYear(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#isoWeekYear(java.lang.Object)) | [TestIsoWeekYear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestIsoWeekYear.java) |
| [$last](http://docs.mongodb.org/manual/reference/operator/aggregation/last) | [AccumulatorExpressions#last(Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#last(java.lang.Object)) |
| [TestLast](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLast.java) | [$lastN](http://docs.mongodb.org/manual/reference/operator/aggregation/lastN) |
| [AccumulatorExpressions#lastN(Object,Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#lastN(java.lang.Object,java.lang.Object)) | [TestLastN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLastN.java) |
| [$let](http://docs.mongodb.org/manual/reference/operator/aggregation/let) | [VariableExpressions#let(Expression)](javadoc/dev/morphia/aggregation/expressions/VariableExpressions.html#let(dev.morphia.aggregation.expressions.impls.Expression)) |
| [TestLet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLet.java) | [$linearFill](http://docs.mongodb.org/manual/reference/operator/aggregation/linearFill) |
| [WindowExpressions#linearFill(Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#linearFill(java.lang.Object)) | [TestLinearFill](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLinearFill.java) |
| [$literal](http://docs.mongodb.org/manual/reference/operator/aggregation/literal) | [Expressions#literal(Object)](javadoc/dev/morphia/aggregation/expressions/Expressions.html#literal(java.lang.Object)) |
| [TestLiteral](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLiteral.java) | [$ln](http://docs.mongodb.org/manual/reference/operator/aggregation/ln) |
| [MathExpressions#ln(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#ln(java.lang.Object)) | [TestLn](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLn.java) |
| [$locf](http://docs.mongodb.org/manual/reference/operator/aggregation/locf) | [WindowExpressions#locf(Object)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#locf(java.lang.Object)) |
| [TestLocf](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLocf.java) | [$log](http://docs.mongodb.org/manual/reference/operator/aggregation/log) |
| [MathExpressions#log(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#log(java.lang.Object,java.lang.Object)) | [TestLog](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLog.java) |
| [$log10](http://docs.mongodb.org/manual/reference/operator/aggregation/log10) | [MathExpressions#log10(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#log10(java.lang.Object)) |
| [TestLog10](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLog10.java) | [$lt](http://docs.mongodb.org/manual/reference/operator/aggregation/lt) |
| [ComparisonExpressions#lt(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#lt(java.lang.Object,java.lang.Object)) | [TestLt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLt.java) |
| [$lte](http://docs.mongodb.org/manual/reference/operator/aggregation/lte) | [ComparisonExpressions#lte(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#lte(java.lang.Object,java.lang.Object)) |
| [TestLte](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLte.java) | [$ltrim](http://docs.mongodb.org/manual/reference/operator/aggregation/ltrim) |
| [StringExpressions#ltrim(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#ltrim(java.lang.Object)) | [TestLtrim](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestLtrim.java) |
| [$map](http://docs.mongodb.org/manual/reference/operator/aggregation/map) | [ArrayExpressions#map(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#map(java.lang.Object,java.lang.Object)) |
| [TestMap](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMap.java) | [$max](http://docs.mongodb.org/manual/reference/operator/aggregation/max) |
| [AccumulatorExpressions#max(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#max(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestMax](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMax.java) |
| [$maxN](http://docs.mongodb.org/manual/reference/operator/aggregation/maxN) | [AccumulatorExpressions#maxN(Object,Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#maxN(java.lang.Object,java.lang.Object)) |
| [TestMaxN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMaxN.java) | [$median](http://docs.mongodb.org/manual/reference/operator/aggregation/median) |
| [MathExpressions#median(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#median(java.lang.Object)) | [TestMedian](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMedian.java) |
| [$mergeObjects](http://docs.mongodb.org/manual/reference/operator/aggregation/mergeObjects) | [ObjectExpressions#mergeObjects()](javadoc/dev/morphia/aggregation/expressions/ObjectExpressions.html#mergeObjects()) |
| [TestMergeObjects](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMergeObjects.java) | [$meta](http://docs.mongodb.org/manual/reference/operator/aggregation/meta) |
| [TestMeta](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMeta.java) | [$millisecond](http://docs.mongodb.org/manual/reference/operator/aggregation/millisecond) |
| [DateExpressions#milliseconds(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#milliseconds(java.lang.Object)) | [TestMillisecond](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMillisecond.java) |
| [$min](http://docs.mongodb.org/manual/reference/operator/aggregation/min) | [AccumulatorExpressions#min(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#min(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestMin](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMin.java) | [$minN](http://docs.mongodb.org/manual/reference/operator/aggregation/minN) |
| [AccumulatorExpressions#minN(Object,Object)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#minN(java.lang.Object,java.lang.Object)) | [TestMinN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMinN.java) |
| [$minute](http://docs.mongodb.org/manual/reference/operator/aggregation/minute) | [DateExpressions#minute(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#minute(java.lang.Object)) |
| [TestMinute](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMinute.java) | [$mod](http://docs.mongodb.org/manual/reference/operator/aggregation/mod) |
| [MathExpressions#mod(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#mod(java.lang.Object,java.lang.Object)) | [TestMod](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMod.java) |
| [$month](http://docs.mongodb.org/manual/reference/operator/aggregation/month) | [DateExpressions#month(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#month(java.lang.Object)) |
| [TestMonth](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMonth.java) | [$multiply](http://docs.mongodb.org/manual/reference/operator/aggregation/multiply) |
| [MathExpressions#multiply(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#multiply(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestMultiply](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestMultiply.java) |
| [$ne](http://docs.mongodb.org/manual/reference/operator/aggregation/ne) | [ComparisonExpressions#ne(Object,Object)](javadoc/dev/morphia/aggregation/expressions/ComparisonExpressions.html#ne(java.lang.Object,java.lang.Object)) |
| [TestNe](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestNe.java) | [$not](http://docs.mongodb.org/manual/reference/operator/aggregation/not) |
| [BooleanExpressions#not(Object)](javadoc/dev/morphia/aggregation/expressions/BooleanExpressions.html#not(java.lang.Object)) | [TestNot](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestNot.java) |
| [$objectToArray](http://docs.mongodb.org/manual/reference/operator/aggregation/objectToArray) | [ArrayExpressions#objectToArray(Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#objectToArray(java.lang.Object)) |
| [TestObjectToArray](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestObjectToArray.java) | [$or](http://docs.mongodb.org/manual/reference/operator/aggregation/or) |
| [TestOr](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestOr.java) | [$percentile](http://docs.mongodb.org/manual/reference/operator/aggregation/percentile) |
| [TestPercentile](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestPercentile.java) | [$pow](http://docs.mongodb.org/manual/reference/operator/aggregation/pow) |
| [MathExpressions#pow(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#pow(java.lang.Object,java.lang.Object)) | [TestPow](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestPow.java) |
| [$push](http://docs.mongodb.org/manual/reference/operator/aggregation/push) | [TestPush](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestPush.java) |
| [$radiansToDegrees](http://docs.mongodb.org/manual/reference/operator/aggregation/radiansToDegrees) | [TrigonometryExpressions#radiansToDegrees(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#radiansToDegrees(java.lang.Object)) |
| [TestRadiansToDegrees](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRadiansToDegrees.java) | [$rand](http://docs.mongodb.org/manual/reference/operator/aggregation/rand) |
| [Miscellaneous#rand()](javadoc/dev/morphia/aggregation/expressions/Miscellaneous.html#rand()) | [TestRand](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRand.java) |
| [$range](http://docs.mongodb.org/manual/reference/operator/aggregation/range) | [TestRange](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRange.java) |
| [$rank](http://docs.mongodb.org/manual/reference/operator/aggregation/rank) | [WindowExpressions#rank()](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#rank()) |
| [TestRank](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRank.java) | [$reduce](http://docs.mongodb.org/manual/reference/operator/aggregation/reduce) |
| [ArrayExpressions#reduce(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#reduce(java.lang.Object,java.lang.Object,java.lang.Object)) | [TestReduce](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestReduce.java) |
| [$regexFind](http://docs.mongodb.org/manual/reference/operator/aggregation/regexFind) | [StringExpressions#regexFind(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#regexFind(java.lang.Object)) |
| [TestRegexFind](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRegexFind.java) | [$regexFindAll](http://docs.mongodb.org/manual/reference/operator/aggregation/regexFindAll) |
| [StringExpressions#regexFindAll(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#regexFindAll(java.lang.Object)) | [TestRegexFindAll](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRegexFindAll.java) |
| [$regexMatch](http://docs.mongodb.org/manual/reference/operator/aggregation/regexMatch) | [StringExpressions#regexMatch(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#regexMatch(java.lang.Object)) |
| [TestRegexMatch](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRegexMatch.java) | [$replaceAll](http://docs.mongodb.org/manual/reference/operator/aggregation/replaceAll) |
| [StringExpressions#replaceAll(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#replaceAll(java.lang.Object,java.lang.Object,java.lang.Object)) | [TestReplaceAll](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestReplaceAll.java) |
| [$replaceOne](http://docs.mongodb.org/manual/reference/operator/aggregation/replaceOne) | [StringExpressions#replaceOne(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#replaceOne(java.lang.Object,java.lang.Object,java.lang.Object)) |
| [TestReplaceOne](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestReplaceOne.java) | [$reverseArray](http://docs.mongodb.org/manual/reference/operator/aggregation/reverseArray) |
| [ArrayExpressions#reverseArray(Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#reverseArray(java.lang.Object)) | [TestReverseArray](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestReverseArray.java) |
| [$round](http://docs.mongodb.org/manual/reference/operator/aggregation/round) | [MathExpressions#round(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#round(java.lang.Object,java.lang.Object)) |
| [TestRound](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRound.java) | [$rtrim](http://docs.mongodb.org/manual/reference/operator/aggregation/rtrim) |
| [StringExpressions#rtrim(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#rtrim(java.lang.Object)) | [TestRtrim](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestRtrim.java) |
| [$sampleRate](http://docs.mongodb.org/manual/reference/operator/aggregation/sampleRate) | [Miscellaneous#sampleRate(double)](javadoc/dev/morphia/aggregation/expressions/Miscellaneous.html#sampleRate(double)) |
| [TestSampleRate](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSampleRate.java) | [$second](http://docs.mongodb.org/manual/reference/operator/aggregation/second) |
| [DateExpressions#second(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#second(java.lang.Object)) | [TestSecond](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSecond.java) |
| [$setDifference](http://docs.mongodb.org/manual/reference/operator/aggregation/setDifference) | [SetExpressions#setDifference(Object,Object)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#setDifference(java.lang.Object,java.lang.Object)) |
| [TestSetDifference](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetDifference.java) | [$setEquals](http://docs.mongodb.org/manual/reference/operator/aggregation/setEquals) |
| [SetExpressions#setEquals(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#setEquals(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestSetEquals](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetEquals.java) |
| [$setField](http://docs.mongodb.org/manual/reference/operator/aggregation/setField) | [Miscellaneous#setField(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/Miscellaneous.html#setField(java.lang.Object,java.lang.Object,java.lang.Object)) |
| [TestSetField](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetField.java) | [$setIntersection](http://docs.mongodb.org/manual/reference/operator/aggregation/setIntersection) |
| [SetExpressions#setIntersection(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#setIntersection(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestSetIntersection](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetIntersection.java) |
| [$setIsSubset](http://docs.mongodb.org/manual/reference/operator/aggregation/setIsSubset) | [SetExpressions#setIsSubset(Object,Object)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#setIsSubset(java.lang.Object,java.lang.Object)) |
| [TestSetIsSubset](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetIsSubset.java) | [$setUnion](http://docs.mongodb.org/manual/reference/operator/aggregation/setUnion) |
| [SetExpressions#setUnion(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/SetExpressions.html#setUnion(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestSetUnion](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSetUnion.java) |
| [$shift](http://docs.mongodb.org/manual/reference/operator/aggregation/shift) | [TestShift](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestShift.java) |
| [$sin](http://docs.mongodb.org/manual/reference/operator/aggregation/sin) | [TrigonometryExpressions#sin(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#sin(java.lang.Object)) |
| [TestSin](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSin.java) | [$sinh](http://docs.mongodb.org/manual/reference/operator/aggregation/sinh) |
| [TrigonometryExpressions#sinh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#sinh(java.lang.Object)) | [TestSinh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSinh.java) |
| [$size](http://docs.mongodb.org/manual/reference/operator/aggregation/size) | [ArrayExpressions#size(Object)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#size(java.lang.Object)) |
| [TestSize](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSize.java) | [$slice](http://docs.mongodb.org/manual/reference/operator/aggregation/slice) |
| [ArrayExpressions#slice(Object,int)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#slice(java.lang.Object,int)) | [TestSlice](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSlice.java) |
| [$sortArray](http://docs.mongodb.org/manual/reference/operator/aggregation/sortArray) | [ArrayExpressions#sortArray(Object,Sort...)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#sortArray(java.lang.Object,dev.morphia.query.Sort%2E%2E%2E)) |
| [TestSortArray](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSortArray.java) | [$split](http://docs.mongodb.org/manual/reference/operator/aggregation/split) |
| [StringExpressions#split(Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#split(java.lang.Object,java.lang.Object)) | [TestSplit](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSplit.java) |
| [$sqrt](http://docs.mongodb.org/manual/reference/operator/aggregation/sqrt) | [MathExpressions#sqrt(Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#sqrt(java.lang.Object)) |
| [TestSqrt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSqrt.java) | [$stdDevPop](http://docs.mongodb.org/manual/reference/operator/aggregation/stdDevPop) |
| [WindowExpressions#stdDevPop(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#stdDevPop(java.lang.Object,java.lang.Object%2E%2E%2E)) | [TestStdDevPop](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestStdDevPop.java) |
| [$stdDevSamp](http://docs.mongodb.org/manual/reference/operator/aggregation/stdDevSamp) | [WindowExpressions#stdDevSamp(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/WindowExpressions.html#stdDevSamp(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestStdDevSamp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestStdDevSamp.java) | [$strLenBytes](http://docs.mongodb.org/manual/reference/operator/aggregation/strLenBytes) |
| [StringExpressions#strLenBytes(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#strLenBytes(java.lang.Object)) | [TestStrLenBytes](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestStrLenBytes.java) |
| [$strLenCP](http://docs.mongodb.org/manual/reference/operator/aggregation/strLenCP) | [StringExpressions#strLenCP(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#strLenCP(java.lang.Object)) |
| [TestStrLenCP](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestStrLenCP.java) | [$strcasecmp](http://docs.mongodb.org/manual/reference/operator/aggregation/strcasecmp) |
| [StringExpressions#strcasecmp(Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#strcasecmp(java.lang.Object,java.lang.Object)) | [TestStrcasecmp](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestStrcasecmp.java) |
| [$substrBytes](http://docs.mongodb.org/manual/reference/operator/aggregation/substrBytes) | [TestSubstrBytes](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSubstrBytes.java) |
| [$substrCP](http://docs.mongodb.org/manual/reference/operator/aggregation/substrCP) | [StringExpressions#substrCP(Object,Object,Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#substrCP(java.lang.Object,java.lang.Object,java.lang.Object)) |
| [TestSubstrCP](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSubstrCP.java) | [$subtract](http://docs.mongodb.org/manual/reference/operator/aggregation/subtract) |
| [MathExpressions#subtract(Object,Object)](javadoc/dev/morphia/aggregation/expressions/MathExpressions.html#subtract(java.lang.Object,java.lang.Object)) | [TestSubtract](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSubtract.java) |
| [$sum](http://docs.mongodb.org/manual/reference/operator/aggregation/sum) | [AccumulatorExpressions#sum(Object,Object...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#sum(java.lang.Object,java.lang.Object%2E%2E%2E)) |
| [TestSum](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSum.java) | [$switch](http://docs.mongodb.org/manual/reference/operator/aggregation/switch) |
| [ConditionalExpressions#switchExpression()](javadoc/dev/morphia/aggregation/expressions/ConditionalExpressions.html#switchExpression()) | [TestSwitch](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestSwitch.java) |
| [$tan](http://docs.mongodb.org/manual/reference/operator/aggregation/tan) | [TrigonometryExpressions#tan(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#tan(java.lang.Object)) |
| [TestTan](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTan.java) | [$tanh](http://docs.mongodb.org/manual/reference/operator/aggregation/tanh) |
| [TrigonometryExpressions#tanh(Object)](javadoc/dev/morphia/aggregation/expressions/TrigonometryExpressions.html#tanh(java.lang.Object)) | [TestTanh](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTanh.java) |
| [$toBool](http://docs.mongodb.org/manual/reference/operator/aggregation/toBool) | [TypeExpressions#toBool(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toBool(java.lang.Object)) |
| [TestToBool](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToBool.java) | [$toDate](http://docs.mongodb.org/manual/reference/operator/aggregation/toDate) |
| [TestToDate](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToDate.java) | [$toDecimal](http://docs.mongodb.org/manual/reference/operator/aggregation/toDecimal) |
| [TypeExpressions#toDecimal(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toDecimal(java.lang.Object)) | [TestToDecimal](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToDecimal.java) |
| [$toDouble](http://docs.mongodb.org/manual/reference/operator/aggregation/toDouble) | [TypeExpressions#toDouble(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toDouble(java.lang.Object)) |
| [TestToDouble](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToDouble.java) | [$toInt](http://docs.mongodb.org/manual/reference/operator/aggregation/toInt) |
| [TypeExpressions#toInt(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toInt(java.lang.Object)) | [TestToInt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToInt.java) |
| [$toLong](http://docs.mongodb.org/manual/reference/operator/aggregation/toLong) | [TypeExpressions#toLong(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toLong(java.lang.Object)) |
| [TestToLong](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToLong.java) | [$toLower](http://docs.mongodb.org/manual/reference/operator/aggregation/toLower) |
| [StringExpressions#toLower(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#toLower(java.lang.Object)) | [TestToLower](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToLower.java) |
| [$toObjectId](http://docs.mongodb.org/manual/reference/operator/aggregation/toObjectId) | [TypeExpressions#toObjectId(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#toObjectId(java.lang.Object)) |
| [TestToObjectId](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToObjectId.java) | [$toString](http://docs.mongodb.org/manual/reference/operator/aggregation/toString) |
| [TestToString](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToString.java) | [$toUpper](http://docs.mongodb.org/manual/reference/operator/aggregation/toUpper) |
| [StringExpressions#toUpper(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#toUpper(java.lang.Object)) | [TestToUpper](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestToUpper.java) |
| [$top](http://docs.mongodb.org/manual/reference/operator/aggregation/top) | [AccumulatorExpressions#top(Object,Sort...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#top(java.lang.Object,dev.morphia.query.Sort%2E%2E%2E)) |
| [TestTop](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTop.java) | [$topN](http://docs.mongodb.org/manual/reference/operator/aggregation/topN) |
| [AccumulatorExpressions#topN(Object,Object,Sort...)](javadoc/dev/morphia/aggregation/expressions/AccumulatorExpressions.html#topN(java.lang.Object,java.lang.Object,dev.morphia.query.Sort%2E%2E%2E)) | [TestTopN](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTopN.java) |
| [$trim](http://docs.mongodb.org/manual/reference/operator/aggregation/trim) | [StringExpressions#trim(Object)](javadoc/dev/morphia/aggregation/expressions/StringExpressions.html#trim(java.lang.Object)) |
| [TestTrim](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTrim.java) | [$trunc](http://docs.mongodb.org/manual/reference/operator/aggregation/trunc) |
| [TestTrunc](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTrunc.java) | [$tsIncrement](http://docs.mongodb.org/manual/reference/operator/aggregation/tsIncrement) |
| [DateExpressions#tsIncrement(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#tsIncrement(java.lang.Object)) | [TestTsIncrement](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTsIncrement.java) |
| [$tsSecond](http://docs.mongodb.org/manual/reference/operator/aggregation/tsSecond) | [DateExpressions#tsSecond(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#tsSecond(java.lang.Object)) |
| [TestTsSecond](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestTsSecond.java) | [$type](http://docs.mongodb.org/manual/reference/operator/aggregation/type) |
| [TypeExpressions#type(Object)](javadoc/dev/morphia/aggregation/expressions/TypeExpressions.html#type(java.lang.Object)) | [TestType](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestType.java) |
| [$unsetField](http://docs.mongodb.org/manual/reference/operator/aggregation/unsetField) | [Miscellaneous#unsetField(Object,Object)](javadoc/dev/morphia/aggregation/expressions/Miscellaneous.html#unsetField(java.lang.Object,java.lang.Object)) |
| [TestUnsetField](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestUnsetField.java) | [$week](http://docs.mongodb.org/manual/reference/operator/aggregation/week) |
| [DateExpressions#week(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#week(java.lang.Object)) | [TestWeek](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestWeek.java) |
| [$year](http://docs.mongodb.org/manual/reference/operator/aggregation/year) | [DateExpressions#year(Object)](javadoc/dev/morphia/aggregation/expressions/DateExpressions.html#year(java.lang.Object)) |
| [TestYear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestYear.java) | [$zip](http://docs.mongodb.org/manual/reference/operator/aggregation/zip) |
| [ArrayExpressions#zip(Object...)](javadoc/dev/morphia/aggregation/expressions/ArrayExpressions.html#zip(java.lang.Object%2E%2E%2E)) | [TestZip](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/aggregation/expressions/TestZip.java) |
