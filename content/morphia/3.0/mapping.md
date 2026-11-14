---
title: "Mapping"
weight: 50
group: "Mapping"
---

## Classes

Mapping is triggered by annotating your type with the [@Entity](javadoc/dev/morphia/annotations/Entity.html) annotation. This
instructs Morphia to inspect your type compute various metadata items about it. If you wish use a particular type as "top level" type,
you will need to annotate one field with the [@Id](javadoc/dev/morphia/annotations/Id.html) annotation. Not every type will need to
serve as a top level type (read: be mapped to a collection) and so this ID field is optional with the caveat mentioned in the call out
note below. Top level types have their own collections whose names can be mapped via the `value` parameter. Leaving this value
blank will leave Morphia free to compute the collection name as defined by the collection naming strategy defined in
[MorphiaConfig](javadoc/dev/morphia/config/MorphiaConfig.html). That default is currently the camel case value of the class's
simple name. For example, to map a `UserProfile` entity under this strategy, the collection name would be mapped to `userProfile`.

Any type annotated with [@Entity](javadoc/dev/morphia/annotations/Entity.html) may optionally have a field annotated with
[@Id](javadoc/dev/morphia/annotations/Id.html). The type of the field can be any type so long as Morphia, or the driver, has a codec
that can map the data to and from mongodb. When mapping an entity, one can also define [indexes](../indexing/) and
[schema validations](../schema-validation/) as part of the entity declaration as well.

{{< admonition type="note" title="Note" >}}
As of 2.2, [@Embedded](javadoc/dev/morphia/annotations/Embedded.html) has been deprecated in favor of
[@Entity](javadoc/dev/morphia/annotations/Entity.html).  The distinction between the two annotations has been, historically, much
more significant than it is at present.  Due to the confusion about when to use which annotation and the meaning of "embedded" in
general, it is being decommissioned.  The two annotations have grown to mean essentially the same thing and so have become increasingly
redundant.
{{< /admonition >}}

{{< admonition type="warning" title="Warning" >}}
Entities annotated with [@Entity](javadoc/dev/morphia/annotations/Entity.html) that lack an
[@Id](javadoc/dev/morphia/annotations/Id.html) are not eligible to serve as "top level" types.  This means they will not be mapped to
a collection nor can they serve as the basis for querying or be saved directly (only as fields on top level types).  ID fields are used to
perform proper updates on previously persisted entities.  Without that ID Morphia, can not properly restrict the update to the correct
document in the database.
{{< /admonition >}}

## Constructors

Morphia creates an entity through one of its constructors. A constructor can be used when each of its parameters names a mapped
property and has that property's type. Among those constructors, Morphia picks:

1. one that takes every final property, if there is one, then
2. the one that takes the most properties.

Properties the constructor doesn't take are set afterward through their fields or setters, so a constructor needs to take only the
properties that can't be set any other way, such as final ones. A parameter matches a property by the property's name in the source.
If a parameter's name can't match it, the [@Name](javadoc/dev/morphia/annotations/Name.html) annotation gives the parameter an explicit
name to match instead.

