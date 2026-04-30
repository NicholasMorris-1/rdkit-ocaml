open Ctypes
open Foreign
open Rdkit_ocaml
open Cffi
open Helper



let () = Printf.printf "RDKit version: %s\n" (Cffi.version ());
         let smi = get_canonical_smiles "c1cc(O)ccc1"
         in
         Printf.printf "Canonical SMILES: %s\n" smi
