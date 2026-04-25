open Ctypes
open Foreign
open Rdkit_ocaml
open Helper


(*Define some hetero-cyles and store them in pickle form*)

let naphthalene = get_mol_pkl_from_smiles "c12ccccc1cccc2"
let benzoxazole = get_mol_pkl_from_smiles "n1c2ccccc2oc1"
let indane = get_mol_pkl_from_smiles "c1ccc2c(c1)CCC2"
let skatole = get_mol_pkl_from_smiles "CC1=CNC2=CC=CC=C12"
let benzene = get_mol_pkl_from_smiles "c1ccccc1"
let quinoline = get_mol_pkl_from_smiles "n1cccc2ccccc12"

let my_mols = [naphthalene;
               benzoxazole;
               indane;
               skatole;
               benzene;
               quinoline]





let () = Printf.printf "RDKit version: %s\n" (Cffi.version ());
         let smi = get_canonical_smiles "c1cc(O)ccc1"
         in
         Printf.printf "Canonical SMILES: %s\n" smi
