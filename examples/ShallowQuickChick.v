From QuickChick Require Import QuickChick.
From PropLang Require Import PropLang.

Import QcDefaultNotation.

Local Open Scope qc_scope.
Local Open Scope prop_scope.

#[local] Instance FuzzyNat : Fuzzy nat := { fuzz x := ret x }.

Definition addition_commutes (x y : nat) : bool :=
  Nat.eqb (x + y) (y + x).

Definition curried_example : CProp ∅ :=
  FORALL x :- nat gen:(choose (0, 10))
  FORALL y :- nat ,
  CHECK (fun input : nat * (nat * nat) =>
    let '(y, (x, _)) := input in addition_commutes x y).

Definition checker_example : Checker :=
  mk_shallow ∅ curried_example 0.

QuickChick checker_example.
