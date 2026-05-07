open OUnit2
open Ctypes
open Rdkit_ocaml.Cffi

let short i = i
let int_of_short i = i
let int_of_size_t x = Unsigned.Size_t.to_int x
let size_t_of_int i = Unsigned.Size_t.of_int i

let malloc =
  Foreign.foreign ~from:libc "malloc" (size_t @-> returning (ptr void))

let assert_ok msg rc = assert_bool msg (int_of_short rc <> 0)
let assert_not_null msg p = assert_bool msg (not (is_null p))
let as_void p = coerce (ptr char) (ptr void) p
let as_chars p = coerce (ptr void) (ptr char) p
let null_char_ptr = from_voidp char null
let null_size_ptr = from_voidp size_t null
let null_pkl_ptr = from_voidp pkl_typ null

let c_setenv =
  Foreign.foreign ~from:libc "setenv" (string @-> string @-> int @-> returning int)

let c_unsetenv =
  Foreign.foreign ~from:libc "unsetenv" (string @-> returning int)

let restore_env name value =
  match value with
  | Some v -> ignore (c_setenv name v 1)
  | None -> ignore (c_unsetenv name)

let free_c_char p =
  if not (is_null p) then c_free (as_void p)

let contains s sub =
  let len = String.length s and sub_len = String.length sub in
  let rec loop i =
    i + sub_len <= len
    && (String.sub s i sub_len = sub || loop (i + 1))
  in
  sub_len = 0 || loop 0

let with_mol ?(details = "") smiles f =
  let szp = alloc_size_t () in
  let pkl = get_mol smiles szp details in
  assert_not_null ("get_mol failed for " ^ smiles) pkl;
  let sz = read_size_t szp in
  assert_bool "pickle size should be positive" (int_of_size_t sz > 0);
  Fun.protect ~finally:(fun () -> free_ptr pkl) (fun () -> f pkl sz)

let with_qmol ?(details = "") smarts f =
  let szp = alloc_size_t () in
  let pkl = get_qmol smarts szp details in
  assert_not_null ("get_qmol failed for " ^ smarts) pkl;
  let sz = read_size_t szp in
  assert_bool "query pickle size should be positive" (int_of_size_t sz > 0);
  Fun.protect ~finally:(fun () -> free_ptr pkl) (fun () -> f pkl sz)

let with_rxn smarts f =
  let szp = alloc_size_t () in
  let pkl = get_rxn smarts szp "" in
  assert_not_null "get_rxn failed" pkl;
  let sz = read_size_t szp in
  assert_bool "reaction pickle size should be positive" (int_of_size_t sz > 0);
  Fun.protect ~finally:(fun () -> free_ptr pkl) (fun () -> f pkl sz)

let with_inplace_mol ?(details = "") smiles f =
  let szp = alloc_size_t () in
  let pkl = get_mol smiles szp details in
  assert_not_null ("get_mol failed for " ^ smiles) pkl;
  let pkl_ref = allocate pkl_typ pkl in
  let sz_ref = allocate size_t (read_size_t szp) in
  Fun.protect
    ~finally:(fun () -> free_ptr (!@ pkl_ref))
    (fun () -> f pkl_ref sz_ref)

let smiles_of pkl sz = get_smiles pkl sz None

let copy_string_to_malloc s =
  let len = String.length s in
  let raw = malloc (size_t_of_int len) in
  assert_not_null "malloc failed" raw;
  let p = as_chars raw in
  for i = 0 to len - 1 do
    p +@ i <-@ s.[i]
  done;
  p, size_t_of_int len

let one_by_one_png =
  "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82"

let test_housekeeping _ =
  assert_bool "version should be non-empty" (String.length (version ()) > 0);
  assert_ok "disable_logging should succeed" (disable_logging ());
  assert_ok "enable_logging should succeed" (enable_logging ());
  assert_ok "disable_logger rdApp.info should succeed" (disable_logger "rdApp.info");
  assert_ok "enable_logger rdApp.info should succeed" (enable_logger "rdApp.info")

let test_strlen_and_free_ptr _ =
  with_mol "CCO" (fun pkl sz ->
      let raw = get_svg_raw pkl sz "" in
      assert_not_null "get_svg raw pointer should be non-null" raw;
      assert_bool "svg should have a positive strlen" (int_of_size_t (strlen raw) > 0);
      free_ptr raw)

let housekeeping_tests =
  "housekeeping" >::: [
    "version_and_logging" >:: test_housekeeping;
    "strlen_and_free_ptr" >:: test_strlen_and_free_ptr;
  ]

