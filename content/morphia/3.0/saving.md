---
title: "Saving Lists of Entities"
weight: 135
group: "Writing Data"
---

[Datastore#insert(List)](++javadoc/dev/morphia/Datastore.html#insert(java.util.List,dev.morphia.InsertManyOptions)++) and
[Datastore#save(List)](++javadoc/dev/morphia/Datastore.html#save(java.util.List,dev.morphia.InsertManyOptions)++) write many
entities at once.
Entities going to the same collection are sent in a single batch, whatever their class: subclasses stored in their parent's
collection, or unrelated classes mapped to the same collection name, all go out together.
`save(List)` sends new entities in batches first, then saves the entities that already have an id, or have a `@Version`
property, one at a time.

## When some entities fail

A common case is loading a batch of records into a collection with a unique index, where some of the records are already
stored or collide with each other:

```java
@Entity("readings")
@Indexes(@Index(fields = @Field("sensorTime"), options = @IndexOptions(unique = true)))
public class Reading {
    @Id
    private ObjectId id;
    private String sensorTime;
    // ...
}
```

By default, list writes are **ordered**, as they are in the MongoDB driver.
The server writes the documents in order and stops at the first one it rejects; nothing after it is written.
That includes later batches, when the list spans collections.
Ordering applies within each collection, not across a whole list that spans several.

To keep going past bad records, turn ordering off.
The server then attempts every document and stores all the valid ones, in one round trip per collection:

```java
try {
    datastore.insert(readings, new InsertManyOptions().ordered(false));
} catch (MorphiaBulkWriteException e) {
    for (BulkWriteFailure failure : e.getFailures()) {
        LOG.warn("Reading {} was not stored: {}", failure.index(), failure.error().getMessage());
    }
}
```

This is usually what you want for loading data.

## What the exception tells you

Whenever any entity isn't stored, `insert(List)` and `save(List)` throw a
[MorphiaBulkWriteException](++javadoc/dev/morphia/MorphiaBulkWriteException.html++).
It describes the outcome in terms of the entities you passed in:

* `getFailures()` lists each rejected entity with its position in your list and the reason.
  The reason is the server's `WriteError` (a duplicate key or a document validation failure, say) or, for a `@Version`
  conflict in `save(List)`, the `VersionMismatchException`.
* `getFailedEntities()` returns just the rejected entities.
* `getUnprocessedEntities()` returns the entities that were never sent because an ordered write stopped first.
  It's always empty for unordered writes outside a transaction.

Together, the failed and unprocessed entities are exactly what isn't in the database.
Retrying them is safe: nothing already stored is sent again, and Morphia clears any id it generated for them, so a retry
inserts them rather than turning into a replace.
Ids you assigned yourself are left alone.

`MorphiaBulkWriteException` extends the driver's `MongoBulkWriteException`, so code that catches the driver type still works,
and the indexes in `getWriteErrors()` refer to positions in your list too.

## If you need strict order

Unordered writes can't promise which of two colliding documents in the same batch wins.
If that matters, keep the default ordered write and resume after each failure yourself:

```java
List<Reading> remaining = readings;
while (!remaining.isEmpty()) {
    try {
        datastore.save(remaining);
        remaining = List.of();
    } catch (MorphiaBulkWriteException e) {
        log(e.getFailures());
        remaining = e.getUnprocessedEntities();
    }
}
```

This costs a round trip for every failure, and each retry re-sends the rest of the list, which is why Morphia doesn't do it
for you.
When most of a large list is already stored, it can be slower than saving one entity at a time; prefer `ordered(false)`
unless the order really matters.

## Transactions

A write error aborts a MongoDB transaction, so inside one, list writes stop at the first failure even when unordered, and the
rest are reported as unprocessed.
Entities the exception doesn't list as failed or unprocessed are only stored if the transaction is retried and commits.
See [Transactions](../transactions/).
