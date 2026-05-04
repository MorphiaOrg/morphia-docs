---
title: "Aggregation Stages"
weight: 999
---

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
