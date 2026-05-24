From Stdlib Require Import String.

From QuickChick Require Import QuickChick.
From PropLang Require Import PropLang.

Import QcDefaultNotation.
Import MonadNotation.

Local Open Scope qc_scope.
Local Open Scope nat_scope.
Local Open Scope prop_scope.
Local Open Scope string_scope.

Definition small_nat : G nat := choose (0, 10).

Definition bounded_nat (n : nat) : G nat := choose (0, n).

Definition nearby_nat (n : nat) : G nat := choose (n - 3, n + 3).

Definition distinct (x y : nat) : bool :=
  negb (Nat.eqb y x).

Definition distinct_pair_example : CProp ∅ :=
  @ForAll _ ∅ "x" (fun _ => small_nat) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  @ForAll _ (nat · ∅) "y" (fun '(x, _) => bounded_nat x) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  Check (nat · (nat · ∅)) (fun '(y, (x, _)) => distinct x y))).

Definition example_test :=
  runLoop 100 distinct_pair_example.

Extraction "examples/extraction_example.ml" example_test.
