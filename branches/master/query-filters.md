---
title: "Query Filters"
weight: 999
---

| Operator | Docs |
|---|---|
| Test Examples | [$all](http://docs.mongodb.org/manual/reference/operator/query/all) |
| [Filters#all(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#all(java.lang.String,java.lang.Object)) | [TestAll](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestAll.java) |
| [$and](http://docs.mongodb.org/manual/reference/operator/query/and) | [Filters#and(Filter...)](javadoc/dev/morphia/query/filters/Filters.html#and(dev.morphia.query.filters.Filter%2E%2E%2E)) |
| [TestAnd](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestAnd.java) | [$bitsAllClear](http://docs.mongodb.org/manual/reference/operator/query/bitsAllClear) |
| [Filters#bitsAllClear(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#bitsAllClear(java.lang.String,java.lang.Object)) | [TestBitsAllClear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestBitsAllClear.java) |
| [$bitsAllSet](http://docs.mongodb.org/manual/reference/operator/query/bitsAllSet) | [Filters#bitsAllSet(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#bitsAllSet(java.lang.String,java.lang.Object)) |
| [TestBitsAllSet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestBitsAllSet.java) | [$bitsAnyClear](http://docs.mongodb.org/manual/reference/operator/query/bitsAnyClear) |
| [Filters#bitsAnyClear(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#bitsAnyClear(java.lang.String,java.lang.Object)) | [TestBitsAnyClear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestBitsAnyClear.java) |
| [$bitsAnySet](http://docs.mongodb.org/manual/reference/operator/query/bitsAnySet) | [Filters#bitsAnySet(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#bitsAnySet(java.lang.String,java.lang.Object)) |
| [TestBitsAnySet](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestBitsAnySet.java) | [$box](http://docs.mongodb.org/manual/reference/operator/query/box) |
| [Filters#box(String,Point,Point)](javadoc/dev/morphia/query/filters/Filters.html#box(java.lang.String,com.mongodb.client.model.geojson.Point,com.mongodb.client.model.geojson.Point)) | [TestBox](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestBox.java) |
| [$center](http://docs.mongodb.org/manual/reference/operator/query/center) | [Filters#center(String,Point,double)](javadoc/dev/morphia/query/filters/Filters.html#center(java.lang.String,com.mongodb.client.model.geojson.Point,double)) |
| [TestCenter](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestCenter.java) | [$centerSphere](http://docs.mongodb.org/manual/reference/operator/query/centerSphere) |
| [Filters#centerSphere(String,Point,double)](javadoc/dev/morphia/query/filters/Filters.html#centerSphere(java.lang.String,com.mongodb.client.model.geojson.Point,double)) | [TestCenterSphere](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestCenterSphere.java) |
| [$comment](http://docs.mongodb.org/manual/reference/operator/query/comment) | [Filters#comment(String)](javadoc/dev/morphia/query/filters/Filters.html#comment(java.lang.String)) |
| [TestComment](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestComment.java) | [$elemMatch](http://docs.mongodb.org/manual/reference/operator/query/elemMatch) |
| [TestElemMatch](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestElemMatch.java) | [$eq](http://docs.mongodb.org/manual/reference/operator/query/eq) |
| [Filters#eq(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#eq(java.lang.String,java.lang.Object)) | [TestEq](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestEq.java) |
| [$exists](http://docs.mongodb.org/manual/reference/operator/query/exists) | [Filters#exists(String)](javadoc/dev/morphia/query/filters/Filters.html#exists(java.lang.String)) |
| [TestExists](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestExists.java) | [$expr](http://docs.mongodb.org/manual/reference/operator/query/expr) |
| [Filters#expr(Expression)](javadoc/dev/morphia/query/filters/Filters.html#expr(dev.morphia.aggregation.expressions.impls.Expression)) | [TestExpr](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestExpr.java) |
| [$geoIntersects](http://docs.mongodb.org/manual/reference/operator/query/geoIntersects) | [Filters#geoIntersects(String,Geometry)](javadoc/dev/morphia/query/filters/Filters.html#geoIntersects(java.lang.String,com.mongodb.client.model.geojson.Geometry)) |
| [TestGeoIntersects](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestGeoIntersects.java) | [$geoWithin](http://docs.mongodb.org/manual/reference/operator/query/geoWithin) |
| [TestGeoWithin](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestGeoWithin.java) | [$geometry](http://docs.mongodb.org/manual/reference/operator/query/geometry) |
| [Filters#geometry(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#geometry(java.lang.String,java.lang.Object)) | [TestGeometry](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestGeometry.java) |
| [$gt](http://docs.mongodb.org/manual/reference/operator/query/gt) | [TestGt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestGt.java) |
| [$gte](http://docs.mongodb.org/manual/reference/operator/query/gte) | [TestGte](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestGte.java) |
| [$in](http://docs.mongodb.org/manual/reference/operator/query/in) | [TestIn](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestIn.java) |
| [$jsonSchema](http://docs.mongodb.org/manual/reference/operator/query/jsonSchema) | [Filters#jsonSchema(Document)](javadoc/dev/morphia/query/filters/Filters.html#jsonSchema(org.bson.Document)) |
| [TestJsonSchema](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestJsonSchema.java) | [$lt](http://docs.mongodb.org/manual/reference/operator/query/lt) |
| [TestLt](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestLt.java) | [$lte](http://docs.mongodb.org/manual/reference/operator/query/lte) |
| [TestLte](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestLte.java) | [$maxDistance](http://docs.mongodb.org/manual/reference/operator/query/maxDistance) |
| [Filters#maxDistance(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#maxDistance(java.lang.String,java.lang.Object)) | [TestMaxDistance](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestMaxDistance.java) |
| [$meta](http://docs.mongodb.org/manual/reference/operator/query/meta) | [TestMeta](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestMeta.java) |
| [$minDistance](http://docs.mongodb.org/manual/reference/operator/query/minDistance) | [Filters#minDistance(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#minDistance(java.lang.String,java.lang.Object)) |
| [TestMinDistance](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestMinDistance.java) | [$mod](http://docs.mongodb.org/manual/reference/operator/query/mod) |
| [TestMod](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestMod.java) | [$natural](http://docs.mongodb.org/manual/reference/operator/query/natural) |
| [TestNatural](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNatural.java) | [$ne](http://docs.mongodb.org/manual/reference/operator/query/ne) |
| [Filters#ne(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#ne(java.lang.String,java.lang.Object)) | [TestNe](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNe.java) |
| [$near](http://docs.mongodb.org/manual/reference/operator/query/near) | [Filters#near(String,Point)](javadoc/dev/morphia/query/filters/Filters.html#near(java.lang.String,com.mongodb.client.model.geojson.Point)) |
| [TestNear](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNear.java) | [$nearSphere](http://docs.mongodb.org/manual/reference/operator/query/nearSphere) |
| [Filters#nearSphere(String,Point)](javadoc/dev/morphia/query/filters/Filters.html#nearSphere(java.lang.String,com.mongodb.client.model.geojson.Point)) | [TestNearSphere](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNearSphere.java) |
| [$nin](http://docs.mongodb.org/manual/reference/operator/query/nin) | [Filters#nin(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#nin(java.lang.String,java.lang.Object)) |
| [TestNin](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNin.java) | [$nor](http://docs.mongodb.org/manual/reference/operator/query/nor) |
| [Filters#nor(Filter...)](javadoc/dev/morphia/query/filters/Filters.html#nor(dev.morphia.query.filters.Filter%2E%2E%2E)) | [TestNor](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNor.java) |
| [$not](http://docs.mongodb.org/manual/reference/operator/query/not) | [Filter#not()](javadoc/dev/morphia/query/filters/Filter.html#not()) |
| [TestNot](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestNot.java) | [$or](http://docs.mongodb.org/manual/reference/operator/query/or) |
| [Filters#or(Filter...)](javadoc/dev/morphia/query/filters/Filters.html#or(dev.morphia.query.filters.Filter%2E%2E%2E)) | [TestOr](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestOr.java) |
| [$polygon](http://docs.mongodb.org/manual/reference/operator/query/polygon) | [Filters#polygon(String,Point...)](javadoc/dev/morphia/query/filters/Filters.html#polygon(java.lang.String,com.mongodb.client.model.geojson.Point%2E%2E%2E)) |
| [TestPolygon](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestPolygon.java) | [$regex](http://docs.mongodb.org/manual/reference/operator/query/regex) |
| [TestRegex](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestRegex.java) | [$size](http://docs.mongodb.org/manual/reference/operator/query/size) |
| [Filters#size(String,int)](javadoc/dev/morphia/query/filters/Filters.html#size(java.lang.String,int)) | [TestSize](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestSize.java) |
| [$slice](http://docs.mongodb.org/manual/reference/operator/query/slice) | [ArraySlice#limit(int)](javadoc/dev/morphia/query/ArraySlice.html#limit(int)) |
| [TestSlice](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestSlice.java) | [$text](http://docs.mongodb.org/manual/reference/operator/query/text) |
| [Filters#text(String)](javadoc/dev/morphia/query/filters/Filters.html#text(java.lang.String)) | [TestText](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestText.java) |
| [$type](http://docs.mongodb.org/manual/reference/operator/query/type) | [Filters#type(String,Type...)](javadoc/dev/morphia/query/filters/Filters.html#type(java.lang.String,dev.morphia.query.Type%2E%2E%2E)) |
| [TestType](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestType.java) | [$uniqueDocs](http://docs.mongodb.org/manual/reference/operator/query/uniqueDocs) |
| [Filters#uniqueDocs(String,Object)](javadoc/dev/morphia/query/filters/Filters.html#uniqueDocs(java.lang.String,java.lang.Object)) | [TestUniqueDocs](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestUniqueDocs.java) |
| [$where](http://docs.mongodb.org/manual/reference/operator/query/where) | [Filters#where(String)](javadoc/dev/morphia/query/filters/Filters.html#where(java.lang.String)) |
| [TestWhere](https://github.com/MorphiaOrg/morphia/blob/master/core/src/test/java/dev/morphia/test/query/filters/TestWhere.java) |  |
