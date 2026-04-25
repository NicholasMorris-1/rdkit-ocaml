open Ctypes
open Foreign
open Cffi

(*Helper functions*)


(*must free the pkl pointer once used*)
let get_mol_pkl_from_smiles smiles =
  let pkl_size_ptr = alloc_size_t () in
  let pkl = get_mol smiles pkl_size_ptr "" in
  pkl


let get_canonical_smiles smiles =
  let pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let pkl = get_mol smiles pkl_size_ptr "" in
  let pkl_size = !@ pkl_size_ptr in
  let smiles_out = get_smiles pkl pkl_size None in
  free_ptr pkl;
  smiles_out

let mol_to_svg molecule =
  let pkl_size_ptr = alloc_size_t () in
  let pkl_size = !@ pkl_size_ptr in
  let svg = get_svg molecule pkl_size None in
  svg

let output_svg_to_file svg name =
  let filename = name ^ ".svg" in
  let oc = open_out filename in
  Printf.fprintf oc "%s\n" svg;
  close_out oc

let mol_to_svg mol name =
  let svg = mol_to_svg mol in
  output_svg_to_file svg name




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
