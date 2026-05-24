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

Definition less_than (x y : nat) : bool :=
  Nat.ltb y x.

Definition implication_example : CProp ∅ :=
  @ForAll _ ∅ "x" (fun _ => small_nat) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  @ForAll _ (nat · ∅) "y" (fun '(x, _) => bounded_nat x) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  Implies (nat · (nat · ∅)) (fun '(y, (x, _)) => Nat.ltb x y) (
  Check (nat · (nat · ∅)) (fun '(y, (x, _)) => less_than x y)))).

Definition distinct_pair_example : CProp ∅ :=
  @ForAll _ ∅ "x" (fun _ => small_nat) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  @ForAll _ (nat · ∅) "y" (fun '(x, _) => bounded_nat x) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  Check (nat · (nat · ∅)) (fun '(y, (x, _)) => negb (Nat.eqb y x)))).

Definition sized_example : CProp ∅ :=
  @ForAll _ ∅ "x" (sized _ (fun _ size => ret size)) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  Check (nat · ∅) (fun '(x, _) => less_than x 3)).

Definition basic_run : G Result :=
  runLoop 100 distinct_pair_example.

Sample1 basic_run.

Definition sampled_result : Result :=
  invoke basic_run.
