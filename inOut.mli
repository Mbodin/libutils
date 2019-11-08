(** Module InOut
 * Specifies an interface for inputs and outputs. **)

(** Specifies the different properties of div elements. **)
type layout =
  | Normal (** No special layout. **)
  | Centered (** Its content is centered. **)
  | Inlined (** The block is inlined. **)

(** Specific options for cells in tables. **)
type cell_option = {
    row : int
      (** This interger enables rows to be merged: for each cells, it indicates
       * how many rows are merged with the current cell.  If the integer is [1],
       * the cell is a normal cell, but if it is more than [1], the cell has
       * been merged with cells below.**) ;
    col : int (** Similar than [row], but merging columns instead of rows. **) ;
    classes : string list (** Some CSS-specific classes. **)
  }

(** The options for a normal cell. **)
val default : cell_option

(** A simplified representation of DOM’s nodes. **)
type 'node block =
  | Div of layout * 'node block list (** A div node, with its layout. **)
  | P of 'node block list (** A paragraph node. **)
  | List of bool * 'node block list
      (** A list of items.
       * The boolean indicates whether bullets should be drawn. **)
  | Space (** Some space between texts. **)
  | Text of string (** A simple text. **)
  | FoldableBlock of bool * string * 'node block
      (** A title that can hide a node.
       * The boolean states whether the block should be unfolded by default. **)
  | Link of string * string (** A link and its associated address. **)
  | LinkContinuation of bool * string * (unit -> unit)
      (** A link and its associated continuation.
       * The boolean indicates whether the arrow is forwards. **)
  | LinkFile of string * string * string * bool * (unit -> string)
      (** Creates a link to a file whose content is computed.
       * The first argument is the link text, the second the file name,
       * the third the mime type, and the fifth its content.
       * The fourth indicates wether newlines should be adapted to the
       * host’s operating system or not. **)
  | Table of string list
             * ('node block * cell_option) list
             * (string list * ('node block * cell_option) list) list
    (** A table, with its headers and its content (given line by line).
     * It is also provided with some specific cell options for each content cell.
     * Each line is also provided with a list of CSS classes, given as string.
     * Finally, the whole table is associated with another list of CSS classes. **)
  | Node of 'node (** For all cases where more control is needed,
                   * we can directly send a node. **)

(** Adds the expected spaces between block elements. **)
val add_spaces : 'node block -> 'node block

(** This is the signature specified in this file.
 * It is satisfied by the various files [lib/inOut_*.ml]. **)
module type T = sig

  (** Pauses the program for a short amount of time. **)
  val pause : unit -> unit Lwt.t

  (** Stops the loading animation. **)
  val stopLoading : unit -> unit Lwt.t

  (** Starts the loading animation. **)
  val startLoading : unit -> unit Lwt.t

  (** Set or unset the printing mode, a mode more adapted to printing. **)
  val set_printing_mode : unit -> unit
  val unset_printing_mode : unit -> unit

  (** Log the given message. **)
  val log : string -> unit

  (** Fetch a file from an address and returns its content. **)
  val get_file : string -> string Lwt.t

  (** Get parameters from the current address, in the form of a list of string. **)
  val get_parameters : unit -> (string * string) list

  (** Write parameters to the address. **)
  val set_parameters : (string * string) list -> unit

  (** The local set of accepted languages. **)
  val languages : string list


  (** An abstract type for representing nodes. **)
  type node

  (** Converts the block to a node. **)
  val block_node : node block -> node

  (** Adds the node to the [response] div in the main webpage.
   * If [error] is [true], the node is highlighted as an error. **)
  val print_node : ?error:bool -> node -> unit

  (** A composition of [add_spaces], [block_node], and [print_node]. **)
  val print_block : ?error:bool -> node block -> unit

  (** Clears the [response] div in the main webpage. **)
  val clear_response : unit -> unit

  (** Create a text output as a number which can be later reset. **)
  val createNumberOutput : int -> node * (int -> unit)

  (** Create a text output as a number which can be later reset. **)
  val createTextOutput : string -> node * (string -> unit)

  (** Create a (positive) number input with default value given as argument.
   * It also returns a function reading it. **)
  val createNumberInput : ?min:int -> ?max:int -> int -> node * (unit -> int)

  (** Create a text input with default value given as argument.
   * It also returns a function reading it. **)
  val createTextInput : string -> node * (unit -> string)

  (** Create a text input meant to return a list of things.
   * Each time that the user type a string, it is fed to its argument function.
   * The strings of the returned list is shown to the user.  The final list can
   * be fetched with the function returned with the node.
   * The initial list and a placeholder string is given to the function to help
   * the user. **)
  val createResponsiveListInput : (string * 'a) list -> string -> (string -> (string * 'a) list) -> node * (unit -> 'a list)

  (** Create a range input between [0.] and [1.].
   * As of [createNumberInput], it also returns a function reading it. **)
  val createPercentageInput : float -> node * (unit -> float)

  (** Create a date input.
   * As of [createNumberInput], it also returns a function reading it. **)
  val createDateInput : Date.t -> node * (unit -> Date.t)

  (** Create a switch button.
   * It takes a function that will be called at each state change as argument.
   * It also returns a setter and a getter.
   * The first string is the text associated with the button, to which can be
   * added three facultative texts: one serving as a description, one added
   * afterwards for when the button is on, and one when the button is off. **)
  val createSwitch : string -> string option -> string option -> string option -> bool -> (unit -> unit) -> node * (bool -> unit) * (unit -> bool)

  (** Create a button to import a file.
   * It takes as argument the list of extension it accepts.
   * It also takes as argument a function called before loading the file into
   * memory.
   * As of the other reading functions, it returns the created element and
   * a reading function.
   * This reading function returns both the file name and its content. **)
  val createFileImport : string list -> (unit -> unit Lwt.t) -> node * (unit -> (string * string) Lwt.t)

end

