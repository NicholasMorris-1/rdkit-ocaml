open Ctypes
open Foreign
open Rdkit_ocaml

let () = Printf.printf "RDKit version: %s\n" (Cffi.version ());
         let smi = Helper.get_canonical_smiles "c1cc(O)ccc1"
         in
         Printf.printf "Canonical SMILES: %s\n" smi
