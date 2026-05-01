# RDKit-OCaml

This project provides an interface to use RDkit inside OCaml. RDKit is a cheminformatics library implemented in C++. There are Python, Java and JavaScript bindings available, but it would be useful to take advantage of some OCaml features such as GADTs for cheminformatics work.
The RDKit library now has an API that exposes some of its most common functionality in a [C Wrapper](https://greglandrum.github.io/rdkit-blog/posts/2021-05-01-rdkit-cffi-part1.html). 

Here we use [ctypes](https://opam.ocaml.org/packages/ctypes/), to call the exposed C functions, the heavy lifting is done in /lib/cffi.ml. 

Using this approach we can only use the functions in minimimallib, and if we wanted to extend to the full RDKit functionality, we would require a new approach. It should be possible to run the rest through SWIG and someone more knowledgeable than me in C would be able to clean the generated C layer. 

In the main file we have a minimal example of generating a canonical smiles string. But I still need to write a full test suite for the functions. 

## Building the project   

This project relies on a compiled from source RDkit (which I have included as a git submodule). I would recommend using nix and the provided nix-shell to manage dependencies. 

Simply install [Nix](https://nixos.org/download/) if you haven't  already, then run form the root directory 

`nix-shell` 

Then run

`bash build_rdkit.sh` 

This should hopefully build the rdkit repo and generate the required librdkitcffi.so file that is linked in the project. You need to export the library path so the compiled project can find the file 

`export RDKIT_CFFI_LIB=/path/to/librdkitcffi.so`  

The path is probably something like `~/rdkit-ocaml/build/rdkit/lib/librdkitcffi.so`

If you really do not want to use Nix, you can resolve the dependencies manually but this can be quite tricky. More info is [here](https://www.rdkit.org/docs/Install.html). 

### Running the minimal example 

``` shell
 dune build
 cd lib/
 dune exec rdkit-ocaml
```

### Running examples 

Once you have built the executables you can try out the examples by running 

``` shell
dune exec examples/<example>.exe
```
