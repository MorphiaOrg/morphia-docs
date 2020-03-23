+++
title = "Aggregation"
[menu.main]
  parent = "Reference Guides"
  pre = "<i class='fa fa-file-text-o'></i>"
+++

The [aggregation framework]({{< docsref "aggregation" >}}) in MongoDB allows you to define a series (called a pipeline) of
operations (called stages) against the data in a collection.  These pipelines can be used for analytics or they can be used to
convert your data from one form to another.  This guide will not go in to the details of how aggregation works, however.  The official
 MongoDB [documentation]({{< docsref "aggregation" >}}) has extensive tutorials on such details.  Rather, this
 guide will focus on the Morphia API.  The examples shown here are taken from the [tests]({{< srcref
  "morphia/src/test/java/dev/morphia/aggregation/AggregationTest.java">}}) in Morphia itself.

Writing an aggregation pipeline starts just like writing a standard query.  As with querying, we start with the `Datastore`:

```java
Iterator<Author> aggregate = datastore.aggregate(Book.class)
      .group("author", grouping("books", push("title")))
      .out(Author.class, options);
```

`createAggregation()` takes a `Class` literal.  This lets Morphia know which collection to perform this aggregation
against.  Because of the transformational operations available in the aggregation [pipeline]({{< docsref "core/aggregation-pipeline" >}}),
 Morphia can not validate as much as it can with querying so care will need to be taken to ensure
 document fields actually exist when referencing them in your pipeline.

## The Pipeline
Aggregation operations are comprised of a series stages.  Our example here has only one readerState: `group()`.  This method is the Morphia
equivalent of the [`$group`]({{< docsref "reference/operator/aggregation/group/" >}}) operator.  This readerState, as the name
suggests, groups together documents based on the given field's values.  In this example, we are collecting together all the books by
author.  The first parameter to `group()` defines the `_id` of the resulting documents.  Within this grouping, this pipeline takes the
`books` fields for each author and extracts the `title`.  With this grouping of data, we're then `push()`ing the titles in to an array
in the final document.  This example is the Morphia equivalent of an [example]({{< docsref
"reference/operator/aggregation/group/#group-title-by-author" >}}) found in the aggregation tutorials.  This results in a series of
 documents that look like this:

 ```json
 { "_id" : "Homer", "books" : [ "The Odyssey", "Iliad" ] }
 { "_id" : "Dante", "books" : [ "The Banquet", "Divine Comedy", "Eclogues" ] }
 ```

## Executing the Pipeline

Once your pipeline is complete, you can execute it via the `execute()` method.  This method takes a `Class` reference for the target
 type of your aggregation.  Given this type, Morphia will map each document in the results and return it.  Additionally, you can also
  include some options to `execute()`. We can use the various options on the 
[`AggregationOptions`]({{< apiref "dev/morphia/aggregation/experimental/AggregationOptions.html" >}}) class to configure how we want the
 pipeline to execute.

### $out

But this example doesn't use `aggregate()`, of course, it uses `out()` which gives us access to the `$out` pipeline readerState.  [`$out`]
({{< docsref "reference/operator/aggregation/out/" >}}) is a new operator in MongoDB 2.6 that allows the results of a
pipeline to be stored in to a named collection.  This collection can not be sharded or a capped collection, however.  This collection,
if it does not exist, will be created upon execution of the pipeline.

{{% notice warn %}}
Any existing data in the collection will be replaced by the output of the aggregation.
{{% /notice %}}

An example aggregation using the `$out` stage looks like this:

```java
datastore.aggregate(Book.class)
       .group(Group.of(id("author"))
                   .field("books", push()
                                       .single(field("title"))))
       .out(Out.to(Author.class));
```

You'll note that `out()` is the final method called here rather than `execute()`.  This is because `$out` must be the final stage in the
pipeline and it simply makes no sense to do anything other than execute the pipeline at that point.  If you look at what we're passing
to the method, you'll notice the `Out` class.  There are currently two methods of note on `Out`:  `to(Class)` and `to(String)`.  Using
either of these methods instructs Morphia to write to either the collection mapped for the given `Class` or the named collection as
noted by the String give.

{{% notice info %}}
You may be wondering about the use of `Out` here and that it seems a bit overcomplicated.  One of the design goals for the 2.0 API is to
simplify the overall API and to reduce the number of overloads through the introduction of parameter or options objects.  By limiting
the `Aggregation` API to two methods for `$out` (the seconds takes an `AggregationOptions` reference), we can keep `Aggregation` itself
slim and incorporate any future variations in `$out` limited to the `Out` class.  This should, hopefully, make both APIs easier to
digest and evolve.
{{% /notice %}}

### $merge
[`$merge`]({{< docsref "reference/operator/aggregation/merge/" >}}) is a very similar option with a some major differences.  The biggest
 difference is that `$merge` can write to existing collections without destroying the existing documents.  `$out` would obliterate any
  existing documents and replace them with the results of the pipeline.  `$merge`, however, can deposit these new results alongside
   existing data and update existing data.

Using `$merge` might look something like this:

```java
datastore.aggregate(Salary.class)
   .group(Group.of(id()
                       .field("fiscal_year")
                       .field("dept"))
               .field("salaries", sum(field("salary"))))
   .merge(Merge.into("budgets")
               .on("_id")
               .whenMatched(WhenMatched.REPLACE)
               .whenNotMatched(WhenNotMatched.INSERT));
```

Much like `out()` above, for `merge()` we pass in a `Merge` reference as created by the `Merge.into()` method.  A merge is slightly more
complex and so has more options to consider.  In this example, we're merging in to the `budgets` collection and merging any existing
documents based on the `_id` as denoted using the `on()` method.  Because there may be existing data in the collection, we need to
instruct the operation how to handle those cases.  In this example, when documents matching we're choosing to replace them and when
they don't we're instructing the operation to insert the new documents in to the collection.