///usr/bin/env jbang "$0" "$@" ; exit $?
//KOTLIN 2.1.20
//DEPS org.semver4j:semver4j:5.6.0
//DEPS com.fasterxml.jackson.core:jackson-databind:2.15.2
//DEPS com.fasterxml.jackson.dataformat:jackson-dataformat-xml:2.15.2

import com.fasterxml.jackson.dataformat.xml.XmlMapper
import org.semver4j.Semver
import java.io.File
import java.net.URI

const val RELEASE_BASE  = "https://repo1.maven.org/maven2/dev/morphia/morphia"
const val SNAPSHOT_BASE = "https://central.sonatype.com/repository/maven-snapshots/dev/morphia/morphia"

fun main(vararg args: String) {
    require(args.isNotEmpty()) { "Usage: syncVersions.kt <branch> | --latest" }

    if (args[0] == "--latest") {
        println(latestRelease() ?: "")
        return
    }

    val branch = args[0]
    val minorVersion = File("content/morphia/$branch/.version").readText().trim()
    val (major, minor) = minorVersion.split(".").map { it.toInt() }
    val artifact = if (major == 1) "core" else "morphia-core"

    val version = latestRelease(artifact, major, minor)
        ?: latestSnapshot(artifact, major, minor)
        ?: "$minorVersion.0-SNAPSHOT"
    println(version)
}

fun latestRelease(): String? = try {
    val doc = XmlMapper().readTree(URI("$RELEASE_BASE/morphia-core/maven-metadata.xml").toURL())
    doc["versioning"]["versions"]["version"].elements().asSequence()
        .mapNotNull { Semver.parse(it.asText()) }
        .filter { it.preRelease.isEmpty() }
        .maxWithOrNull(compareBy({ it.major }, { it.minor }, { it.patch }))
        ?.toString()
} catch (_: Exception) { null }

fun latestRelease(artifact: String, major: Int, minor: Int): String? = try {
    val doc = XmlMapper().readTree(URI("$RELEASE_BASE/$artifact/maven-metadata.xml").toURL())
    doc["versioning"]["versions"]["version"].elements().asSequence()
        .mapNotNull { Semver.parse(it.asText()) }
        .filter { it.preRelease.isEmpty() && it.major == major && it.minor == minor }
        .maxByOrNull { it.patch }
        ?.toString()
} catch (_: Exception) { null }

fun latestSnapshot(artifact: String, major: Int, minor: Int): String? = try {
    val doc = XmlMapper().readTree(URI("$SNAPSHOT_BASE/$artifact/maven-metadata.xml").toURL())
    doc["versioning"]["versions"]["version"].elements().asSequence()
        .map { it.asText() }
        .filter { it.startsWith("$major.$minor.") && it.contains("SNAPSHOT") }
        .maxOrNull()
} catch (_: Exception) { null }
