open Ctypes
open Foreign
open Cffi

(*Helper functions*)

let get_canonical_smiles smiles =
  let pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let pkl = get_mol smiles pkl_size_ptr "" in
  let pkl_size = !@ pkl_size_ptr in
  let smiles_out = get_smiles pkl pkl_size None in
  free_ptr pkl;
  smiles_out


let sub_structure_search mol_smiles query_smiles =
  let mol_pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let mol_pkl = get_mol mol_smiles mol_pkl_size_ptr "" in
  let mol_pkl_size = !@ mol_pkl_size_ptr in
  let query_pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let query_pkl = get_qmol query_smiles query_pkl_size_ptr "" in
  let query_pkl_size = !@ query_pkl_size_ptr in
  let matches_json = get_substruct_matches mol_pkl mol_pkl_size query_pkl query_pkl_size None in
  free_ptr mol_pkl;
  free_ptr query_pkl;
  matches_json
