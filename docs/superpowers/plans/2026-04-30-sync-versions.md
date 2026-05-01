# syncVersions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `bin/extractVersions.kt` with `bin/syncVersions.kt` that queries Maven Central for the latest released Morphia version per branch, syncs `docs/antora.yml` if stale (committing and pushing), and outputs the version for `versions.list`; also migrate Makefile GitHub interactions to the `gh` CLI.

**Architecture:** A single jbang Kotlin script handles Maven Central querying, antora.yml diffing/patching, and git commit+push. The Makefile `versions.list` target calls this script once per branch, replacing the old `extractVersions.kt` invocations. Clone operations in the Makefile switch from token-embedded URLs to `gh repo clone`.

**Tech Stack:** Kotlin (jbang), semver4j, maven-model, jackson-dataformat-xml (Maven Central XML), snakeyaml (antora.yml read/write), gh CLI, GNU make

> **Note:** Do not commit changes to this repo until the user approves the implementation.

---

### Task 1: Create `bin/syncVersions.kt`

**Files:**
- Create: `bin/syncVersions.kt`

- [ ] **Step 1: Create the script**

Create `bin/syncVersions.kt`:

```kotlin
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
    val onlyMinor = args.size > 1 && args[1] == "onlyminor"
    val pom = MavenStaxReader().read(POM_FILE.inputStream())
    val pomVersion = Semver.parse(pom.version) ?: error("Cannot parse pom version: ${pom.version}")
    val major = pomVersion.major
    val minor = pomVersion.minor

    val latest = latestRelease(major, minor)
    if (latest != null) {
        syncAntora(latest.toString(), "$major.$minor", snapshot = false)
        println(if (onlyMinor) "$major.$minor" else latest.toString())
    } else {
        val snap = pomVersion.toString()
        syncAntora(snap, "$major.$minor", snapshot = true)
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

@Suppress("UNCHECKED_CAST")
fun syncAntora(version: String, minorVersion: String, snapshot: Boolean) {
    val opts = DumperOptions().apply { defaultFlowStyle = DumperOptions.FlowStyle.BLOCK }
    val yaml = Yaml(opts)
    val data = yaml.load<MutableMap<String, Any>>(ANTORA_FILE.readText())
    val attrs = (data["asciidoc"] as Map<String, Any>)["attributes"] as MutableMap<String, Any>

    val unchanged = attrs["version"].toString() == version &&
        data["version"].toString() == minorVersion &&
        snapshot == (data["prerelease"] != null)
    if (unchanged) return

    data["version"] = minorVersion
    attrs["version"] = version
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
    val exit = ProcessBuilder(*cmd).inheritIO().start().waitFor()
    if (exit != 0) error("Failed (exit $exit): ${cmd.joinToString(" ")}")
}
```

- [ ] **Step 2: Test against 2.5.x (already up-to-date — no commit expected)**

```bash
git -C build/morphia checkout 2.5.x --quiet
jbang bin/syncVersions.kt 2.5.x
```

Expected output: `2.5.2`
Expected: no git commit occurs (antora.yml already has `2.5.2`)

```bash
jbang bin/syncVersions.kt 2.5.x onlyminor
```

Expected output: `2.5`

- [ ] **Step 3: Test against 2.4.x (stale — commit expected)**

```bash
git -C build/morphia checkout 2.4.x --quiet
jbang bin/syncVersions.kt 2.4.x
```

Expected output: `2.4.20`
Expected side effects:
- `build/morphia/docs/antora.yml` updated: `asciidoc.attributes.version` changed from `2.4.19` to `2.4.20`
- Commit `chore: update version to 2.4.20` pushed to `2.4.x` branch in morphia repo

Verify:
```bash
git -C build/morphia log --oneline -1
```
Expected: `chore: update version to 2.4.20`

- [ ] **Step 4: Test against master (snapshot branch)**

```bash
git -C build/morphia checkout master --quiet
jbang bin/syncVersions.kt master
```

