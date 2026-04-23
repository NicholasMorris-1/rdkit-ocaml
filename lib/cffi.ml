open Ctypes
open Foreign


(*Link the .so file, if the build was successful this relative path should point correctly *)
(* to the file *)

let rdkit =
  Dl.dlopen
    ~filename:"../build/rdkit/lib/librdkitcffi.so"
    ~flags:[ Dl.RTLD_NOW ]

let libc = Dl.dlopen ~filename:"libc.so.6" ~flags:[ Dl.RTLD_NOW ]

(*The core the ABI implementaiton is a "pickeld" binary representation of a molecule*)
(*We treat it as a char pointer*)

type pkl = char ptr

let pkl_typ : pkl typ = ptr char

(*Many functions take in JSONs as arguments*)

let json_opt = ptr_opt char

(** Modification functions take [char **pkl, size_t *pkl_sz] — the pickle
    is reallocated in place.  We model these as [ptr pkl_typ] and
    [ptr size_t]. *)
let pkl_ptr = ptr pkl_typ    (* char **  *)
let sz_ptr  = ptr size_t     (* size_t * *)


let short_t = short

let c_free =
  foreign ~from:libc "free" (ptr void @-> returning void)




(*Logging and housekeeping*)

let version =
  foreign ~from:rdkit "version" (void @-> returning string)

(** [free_ptr ptr] frees a [char *] returned by any RDKit function.
    Prefer this over [c_free] for mol/smiles/svg buffers. *)
let free_ptr =
  foreign ~from:rdkit "free_ptr" (pkl_typ @-> returning void)

let enable_logging =
  foreign ~from:rdkit "enable_logging" (void @-> returning short_t)

let disable_logging =
  foreign ~from:rdkit "disable_logging" (void @-> returning short_t)

let enable_logger =
  foreign ~from:rdkit "enable_logger" (string @-> returning short_t)

let disable_logger =
  foreign ~from:rdkit "disable_logger" (string @-> returning short_t)

(*Molecules*)

(** [get_mol smiles mol_sz_ptr details_json] parses a SMILES (or molblock,
    or InChI) and returns a pickle.  [mol_sz_ptr] receives the byte length.
    Pass [""] or use [json_opt] / [None] for details. *)
let get_mol =
  foreign ~from:rdkit "get_mol"
    (string @-> sz_ptr @-> string @-> returning pkl_typ)

(** Like [get_mol] but for query molecules (SMARTS). *)
let get_qmol =
  foreign ~from:rdkit "get_qmol"
    (string @-> sz_ptr @-> string @-> returning pkl_typ)

(** [get_rxn smiles mol_sz_ptr details_json] parses a reaction SMILES. *)
let get_rxn =
  foreign ~from:rdkit "get_rxn"
    (string @-> sz_ptr @-> string @-> returning pkl_typ)


(*Pickle serialization and string representations*)


(** Returns a V2000 molblock string.  Caller must [free_ptr] the result. *)
let get_molblock =
  foreign ~from:rdkit "get_molblock"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns a V3000 molblock string. *)
let get_v3kmolblock =
  foreign ~from:rdkit "get_v3kmolblock"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns a V2000 molblock (explicit alias exposed by newer RDKit). *)
let get_v2kmolblock =
  foreign ~from:rdkit "get_v2kmolblock"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns canonical SMILES. *)
let get_smiles =
  foreign ~from:rdkit "get_smiles"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns SMARTS. *)
let get_smarts =
  foreign ~from:rdkit "get_smarts"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns CXSMILES (ChemDraw extended SMILES). *)
let get_cxsmiles =
  foreign ~from:rdkit "get_cxsmiles"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns CXSMARTS. *)
let get_cxsmarts =
  foreign ~from:rdkit "get_cxsmarts"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns a JSON representation of the molecule. *)
let get_json =
  foreign ~from:rdkit "get_json"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(* InChI support — only available when RDKit is built with InChI.
   Wrap in an option so the rest of the module loads even without it. *)

(** [get_inchi pkl pkl_sz details] — requires RDK_BUILD_INCHI_SUPPORT. *)
let get_inchi =
  try
    Some
      (foreign ~from:rdkit "get_inchi"
         (pkl_typ @-> size_t @-> json_opt @-> returning string))
  with _ -> None

(** [get_inchi_for_molblock ctab details] — requires InChI support. *)
let get_inchi_for_molblock =
  try
    Some
      (foreign ~from:rdkit "get_inchi_for_molblock"
         (string @-> json_opt @-> returning string))
  with _ -> None