An entity with life cycle methods, or with `@EntityListeners`, is always created through its no-argument constructor. See
[Life Cycle Methods](../life-cycle-methods/#entities-created-through-a-constructor).

### Final fields

Starting with JDK 26, [JEP 500](https://openjdk.org/jeps/500) restricts setting a final field through reflection: the JVM prints a warning
the first time it happens, `--illegal-final-field-mutation=deny` makes it fail, and a future JDK will deny it by default. So that it
never has to, Morphia sets final properties only through a constructor. Each final property, including one initialized where it's
declared, such as `final List<String> tags = new ArrayList<>()`, must be a parameter of the constructor Morphia uses:

```java
@Entity
public class Order {
    @Id
    private ObjectId id;
    private final String customer;
    private final List<String> items;
    private String status;

    public Order(String customer, List<String> items) {
        this.customer = customer;
        this.items = items;
    }
}
```

Here `customer` and `items` are passed to the constructor, and `id` and `status` are set afterward.

When an entity's final properties aren't all passed to its constructor, Morphia logs a warning when it maps the entity. On a JVM that
denies setting final fields, mapping fails instead, with a `ConstraintViolationException` that names the properties. To fix it, add a
constructor that takes them or make them non-final. An entity with life cycle methods can't take them through a constructor, so its
properties must be non-final. Morphia doesn't check final properties when `morphia.ignore-finals` is set, since they aren't stored.

{{< admonition type="warning" title="Warning" >}}
Changing the mapping configuration can interfere with Morphia's ability to map arguments and fields so be careful when making changes to such things as the default field naming strategy or [@Property](javadoc/dev/morphia/annotations/Property.html) definitions.
{{< /admonition >}}

For this mapping to take place, the source must be compiled to include the parameters in the generated bytecode.
With `javac` this is typically already configured by default.
However, Kotlin users will likely need to configure their builds to include the appropriate option.
For maven users, it's as simple as adding one line to the Kotlin maven plugin `<configuration>`:

```xml
    <javaParameters>true</javaParameters>
```

## External types

Sometimes persisted types come from external libraries whose source is either unavailable or simply can't be modified.
Using these types would be impossible give then annotation requirements as stated above.
Morphia 2.3 introduces a new experimental API that loosens these restrictions a bit.
Using [@ExternalEntity](javadoc/dev/morphia/annotations/ExternalEntity.html) these external types can be mapped using a proxy type.

Consider the following two types.
This first type is an external entity which, for whatever reason, can not be annotated with Morphia's annotations.

```java
public class ThirdPartyEntity {
    public String field;
    public Long number;

    // other methods

    @Override
    public int hashCode() {
        // ...
    }

    @Override
    public boolean equals(Object o) {
       // ...
    }
}
```

This class could contain any amount of other code but what we're interested in is mapping those two fields.
To accomplish this, we define a mix-in type:

```java
@ExternalEntity(value = "extEnt",
    discriminator = "ext",
    discriminatorKey = "_xt",
    concern = "JOURNALED",
    cap = @CappedAt(count = 123, value = 456),
    target = ThirdPartyEntity.class)
public class ThirdPartyEntityMixIn {
    public String field;
    @Id
    public Long number;
}
```

Here you'll note the use of the new annotation.  `ExternalEntity` looks just like [Entity](javadoc/dev/morphia/annotations/Entity.html)
but has a new field called `targetType`.
As you can see here, we list the target type as our original `ThirdPartyEntity`.
But this mix-in type otherwise looks just like the external type we're trying to map.
Annotations can be applied to the fields and methods on the mix-in types and those values will be applied to the mapping data as normal.
Using this approach, we can define alternate names for fields and map collection names, etc., as if we owned the original type all without touching it.
As with all top level entities, if you want to store this type in its own collection, you'll need to mark a field as the ID field.
But once this mapping is done, you can then query against the original type just as you would any other Morphia entity.
The mix-in type can happily be ignored once you're done with mapping.

{{< admonition type="note" title="Note" >}}
This API is experimental and is likely to shift a bit as it sees usage and feedback from the community.
{{< /admonition >}}

## Versioning

Entities can be versioned to ensure that changes are applied serially and that no other processes are modifying an object in between the time it's fetched, modified, and written back to the database.
To achieve this, simply add a field to a type, it can be a `long` or a
`Long`, and annotate that field with  [@Version](javadoc/dev/morphia/annotations/Version.html).
Morphia will take care of the rest.
If an object is fetched and another process updates the corresponding document in the database before it can be persisted back, an exception will be thrown when the write is attempted.

{{< admonition type="note" title="Note" >}}
This field must not be initialized to anything other than zero or null or the ID field must be null.
Morphia checks the value of the version field or that the ID is null in order properly save the first version.
If neither of these conditions are true, the entity will not be persisted.
{{< /admonition >}}

## Fields

By default, any non-static field on a mapped class will be processed for persistence.
If a field is to be excluded from the mapping, it can be decorated with the `transient` keyword, annotated with
[@Transient](javadoc/dev/morphia/annotations/Transient.html), or with the `java.beans.Transient` annotation.
Otherwise all fields will be included that are defined on the mapped class and any super type.
However, Morphia will ignore fields in any super types found in `java*` packages which includes the standard JDK classes and the Java EE APIs.

There are times when it is necessary to modify a field mapping's name, e.g. Using the
[@Property](javadoc/dev/morphia/annotations/Property.html) annotation, a new name can be defined that will be used when writing to and reading from the database.
During a schema evolution, it is possible to load a field from an old name as well using the
[@AlsoLoad](javadoc/dev/morphia/annotations/AlsoLoad.html) annotation.
Using this annotation, multiple old names can be used to find a field's value in a returned document from query.
However, only the field's name or the value specified in the `@Property` annotation will be used when writing documents back to the database.
Similarly, if data is only intended to be loaded from the database but never written back, that field can be annotated with [@LoadOnly](javadoc/dev/morphia/annotations/LoadOnly.html)

If you do not specify a name via `@Property`, the default field naming strategy will be used.
The default strategy is to use the field's name as defined in the source.
This strategy can be changed globally via the field naming strategy option configured via
[MorphiaConfig](javadoc/dev/morphia/config/MorphiaConfig.html).
Simple indexes can be defined on a field if all that is needed for the index is a single field.
This can be done via the [@Indexed](javadoc/dev/morphia/annotations/Indexed.html) annotation.

## Methods

{{< admonition type="warning" title="Warning" >}}
Method-based mapping is new in 2.2. While testing has been done to ensure everything works the same as with fields, there may some esoteric combinations of features that reveal a gap in functionality.
Please file an [issue](https://github.com/MorphiaOrg/morphia/issues)
if you encounter such a case.
{{< /admonition >}}

As of 2.2, mapping information can be defined on methods instead of fields.
All the same rules apply, simply the location of the annotations are moved to the getters and/or setters. Annotations can live on either the `get` or the `set` method and Morphia will detect them.
If the same annotation is applied to both the `get` and the `set` behavior is unpredictable so care should be taken to avoid such a scenario.
Customs in other libraries tend to favor annotating the `get` methods and this is also recommended here for consistency.

In order for methods to be considered as definitions of persistable properties, the Java Bean Spec largely applies here.
This has some very basic rules for your methods:

1. `get` methods take no parameters
2. `set` methods take one parameter and the type of that parameter should generally match the return type of the getter. These setter methods also return void.
3. If a property is a boolean type, the getter often uses `is` rather than `get` yielding a method named, e.g., `isEnabled()` rather than
`getEnabled()`.
4. The type of the property is determined by the return value of the getter.
5. The name of the property is determined by stripping the `get` prefix (or `is` for boolean types) and lower casing the first letter.
This is the default name of the property subject to property naming rules as defined in
[MorphiaConfig](javadoc/dev/morphia/config/MorphiaConfig.html)

To enable method mapping, a method has been added to [MorphiaConfig](javadoc/dev/morphia/config/MorphiaConfig.html)
allowing for the configuration of either field or method mapping.

{{< admonition type="note" title="Note" >}}
Mapping is currently done via either fields or by methods. It is not currently allowed to map using both schemes simultaneously. This will
likely change in the future but for now is not allowed.
{{< /admonition >}}
