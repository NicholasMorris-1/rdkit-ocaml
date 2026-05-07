open Rdkit_ocaml
open Helper

(*Define some hetero-cyles*)

let naphthalene = {
    name = "naphthalene";
    smiles = "c1ccc2ccccc2c1"
  }
let benzoxazole = {
    name = "benzoxazole";
    smiles = "n1c2ccccc2oc1" }

let indane = {
    name = "indane";
    smiles = "c1ccc2c(c1)CCC2"
  }
let skatole = {
    name = "skatole";
    smiles =  "Cn1cc2ccccc2c1"
  }
let benzene = {
    name = "benzene";
    smiles =  "c1ccccc1"
  }
let quinoline = {
    name = "quinoline";
    smiles =  "c1cc2cccnc2cc1"
  }

let mol_list = [naphthalene; benzoxazole;  indane; skatole; benzene; quinoline]


let in_two_rings = "[R2]"
let five_membered_ring = "[r5]"
(*Five membered ring fused to a benzene ring*)
let benzo_five = "[*r5R1]1[cR2]2[cR1][cR1][cR1][cR1][cR2]2[*r5R1][*r5R1]1"
(*Six membered ring fused to a benzene*)
let benzo_six = "[*r6R1]1[cR2]2[cR1][cR1][cR1][cR1][cR2]2[*r6R1][*r6R1][*r6R1]1"

let query_in_two_rings mol = query_smiles mol in_two_rings
let query_five_membered_ring mol = query_smiles mol five_membered_ring
let query_benzo_five mol = query_smiles mol benzo_five
let query_benzo_six mol = query_smiles mol benzo_six



let queries = [
  ("in_two_rings",    query_in_two_rings);
  ("five_membered",   query_five_membered_ring);
  ("benzo_five",      query_benzo_five);
  ("benzo_six",       query_benzo_six);
]

let () =
  List.iter (fun mol ->
    Printf.printf "Molecule: %s\n" mol.name;
    List.iter (fun (label, query) ->
      let res = query mol in
      Printf.printf "  %-20s %b\n" label res
    ) queries
  ) mol_list
