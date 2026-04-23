{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core build tools
    cmake
    gnumake
    gcc
    pkg-config
    ocaml
    dune
    ocamlPackages.ctypes
    ocamlPackages.ctypes-foreign
    ocamlPackages.findlib
    ocamlPackages.merlin
    ocamlPackages.ounit2




    # Required C++ deps
    boost
    eigen
    sqlite

    # Optional but strongly recommended
    cairo
    freetype
    libpng
    zlib

    # Python (for RDKit Python bindings)
    python311
    python311Packages.numpy

    # Optional chemistry / parsing support
    libxml2

    # Testing / extras
    catch2
  ];

  # Helpful environment setup
  shellHook = ''
    export RDBASE=$PWD
    echo "RDKit build environment ready"
  '';
}
