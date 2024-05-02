(* Coursera Programming Languages, Homework 3, Provided Code *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern
datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = Anything
	     | UnitT
	     | IntT
	     | TupleT of typ list
	     | Datatype of string

(**** you can put all your code here ****)

(* 1. *)
val only_capitals = List.filter (fn s => Char.isUpper (String.sub(s, 0)))

(* 2. *)
val longest_string1 = List.foldl (fn (x, y) => if (String.size x) > (String.size y) then x else y) ""

(* 3. *)
val longest_string2 = List.foldl (fn (x, y) => if (String.size x) >= (String.size y) then x else y) ""

(* 4. *)
fun longest_string_helper f =
    List.foldl (fn (x, y) => if f(String.size x, String.size y) then x else y) ""
                                          
val longest_string3 = longest_string_helper (fn (x, y) => x > y)
val longest_string4 = longest_string_helper (fn (x, y) => x >= y)

                                            
(* 5. *)
val longest_capitalized = longest_string1 o only_capitals

(* 6. *)
val rev_string = String.implode o List.rev o String.explode

(* 7. *)
fun first_answer f xs =
    case xs of
        [] => raise NoAnswer
      | x::xs' => case f x of
                      NONE => first_answer f xs'
                    | SOME v => v

(* 8. *)
fun all_answers f xs =
    let fun helper xs rsf =
            case xs of
                [] => SOME rsf
              | x::xs' => case f x of
                              NONE => NONE
                            | SOME lst => helper xs' (rsf @ lst)
    in helper xs []
    end


(* 9. *)
        
(* a *)
val count_wildcards = g (fn () => 1) (fn x => 0)
(* b *)
val count_wild_and_variable_lengths = g (fn () => 1) String.size
(* c *)
fun count_some_var (s, p) = g (fn () => 0) (fn x => if x = s then 1 else 0) p


(* 10. *)
fun check_pat p =
    let fun get_variables p =
            case p of
                Variable x => [x]
	      | TupleP ps => List.foldl (fn (p',i) => (get_variables p') @ i) [] ps
	      | ConstructorP(_,p') => get_variables p'
              | _ => []

        fun has_duplicates xs =
            case xs of
                [] => false
              | x::xs' => (List.exists (fn s => s = x) xs') orelse (has_duplicates xs')
                                      
    in (not o has_duplicates o get_variables) p
    end

        
(* 11. *)
fun match (v : valu, p : pattern) : (string * valu) list option =
    case (v, p) of
        (_, Wildcard) => SOME []
      | (_, Variable s) => SOME [(s, v)]
      | (Unit, UnitP) => SOME []
      | (Const n1, ConstP n2) => if n1 = n2 then SOME [] else NONE
      | (Tuple vs, TupleP ps) => if length vs = length ps
                                 then all_answers match (ListPair.zip(vs, ps))
                                 else NONE
      | (Constructor(s1, v), ConstructorP(s2, p)) => if s1 = s2 then match(v, p) else NONE
      | _ => NONE


(* 12. *)
fun first_match v ps =
    SOME (first_answer (fn p => match(v, p)) ps)
    handle NoAnswer => NONE

                               
(* Challenge problem *)
fun typecheck_patterns (ds : (string*string*typ) list, ps : pattern list) : typ option =
    let fun option_zip (xs1 : 'a list, xs2 : 'a list) : ('a option * 'a option) list =
            case (xs1, xs2) of
                ([], []) => []
              | (x1::xs1', x2::xs2') => (SOME x1, SOME x2) :: option_zip(xs1', xs2')
              | _ => []
                         
        fun join_options (xs : 'a option list) : 'a list option =
            SOME (List.map valOf xs)
            handle Option => NONE
                                                      
        fun join_types (to1 : typ option, to2 : typ option) : typ option =
            case (to1, to2) of
                (NONE, _) => NONE
              | (_, NONE) => NONE
              | (SOME Anything, to) => to
              | (to, SOME Anything) => to
              | (SOME (TupleT ts1), SOME (TupleT ts2)) =>
                if length ts1 = length ts2
                then let val ts_opts = (join_options
                                            (List.map join_types
                                                      (option_zip (ts1, ts2))))
                     in Option.map TupleT ts_opts
                     end
                else NONE
              | (SOME (Datatype s1), SOME (Datatype s2)) => if s1 = s2 then SOME (Datatype s1) else NONE
              | _ => if to1 = to2 then to1 else NONE
                         
        fun get_constructor (n : string, t : typ) : typ option =
            let fun f (c : (string*string*typ)) : typ option =
                    let val (n', d, t') = c
                    in if n <> n'
                       then NONE
                       else Option.map (fn x => Datatype d) (join_types (SOME t, SOME t'))
                    end
                        
            in
                SOME (first_answer f ds)
                handle NoAnswer => NONE
            end
                
        fun get_lenient_type (p : pattern) : typ option =
            case p of
	        Wildcard    => SOME Anything
	      | Variable _  => SOME Anything
              | UnitP => SOME UnitT
              | ConstP _ => SOME IntT
	      | TupleP ps  => Option.map TupleT (join_options (map get_lenient_type ps))
	      | ConstructorP(n, p') => Option.mapPartial (fn t => get_constructor (n, t)) (get_lenient_type p')

                                                          
    in case ps of
           [] => NONE
         | _  => (List.foldl join_types (SOME Anything) (List.map get_lenient_type ps))
    end
        

