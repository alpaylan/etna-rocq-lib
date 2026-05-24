# Examples

These files are intentionally outside the installed library surface in the
root `_CoqProject`.

- `Basic.v` shows direct construction of `CProp` values, sized generators, and
  `Sample` output from the default `runLoop`.
- `ShallowQuickChick.v` shows the lightweight `FORALL`/`CHECK` notation and
  conversion to a QuickChick `Checker`.
- `TargetedPbt.v` shows `targetLoop` with an explicit feedback function and a
  heap-backed seed pool.
- `Extraction.v` shows the current `runLoop` extraction shape used by workload
  runners.

From the repository root, check an example with:

```sh
rocq compile -q -Q . PropLang examples/Basic.v
rocq compile -q -Q . PropLang examples/TargetedPbt.v
```

`Basic.v`, `TargetedPbt.v`, and `ShallowQuickChick.v` include vernacular
commands that print results while compiling:

- `Sample1 basic_run.` runs the default `runLoop` generator and prints sampled
  `Result` values.
- `Sample1 targeted_run.` runs the targeted loop generator and prints sampled
  `Result` values.
- `QuickChick checker_example.` runs the shallow QuickChick checker produced
  from a `CProp`.
