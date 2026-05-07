open Ctypes
open Foreign
open Cffi
open Vg
open Cairo
open Types
open Json_parser


(*Define an ADT for molecules with their name and smiles String.*)


type molecule = {
    name : string;
    smiles: string
  }



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



let mol_pkl_to_svg mol_pkl =
  let mol_pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let mol_pkl_size = !@ mol_pkl_size_ptr in
  let svg = get_svg mol_pkl mol_pkl_size "" in
  svg

let smiles_to_svg smiles =
  let mol_pkl = get_mol_pkl_from_smiles smiles in
  let svg = mol_pkl_to_svg mol_pkl in
  free_ptr mol_pkl;
  svg



(*This only works if librsvg is installed on the sytem, should work in the nix shell, *)
(* otherwise run sudo apt install librsvg2-bin *)
let svg_to_png svg_string output_file output_dir =
  let tmp = Filename.temp_file "image" ".svg" in
  let oc = open_out tmp in
  output_string oc svg_string;
  close_out oc;
  let cmd = Printf.sprintf "rsvg-convert -f png -o %s %s" output_file tmp in
  let ret = Sys.command cmd in
  Sys.remove tmp;
  if ret <> 0 then failwith "rsvg-convert failed"


let svg_to_png_in_dir svg_string output_file output_dir =
  let tmp = Filename.temp_file "image" ".svg" in
  let oc = open_out tmp in
  output_string oc svg_string;
  close_out oc;
  let output_path = Filename.concat output_dir output_file in
  let cmd = Printf.sprintf "rsvg-convert -f png -o %s %s" output_path tmp in
  let ret = Sys.command cmd in
  Sys.remove tmp;
  if ret <> 0 then failwith "rsvg-convert failed"


let output_svg_to_file svg name =
  let filename = name ^ ".svg" in
  let oc = open_out filename in
  output_string oc svg;
  close_out oc

let smiles_to_output_svg smiles filename =
  let svg = smiles_to_svg smiles in
  output_svg_to_file svg filename

let smiles_to_output_png smiles filename =
  let svg = smiles_to_svg smiles in
  let png_filename = filename ^ ".png" in
  svg_to_png svg png_filename


(* Full pipeline from smiles to PNG, with appropriate freeing of pointers *)
let smiles_to_output_png smiles filename output_dir =
  let pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let pkl = get_mol smiles pkl_size_ptr "" in
  if is_null pkl then failwith ("get_mol failed for: " ^ smiles);

  let pkl_size = !@ pkl_size_ptr in

  let svg_ptr = get_svg_raw pkl pkl_size "" in
  free_ptr pkl;

  if is_null svg_ptr then failwith ("get_svg failed for: " ^ smiles);

  let len = Unsigned.Size_t.to_int (strlen svg_ptr) in
  let svg = Ctypes.string_from_ptr svg_ptr ~length:len in
  free_ptr svg_ptr;

  let png_filename = filename ^ ".png" in
  svg_to_png_in_dir svg png_filename output_dir




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

let query_smiles mol query =
  let matches = sub_structure_search mol.smiles query in
  match matches with
  | "{}" -> false
  | _ -> true


let get_ocaml_mol_from_smiles smiles =
  let mol_pkl_size_ptr = allocate size_t (Unsigned.Size_t.of_int 0) in
  let mol_pkl = get_mol smiles mol_pkl_size_ptr "" in
  let mol_pkl_size = !@ mol_pkl_size_ptr in
  let mol_json = get_json mol_pkl mol_pkl_size None in
  let mol = parse_rdkit_mol_json (Yojson.Basic.from_string mol_json) in
  free_ptr mol_pkl;
  mol
