(*
  The MIT License (MIT)
  
  Copyright (c) 2016 Maxime Ransan <maxime.ransan@gmail.com>
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*)

(** Backend for compiling Protobuf messages to OCaml 
 *)

(** This module focuses on the compilation steps which transforms a 
    fully resolved Protobuf message into an OCaml representation. 

    After compilation this module also expose code generation 
    functionality. 
 *)

(** {2 Compilation } *) 

val compile :
  Pbtt.resolved Pbtt.proto ->
  Pbtt.resolved Pbtt.proto_type -> 
  Ocaml_types.type_ list 

val module_of_file_name : string -> string 
(** [module_of_file_name filename] returns the corresponding OCaml module name
  *)

val rev_split_by_naming_convention : string -> string list 
(** [rev_split_by_naming_convention s] will split [s] according to the protobuf
    coding style convention. The rule split are 
    {ul
    {- character ['_'] is a separator}
    {- the first uppercase letter after a lower case is a separator (ie FooBar will be split into [ ["Bar";"Foo"] ]}  
    }
 *)

(* --- Testing purpose only --- *)

val type_name : string list -> string -> string 

val constructor_name : string -> string 
