# etna-rocq-lib

Shared Rocq/Coq support library for [Etna](https://github.com/alpaylan/etna-cli)
workloads. Provides the `PropLang` plugin used by the `*Proplang` workload
variants.

## Usage

Consumed as a git submodule at `./Lib/` inside `*Proplang` workload repos
(`etna-rocq-bst-proplang`, `etna-rocq-rbt-proplang`, ...). Each workload's
`setup_steps` runs `./Lib/build -i` first, which invokes `coq_makefile`,
builds `PropLang.v`, and installs the result to coq's `user-contrib/PropLang`
so subsequent workload runners can `From PropLang Require Import PropLang.`.

It is not a standalone workload — it has no `etna.toml`.

## Build

```
./build -i   # compile and install
./build -c   # clean before build
```
