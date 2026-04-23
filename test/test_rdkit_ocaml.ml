open OUnit2


let test_version _ =
  let version = Rdkit_ocaml.Cffi.version () in
  assert_equal "Release_202dddddddddddddddd44_06_1" version


let tests = "Test suite for Rdkit_ocaml" >::: [
  "test_version" >:: test_version
]

let _ =
  run_test_tt_main tests
