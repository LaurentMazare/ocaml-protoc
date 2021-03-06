# ocaml-protoc

A [protobuf](https://developers.google.com/protocol-buffers/) compiler for OCaml. 

* [Introduction](#introduction)
* [Simple Example](#a-simple-example)
* [Build/Install](#build-install)
* [Protobuf <-> OCaml mapping](doc/protobuf_ocaml_mapping.md)
* [Compiler Internals](doc/compiler_internals.md)
* [Protobuf extensions](doc/ocaml_extensions.md)
* [Benchmarking](doc/benchmarking.md)


### Introduction 

`ocaml-protoc` compiles [protobuf message files](https://developers.google.com/protocol-buffers/docs/proto) into 
[OCaml modules](http://caml.inria.fr/pub/docs/manual-ocaml/moduleexamples.html). Each message/enum/oneof protobuf type 
will have a corresponding OCaml type along with the following functions:
* `encode_<type>` : encode the generated type to `bytes` following protobuf specification
* `decode_<type>` : decode the generated type from `bytes` following protobuf specification
* `default_<type>` : default value honoring [protobuf default attributes](https://developers.google.com/protocol-buffers/docs/proto#optional) or [protobuf version 3 default rules](https://developers.google.com/protocol-buffers/docs/proto3#default) 
* `pp_<type>` : pretty print of the OCaml type

The compiler relies on a runtime library `pbrt` which itself is implemented using the same runtime library as [ppx_deriving_protobuf](https://github.com/whitequark/ppx_deriving_protobuf/) for low level encoding/decoding. OCaml users have now 2 complementary options to choose from when looking for a protobuf serialization:
* If the application is mainly OCaml then `ppx_deriving_protobuf` is usually the best tool. Developers leverage the OCaml type system as a schema definition and require minimum effort to support serialization. 
* If the serialized data is shared across multiple languages or as a server interface then the `.proto` file is a good language independent type definition. `ocaml-protoc` is then more likely a better option guaranteeing that the generated type will conform to the schema definition when being serialized.

### A simple example

Let's take a similar example as the [google one](https://developers.google.com/protocol-buffers/docs/overview#how-do-they-work):

```Javascript
message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;
  repeated string phone = 4;
}
```
The following OCaml code will get generated after running `ocaml-protoc -ml_out ./ example.proto`
```OCaml
(** example01.proto Generated Types and Encoding *)

(** {2 Types} *)

type person = {
  name : string;
  id : int32;
  email : string option;
  phone : string list;
}


(** {2 Default values} *)

val default_person : 
  ?name:string ->
  ?id:int32 ->
  ?email:string option ->
  ?phone:string list ->
  unit ->
  person
(** [default_person ()] is the default value for type [person] *)


(** {2 Protobuf Decoding} *)

val decode_person : Pbrt.Decoder.t -> person
(** [decode_person decoder] decodes a [person] value from [decoder] *)


(** {2 Protobuf Encoding} *)

val encode_person : person -> Pbrt.Encoder.t -> unit
(** [encode_person v encoder] encodes [v] with the given [encoder] *)


(** {2 Formatters} *)

val pp_person : Format.formatter -> person -> unit 
(** [pp_person v] formats v] *)
```

You can then use this OCaml module in your application to populate, serialize, and retrieve `person` protocol buffer messages.
For example:

```OCaml
let () =

  (* Create OCaml value of generated type *) 
  let person = Example_pb.({ 
    name = "John Doe"; 
    id = 1234l;
    email = Some "jdoe@example.com"; 
    phone = ["123-456-7890"];
  }) in 
  
  (* Create a Protobuf encoder and encode value *)
  let encoder = Pbrt.Encoder.create () in 
  Example_pb.encode_person person encoder; 

  (* Output the protobuf message to a file *) 
  let oc = open_out "myfile" in 
  output_bytes oc (Pbrt.Encoder.to_bytes encoder);
  close_out oc
```

Then later on you can read your message back in:
```OCaml
let () = 
  (* Read bytes from the file *) 
  let bytes = 
    let ic = open_in "myfile" in 
    let len = in_channel_length ic in 
    let bytes = Bytes.create len in 
    really_input ic bytes 0 len; 
    close_in ic; 
    bytes 
  in 
  
  (* Decode the person and Pretty-print it *)
  let person = Test14_pb.decode_person (Pbrt.Decoder.of_bytes bytes) in 
  Format.fprintf Format.std_formatter "%a" Test14_pb.pp_person person
```

*OCaml users will immediately point to the use of `int32` type in the generated code which might not be the most convenient choice. One can modify this behavior using [custom extensions](doc/ocaml_extensions.md).* 

### Build-Install

**Prerequesite**

`ocaml-protoc` depends on :
* the OCaml compiler distribution (byte code/native compiler and ocamlbuild).
* [ppx_deriving_protobuf](https://github.com/whitequark/ppx_deriving_protobuf) for the generated code runtime.

**Intall from OPAM**

```bash
opam install ocaml-protoc
```

**Install from source with [ocamlfind](http://projects.camlcity.org/projects/findlib.html)**

```bash
mkdir -p tmp/bin
export PREFIX=`pwd`/tmp
make install
```

**Build your program** 

Here are the steps to build the example above where the source are in `src/examples/`. We now assume that `$PREFIX/bin` is in your path.

```Bash
# Generate the OCaml protobuf module 
ocaml-protoc -ml_out ./ example01.proto

# Compile the example including the ocaml protobuf runtime (pbrt.cmxa) and it's dependencies.
ocamlfind ocamlopt -linkpkg  -package ocaml-protoc tmp_pb.mli tmp_pb.ml main.ml
```

Alternatively if you are using `findlib`:
```Bash
ocamlfind ocamlopt -linkpkg -package ppx_deriving_prototub.runtime -package ocaml-protoc \
  -o example01 \
  example01_pb.mli example01_pb.ml example01.ml
```

You can now run the example
```Bash
./example01
```
### Protobuf <-> OCaml mapping
see [here](doc/protobuf_ocaml_mapping.md).

### Compiler Internals

see [here](doc/compiler_internals.md)

### Protobuf Extensions
 
see [here](doc/ocaml_extensions.md)

### Benchmarking
 
see [here](doc/benchmarking.md)
