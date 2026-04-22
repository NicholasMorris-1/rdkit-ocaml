{
  description = "An OCaml interface for RDKit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ocamlPackages = pkgs.ocamlPackages;

        # -------------------------------------------------------
        # 1. RDKit built from source with CFFI
        # -------------------------------------------------------
        rdkit = pkgs.stdenv.mkDerivation {
          pname = "rdkit";
          version = "2024.03.1";

          src = pkgs.fetchFromGitHub {
            owner = "rdkit";
            repo = "rdkit";
            rev = "ba0b6f3bafb391c17d7da9783f09817a4ba0f8f1";
            sha256 = "sha256-8X+Q3n141tll8MEWjkhbelK2sSD470uBrFblcXq0VL8=";
          };

          nativeBuildInputs = with pkgs; [ cmake pkg-config git ];

          buildInputs = with pkgs; [
            boost eigen cairo freetype zlib catch2
          ];

          cmakeFlags = [
            "-DRDK_BUILD_CFFI_LIB=ON"
            "-DRDK_BUILD_PYTHON_WRAPPERS=OFF"
            "-DRDK_BUILD_INCHI_SUPPORT=ON"
            "-DRDK_BUILD_CAIRO_SUPPORT=ON"
            "-DRDK_INSTALL_STATIC_LIBS=OFF"
            "-DRDK_BUILD_TESTS=OFF"
            "-DRDK_BUILD_CPP_TESTS=OFF"
            "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
            "-DCMAKE_BUILD_TYPE=Release"
          ];

          postInstall = ''
            if [ ! -f $out/lib/librdkitcffi.so ]; then
              echo "ERROR: librdkitcffi.so was not built!"
              exit 1
            fi
          '';

          meta = {
            description = "RDKit cheminformatics library built with CFFI wrapper";
            homepage = "https://www.rdkit.org";
            license = pkgs.lib.licenses.bsd3;
          };
        };

        # -------------------------------------------------------
        # 2. Build the entire dune workspace in one derivation.
        #    This handles both lib/ and bin/ in one shot, which is
        #    how dune workspaces are meant to be consumed by Nix.
        # -------------------------------------------------------
        ocaml-rdkit = ocamlPackages.buildDunePackage {
          pname = "ocaml-rdkit";
          version = "0.1.0";

          # Point at the workspace root so dune sees all packages
          src = ./.;

          nativeBuildInputs = with pkgs; [ pkg-config makeWrapper ];

          buildInputs = with ocamlPackages; [
            ctypes
            ctypes-foreign
          ];

          # Expose rdkit headers and library to the C compiler / linker
          # that dune invokes for any C stubs
          NIX_LDFLAGS = "-L${rdkit}/lib -lrdkitcffi";
          NIX_CFLAGS_COMPILE = "-I${rdkit}/include/rdkit";

          # Bake the rpath into any native shared objects produced by
          # dune (e.g. ctypes C stubs built as .so files)
          postFixup = ''
            find $out -name "*.so" | while read f; do
              patchelf --add-rpath ${rdkit}/lib "$f" || true
            done

            # Wrap every binary so the rdkit .so is always found
            find $out/bin -type f | while read f; do
              wrapProgram "$f" \
                --prefix LD_LIBRARY_PATH : ${rdkit}/lib
            done
          '';
        };

        # -------------------------------------------------------
        # 3. Docker image
        # -------------------------------------------------------
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "rdkit-ocaml-app";
          tag = "latest";
          maxLayers = 120;

          contents = [
            ocaml-rdkit
            rdkit
            pkgs.cacert
          ];

          config = {
            Cmd = [ "/bin/myapp" ];
            Env = [
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "LD_LIBRARY_PATH=${rdkit}/lib"
            ];
          };
        };

      in {
        packages = {
          default = ocaml-rdkit;
          myapp   = ocaml-rdkit;
          rdkit   = rdkit;
          docker  = dockerImage;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with ocamlPackages; [
            ocaml
            dune_3
            findlib
            ocaml-lsp
            ocamlformat
            ctypes
            ctypes-foreign
            rdkit
            pkgs.pkg-config
            pkgs.cmake
            pkgs.patchelf
            pkgs.gdb
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${rdkit}/lib:$LD_LIBRARY_PATH"
            export PKG_CONFIG_PATH="${rdkit}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export C_INCLUDE_PATH="${rdkit}/include/rdkit:$C_INCLUDE_PATH"

            echo "--------------------------------------"
            echo " OCaml + RDKit dev environment ready"
            echo " librdkitcffi.so: $(ls ${rdkit}/lib/librdkitcffi.so 2>/dev/null || echo 'NOT FOUND')"
            echo "--------------------------------------"
          '';
        };
      });
}