(** [get_inchikey_for_inchi inchi] — requires InChI support. *)
let get_inchikey_for_inchi =
  try
    Some (foreign ~from:rdkit "get_inchikey_for_inchi" (string @-> returning string))
  with _ -> None

(*Fragementation *)

(** [get_mol_frags pkl pkl_sz frags_sz_array_ptr num_frags_ptr details mappings_ptr]

    Returns a [char**] array of [num_frags] pickles.
    - [frags_sz_array_ptr] receives a [size_t*] of per-fragment sizes.
    - [num_frags_ptr] receives the fragment count.
    - [mappings_ptr] receives (optionally) a JSON atom-mapping string;
      pass [ptr_opt char] / [None] if you don't need it.

    The returned array must be freed with [free_mol_array]. *)
let get_mol_frags =
  foreign ~from:rdkit "get_mol_frags"
    (pkl_typ          (* pkl          *)
     @-> size_t       (* pkl_sz       *)
     @-> ptr sz_ptr   (* frags_pkl_sz_array — size_t ** *)
     @-> sz_ptr       (* num_frags    — size_t *  *)
     @-> json_opt     (* details_json *)
     @-> ptr_opt (ptr char) (* mappings_json — char ** *)
     @-> returning (ptr pkl_typ)) (* char ** *)

(** Frees the array returned by [get_mol_frags]. *)
let free_mol_array =
  foreign ~from:rdkit "free_mol_array"
    (ptr (ptr pkl_typ) @-> ptr sz_ptr @-> returning void)

(*Substructure search*)

(** Returns a JSON object with the first match atom indices, or ["{}"] on
    no match. *)
let get_substruct_match =
  foreign ~from:rdkit "get_substruct_match"
    (pkl_typ @-> size_t   (* mol   *)
     @-> pkl_typ @-> size_t (* query *)
     @-> json_opt
     @-> returning string)

(** Returns a JSON array of all match atom-index lists. *)
let get_substruct_matches =
  foreign ~from:rdkit "get_substruct_matches"
    (pkl_typ @-> size_t
     @-> pkl_typ @-> size_t
     @-> json_opt
     @-> returning string)

(* Drawing  *)

(** Returns an SVG string for a molecule. *)
let get_svg =
  foreign ~from:rdkit "get_svg"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns an SVG string for a reaction. *)
let get_rxn_svg =
  foreign ~from:rdkit "get_rxn_svg"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(*Descriptors*)

(** Returns a JSON object of RDKit descriptors. *)
let get_descriptors =
  foreign ~from:rdkit "get_descriptors"
    (pkl_typ @-> size_t @-> returning string)

(** Returns the Morgan fingerprint as a bit-string. *)
let get_morgan_fp =
  foreign ~from:rdkit "get_morgan_fp"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

(** Returns the Morgan fingerprint as raw bytes.
    [nbytes_ptr] receives the byte count. *)
let get_morgan_fp_as_bytes =
  foreign ~from:rdkit "get_morgan_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ)

(** RDKit topological fingerprint as bit-string. *)
let get_rdkit_fp =
  foreign ~from:rdkit "get_rdkit_fp"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

let get_rdkit_fp_as_bytes =
  foreign ~from:rdkit "get_rdkit_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ)

(** Pattern fingerprint as bit-string. *)
let get_pattern_fp =
  foreign ~from:rdkit "get_pattern_fp"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

let get_pattern_fp_as_bytes =
  foreign ~from:rdkit "get_pattern_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ)

(** Topological torsion fingerprint as bit-string. *)
let get_topological_torsion_fp =
  foreign ~from:rdkit "get_topological_torsion_fp"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

let get_topological_torsion_fp_as_bytes =
  foreign ~from:rdkit "get_topological_torsion_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ)

(** Atom-pair fingerprint as bit-string. *)
let get_atom_pair_fp =
  foreign ~from:rdkit "get_atom_pair_fp"
    (pkl_typ @-> size_t @-> json_opt @-> returning string)

let get_atom_pair_fp_as_bytes =
  foreign ~from:rdkit "get_atom_pair_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ)

(** MACCS keys fingerprint as bit-string (166 bits). *)
let get_maccs_fp =
  foreign ~from:rdkit "get_maccs_fp"
    (pkl_typ @-> size_t @-> returning string)

