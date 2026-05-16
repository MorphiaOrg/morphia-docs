---
title: "API Changes: Morphia 2.5 to 3.0"
weight: 999
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

This document outlines the public API changes between Morphia 2.5 and 3.0, providing a comprehensive side-by-side comparison of all modified classes and their methods. The migration from 2.5 to 3.0 represents a significant modernization of the Morphia API, with substantial changes to the aggregation framework, query interface, and datastore operations.

The changes focus on simplifying the API surface, removing deprecated functionality, and providing more consistent method signatures across the framework. Developers upgrading from 2.5 will need to adapt their code to use the new streamlined interfaces, particularly around aggregation pipelines and query operations.

## Key Observations

**Aggregation Framework Redesign**: The most substantial change is in the aggregation API. Version 2.5 provided an extensive fluent interface with methods for each aggregation stage (addFields, bucket, group, etc.), while version 3.0 adopts a streamlined pipeline-based approach. The new API focuses on building pipelines using `pipeline()` methods and executing them with `iterator()` and `toList()`.

**Query API Modernization**: The query interface has been significantly simplified. Legacy methods like `criteria()`, `field()`, `execute()`, and `find()` have been removed in favor of a more focused filter-based approach. The `filter()` method has changed from concrete to abstract, indicating a shift toward more structured query building.

**Datastore Method Consolidation**: Several deprecated methods have been removed from the Datastore interface, including string-based operations, legacy query creation methods, and various utility functions. The API now emphasizes type safety and modern MongoDB driver patterns.

**Improved Method Signatures**: New overloads have been added with additional options parameters, providing more flexibility while maintaining backward compatibility where possible. Some methods have transitioned from concrete to abstract implementations, allowing for better extensibility.

## Method Changes by Class

### dev.morphia.Datastore

| 2.5 | 3.0 |
|---|---|
| `abstract dev.morphia.aggregation.Aggregation aggregate(java.lang.String)` |  |
| `abstract dev.morphia.aggregation.Aggregation aggregate(java.lang.Class)` |  |
|  | `dev.morphia.aggregation.Aggregation aggregate(dev.morphia.aggregation.AggregationOptions)` |
|  | `dev.morphia.aggregation.Aggregation aggregate(java.lang.Class)` |
|  | `dev.morphia.aggregation.Aggregation aggregate(java.lang.Class, dev.morphia.aggregation.AggregationOptions)` |
|  | `dev.morphia.aggregation.Aggregation aggregate(java.lang.Class, java.lang.Class)` |
|  | `abstract dev.morphia.aggregation.Aggregation aggregate(java.lang.Class, java.lang.Class, dev.morphia.aggregation.AggregationOptions)` |
| `abstract dev.morphia.aggregation.AggregationPipeline createAggregation(java.lang.Class)` |  |
| `dev.morphia.query.Query createQuery(java.lang.Class)` |  |
| `dev.morphia.query.UpdateOperations createUpdateOperations(java.lang.Class)` |  |
| `com.mongodb.client.result.DeleteResult delete(dev.morphia.query.Query)` |  |
| `com.mongodb.client.result.DeleteResult delete(dev.morphia.query.Query, dev.morphia.DeleteOptions)` |  |
| `abstract dev.morphia.void enableDocumentValidation()` |  |
| `abstract dev.morphia.void ensureCaps()` |  |
| `abstract dev.morphia.void ensureIndexes()` |  |
| `abstract dev.morphia.query.Query find(java.lang.String)` |  |
| `dev.morphia.query.Query find(java.lang.String, java.lang.Class)` |  |
|  | `abstract dev.morphia.query.Query find(java.lang.Class, org.bson.Document, dev.morphia.query.FindOptions)` |
| `dev.morphia.T findAndDelete(dev.morphia.query.Query)` |  |
| `dev.morphia.T findAndDelete(dev.morphia.query.Query, dev.morphia.FindAndModifyOptions)` |  |
| `dev.morphia.T findAndModify(dev.morphia.query.Query, dev.morphia.query.UpdateOperations)` |  |
| `dev.morphia.T findAndModify(dev.morphia.query.Query, dev.morphia.query.UpdateOperations, dev.morphia.FindAndModifyOptions)` |  |
| `abstract org.bson.codecs.configuration.CodecRegistry getCodecRegistry()` |  |
| `abstract java.lang.String getLoggedQuery(dev.morphia.query.FindOptions)` |  |
| `abstract dev.morphia.mapping.Mapper getMapper()` |  |
| `dev.morphia.void merge(dev.morphia.T, com.mongodb.WriteConcern)` |  |
| `java.util.List save(java.lang.Iterable)` |  |
| `java.util.List save(java.lang.Iterable, dev.morphia.InsertOptions)` |  |
| `dev.morphia.T save(dev.morphia.T, dev.morphia.InsertOptions)` |  |
| `com.mongodb.client.result.UpdateResult update(dev.morphia.query.Query, dev.morphia.query.UpdateOperations)` |  |
| `com.mongodb.client.result.UpdateResult update(dev.morphia.query.Query, dev.morphia.query.UpdateOperations, dev.morphia.UpdateOptions)` |  |