let test_get_mol_and_smiles _ =
  with_mol "c1cc(O)ccc1" (fun pkl sz ->
      assert_equal "Oc1ccccc1" (get_smiles pkl sz None);
      assert_equal "Oc1ccccc1" (get_smiles pkl sz (Some "{\"canonical\":true}")))

let test_get_qmol_and_smarts _ =
  with_qmol "c1ccccc1" (fun pkl sz ->
      assert_bool "SMARTS should mention aromatic carbons"
        (contains (get_smarts pkl sz None) "c"))

let test_get_rxn _ =
  with_rxn "CCO>>CC=O" (fun pkl sz ->
      let svg = get_rxn_svg pkl sz (Some "") in
      assert_bool "reaction SVG should contain svg markup" (contains svg "<svg"))

let molecule_tests =
  "molecules" >::: [
    "get_mol" >:: test_get_mol_and_smiles;
    "get_qmol" >:: test_get_qmol_and_smarts;
    "get_rxn" >:: test_get_rxn;
  ]

let test_serialisation_functions _ =
  with_mol "c1cc(O)ccc1" (fun pkl sz ->
      assert_bool "V2000 molblock should contain atom lines" (contains (get_molblock pkl sz None) "V2000");
      assert_bool "V2K molblock should contain atom lines" (contains (get_v2kmolblock pkl sz None) "V2000");
      assert_bool "V3K molblock should contain CTAB" (contains (get_v3kmolblock pkl sz None) "V3000");
      assert_equal "Oc1ccccc1" (get_cxsmiles pkl sz None);
      assert_bool "CXSMARTS should be non-empty" (String.length (get_cxsmarts pkl sz None) > 0);
      assert_bool "JSON should contain molecule data" (contains (get_json pkl sz None) "molecules"))

let test_inchi_functions _ =
  match get_inchi, get_inchi_for_molblock, get_inchikey_for_inchi with
  | Some get_inchi, Some get_inchi_for_molblock, Some get_inchikey_for_inchi ->
      with_mol "CCO" (fun pkl sz ->
          let inchi = get_inchi pkl sz None in
          assert_bool "InChI should be returned" (contains inchi "InChI=");
          let molblock = get_molblock pkl sz None in
          let inchi2 = get_inchi_for_molblock molblock None in
          assert_bool "molblock InChI should be returned" (contains inchi2 "InChI=");
          assert_equal "LFQSCWFLJHTTHZ-UHFFFAOYSA-N" (get_inchikey_for_inchi inchi))
  | _ -> skip_if true "RDKit was built without InChI support"

let serialisation_tests =
  "serialisation" >::: [
    "molblock_smiles_smarts_json" >:: test_serialisation_functions;
    "inchi_optional" >:: test_inchi_functions;
  ]

let test_mol_frags _ =
  with_mol "n1ccccc1.CC(C)C.OCCCN" (fun pkl sz ->
      let sizes_ref = allocate sz_ptr null_size_ptr in
      let count_ref = alloc_size_t () in
      let mapping_ref = allocate (ptr char) null_char_ptr in
      let frags = get_mol_frags pkl sz sizes_ref count_ref (Some "") (Some mapping_ref) in
      assert_not_null "fragment array should be returned" frags;
      assert_equal 3 (int_of_size_t (!@ count_ref));
      let sizes = !@ sizes_ref in
      let expected = [| "c1ccncc1"; "CC(C)C"; "NCCCO" |] in
      Array.iteri
        (fun i smi ->
          let frag = !@ (frags +@ i) in
          let frag_sz = !@ (sizes +@ i) in
          assert_equal smi (get_smiles frag frag_sz None))
        expected;
      let mapping = !@ mapping_ref in
      assert_not_null "mapping JSON should be returned" mapping;
      let mapping_len = int_of_size_t (strlen mapping) in
      let mapping_json = string_from_ptr mapping ~length:mapping_len in
      assert_bool "mapping JSON should describe fragments" (contains mapping_json "\"frags\"");
      c_free (as_void mapping);
      for i = 0 to int_of_size_t (!@ count_ref) - 1 do
        free_ptr (!@ (frags +@ i))
      done;
      c_free (coerce (ptr pkl_typ) (ptr void) frags);
      c_free (coerce sz_ptr (ptr void) sizes))

let fragmentation_tests = "fragmentation" >::: [ "get_mol_frags" >:: test_mol_frags ]

let test_substructure_functions _ =
  with_mol "CC(=O)O" (fun mol mol_sz ->
      with_qmol "C(=O)O" (fun q q_sz ->
          assert_bool "single match should be non-empty"
            (contains (get_substruct_match mol mol_sz q q_sz None) "[");
          assert_bool "all matches should be non-empty"
            (contains (get_substruct_matches mol mol_sz q q_sz None) "[")))

