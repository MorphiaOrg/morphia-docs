---
title: "Mapper Benchmarks"
description: "JMH results comparing Morphia's reflection and critter mappers over time"
---

Morphia can map entities in three ways, and these benchmarks track how they compare as the code changes:

- **reflection** — the default `ReflectiveMapper`, which discovers entity models with reflection at runtime.
- **critter** — the `CritterMapper` using models generated ahead of time by the `critter-maven` plugin.
- **critter-runtime** — the `CritterMapper` with no generated models on the classpath, so it generates them at runtime instead.

Each run of the [Mapper Profiling](https://github.com/MorphiaOrg/morphia/actions/workflows/mapper-profiling.yml) workflow
runs the JMH benchmarks from the `benchmarks` module against all three variants and records the results here. The workflow
is run by hand against `master`, on GitHub-hosted runners, so the absolute numbers are noisy from run to run. The ratios
between variants within the same run are the more reliable signal. Lower is better for every benchmark shown.
