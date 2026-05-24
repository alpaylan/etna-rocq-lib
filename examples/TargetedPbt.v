From Stdlib Require Import String ZArith.

From QuickChick Require Import QuickChick.
From PropLang Require Import PropLang SeedPool Heap TargetLoop.

Import QcDefaultNotation.
Import MonadNotation.

Local Open Scope qc_scope.
Local Open Scope nat_scope.
Local Open Scope prop_scope.
Local Open Scope string_scope.
Local Open Scope Z_scope.

Definition small_nat : G nat := choose (0%nat, 10%nat).

Definition bounded_nat (n : nat) : G nat := choose (0%nat, n).

Definition nearby_nat (n : nat) : G nat := choose ((n - 3)%nat, (n + 3)%nat).

Definition distinct (x y : nat) : bool :=
  negb (Nat.eqb y x).

Definition distinct_pair_example : CProp ∅ :=
  @ForAll _ ∅ "x" (fun _ => small_nat) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  @ForAll _ (nat · ∅) "y" (fun '(x, _) => bounded_nat x) (fun _ => nearby_nat) (fun _ => shrink) (fun _ => show) (
  Check (nat · (nat · ∅)) (fun '(y, (x, _)) => distinct x y))).

Definition nat_distance (x y : nat) : nat :=
  if Nat.leb x y then Nat.sub y x else Nat.sub x y.

Definition equality_feedback (input : ⟦⦗distinct_pair_example⦘⟧) : Z :=
  let '(y, (x, _)) := input in
  100 - Z.of_nat (nat_distance x y).

Definition seed_pool : Type :=
  @LeftistHeap.Heap ⟦⦗distinct_pair_example⦘⟧ Z.

Definition initial_pool : seed_pool := mkPool tt.

Definition targeted_run : G Result :=
  targetLoop 100 distinct_pair_example equality_feedback initial_pool _.

Sample1 targeted_run.

Definition targeted_result : Result := invoke targeted_run.