let substructure_tests =
  "substructure" >::: [ "match_and_matches" >:: test_substructure_functions ]

let test_drawing_functions _ =
  with_mol "CCO" (fun pkl sz ->
      assert_bool "molecule SVG should contain svg markup" (contains (get_svg pkl sz "") "<svg");
      let raw = get_svg_raw pkl sz "" in
      assert_not_null "raw SVG pointer should be returned" raw;
      assert_bool "raw SVG should contain data" (int_of_size_t (strlen raw) > 0);
      free_ptr raw);
  with_rxn "CCO>>CC=O" (fun pkl sz ->
      assert_bool "reaction SVG should contain svg markup" (contains (get_rxn_svg pkl sz (Some "")) "<svg"))

let drawing_tests = "drawing" >::: [ "svg" >:: test_drawing_functions ]

let test_descriptor_and_fingerprint_strings _ =
  with_mol "c1nccc(O)c1" (fun pkl sz ->
      assert_bool "descriptors should contain AMW" (contains (get_descriptors pkl sz) "amw");
      assert_equal 64 (String.length (get_morgan_fp pkl sz (Some "{\"radius\":2,\"nBits\":64}")));
      assert_equal 64 (String.length (get_rdkit_fp pkl sz (Some "{\"nBits\":64}")));
      assert_equal 64 (String.length (get_pattern_fp pkl sz (Some "{\"nBits\":64}")));
      assert_equal 64 (String.length (get_topological_torsion_fp pkl sz (Some "{\"nBits\":64}")));
      assert_equal 64 (String.length (get_atom_pair_fp pkl sz (Some "{\"nBits\":64}")));
      assert_equal 167 (String.length (get_maccs_fp pkl sz));
      match get_avalon_fp with
      | Some f -> assert_equal 64 (String.length (f pkl sz (Some "{\"nBits\":64}")))
      | None -> ())

let check_fp_bytes name f pkl sz json expected_bytes =
  let nbytes = alloc_size_t () in
  let bytes = f pkl sz nbytes json in
  assert_not_null (name ^ " bytes pointer should be returned") bytes;
  assert_equal expected_bytes (int_of_size_t (!@ nbytes));
  free_ptr bytes

let test_fingerprint_byte_buffers _ =
  with_mol "c1nccc(O)c1" (fun pkl sz ->
      check_fp_bytes "Morgan" get_morgan_fp_as_bytes pkl sz (Some "{\"radius\":2,\"nBits\":64}") 8;
      check_fp_bytes "RDKit" get_rdkit_fp_as_bytes pkl sz (Some "{\"nBits\":64}") 8;
      check_fp_bytes "Pattern" get_pattern_fp_as_bytes pkl sz (Some "{\"nBits\":64}") 8;
      check_fp_bytes "Topological torsion" get_topological_torsion_fp_as_bytes pkl sz (Some "{\"nBits\":64}") 8;
      check_fp_bytes "Atom pair" get_atom_pair_fp_as_bytes pkl sz (Some "{\"nBits\":64}") 8;
      let nbytes = alloc_size_t () in
      let maccs = get_maccs_fp_as_bytes pkl sz nbytes in
      assert_not_null "MACCS bytes pointer should be returned" maccs;
      assert_equal 21 (int_of_size_t (!@ nbytes));
      free_ptr maccs;
      match get_avalon_fp_as_bytes with
      | Some f -> check_fp_bytes "Avalon" f pkl sz (Some "{\"nBits\":64}") 8
      | None -> ())

let descriptor_tests =
  "descriptors_and_fingerprints" >::: [
    "strings" >:: test_descriptor_and_fingerprint_strings;
    "byte_buffers" >:: test_fingerprint_byte_buffers;
  ]

let test_modification_functions _ =
  with_inplace_mol "CCC" (fun pkl_ref sz_ref ->
      assert_ok "add_hs should succeed" (add_hs pkl_ref sz_ref);
      assert_bool "explicit hydrogen should appear in molblock"
        (contains (get_molblock (!@ pkl_ref) (!@ sz_ref) None) " H ");
      assert_ok "remove_all_hs should succeed" (remove_all_hs pkl_ref sz_ref);
      assert_equal "CCC" (smiles_of (!@ pkl_ref) (!@ sz_ref));
      assert_ok "remove_hs should succeed" (remove_hs pkl_ref sz_ref None));
  let standardisers =
    [
      ("cleanup", cleanup);
      ("normalize", normalize);
      ("neutralize", neutralize);
      ("reionize", reionize);
      ("canonical_tautomer", canonical_tautomer);
      ("charge_parent", charge_parent);
      ("fragment_parent", fragment_parent);
    ]
  in
  List.iter
    (fun (name, f) ->
      with_inplace_mol "C[N+](=O)[O-].Cl" (fun pkl_ref sz_ref ->
          assert_ok (name ^ " should succeed") (f pkl_ref sz_ref None);
          assert_bool (name ^ " should leave a readable molecule")
            (String.length (smiles_of (!@ pkl_ref) (!@ sz_ref)) > 0)))
    standardisers

