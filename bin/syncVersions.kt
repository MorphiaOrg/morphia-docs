///usr/bin/env jbang "$0" "$@" ; exit $?
//KOTLIN 2.1.20
//DEPS org.apache.maven:maven-model:4.0.0-rc-5
//DEPS org.semver4j:semver4j:5.6.0
//DEPS com.fasterxml.jackson.core:jackson-databind:2.15.2
//DEPS com.fasterxml.jackson.dataformat:jackson-dataformat-xml:2.15.2
//DEPS org.yaml:snakeyaml:2.2

import com.fasterxml.jackson.dataformat.xml.XmlMapper
import org.apache.maven.model.v4.MavenStaxReader
import org.semver4j.Semver
import org.yaml.snakeyaml.DumperOptions
import org.yaml.snakeyaml.Yaml
import java.io.File
import java.net.URL

val MORPHIA_DIR = File("build/morphia")
val ANTORA_FILE = File(MORPHIA_DIR, "docs/antora.yml")
val POM_FILE = File(MORPHIA_DIR, "pom.xml")

fun main(vararg args: String) {
    require(args.isNotEmpty()) { "Usage: syncVersions.kt <branch> [onlyminor]" }
    val branch = args[0]
    val onlyMinor = args.size > 1 && args[1] == "onlyminor"
    val pom = POM_FILE.inputStream().use { MavenStaxReader().read(it) }
    val pomVersion = Semver.parse(pom.version) ?: error("Cannot parse pom version: ${pom.version}")
    val major = pomVersion.major
    val minor = pomVersion.minor
    val srcRef = "https://github.com/MorphiaOrg/morphia/tree/$branch"

    val latest = latestRelease(major, minor)
    if (latest != null) {
        syncAntora(latest.toString(), "$major.$minor", snapshot = false, srcRef = srcRef)
        println(if (onlyMinor) "$major.$minor" else latest.toString())
    } else {
        val snap = pomVersion.toString()
        syncAntora(snap, "$major.$minor", snapshot = true, srcRef = srcRef)
        println(if (onlyMinor) "$major.$minor" else snap)
    }
}

fun latestRelease(major: Int, minor: Int): Semver? {
    val artifact = if (major == 1) "core" else "morphia-core"
    val url = "https://repo1.maven.org/maven2/dev/morphia/morphia/$artifact/maven-metadata.xml"
    val doc = XmlMapper().readTree(URL(url))
    val versions = doc["versioning"]["versions"]["version"]
    return versions.elements().asSequence()
        .mapNotNull { Semver.parse(it.asText()) }
        .filter { it.preRelease.isEmpty() }
        .filter { it.major == major && it.minor == minor }
        .maxByOrNull { it.patch }
}

fun syncAntora(version: String, minorVersion: String, snapshot: Boolean, srcRef: String) {
    val opts = DumperOptions().apply { defaultFlowStyle = DumperOptions.FlowStyle.BLOCK }
    val yaml = Yaml(opts)
    val data = yaml.load<MutableMap<String, Any>>(ANTORA_FILE.readText())
    val asciidoc = data["asciidoc"] as? Map<*, *>
        ?: error("antora.yml missing 'asciidoc' key")
    @Suppress("UNCHECKED_CAST")
    val attrs = asciidoc["attributes"] as? MutableMap<String, Any>
        ?: error("antora.yml missing 'asciidoc.attributes' key")

    val unchanged = attrs["version"].toString() == version &&
        data["version"].toString() == minorVersion &&
        snapshot == (data["prerelease"] == "-SNAPSHOT") &&
        attrs["srcRef"].toString() == srcRef
    if (unchanged) return

    data["version"] = minorVersion
    attrs["version"] = version
    attrs["srcRef"] = srcRef
    if (snapshot) data["prerelease"] = "-SNAPSHOT" else data.remove("prerelease")

    ANTORA_FILE.writeText("---\n" + yaml.dump(data))
    gitCommitPush(version)
}

fun gitCommitPush(version: String) {
    runCmd("git", "-C", MORPHIA_DIR.path, "add", "docs/antora.yml")
    runCmd("git", "-C", MORPHIA_DIR.path, "commit", "-m", "chore: update version to $version")
    runCmd("git", "-C", MORPHIA_DIR.path, "push")
}

fun runCmd(vararg cmd: String) {
    val proc = ProcessBuilder(*cmd).redirectErrorStream(true).start()
    proc.inputStream.copyTo(System.err)
    val exit = proc.waitFor()
    if (exit != 0) error("Failed (exit $exit): ${cmd.joinToString(" ")}")
}
