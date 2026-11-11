---
title: "Getting Started"
weight: 10
---

The recommended way to get started using Morphia in your project is with a dependency management system such as maven or gradle.
To use Morphia using either build tool, you will need to update your build configuration with the following information.

```xml
<dependencies>
    <dependency>
        <groupId>dev.morphia.morphia</groupId>
        <artifactId>morphia-core</artifactId>
        <version>3.0.0-SNAPSHOT</version>
    </dependency>
</dependencies>
```

If you want to use a `-SNAPSHOT` build you will need to add the appropriate repository information to you pom:

```xml
<repositories>
    <repository>
        <id>sonatype-snapshots</id>
        <url>https://oss.sonatype.org/content/repositories/snapshots</url>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
</repositories>
```

Gradle users can use the following dependency declaration:

```groovy
dependencies {
    compile 'dev.morphia.morphia:morphia-core:3.0.0-SNAPSHOT'
}
```

To use `-SNAPSHOT` builds, an additional repository will be needed:

```groovy
repositories {
    maven {
        url 'https://oss.sonatype.org/content/repositories/snapshots'
    }
}
```


{{< admonition type="note" title="Note" >}}
Morphia 3.0 requires Java 17 or greater and a minimum driver version of 5.0.
Morphia is actively tested on MongoDB server versions 7.0 and above.  Morphia will likely work on older server versions, but those 
remain untested and no guarantees are made.
{{< /admonition >}}