let modification_tests =
  "modifications" >::: [ "in_place_modifications" >:: test_modification_functions ]

let test_coordinate_functions _ =
  prefer_coordgen (short 0);
  with_inplace_mol "c1ccccc1" (fun pkl_ref sz_ref ->
      assert_equal 0 (int_of_short (has_coords (!@ pkl_ref) (!@ sz_ref)));
      assert_ok "set_2d_coords should succeed" (set_2d_coords pkl_ref sz_ref);
      assert_bool "2D coords should be present"
        (int_of_short (has_coords (!@ pkl_ref) (!@ sz_ref)) > 0));
  with_inplace_mol "CCO" (fun pkl_ref sz_ref ->
      assert_ok "set_3d_coords should succeed" (set_3d_coords pkl_ref sz_ref (Some ""));
      assert_bool "3D coords should be present"
        (int_of_short (has_coords (!@ pkl_ref) (!@ sz_ref)) > 0));
  with_inplace_mol "c1ccccc1O" (fun pkl_ref sz_ref ->
      with_inplace_mol "c1ccccc1" (fun template_ref template_sz_ref ->
          assert_ok "template set_2d_coords should succeed"
            (set_2d_coords template_ref template_sz_ref);
          let mapping_ref = allocate (ptr char) null_char_ptr in
          assert_ok "set_2d_coords_aligned should succeed"
            (set_2d_coords_aligned pkl_ref sz_ref (!@ template_ref) (!@ template_sz_ref) (Some "") (Some mapping_ref));
          let mapping = !@ mapping_ref in
          assert_not_null "alignment mapping should be returned" mapping;
          c_free (as_void mapping)))

let coordinate_tests = "coordinates" >::: [ "coords" >:: test_coordinate_functions ]

let test_chirality_toggles _ =
  let legacy = Sys.getenv_opt "RDK_USE_LEGACY_STEREO_PERCEPTION" in
  let nontetrahedral = Sys.getenv_opt "RDK_ENABLE_NONTETRAHEDRAL_STEREO" in
  Fun.protect
    ~finally:(fun () ->
      restore_env "RDK_USE_LEGACY_STEREO_PERCEPTION" legacy;
      restore_env "RDK_ENABLE_NONTETRAHEDRAL_STEREO" nontetrahedral)
    (fun () ->
      ignore (use_legacy_stereo_perception (short 0));
      ignore (use_legacy_stereo_perception (short 1));
      ignore (allow_non_tetrahedral_chirality (short 0));
      ignore (allow_non_tetrahedral_chirality (short 1)))

let chirality_tests = "chirality" >::: [ "toggles" >:: test_chirality_toggles ]

let test_png_metadata_functions _ =
  let png, png_sz = copy_string_to_malloc one_by_one_png in
  let png_ref = allocate pkl_typ png in
  let png_sz_ref = allocate size_t png_sz in
  with_inplace_mol "CCO" (fun mol_ref mol_sz_ref ->
      assert_ok "set_2d_coords should succeed before PNG embedding"
        (set_2d_coords mol_ref mol_sz_ref);
      Fun.protect
        ~finally:(fun () -> free_c_char (!@ png_ref))
        (fun () ->
          assert_ok "add_mol_to_png_blob should succeed"
            (add_mol_to_png_blob png_ref png_sz_ref (!@ mol_ref) (!@ mol_sz_ref)
               (Some "{\"includePkl\":false,\"includeSmiles\":true,\"includeMol\":true}"));
          let out_ref = allocate pkl_typ null_char_ptr in
          let out_sz_ref = alloc_size_t () in
          assert_ok "get_mol_from_png_blob should recover molecule"
            (get_mol_from_png_blob (!@ png_ref) (!@ png_sz_ref) out_ref out_sz_ref (Some ""));
          assert_equal "CCO" (get_smiles (!@ out_ref) (!@ out_sz_ref) None);
          free_ptr (!@ out_ref);
          let arr_ref = allocate pkl_ptr null_pkl_ptr in
          let sizes_ref = allocate sz_ptr null_size_ptr in
          assert_ok "get_mols_from_png_blob should recover molecule array"
            (get_mols_from_png_blob (!@ png_ref) (!@ png_sz_ref) arr_ref sizes_ref
               (Some "{\"includeSmiles\":true}"));
          let arr = !@ arr_ref in
          let sizes = !@ sizes_ref in
          assert_not_null "PNG molecule array should be returned" arr;
          assert_equal "CCO" (get_smiles (!@ arr) (!@ sizes) None);
          free_mol_array arr_ref sizes_ref))

