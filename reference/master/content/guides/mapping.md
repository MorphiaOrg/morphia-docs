+++
title = "Mapping"
[menu.main]
  parent = "Reference Guides"
  pre = "<i class='fa fa-file-text-o'></i>"
+++

## Classes

Mapping is achieved through one of two annotations to start:  [@Entity]({{< apiref "dev/morphia/annotations/Entity" >}}) and 
[@Embedded]({{< apiref "dev/morphia/annotations/Embedded" >}}).  In order for Morphia to consider any type for mapping, it must have one
of these two annotation.  `@Entity` is used to denote a "top level" type.  These types tend to have their own collections whose names
can be mapped via the `value` parameter.  Leaving this value blank will leave Morphia free to compute the collection name as defined by
the collection naming strategy defined in [@MapperOptions]({{< apiref "dev/morphia/mapping/MapperOptions" >}}).  That default is
currently the camel case value of the class's simple name.  For example, to map a `UserProfile` entity under this strategy, the
collection name would be mapped to `userProfile`. 

Any type annotated with `@Entity` must have a field annotated with [@Id]({{< apiref "dev/morphia/annotations/Id" >}}).  The type of the
field can be any type so long as Morphia or the driver have codecs that can map the data to and from mongodb.  When mapping an entity,
 one can also define [indexes]({{< relref "indexing.md" >}}) and [schema validations]({{< relref "schemaValidation.md" >}}) as part of
  the entity declaration as well.

### External types
Some times persisted types come from external libraries whose source is either unavailable or simply can't be modified.  Using these
 types would be impossible give then annotation requirements as stated above.  Morphia 2.1 introduces a new experimental API that loosens
  these restrictions a bit.  Using [Mapper#mapExternal]({{< apiref "dev/morphia/mapping/Mapper#mapExternal(A,java.lang.Class)" >}}) these
   external types can be passed in for use as embedded types in other entities.  An optional instance of `@Embedded` can created using the 
[EmbeddedBuilder]({{< apiref "dev/morphia/annotations/experimental/EmbeddedBuilder" >}}).  A null can be passed in to simply accept the
 default values.
 
{{% notice note %}}
This API is experimental and is likely to shift a bit as it sees usage and feedback from the community.
{{% /notice %}}
 
### Versioning
Entities can be versioned to ensure that changes are applied serially and that no other processes are modifying an object in between the
time it's fetched, modified, and written back to the database.  To achieve this, simply add a field to a type, it can be a `long` or a
`Long` and annotation that field with [@Version]({{< apiref "dev/morphia/annotations/Version" >}}).  This field must not be initialized
to anything other than zero or null, however.  Morphia will take care of the rest.  If an object is fetched and another process
updates the corresponding document in the database before it can be persisted back, an exception will be thrown when the write is
 attempted.

## Fields

By default, any non-static field on a mapped class will be processed for persistence.  If a field is to be excluded from the mapping, it
can be decorated with the `transient` keyword, annotated with  [@Transient]({{< apiref "dev/morphia/annotations/Transient" >}}), or with
the `java.beans.Transient` annotation.  Otherwise all fields will be included that are defined on the mapped class and any super type.
However, Morphia will ignore fields in any super types found in `java*` packages which includes the standard JDK classes and the Java EE
 APIs.
 
There are times when it is necessary to modify a field mapping's name, e.g.  Using the 
[@Property]({{< apiref "dev/morphia/annotations/Property" >}}) annotation, a new name can be defined that will be used when writing to
 and reading from the database.  During a schema evolution, it is possible to load a field from an old name as well using the
[@AlsoLoad]({{< apiref "dev/morphia/annotations/AlsoLoad" >}}) annotation.  Using this annotation, multiple old names can be used to
find a field's value in a returned document from query.  However, only the field's name or the value specified in the `@Property`
annotation will be used when writing documents back to the database.  Similarly, if data is only intended to be loaded from the database
 but never written back, that field can be annotated with [@LoadOnly]({{< apiref "dev/morphia/annotations/LoadOnly" >}})

If you do not specify a name via `@Property`, the default field naming strategy will be used.  The default strategy is to use the field's
name as defined in the source.  This strategy can be changed globally via the field naming strategy option on 
[@MapperOptions]({{< apiref "dev/morphia/mapping/MapperOptions" >}}).  Simple indexes can be defined on a field if all that is needed for
 the index is a single field.  This can be done via the [@Indexed]({{< apiref "dev/morphia/annotations/Indexed" >}}) annotation.