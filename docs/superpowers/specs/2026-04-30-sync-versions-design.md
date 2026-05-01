# Design: syncVersions — Maven Central version sync and gh CLI migration

## Summary

Replace `bin/extractVersions.kt` with `bin/syncVersions.kt`, a jbang Kotlin script that queries Maven Central for the latest released Morphia version per branch, syncs `docs/antora.yml` in the morphia repo if it is stale, commits and pushes the change, and outputs the version for `versions.list`. Also migrate all GitHub interactions in the Makefile from token-based URLs to the `gh` CLI.

---

## Script: `bin/syncVersions.kt`

### Invocation

Called once per branch from the Makefile `versions.list` target:

```
jbang --quiet bin/syncVersions.kt <branch> [onlyminor]
```

- `<branch>`: the branch name being processed (e.g. `master`, `2.4.x`)
- `onlyminor`: optional second argument; when present, print only `major.minor` instead of the full version (used for the index link sed fixup)

### Dependencies

- `org.apache.maven:maven-model:4.0.0-rc-5` (already used)
- `org.semver4j:semver4j:5.6.0` (already used)
- `com.fasterxml.jackson.core:jackson-databind:2.15.2`
- `com.fasterxml.jackson.dataformat:jackson-dataformat-xml:2.15.2`
- `org.yaml:snakeyaml:2.2`

### Per-branch logic

1. Read `build/morphia/pom.xml` → extract `major.minor` (e.g. `2.4` from `2.4.0-SNAPSHOT`)
2. Query `https://repo1.maven.org/maven2/dev/morphia/morphia/morphia-core/maven-metadata.xml` → collect all versions, filter out pre-releases/alphas/betas/RCs, group by `major.minor`, find the highest patch for the matching group
3. Read `build/morphia/docs/antora.yml` via SnakeYAML

**Released version found:**
- If `asciidoc.attributes.version` already matches the Maven Central result → no change
- Otherwise: set `version` to `major.minor`, remove `prerelease` key if present, set `asciidoc.attributes.version` to the full release version, write the file, commit + push
- Print the full release version (or `major.minor` if `onlyminor`)

**No released version found (e.g. master/next major):**
- Use the full SNAPSHOT version from pom.xml (e.g. `3.0.0-SNAPSHOT`)
- If `asciidoc.attributes.version` already matches and `prerelease: "-SNAPSHOT"` is present → no change
- Otherwise: set `version` to `major.minor`, set `prerelease: "-SNAPSHOT"`, set `asciidoc.attributes.version` to the SNAPSHOT string, write the file, commit + push
- Print the SNAPSHOT version (or `major.minor` if `onlyminor`)

### Commit/push

When an update is required:

```
git -C build/morphia add docs/antora.yml
git -C build/morphia commit -m "chore: update version to X.Y.Z"
git -C build/morphia push
```

Executed via `ProcessBuilder`. Any non-zero exit causes the script to print to stderr and exit non-zero, failing the Makefile target loudly. Git identity relies on whatever is already configured in the working tree.

---

## Makefile changes

### Clone: replace token URL with gh CLI

Remove:
```makefile
MORPHIA_GITHUB=https://evanchooly:${{ secrets.PUSH_TOKEN }}@github.com/MorphiaOrg/morphia.git
```

Initial clone becomes:
```makefile
gh repo clone MorphiaOrg/morphia build/morphia
```

Subsequent pulls remain plain `git -C build/morphia pull --all --quiet` — gh CLI manages credentials.

### `versions.list` target

Replace the `extractVersions.kt` invocation loop with a call to `syncVersions.kt`. The onlyminor sed fixup (lines 36–39) is retained unchanged, calling `syncVersions.kt <branch> onlyminor`.

### `push` target

No change. `git push ${REMOTE_REPO}` continues to work — gh CLI provides credential support for plain git push once the repo was cloned via gh.

### `extractVersions.kt`

Deleted. `syncVersions.kt` is a full replacement.

---

## antora.yml format reference

Released branch example:
```yaml
---
name: "morphia"
title: "Morphia"
version: "2.4"
nav:
- "modules/ROOT/nav.adoc"
asciidoc:
  attributes:
    version: "2.4.20"
    srcRef: "https://github.com/MorphiaOrg/morphia/tree/2.4.x"
```

Snapshot/prerelease branch example:
```yaml
---
name: "morphia"
title: "Morphia"
version: "3.0"
prerelease: "-SNAPSHOT"
nav:
- "modules/ROOT/nav.adoc"
asciidoc:
  attributes:
    version: "3.0.0-SNAPSHOT"
    srcRef: "https://github.com/MorphiaOrg/morphia/blob/master"
```

---

## Error handling

- Maven Central fetch failure: print to stderr, exit non-zero
- pom.xml parse failure: print to stderr, exit non-zero
- antora.yml parse/write failure: print to stderr, exit non-zero
- git commit/push failure: print to stderr, exit non-zero
- All errors surface immediately so the Makefile `versions.list` target fails fast