let png_tests = "png_metadata" >::: [ "png_blob_round_trip" >:: test_png_metadata_functions ]

let test_log_handles _ =
  assert_ok "disable_logging should succeed" (disable_logging ());
  let handle = set_log_capture "rdApp.*" in
  assert_bool "set_log_capture should return a handle" (not (is_null handle));
  ignore (get_mol "CN(C)(C)C" (alloc_size_t ()) "");
  let buffer = get_log_buffer handle in
  assert_bool "captured log should contain valence error" (contains buffer "Explicit valence");
  assert_ok "clear_log_buffer should succeed" (clear_log_buffer handle);
  assert_equal "" (get_log_buffer handle);
  let handle_ref = allocate log_handle_t handle in
  assert_ok "destroy_log_handle should succeed" (destroy_log_handle handle_ref);
  assert_bool "destroy_log_handle should null out handle" (is_null (!@ handle_ref));
  assert_ok "enable_logging should succeed" (enable_logging ())

let logging_tests = "logging_handles" >::: [ "capture_clear_destroy" >:: test_log_handles ]

let rec prop_keys acc keys =
  let key = !@ keys in
  if is_null key then List.rev acc
  else
    let len = int_of_size_t (strlen key) in
    let s = string_from_ptr key ~length:len in
    prop_keys (s :: acc) (keys +@ 1)

let rec free_prop_list keys =
  let key = !@ keys in
  if not (is_null key) then (
    c_free (as_void key);
    free_prop_list (keys +@ 1))

let test_properties _ =
  with_inplace_mol "CCO" (fun pkl_ref sz_ref ->
      assert_equal 0 (int_of_short (has_prop (!@ pkl_ref) (!@ sz_ref) "name"));
      set_prop pkl_ref sz_ref "name" "ethanol" (short 0);
      assert_equal 1 (int_of_short (has_prop (!@ pkl_ref) (!@ sz_ref) "name"));
      assert_equal "ethanol" (get_prop (!@ pkl_ref) (!@ sz_ref) "name");
      let keys = get_prop_list (!@ pkl_ref) (!@ sz_ref) (short 1) (short 1) in
      assert_not_null "property list should be returned" keys;
      assert_bool "property list should include name" (List.mem "name" (prop_keys [] keys));
      free_prop_list keys;
      c_free (coerce (ptr (ptr char)) (ptr void) keys);
      keep_props pkl_ref sz_ref (Some "{\"props\":[\"name\"]}");
      assert_equal 1 (int_of_short (has_prop (!@ pkl_ref) (!@ sz_ref) "name"));
      assert_ok "clear_prop should succeed" (clear_prop pkl_ref sz_ref "name");
      assert_equal 0 (int_of_short (has_prop (!@ pkl_ref) (!@ sz_ref) "name")))

let property_tests = "properties" >::: [ "set_get_list_clear_keep" >:: test_properties ]

let test_helpers _ =
  let szp = alloc_size_t () in
  assert_equal 0 (int_of_size_t (read_size_t szp));
  let mol_szp = alloc_size_t () in
  let pkl = get_mol "CC" mol_szp "" in
  assert_not_null "get_mol failed for helper test" pkl;
  let new_pkl, new_sz, ok = with_inplace add_hs pkl (read_size_t mol_szp) in
  assert_ok "with_inplace add_hs should succeed" ok;
  assert_bool "with_inplace should return a positive size" (int_of_size_t new_sz > 0);
  assert_bool "with_inplace should return a non-null pickle" (not (is_null new_pkl));
  free_ptr new_pkl

let helper_tests = "helpers" >::: [ "alloc_read_with_inplace" >:: test_helpers ]

let tests =
  "RDKit OCaml CFFI tests" >::: [
    housekeeping_tests;
    molecule_tests;
    serialisation_tests;
    fragmentation_tests;
    substructure_tests;
    drawing_tests;
    descriptor_tests;
    modification_tests;
    coordinate_tests;
    chirality_tests;
    png_tests;
    logging_tests;
    property_tests;
    helper_tests;
  ]

let () = run_test_tt_main tests
