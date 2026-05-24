Require Import String ZArith List Nat.

From QuickChick Require Import QuickChick.
From PropLang Require Import PropLang.

Import ListNotations.
Import QcNotation.
Import MonadNotation.

Local Open Scope qc_scope.
Local Open Scope nat_scope.
Local Open Scope prop_scope.
Local Open Scope string.

(* Prefix each step's key-value pairs with a step number. *)
Fixpoint number_steps (n : nat) (steps : list (list (string * string)))
  : list (string * string) :=
  match steps with
  | [] => []
  | step :: rest =>
    List.map (fun '(k, v) => ("step " ++ show n ++ ": " ++ k, v)) step
    ++ number_steps (S n) rest
  end.

(* Stateful property-based testing loop.

   Defines a property as CProp (St * ∅) so generators see the current
   state in their environment. The loop calls generate_and_run with
   (state, size) as the env, then updates state via [transition]
   after each passing step.

   A single trial runs a sequence of up to [max_steps] steps from
   [init]. If any step's Check returns false, the failing step is
   shrunk and the full trace is reported. *)
Definition statefulLoop
  {St : Type}
  (cprop : CProp (St · ∅))
  (transition : St -> ⟦⦗cprop⦘⟧ -> St)
  (init : St)
  (trials : nat)
  (max_steps : nat)
  : G Result :=
  let fix shrink_step
    (fuel : nat) (state : St) (inputs : ⟦⦗cprop⦘⟧)
    : ⟦⦗cprop⦘⟧ :=
    match fuel with
    | O => inputs
    | S fuel' =>
      match shrink_cprop cprop (state, 0) inputs with
      | Some inputs' => shrink_step fuel' state inputs'
      | None => inputs
      end
    end in
  let fix runTrial
    (state : St)
    (fuel : nat)
    (step_idx : nat)
    (discards : nat)
    (trace : list (list (string * string)))
    : G (option (list (list (string * string))) * nat) :=
    match fuel with
    | O => ret (None, discards)
    | S fuel' =>
      res <- generate_and_run cprop (state, size_log2 step_idx discards);;
      match res with
      | Normal inputs false =>
          let shrunk := shrink_step 10 state inputs in
          let step_info := print_cprop cprop (state, 0) shrunk in
          ret (Some (List.rev (step_info :: trace)), discards)
      | Normal inputs true =>
          let step_info := print_cprop cprop (state, 0) inputs in
          let state' := transition state inputs in
          runTrial state' fuel' (S step_idx) discards (step_info :: trace)
      | Discard _ _ =>
          runTrial state fuel' step_idx (S discards) trace
      end
    end in
  let fix runTrials
    (remaining : nat)
    (passed : nat)
    (total_discards : nat)
    : G Result :=
    match remaining with
    | O => ret (mkResult total_discards false passed [])
    | S remaining' =>
      result_pair <- runTrial init max_steps 0 0 [];;
      let '(result, discards) := result_pair in
      match result with
      | Some trace =>
          ret (mkResult (total_discards + discards) true (passed + 1)
                        (number_steps 0 trace))
      | None =>
          runTrials remaining' (passed + 1) (total_discards + discards)
      end
    end in
  runTrials trials 0 0.
