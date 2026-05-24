Require Import String ZArith List.

From QuickChick Require Import QuickChick.
From PropLang Require Import PropLang.

Import ListNotations.
Import QcNotation.
Import MonadNotation.


Local Open Scope string.
Local Open Scope qc_scope.
Local Open Scope nat_scope.
Local Open Scope Z.
Local Open Scope prop_scope.

(* Axiom parLoop : forall (fuel : nat) (cprop : CProp ∅), unit -> Result.
Extract Constant parLoop => "
      (fun fuel cprop tt ->
      Miou.run  ~domains:4  @@ fun () ->
      let prms = List.init 4 (fun _ -> Miou.call (fun _ -> sample1 (runLoop fuel cprop))) in
      match Miou.await_first prms with
      | Ok value -> value
      | Error exn -> raise exn)
". *)

Axiom parLoop : forall (fuel : nat) (cprop : CProp ∅), unit -> Result.
Extract Constant parLoop => "
  (fun fuel cprop tt ->
    let workers = 4 in
    let run_worker worker_fuel =
      if worker_fuel <= 0 then
        mkResult 0 false 0 []
      else
        let g =
          ((Obj.magic (runLoop worker_fuel cprop))
            : int -> Random.State.t -> result)
        in
        g 5 (Random.State.make_self_init ())
    in
    let combine acc res =
      if acc.foundbug then
        acc
      else if res.foundbug then
        mkResult
          (acc.discards + res.discards)
          true
          (acc.passed + res.passed)
          res.counterexample
      else
        mkResult
          (acc.discards + res.discards)
          false
          (acc.passed + res.passed)
          []
    in
    if fuel <= 0 then
      run_worker 0
    else
      let warmup = Stdlib.min fuel 512 in
      let warmup_res = run_worker warmup in
      if warmup_res.foundbug || fuel <= warmup then
        warmup_res
      else
        let fuel = fuel - warmup in
        let workers = Stdlib.min workers fuel in
        if workers <= 1 then
          combine warmup_res (run_worker fuel)
        else
        let base = fuel / workers in
        let rem = fuel mod workers in
        let fuel_of_worker i =
          if i < rem then base + 1 else base
        in
        let children =
          List.init workers (fun i ->
            let worker_fuel = fuel_of_worker i in
            let rfd, wfd = Unix.pipe () in
            match Unix.fork () with
            | 0 ->
                Unix.close rfd;
                let oc = Unix.out_channel_of_descr wfd in
                let res = run_worker worker_fuel in
                Marshal.to_channel oc res [Marshal.No_sharing];
                flush oc;
                close_out_noerr oc;
                Stdlib.exit 0
            | pid ->
                Unix.close wfd;
                (pid, rfd))
        in
        List.fold_left
          (fun acc (pid, rfd) ->
            let ic = Unix.in_channel_of_descr rfd in
            let res = Marshal.from_channel ic in
            close_in_noerr ic;
            ignore (Unix.waitpid [] pid);
            combine acc res)
          warmup_res
          children)
    ".
    