### dev.morphia.aggregation.Aggregation

| 2.5 | 3.0 |
|---|---|
| `abstract dev.morphia.aggregation.Aggregation addFields(dev.morphia.aggregation.stages.AddFields)` |  |
| `abstract dev.morphia.aggregation.Aggregation addStage(dev.morphia.aggregation.stages.Stage)` |  |
| `abstract dev.morphia.aggregation.Aggregation autoBucket(dev.morphia.aggregation.stages.AutoBucket)` |  |
| `abstract dev.morphia.aggregation.Aggregation bucket(dev.morphia.aggregation.stages.Bucket)` |  |
| `abstract dev.morphia.aggregation.Aggregation changeStream()` |  |
| `abstract dev.morphia.aggregation.Aggregation changeStream(dev.morphia.aggregation.stages.ChangeStream)` |  |
| `abstract dev.morphia.aggregation.Aggregation collStats(dev.morphia.aggregation.stages.CollectionStats)` |  |
| `abstract dev.morphia.aggregation.Aggregation count(java.lang.String)` |  |
| `abstract dev.morphia.aggregation.Aggregation currentOp(dev.morphia.aggregation.stages.CurrentOp)` |  |
| `abstract dev.morphia.aggregation.Aggregation densify(dev.morphia.aggregation.stages.Densify)` |  |
| `abstract dev.morphia.aggregation.Aggregation documents(dev.morphia.aggregation.expressions.impls.DocumentExpression)` |  |
| `abstract dev.morphia.query.internal.MorphiaCursor execute(java.lang.Class)` |  |
| `abstract dev.morphia.query.internal.MorphiaCursor execute(java.lang.Class, dev.morphia.aggregation.AggregationOptions)` |  |
| `abstract dev.morphia.aggregation.Aggregation facet(dev.morphia.aggregation.stages.Facet)` |  |
| `abstract dev.morphia.aggregation.Aggregation fill(dev.morphia.aggregation.stages.Fill)` |  |
| `abstract dev.morphia.aggregation.Aggregation geoNear(dev.morphia.aggregation.stages.GeoNear)` |  |
| `abstract dev.morphia.aggregation.Aggregation graphLookup(dev.morphia.aggregation.stages.GraphLookup)` |  |
| `abstract dev.morphia.aggregation.Aggregation group(dev.morphia.aggregation.stages.Group)` |  |
| `abstract dev.morphia.aggregation.Aggregation indexStats()` |  |
|  | `abstract dev.morphia.query.MorphiaCursor iterator()` |
| `abstract dev.morphia.aggregation.Aggregation limit(long)` |  |
| `abstract dev.morphia.aggregation.Aggregation lookup(dev.morphia.aggregation.stages.Lookup)` |  |
| `abstract dev.morphia.aggregation.Aggregation match(dev.morphia.query.filters.Filter)` |  |
| `abstract dev.morphia.aggregation.void merge(dev.morphia.aggregation.stages.Merge)` |  |
| `abstract dev.morphia.aggregation.void merge(dev.morphia.aggregation.stages.Merge, dev.morphia.aggregation.AggregationOptions)` |  |
| `abstract dev.morphia.aggregation.void out(dev.morphia.aggregation.stages.Out)` |  |
| `abstract dev.morphia.aggregation.void out(dev.morphia.aggregation.stages.Out, dev.morphia.aggregation.AggregationOptions)` |  |
|  | `abstract dev.morphia.aggregation.Aggregation pipeline(dev.morphia.aggregation.stages.Stage)` |
|  | `dev.morphia.aggregation.Aggregation pipeline(java.util.List)` |
| `abstract dev.morphia.aggregation.Aggregation planCacheStats()` |  |
| `abstract dev.morphia.aggregation.Aggregation project(dev.morphia.aggregation.stages.Projection)` |  |
| `abstract dev.morphia.aggregation.Aggregation redact(dev.morphia.aggregation.stages.Redact)` |  |
| `abstract dev.morphia.aggregation.Aggregation replaceRoot(dev.morphia.aggregation.stages.ReplaceRoot)` |  |
| `abstract dev.morphia.aggregation.Aggregation replaceWith(dev.morphia.aggregation.stages.ReplaceWith)` |  |
| `abstract dev.morphia.aggregation.Aggregation sample(long)` |  |
| `dev.morphia.aggregation.Aggregation set(dev.morphia.aggregation.stages.AddFields)` |  |
| `abstract dev.morphia.aggregation.Aggregation set(dev.morphia.aggregation.stages.Set)` |  |
| `abstract dev.morphia.aggregation.Aggregation setWindowFields(dev.morphia.aggregation.stages.SetWindowFields)` |  |
| `abstract dev.morphia.aggregation.Aggregation skip(long)` |  |
| `abstract dev.morphia.aggregation.Aggregation sort(dev.morphia.aggregation.stages.Sort)` |  |
| `abstract dev.morphia.aggregation.Aggregation sortByCount(dev.morphia.aggregation.expressions.impls.Expression)` |  |
|  | `java.util.List toList()` |
| `abstract dev.morphia.aggregation.Aggregation unionWith(java.lang.Class, dev.morphia.aggregation.stages.Stage, dev.morphia.aggregation.stages.Stage)` |  |
| `abstract dev.morphia.aggregation.Aggregation unionWith(java.lang.String, dev.morphia.aggregation.stages.Stage, dev.morphia.aggregation.stages.Stage)` |  |
| `abstract dev.morphia.aggregation.Aggregation unset(dev.morphia.aggregation.stages.Unset)` |  |
| `abstract dev.morphia.aggregation.Aggregation unwind(dev.morphia.aggregation.stages.Unwind)` |  |

