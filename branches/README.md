# branches/

Each subdirectory here corresponds to a Morphia source branch and is the
**permanent source of truth** for that version's documentation.

| Folder    | Version | URL path         | Notes                        |
|-----------|---------|------------------|------------------------------|
| `2.5.x/`  | 2.5     | `/morphia/2.5/`  | Latest stable release        |
| `master/` | 2.5     | `/morphia/2.5/`  | Snapshot — displayed as "master" |
| `2.4.x/`  | 2.4     | `/morphia/2.4/`  | Previous stable release      |

## Adding a new version

1. Create a new folder `branches/<branch-name>/`.
2. Populate it with Markdown content (see "Content structure" below).
3. Add a `.version` file containing the `major.minor` version string.
4. Update `data/versions.yaml` (or run `make data/versions.yaml`).

## Content structure

```
branches/<branch>/
├── .version          # e.g. "2.5"
├── _index.md         # Section index — becomes /morphia/<version>/
├── getting-started/
│   ├── _index.md
│   ├── installation.md
│   └── quickstart.md
├── reference/
│   ├── _index.md
│   └── ...
└── examples/         # Raw source files referenced by include-code shortcode
    └── *.java
```

## Initial seed

Run `make migrate` to perform the initial AsciiDoc → Markdown conversion from
the upstream morphia repository. After that, edits go here directly.
