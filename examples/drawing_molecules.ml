open Rdkit_ocaml
open Helper

(*Define an ADT for molecules with their name and smiles String.*)


type molecule = {
    name : string;
    smiles: string
  }


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

let output_dir = "output_images"

let () = List.iter
           (fun mol ->
             smiles_to_output_png mol.smiles mol.name output_dir) mol_list
