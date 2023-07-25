import com.github.zafarkhaja.semver.Version
import java.io.File
import org.apache.maven.model.io.xpp3.MavenXpp3Reader

///usr/bin/env jbang "$0" "$@" ; exit $?
//KOTLIN 1.9.0
//DEPS org.jetbrains.kotlin:kotlin-stdlib:1.9.0
//DEPS org.apache.maven:maven-model:3.9.2
//DEPS com.github.zafarkhaja:java-semver:0.9.0

fun main(vararg args: String) {
    val master = "master" == args[0]
    val onlyMinor = args.size != 1 && !args[1].isNullOrBlank()
    val pom = MavenXpp3Reader().read(File("build/morphia/pom.xml").inputStream())
    val version = Version.valueOf(pom.version)

    var major = version.majorVersion
    var minor = version.minorVersion
    var patch = version.patchVersion
    if (master) {
        println(version.toString())
    } else {
        if (patch != 0){
            patch--
        } else if (minor != 0){
            minor--
        }
        
        if (onlyMinor) {
            println("$major.$minor")
        } else {
            println(Version.forIntegers(major, minor, patch))
        }
    }
}
