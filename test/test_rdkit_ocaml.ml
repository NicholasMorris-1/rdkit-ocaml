open OUnit2
open Ctypes
open Foreign
open Rdkit_ocaml
open Rdkit_ocaml.Cffi
open Rdkit_ocaml.Helper



(*Housekeeping tests*)

let test_version _ =
  let version = version () in
  assert_bool "version should be non-empty" (String.length version > 0)


(*This largely tests nothing, just ensures it doesn't crash because I am not sure how to test this from the ocaml side*)
let test_free_ptr _ =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_mol "c1cc(O)ccc1" pkl_size_ptr "" in
  free_ptr pkl

(*I haven't figured out how to best test for logging yet*)

let house_keeping_tests = "Housekeeping tests" >::: [
  "test_version" >:: test_version;
  "test_free_ptr" >:: test_free_ptr
]

(*Molecules tests*)

let test_get_mol_phenol _ =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_mol "c1cc(O)ccc1" pkl_size_ptr "" in
  let pkl_size = read_size_t pkl_size_ptr in
  assert_bool "pkl size should be greater than 0" (Unsigned.Size_t.to_int pkl_size > 0);
  (*Convert back to SMILES and check it's a valid phenol *)
  let smiles = get_smiles pkl pkl_size None in
  assert_bool "smiles should be non-empty" (String.length smiles > 0);
  (*Check we get phenol smiles back*)
  assert_equal "Oc1ccccc1" smiles;
  free_ptr pkl

let test_get_mol_carboxylic_acid _ =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_mol "CC(=O)O" pkl_size_ptr "" in
  let pkl_size = !@ pkl_size_ptr in
  assert_bool "pkl size should be greater than 0" (Unsigned.Size_t.to_int pkl_size > 0);
  (*Convert back to SMILES and check it's a valid carboxylic acid *)
  let smiles = get_smiles pkl pkl_size None in
  assert_bool "smiles should be non-empty" (String.length smiles > 0);
  (*Check we get acetic acid smiles back*)
  assert_equal "CC(=O)O" smiles;
  free_ptr pkl

let test_get_mol_lysine _ =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_mol "NCCCC[C@H](N)C(=O)O" pkl_size_ptr "" in
  let pkl_size = !@ pkl_size_ptr in
  assert_bool "pkl size should be greater than 0" (Unsigned.Size_t.to_int pkl_size > 0);
  (*Convert back to SMILES and check it's a valid lysine *)
  let smiles = get_smiles pkl pkl_size None in
  assert_bool "smiles should be non-empty" (String.length smiles > 0);
  (*Check we get lysine smiles back*)
  assert_equal "NCCCC[C@H](N)C(=O)O" smiles;
  free_ptr pkl

let test_get_qmol_phenol _ =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_qmol "c1cc(O)ccc1" pkl_size_ptr "" in
  let pkl_size = !@ pkl_size_ptr in
  assert_bool "pkl size should be greater than 0" (Unsigned.Size_t.to_int pkl_size > 0);
  (*Convert back to SMILES and check it's a valid phenol *)
  let smiles = get_smiles pkl pkl_size None in
  assert_bool "smiles should be non-empty" (String.length smiles > 0);
  (*Check we get phenol smiles back*)
  assert_equal "Oc1ccccc1" smiles;
  free_ptr pkl

let test_get_qmol_matches_substructure _ =
  (* build the target molecule *)
  let mol_size_ptr = alloc_size_t () in
  let mol = get_mol "CC(=O)O" mol_size_ptr "" in
  let mol_size = !@ mol_size_ptr in
  (* build the query — carboxyl group *)
  let qmol_size_ptr = alloc_size_t () in
  let qmol = get_qmol "C(=O)O" qmol_size_ptr "" in
  let qmol_size = !@ qmol_size_ptr in
  (* check it matches *)
  let match_str = get_substruct_match mol mol_size qmol qmol_size None in
  assert_bool "carboxyl should match in acetic acid" (String.length match_str > 0);
  assert_bool "match should not be empty result" (match_str <> "[]");
  free_ptr mol;
  free_ptr qmol

let test_get_substruct_no_match _ =
  let mol_size_ptr = alloc_size_t () in
  let mol = get_mol "CC(=O)O" mol_size_ptr "" in
  let mol_size = !@ mol_size_ptr in
  let qmol_size_ptr = alloc_size_t () in
  let qmol = get_qmol "c1ccccc1" qmol_size_ptr "" in  (* benzene won't match *)
  let qmol_size = !@ qmol_size_ptr in
  let match_str = get_substruct_match mol mol_size qmol qmol_size None in
  assert_equal ~msg:"benzene should not match acetic acid" "{}" match_str;
  free_ptr mol;
  free_ptr qmol


(*TODO: write tests for get_RXN*)


let molecule_tests = "Molecule tests" >::: [
    "test_get_mol_phenol" >:: test_get_mol_phenol;
    "test_get_mol_carboxylic_acid" >:: test_get_mol_carboxylic_acid;
    "test_get_mol_lysine" >:: test_get_mol_lysine;
    "test_get_qmol_phenol" >:: test_get_qmol_phenol;
    "test_get_qmol_matches_substructure" >:: test_get_qmol_matches_substructure;
    "test_get_substruct_no_match" >:: test_get_substruct_no_match
]

(*Pickle Serialisation tests*)

let test_getmolblock _  =
    let pkl_size_ptr = alloc_size_t () in
    let pkl = get_mol "c1cc(O)ccc1" pkl_size_ptr "" in
    let pkl_size = !@ pkl_size_ptr in
    assert_bool "pkl size should be greater than 0" (Unsigned.Size_t.to_int pkl_size > 0);
    let molblock = get_molblock pkl pkl_size None in
    assert_bool "molblock should be non-empty" (String.length molblock > 0);
    free_ptr pkl

let pickle_serialisation_tests = "Pickle Serialisation tests" >::: [
  "test_getmolblock" >:: test_getmolblock
]


let tests = "RDKit OCaml tests" >::: [
  house_keeping_tests;
  molecule_tests;
  pickle_serialisation_tests
]

let ()  =
  run_test_tt_main tests