### dev.morphia.query.Query

| 2.5 | 3.0 |
|---|---|
| `dev.morphia.query.CriteriaContainer and(dev.morphia.query.Criteria)` |  |
| `dev.morphia.query.FieldEnd criteria(java.lang.String)` |  |
| `dev.morphia.query.internal.MorphiaCursor execute()` |  |
| `dev.morphia.query.internal.MorphiaCursor execute(dev.morphia.query.FindOptions)` |  |
| `java.util.Map explain(dev.morphia.query.FindOptions)` |  |
| `abstract java.util.Map explain(dev.morphia.query.FindOptions, com.mongodb.ExplainVerbosity)` |  |
| `dev.morphia.query.FieldEnd field(java.lang.String)` |  |
| `dev.morphia.query.Query filter(dev.morphia.query.filters.Filter)` | `abstract dev.morphia.query.Query filter(dev.morphia.query.filters.Filter)` |
| `dev.morphia.query.Query filter(java.lang.String, java.lang.Object)` |  |
| `dev.morphia.query.internal.MorphiaCursor find()` |  |
| `dev.morphia.query.internal.MorphiaCursor find(dev.morphia.query.FindOptions)` |  |
| `abstract dev.morphia.query.T first(dev.morphia.query.FindOptions)` |  |
| `abstract java.lang.Class getEntityClass()` |  |
| `abstract dev.morphia.query.internal.MorphiaCursor iterator(dev.morphia.query.FindOptions)` |  |
| `abstract dev.morphia.query.internal.MorphiaCursor iterator()` | `abstract dev.morphia.query.MorphiaCursor iterator()` |
| `abstract dev.morphia.query.internal.MorphiaKeyCursor keys()` |  |
| `abstract dev.morphia.query.internal.MorphiaKeyCursor keys(dev.morphia.query.FindOptions)` |  |
| `dev.morphia.query.Modify modify(dev.morphia.query.UpdateOperations)` |  |
| `abstract dev.morphia.query.Modify modify(dev.morphia.query.updates.UpdateOperator, dev.morphia.query.updates.UpdateOperator)` | `dev.morphia.query.T modify(dev.morphia.query.updates.UpdateOperator, dev.morphia.query.updates.UpdateOperator)` |
| `dev.morphia.query.T modify(dev.morphia.ModifyOptions, dev.morphia.query.updates.UpdateOperator)` |  |
|  | `abstract dev.morphia.query.T modify(dev.morphia.ModifyOptions, dev.morphia.query.updates.UpdateOperator, dev.morphia.query.updates.UpdateOperator)` |
| `dev.morphia.query.CriteriaContainer or(dev.morphia.query.Criteria)` |  |
| `dev.morphia.query.Query retrieveKnownFields()` |  |
| `abstract dev.morphia.query.Query search(java.lang.String)` |  |
| `abstract dev.morphia.query.Query search(java.lang.String, java.lang.String)` |  |
| `java.util.stream.Stream stream()` | `abstract java.util.stream.Stream stream()` |
| `java.util.stream.Stream stream(dev.morphia.query.FindOptions)` |  |
| `abstract org.bson.Document toDocument()` |  |
| `dev.morphia.query.Update update(java.util.List)` |  |
| `dev.morphia.query.Update update(dev.morphia.query.UpdateOperations)` |  |
| `com.mongodb.client.result.UpdateResult update(dev.morphia.aggregation.stages.Stage)` |  |
|  | `com.mongodb.client.result.UpdateResult update(dev.morphia.query.updates.UpdateOperator)` |
| `abstract dev.morphia.query.Update update(dev.morphia.query.updates.UpdateOperator, dev.morphia.query.updates.UpdateOperator)` |  |
| `com.mongodb.client.result.UpdateResult update(dev.morphia.UpdateOptions, dev.morphia.aggregation.stages.Stage)` |  |
| `com.mongodb.client.result.UpdateResult update(dev.morphia.UpdateOptions, dev.morphia.query.updates.UpdateOperator)` | `abstract com.mongodb.client.result.UpdateResult update(dev.morphia.UpdateOptions, dev.morphia.query.updates.UpdateOperator)` |
|  | `com.mongodb.client.result.UpdateResult update(dev.morphia.aggregation.stages.Stage, dev.morphia.aggregation.stages.Stage)` |
|  | `abstract com.mongodb.client.result.UpdateResult update(dev.morphia.UpdateOptions, dev.morphia.aggregation.stages.Stage, dev.morphia.aggregation.stages.Stage)` |
