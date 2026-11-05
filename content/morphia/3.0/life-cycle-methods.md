---
title: "Life Cycle Methods"
weight: 180
---

Morphia can call your code at four points in an entity's life cycle:

1. `@PrePersist` - before the entity is encoded for saving
2. `@PostPersist` - after the entity is encoded, before the result is sent to the database
3. `@PreLoad` - before the entity's properties are decoded from a document read from the database
4. `@PostLoad` - after the entity's properties are decoded

There are three places to put that code:

1. methods on the entity itself, annotated with the event's annotation
2. [`@EntityListeners`](++javadoc/dev/morphia/annotations/EntityListeners.html++) classes named on the entity, for code shared by
   several entities
3. global listeners, listed in the [configuration](../configuration/), which run for every entity they accept

{{< admonition type="note" title="Note" >}}
**No Delete Support** Because deletes are usually done with queries there is no way to support a Delete lifecycle event.
{{< /admonition >}}

## Annotated methods

An entity can annotate any of its methods with an event's annotation. Such a method can take an `org.bson.Document` and a
`Datastore`, in any order, or neither. Here is an entity that always saves the date it was last updated:

```java
@Entity
public class BankAccount {
    @Id
    String id;
    Date lastUpdated = new Date();

    @PrePersist
    void trackUpdate() {
        lastUpdated = new Date();
    }
}
```

An `@EntityListeners` class can do the same, with methods that also take the entity. A class used this way must implement
`EntityListener`, for example `EntityListener<BankAccount>`, even when it only has annotated methods, and needs a no-argument
constructor; Morphia creates one instance of it per entity type.

## Listener interfaces

Each event has a listener interface, which `@EntityListeners` classes, global listeners, and entities themselves can implement:

| Event          | Listener                                                                        | Gets the `Document`                                       |
|----------------|---------------------------------------------------------------------------------|-----------------------------------------------------------|
| `@PrePersist`  | [`PrePersistListener<T>`](++javadoc/dev/morphia/PrePersistListener.html++)        | no: it's still empty                                      |
| `@PostPersist` | [`PostPersistListener<T>`](++javadoc/dev/morphia/PostPersistListener.html++)      | no                                                        |
|                | [`PostPersistDocumentListener<T>`](++javadoc/dev/morphia/PostPersistDocumentListener.html++) | the encoded document, and what it changes is saved |
| `@PreLoad`     | [`PreLoadListener<T>`](++javadoc/dev/morphia/PreLoadListener.html++)              | the document being decoded                                |
| `@PostLoad`    | [`PostLoadListener<T>`](++javadoc/dev/morphia/PostLoadListener.html++)            | no                                                        |
|                | [`PostLoadDocumentListener<T>`](++javadoc/dev/morphia/PostLoadDocumentListener.html++) | the document it was decoded from                     |

A listener may implement any number of these, but only one per event: a class that implements both `PostLoadListener` and
`PostLoadDocumentListener` is rejected when it's registered.

The type argument decides which entities a listener sees: a `PrePersistListener<Auditable>` is called for `Auditable` entities alone,
and a `PrePersistListener<Object>` for every entity. A lambda can't keep its type argument, so it's called for every entity; type a
lambda `Object` and check the entity's type in its body, or use a named or anonymous class.

Here is a listener that signs each account's encoded form before it's saved. It has to be a `@PostPersist` listener: at
`@PrePersist`, nothing has been encoded yet.

```java
@Entity
@EntityListeners(DigitalSigner.class)
public class BankAccount {
    @Id
    String id;
    Date lastUpdated = new Date();
}

public class DigitalSigner implements PostPersistDocumentListener<BankAccount> {
    @Override
    public void postPersist(BankAccount entity, Document document, Datastore datastore) {
        document.put("signature", sign(document));
    }
}
```

## Global listeners

Listeners that apply across entities, such as auditing or validation, are listed in the `morphia.listeners` setting, by class name:

```properties
morphia.listeners=com.example.Auditing, dev.morphia.validation.ValidationExtension
```

Each class must implement at least one listener interface and have a public no-argument constructor. In code, pass instances instead,
which can take constructor arguments:

```java
MorphiaConfig config = MorphiaConfig.load()
        .listeners(List.of(new Auditing(clock)));
```

The listeners are fixed when the datastore is created. They run after the entity's own methods and its `@EntityListeners` classes.

## Avoiding the `Document`

When no listener for an event takes the `Document`, Morphia encodes and decodes the entity directly. When one does, Morphia builds
the whole entity as a `Document` first, which costs noticeably more for every entity the listener applies to. Use the interfaces
without the `Document`, and leave the `Document` parameter off annotated methods, unless you need it.

## Entities created through a constructor

An entity whose values are passed to its constructor, such as a record, doesn't exist until all of its properties have been decoded.
Its `@PreLoad` listeners therefore run after decoding, just before its `@PostLoad` listeners, and changes they make to the `Document`
don't affect the entity. An entity with life cycle methods of its own, or with `@EntityListeners`, needs a no-argument constructor;
without one, Morphia can't map it. To listen to an entity that is created only through a constructor, use a
[global listener](#global-listeners) instead.
