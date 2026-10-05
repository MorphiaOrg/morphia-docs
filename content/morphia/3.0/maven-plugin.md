---
title: "Maven Plugin"
weight: 60
---

The `critter-maven` plugin generates Morphia entity models and property accessors at build time (AOT — ahead of time), so they are ready on the classpath before your application starts.
Without the plugin, Morphia generates the same models at each JVM startup.

The plugin is optional; where runtime generation works, it produces identical results.  It is recommended to use the plugin, however, and it is required to get critter models when your entities live outside Morphia's class loader or module (see [Class loaders and modules](#class-loaders-and-modules)).

## Why use it?

| Without plugin (runtime generation) | With plugin (AOT generation) |
|---|---|
| Models generated at JVM startup | Models generated once at build time, loaded instantly |
| Startup cost proportional to number of mapped entities | Zero startup cost — models are regular `.class` files on the classpath |
| No build-time dependency on the plugin | Build-time dependency, no runtime overhead |
| Good for development and smaller applications | Recommended for production deployments and fast-start environments (e.g., serverless, containers) |

Both paths generate the bytecode necessary to manage your entities. The plugin simply moves the generation work from JVM startup to build time.

## Class loaders and modules

Runtime generation defines its property accessors as hidden nestmates of each entity class.
The JVM only allows that with full privilege access to the entity, which Morphia has only when the entity is in the same module as Morphia.
On the classpath, that means the entity must be loaded by the same class loader as Morphia.

That isn't the case in layouts like these:

* Morphia in an application server's shared library directory, with the entities in a web application or other deployment that has its own class loader
* Plugin or isolated class loader setups where the entities are loaded separately from Morphia
* Entities in a separate JPMS module from Morphia

There, runtime generation fails for every entity.
Morphia logs a warning once per entity saying it can't access the entity and falls back to the reflection-based model, so your application keeps working, but without the critter models.

Pre-generated models from the `critter-maven` plugin aren't affected: they are compiled alongside your entities and loaded from the entities' own class loader.
If your application uses one of these layouts, use the plugin to get critter models.

## Setup

Add the plugin to your `pom.xml` and set `morphia.mapper=critter` in your config:

```
<plugin>
    <groupId>dev.morphia.morphia</groupId>
    <artifactId>critter-maven</artifactId>
    <version>${morphia.version}</version>
    <executions>
        <execution>
            <id>generate-critter</id>
            <goals>
                <goal>generate-models</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

```
# META-INF/morphia-config.properties
morphia.mapper=critter
```

When `morphia.mapper=critter` is active and the plugin has run, Morphia loads the pre-generated models automatically — no code changes required.

## Goals

## `generate-models` (default phase: `process-classes`)

Reads compiled `.class` files from `${project.build.outputDirectory}` and writes generated entity model and accessor classes to `target/generated-classes/critter`.
This is the standard goal for most projects. It has no user-configurable parameters.

## How it fits together

```
Maven build
  └─ compile phase          → your entity .class files
  └─ process-classes phase  → critter-maven:generate-models
       reads entity .class files
       writes generated entity model class files
  └─ package phase          → all .class files bundled in JAR

Runtime (morphia.mapper=critter)
  └─ CritterMapper.mapEntity(Hotel.class)
       1. tryLoadPregenerated()  → finds HotelEntityModel on classpath ✓
       2. (skipped)              → no runtime generation needed
       3. (skipped)              → no reflection fallback needed
```

If the plugin was not run (e.g., during a quick `mvn test-compile` without the full lifecycle), step 1 finds nothing and Morphia transparently falls back to runtime generation at step 2.
