# etna-rocq-lib

Shared Rocq/Coq support library for [Etna](https://github.com/alpaylan/etna-cli)
workloads. Provides the `PropLang` library used by the `*Proplang` workload
variants to define properties, run generation/mutation loops, and reuse seed
pool policies.

## Usage

Consumed as a git submodule at `./Lib/` inside `*Proplang` workload repos
(`etna-rocq-bst-proplang`, `etna-rocq-rbt-proplang`, ...). Each workload's
`setup_steps` runs `./Lib/build -i` first, which invokes `coq_makefile`,
builds the modules listed in `_CoqProject`, and installs them to Rocq's
`user-contrib/PropLang`.

Workloads can then import the pieces they need:

```coq
From PropLang Require Import PropLang.
From PropLang Require Import SeedPool Queue Heap DoubleQueue.
From PropLang Require Import FuzzLoop TargetLoop ParLoop.
```

## Build

```bash
./build -i   # compile and install
./build -c   # clean before build
```

To check the examples without adding them to the installed library surface:

```bash
rocq compile -q -Q . PropLang examples/Basic.v
rocq compile -q -Q . PropLang examples/ShallowQuickChick.v
rocq compile -q -Q . PropLang examples/Extraction.v
```

## Layout

- `PropLang.v` contains the core proposition language, generation, mutation,
  shrinking, printing, shallow QuickChick conversion helpers, and the default
  loop result type.
- `seedpool/` contains reusable seed-pool policies and data structures.
  `DoubleQueue.v` keeps interesting valid seeds in a high-priority queue and
  interesting invalid seeds in a low-priority queue.
- `loops/` contains loop strategies built on top of `PropLang.v` and
  `seedpool/`.
- `examples/` contains small, explicit examples and notes. These are not part
  of the installed library surface.
- `_CoqProject` is the source of truth for modules that are built and
  installed by `./build`.

Generated files such as `Makefile`, `.Makefile.d`, `*.vo`, `*.vos`, `*.vok`,
`*.glob`, and extracted example artifacts are ignored.