let get_maccs_fp_as_bytes =
  foreign ~from:rdkit "get_maccs_fp_as_bytes"
    (pkl_typ @-> size_t @-> sz_ptr @-> returning pkl_typ)

(* Avalon fingerprints — conditional on build flag, same try pattern *)
let get_avalon_fp =
  try
    Some
      (foreign ~from:rdkit "get_avalon_fp"
         (pkl_typ @-> size_t @-> json_opt @-> returning string))
  with _ -> None

let get_avalon_fp_as_bytes =
  try
    Some
      (foreign ~from:rdkit "get_avalon_fp_as_bytes"
         (pkl_typ @-> size_t @-> sz_ptr @-> json_opt @-> returning pkl_typ))
  with _ -> None

(* ───────────────────────────────────────────────
   Modification  (in-place:  char **pkl, size_t *pkl_sz)
   ─────────────────────────────────────────────── *)

(** All modification functions mutate the pickle buffer in place and return
    a [short] success flag (1 = ok, 0 = error).

    Usage pattern:
    {[
      let pkl_ref = allocate pkl_typ pkl in
      let sz_ref  = allocate size_t pkl_sz in
      let ok = add_hs pkl_ref sz_ref in
      let new_pkl = !@ pkl_ref in
      let new_sz  = !@ sz_ref  in
    ]}
*)

let add_hs =
  foreign ~from:rdkit "add_hs"
    (pkl_ptr @-> sz_ptr @-> returning short_t)

let remove_all_hs =
  foreign ~from:rdkit "remove_all_hs"
    (pkl_ptr @-> sz_ptr @-> returning short_t)

let remove_hs =
  foreign ~from:rdkit "remove_hs"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)



let cleanup =
  foreign ~from:rdkit "cleanup"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let normalize =
  foreign ~from:rdkit "normalize"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let neutralize =
  foreign ~from:rdkit "neutralize"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let reionize =
  foreign ~from:rdkit "reionize"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let canonical_tautomer =
  foreign ~from:rdkit "canonical_tautomer"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let charge_parent =
  foreign ~from:rdkit "charge_parent"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

let fragment_parent =
  foreign ~from:rdkit "fragment_parent"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)


(*Coordinates*)

(** Prefer CoordGen over the built-in 2-D coordinate generator. *)
let prefer_coordgen =
  foreign ~from:rdkit "prefer_coordgen" (short_t @-> returning void)

(** Returns 1 if the molecule already has coordinates. *)
let has_coords =
  foreign ~from:rdkit "has_coords"
    (pkl_typ @-> size_t @-> returning short_t)

(** Generate 2-D coordinates in place. *)
let set_2d_coords =
  foreign ~from:rdkit "set_2d_coords"
    (pkl_ptr @-> sz_ptr @-> returning short_t)

(** Generate 3-D coordinates in place using ETKDG. *)
let set_3d_coords =
  foreign ~from:rdkit "set_3d_coords"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning short_t)

(** Align 2-D coords to a template pickle.
    [match_json_ptr] receives (optionally) the atom-map JSON;
    pass [ptr_opt char] / [None] to ignore. *)
let set_2d_coords_aligned =
  foreign ~from:rdkit "set_2d_coords_aligned"
    (pkl_ptr           (* pkl           *)
     @-> sz_ptr        (* pkl_sz        *)
     @-> pkl_typ       (* template_pkl  *)
     @-> size_t        (* template_sz   *)
     @-> json_opt      (* details_json  *)
     @-> ptr_opt (ptr char) (* match_json — char ** *)
     @-> returning short_t)

(*Chirality*)

(** Toggle legacy (pre-2021) stereo perception. *)
let use_legacy_stereo_perception =
  foreign ~from:rdkit "use_legacy_stereo_perception"
    (short_t @-> returning short_t)

(** Toggle support for non-tetrahedral chirality (e.g. square planar). *)
let allow_non_tetrahedral_chirality =
  foreign ~from:rdkit "allow_non_tetrahedral_chirality"
    (short_t @-> returning short_t)

(*PNG Metadata*)

(** Embed a molecule pickle into a PNG blob (in place). *)
let add_mol_to_png_blob =
  foreign ~from:rdkit "add_mol_to_png_blob"
    (pkl_ptr    (* png_blob    *)
     @-> sz_ptr (* png_blob_sz *)
     @-> pkl_typ @-> size_t  (* mpkl, mpkl_size *)
     @-> json_opt
     @-> returning short_t)

