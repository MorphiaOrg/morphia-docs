import java.io.File
import org.apache.maven.model.io.xpp3.MavenXpp3Reader
import org.semver4j.Semver

///usr/bin/env jbang "$0" "$@" ; exit $?
//KOTLIN 2.1.20
//DEPS org.apache.maven:maven-model:3.9.2
//DEPS org.semver4j:semver4j:5.6.0

fun main(vararg args: String) {
    val master = "master" == args[0]
    val onlyMinor = args.size != 1 && args[1].isNotBlank()
    val pom = MavenXpp3Reader().read(File("build/morphia/pom.xml").inputStream())
    val version = Semver.parse(pom.version)

    if (version == null) {
        println("Version not found")
        return
    }
    var major = version.major
    var minor = version.minor
    var patch = version.patch
    if (master) {
        println(version.toString())
    } else if (version.preRelease.isNotEmpty() && patch == 0) {
        println(version.toString())
    } else {
        if (patch != 0){
            patch--
        }
        
        if (onlyMinor) {
            println("$major.$minor")
        } else {
            println(Semver.of(major, minor, patch))
        }
    }
}