Expected output: the SNAPSHOT version from master `pom.xml` (e.g. `3.0.0-SNAPSHOT`)
Expected: antora.yml has `prerelease: '-SNAPSHOT'`; commit only occurs if it was missing or version mismatched.

- [ ] **Step 5: Test against 1.6.x (legacy `core` artifact)**

```bash
git -C build/morphia checkout 1.6.x --quiet
jbang bin/syncVersions.kt 1.6.x
```

Expected output: `1.6.1`
Expected: no commit (antora.yml already has `1.6.1`)

---

### Task 2: Update `Makefile`

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Remove `MORPHIA_GITHUB` variable**

Delete this line from the top of the Makefile:
```makefile
MORPHIA_GITHUB=https://evanchooly:${{ secrets.PUSH_TOKEN }}@github.com/MorphiaOrg/morphia.git
```

- [ ] **Step 2: Update `$(GH_PAGES)` clone**

Old:
```makefile
@[ ! -d $@ ] && git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES) || true
```

New:
```makefile
@[ ! -d $@ ] && gh repo clone MorphiaOrg/morphia $(GH_PAGES) -- -b gh-pages || true
```

- [ ] **Step 3: Update `build/morphia` clone**

Old:
```makefile
@[ ! -d $@ ] && git clone $(MORPHIA_GITHUB) build/morphia || true
```

New:
```makefile
@[ ! -d $@ ] && gh repo clone MorphiaOrg/morphia build/morphia || true
```

- [ ] **Step 4: Update `push` target**

Old:
```makefile
git push ${REMOTE_REPO}
```

New:
```makefile
git push
```

- [ ] **Step 5: Update `versions.list` target — dependency and script references**

Change the target dependency:

Old:
```makefile
versions.list: Makefile bin/extractVersions.kt
```

New:
```makefile
versions.list: Makefile bin/syncVersions.kt
```

Replace jbang call in the branch loop:

Old:
```makefile
jbang --quiet bin/extractVersions.kt $$BRANCH >> versions.list ; \
```

New:
```makefile
jbang bin/syncVersions.kt $$BRANCH >> versions.list ; \
```

Replace the `onlyminor` call in the sed fixup block:

Old:
```makefile
VERSION=`jbang --quiet bin/extractVersions.kt $$BRANCH onlyminor` ; \
```

New:
```makefile
VERSION=`jbang bin/syncVersions.kt $$BRANCH onlyminor` ; \
```

- [ ] **Step 6: Verify Makefile syntax**

```bash
make --dry-run versions.list 2>&1 | head -30
```

Expected: commands printed with no syntax errors.

---

### Task 3: Delete `bin/extractVersions.kt`

**Files:**
- Delete: `bin/extractVersions.kt`

- [ ] **Step 1: Remove the old script**

```bash
rm bin/extractVersions.kt
```

- [ ] **Step 2: Confirm no remaining references**

```bash
grep -r "extractVersions" .
```

Expected: no output.

---

### Task 4: End-to-end verification

- [ ] **Step 1: Regenerate versions.list from scratch**

```bash
rm -f versions.list Makefile-javadoc
make versions.list
```

Expected: each branch processed; `versions.list` written with one version per line.

- [ ] **Step 2: Check versions.list content**

```bash
cat versions.list
```

Expected (versions will match Maven Central latest per branch at time of run):
```
3.0.0-SNAPSHOT
2.5.2
2.4.20
2.3.9
1.6.1
```

- [ ] **Step 3: Verify javadoc Makefile generates correctly**

```bash
bash bin/generate-makefile.sh
head -40 Makefile-javadoc
```

Expected: valid targets for each version; snapshot versions reference `central.sonatype.com/repository/maven-snapshots/`; release versions reference `repo1.maven.org`.

- [ ] **Step 4: Show diff and await user approval before committing**

```bash
git diff Makefile
git status
```

Present the output to the user. Do not commit until instructed.