(** Extract the first molecule pickle from a PNG blob. *)
let get_mol_from_png_blob =
  foreign ~from:rdkit "get_mol_from_png_blob"
    (pkl_typ @-> size_t  (* png_blob, png_blob_sz *)
     @-> pkl_ptr         (* mpkl out   — char **  *)
     @-> sz_ptr          (* mpkl_sz out            *)
     @-> json_opt
     @-> returning short_t)

(* Extract all molecule pickles from a PNG blob.
    Returns an array of pickles via [mpkl_array] (char ) and sizes via
    [mpkl_sz_array] (size_t ). Free with [free_mol_array]. *)
let get_mols_from_png_blob =
  foreign ~from:rdkit "get_mols_from_png_blob"
    (pkl_typ @-> size_t     (* png_blob         *)
     @-> ptr pkl_ptr        (* mpkl_array       — char *** *)
     @-> ptr sz_ptr         (* mpkl_sz_array    — size_t ** *)
     @-> json_opt
     @-> returning short_t)

(*Logging Handles*)

(** An opaque log handle returned by [set_log_tee] / [set_log_capture].
    Represented as [void *]. *)
let log_handle_t = ptr void

(** Tee log output (write to both original sink and capture buffer). *)
let set_log_tee =
  foreign ~from:rdkit "set_log_tee"
    (string @-> returning log_handle_t)

(** Capture log output exclusively into an internal buffer. *)
let set_log_capture =
  foreign ~from:rdkit "set_log_capture"
    (string @-> returning log_handle_t)

(** Destroy a log handle.  Pass [allocate (ptr void) handle] as [void **]. *)
let destroy_log_handle =
  foreign ~from:rdkit "destroy_log_handle"
    (ptr log_handle_t @-> returning short_t)

(** Return the accumulated log buffer as a string. *)
let get_log_buffer =
  foreign ~from:rdkit "get_log_buffer"
    (log_handle_t @-> returning string)

(** Clear the accumulated log buffer. *)
let clear_log_buffer =
  foreign ~from:rdkit "clear_log_buffer"
    (log_handle_t @-> returning short_t)

(*Properties*)

(** Returns 1 if the molecule has property [key]. *)
let has_prop =
  foreign ~from:rdkit "has_prop"
    (pkl_typ @-> size_t @-> string @-> returning short_t)

(** Returns a NULL-terminated [char**] array of property keys.
    The caller is responsible for freeing each string and the array itself
    with [c_free]. *)
let get_prop_list =
  foreign ~from:rdkit "get_prop_list"
    (pkl_typ @-> size_t
     @-> short_t   (* includePrivate   *)
     @-> short_t   (* includeComputed  *)
     @-> returning (ptr (ptr char)))

(** Set a string property on the molecule pickle in place. *)
let set_prop =
  foreign ~from:rdkit "set_prop"
    (pkl_ptr @-> sz_ptr
     @-> string   (* key   *)
     @-> string   (* value *)
     @-> short_t  (* computed flag *)
     @-> returning void)

(** Get a string property value.  Returns the value string; caller must free. *)
let get_prop =
  foreign ~from:rdkit "get_prop"
    (pkl_typ @-> size_t @-> string @-> returning string)

(** Remove a property by key. *)
let clear_prop =
  foreign ~from:rdkit "clear_prop"
    (pkl_ptr @-> sz_ptr @-> string @-> returning short_t)

(** Retain only the properties listed in [details_json]. *)
let keep_props =
  foreign ~from:rdkit "keep_props"
    (pkl_ptr @-> sz_ptr @-> json_opt @-> returning void)

(*Helpers*)

(** Allocate a size_t cell initialised to zero, for use with [get_mol] etc. *)
let alloc_size_t () = allocate size_t (Unsigned.Size_t.of_int 0)

(** Read the size_t value out of a pointer cell. *)
let read_size_t = ( !@ )

(** Wrap an in-place modification call so you don't have to manage the
    double-pointer manually.

    [with_inplace f pkl pkl_sz] allocates the required pointer cells,
    calls [f pkl_ref sz_ref], then returns [(new_pkl, new_sz, ok)]. *)
let with_inplace f pkl pkl_sz =
  let pkl_ref = allocate pkl_typ pkl in
  let sz_ref  = allocate size_t pkl_sz in
  let ok = f pkl_ref sz_ref in
  (!@ pkl_ref, !@ sz_ref, ok)
