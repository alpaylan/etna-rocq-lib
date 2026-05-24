From Stdlib Require Import List ZArith.

From PropLang Require Import SeedPool.

Import ListNotations.

Local Open Scope Z_scope.

Record ValidityFeedback := {
  valid : bool;
  score : Z;
}.

#[global] Instance ScalarValidityFeedback : Scalar ValidityFeedback :=
  {| scale := score |}.

Record DoubleQueuePool {A : Type} := {
  hpq : list (@Seed A ValidityFeedback);
  lpq : list (@Seed A ValidityFeedback);
}.

Definition empty {A : Type} : @DoubleQueuePool A :=
  {| hpq := []; lpq := [] |}.

Definition high_priority_energy : Z := 100.

Definition low_priority_energy : Z := 25.

Definition mk_high_priority_seed {A : Type}
  (input : A) (feedback : ValidityFeedback) : @Seed A ValidityFeedback :=
  mkSeed input feedback high_priority_energy.

Definition mk_low_priority_seed {A : Type}
  (input : A) (feedback : ValidityFeedback) : @Seed A ValidityFeedback :=
  mkSeed input feedback low_priority_energy.

Definition insert_high_priority {A : Type}
  (seed : @Seed A ValidityFeedback) (pool : @DoubleQueuePool A)
  : @DoubleQueuePool A :=
  {| hpq := seed :: hpq pool; lpq := lpq pool |}.

Definition insert_low_priority {A : Type}
  (seed : @Seed A ValidityFeedback) (pool : @DoubleQueuePool A)
  : @DoubleQueuePool A :=
  {| hpq := hpq pool; lpq := seed :: lpq pool |}.

Definition seed_score {A : Type} (seed : @Seed A ValidityFeedback) : Z :=
  score (feedback seed).

Definition usable {A : Type} (seed : @Seed A ValidityFeedback) : bool :=
  negb (energy seed =? 0).

Fixpoint best_seed {A : Type}
  (current : option (@Seed A ValidityFeedback))
  (queue : list (@Seed A ValidityFeedback))
  : option (@Seed A ValidityFeedback) :=
  match queue with
  | [] => current
  | seed :: rest =>
      if usable seed then
        match current with
        | None => best_seed (Some seed) rest
        | Some best =>
            if (seed_score seed >? seed_score best)
            then best_seed (Some seed) rest
            else best_seed current rest
        end
      else best_seed current rest
  end.

Definition best_in_queue {A : Type}
  (queue : list (@Seed A ValidityFeedback))
  : option (@Seed A ValidityFeedback) :=
  best_seed None queue.

Definition best_in_pool {A : Type}
  (pool : @DoubleQueuePool A)
  : option (@Seed A ValidityFeedback) :=
  match best_in_queue (hpq pool) with
  | Some seed => Some seed
  | None => best_in_queue (lpq pool)
  end.

Fixpoint revise_queue {A : Type}
  (queue : list (@Seed A ValidityFeedback))
  : list (@Seed A ValidityFeedback) :=
  match queue with
  | [] => []
  | seed :: rest =>
      let rest' := revise_queue rest in
      let '{| input := input; feedback := feedback; energy := energy |} := seed in
      if energy =? 0 then rest'
      else mkSeed input feedback (energy - 1) :: rest'
  end.

Definition invest_seed {A : Type}
  (seed : A * ValidityFeedback) (pool : @DoubleQueuePool A)
  : @DoubleQueuePool A :=
  let '(input, feedback) := seed in
  if valid feedback
  then insert_high_priority (mk_high_priority_seed input feedback) pool
  else insert_low_priority (mk_low_priority_seed input feedback) pool.

#[global] Instance DoubleQueueSeedPool {A : Type}
  : @SeedPool A ValidityFeedback (@DoubleQueuePool A) :=
  {| mkPool _ := empty;
     invest := invest_seed;
     revise pool := {| hpq := revise_queue (hpq pool);
                       lpq := revise_queue (lpq pool) |};
     sample pool := match best_in_pool pool with
                    | None => Generate
                    | Some seed => Mutate seed
                    end;
     best := best_in_pool
  |}.
