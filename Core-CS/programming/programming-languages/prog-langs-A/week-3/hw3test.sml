(* Homework3 Simple Test*)
(* These are basic test cases. Passing these tests does not guarantee that your code will pass the actual homework grader *)
(* To run the test, add a new line to the top of this file: use "homeworkname.sml"; *)
(* All the tests should evaluate to true. For example, the REPL should say: val test1 = true : bool *)
use "hw3.sml";

val test1_1 = only_capitals [] = []
val test1_2 = only_capitals ["A","B","C"] = ["A","B","C"]
val test1_3 = only_capitals ["A","b","C"] = ["A","C"]
val test1_4 = only_capitals ["Abs","Bec","Ceki"] = ["Abs","Bec","Ceki"]
val test1_5 = only_capitals ["aDD","bAD","cHAD"] = []

val test2_1 = longest_string1 [] = ""
val test2_2 = longest_string1 ["A","bc","C"] = "bc"
val test2_3 = longest_string1 ["A","bc","C"] = "bc"
val test2_4 = longest_string1 ["A","bc","CB"] = "bc"
val test2_5 = longest_string1 ["A","bc","Cba"] = "Cba"

val test3_1 = longest_string2 [] = ""
val test3_2 = longest_string2 ["A","bc","C"] = "bc"
val test3_3 = longest_string2 ["A","bc","C"] = "bc"
val test3_4 = longest_string2 ["A","bc","CB"] = "CB"
val test3_5 = longest_string2 ["A","bc","Cba"] = "Cba"

val test4a_1 = longest_string3 [] = ""
val test4a_2 = longest_string3 ["A","bc","C"] = "bc"
val test4a_3 = longest_string3 ["A","bc","C"] = "bc"
val test4a_4 = longest_string3 ["A","bc","CB"] = "bc"
val test4a_5 = longest_string3 ["A","bc","Cba"] = "Cba"

val test4b_1 = longest_string4 [] = ""
val test4b_2 = longest_string4 ["A","bc","C"] = "bc"
val test4b_3 = longest_string4 ["A","bc","C"] = "bc"
val test4b_4 = longest_string4 ["A","bc","CB"] = "CB"
val test4b_5 = longest_string4 ["A","bc","Cba"] = "Cba"
val test4b_6 = longest_string4 ["A","B","C"] = "C"

val test5_1 = longest_capitalized [] = ""
val test5_2 = longest_capitalized ["a","bc","c"] = ""
val test5_3 = longest_capitalized ["A","Bc","C"] = "Bc"
val test5_4 = longest_capitalized ["A","bc","C"] = "A"

val test6_1 = rev_string "" = ""
val test6_2 = rev_string "a" = "a"
val test6_3 = rev_string "abc" = "cba"
val test6_4 = rev_string "Abc" = "cbA"

val test7_1 = first_answer (fn x => if x > 3 then SOME x else NONE) [1,2,3,4,5] = 4
val test7_2 = ((first_answer (fn x => if x > 10 then SOME x else NONE) [1,2,3,4,5]);
               false) handle NoAnswer => true
val test7_3 = ((first_answer (fn x => if x > 0 then SOME x else NONE) []);
               false) handle NoAnswer => true
                                           
val test8_1 = all_answers (fn x => if x = 1 then SOME [x] else NONE) [] = SOME []
val test8_2 = all_answers (fn x => if x = 1 then SOME [x] else NONE) [2,3,4,5,6,7] = NONE
val test8_3 = all_answers (fn x => if x < 4 then SOME [x, x+1] else NONE) [1, 2, 3] = SOME [1, 2, 2, 3, 3, 4]

val test9a_1 = count_wildcards Wildcard = 1
val test9a_2 = count_wildcards UnitP = 0
val test9a_3 = count_wildcards (TupleP [Wildcard, (Variable "S"), Wildcard]) = 2
val test9a_4 = count_wildcards (TupleP [Wildcard, (ConstructorP ("C", TupleP [Wildcard, Wildcard]))]) = 3

val test9b_1 = count_wild_and_variable_lengths (Variable("a")) = 1
val test9b_2 = count_wild_and_variable_lengths (TupleP [Wildcard,(ConstructorP
                                                                    ("C", TupleP [Variable "help", Wildcard]))]) = 6
val test9c_1 = count_some_var ("x", UnitP) = 0
val test9c_2 = count_some_var ("x", Variable("x")) = 1
val test9c_3 = count_some_var ("x", TupleP [Variable "x",(ConstructorP
                                                              ("x", TupleP [Variable "x", Wildcard, Variable "y"]))]) = 2

val test10_1 = check_pat Wildcard = true
val test10_2 = check_pat (Variable("x")) = true
val test10_3 = check_pat (TupleP [Variable("X"), Variable("Y")]) = true
val test10_4 = check_pat (TupleP [Variable("X"), Variable("Y"), Variable("X")]) = false
val test10_5 = check_pat (TupleP [Variable("Y"),(ConstructorP
                                                     ("X", TupleP [Variable "X", Wildcard]))]) = true
val test10_6 = check_pat (TupleP [Variable("X"), (ConstructorP
                                                      ("C", TupleP [Variable "X", Wildcard]))]) = false

val test11_1 = match (Const(1), UnitP) = NONE
val test11_2 = match (Const(1), Wildcard) = SOME []
val test11_3 = match (Unit, UnitP) = SOME []
val test11_4 = match (Const(1), ConstP(2)) = NONE
val test11_5 = match (Const(1), ConstP(1)) = SOME []
val test11_6 = match (Const(1), Variable "s") = SOME [("s", Const(1))]
val test11_7 = match (Tuple [], TupleP[]) = SOME []
val test11_8 = match (Tuple [Const(1), Const(2)], TupleP[Wildcard, Wildcard]) = SOME []
val test11_9 = match (Tuple [Const(1), Constructor("a", Const(2))], TupleP[Wildcard, Variable "s"]) =
               SOME [("s", (Constructor("a", Const(2))))]
val test11_10 = match (Constructor("A", Tuple [Unit, Tuple[], Const(1),
                                               Constructor("B", Tuple[Const(2), Const 3]), Const(4)]), 
                       ConstructorP("A", TupleP[UnitP, Wildcard, Variable "a",
                                               ConstructorP("B", Variable "b"), ConstP(4)]))
                = SOME [("a", Const(1)), ("b", Tuple[Const(2), Const(3)])]

val test11_11 = match (Constructor("A", Tuple [Unit, Tuple[], Const(1),
                                               Constructor("B", Tuple[Const(2), Const 3]), Const(4)]), 
                       ConstructorP("X", TupleP[UnitP, Wildcard, Variable "a",
                                               ConstructorP("B", Variable "b"), ConstP(4)]))
                = NONE

val test12_1 = first_match Unit [UnitP] = SOME []
val test12_2 = first_match Unit [] = NONE
val test12_3 = first_match (Constructor("A", Tuple [Unit, Tuple[], Const(1),
                                               Constructor("B", Tuple[Const(2), Const 3]), Const(4)]))
                       [ConstructorP("X", TupleP[UnitP, Wildcard, Variable "a",
                                                 ConstructorP("B", Variable "b"), ConstP(4)]),
                      ConstructorP("A", TupleP[UnitP, Wildcard, Variable "a",
                                               ConstructorP("B", Variable "b"), ConstP(4)])] =
                       SOME [("a", Const(1)), ("b", Tuple[Const(2), Const(3)])]

val test13_1 = typecheck_patterns([], []) = NONE
val test13_2 = typecheck_patterns([], [Wildcard]) = SOME Anything
val test13_3a = typecheck_patterns([], [TupleP[Variable("x"),Variable("y")],
                                       TupleP[Wildcard,Wildcard]]) = SOME (TupleT[Anything,Anything])
val test13_3b = typecheck_patterns([], [TupleP[Variable("x"),ConstP 10],
                                       TupleP[Wildcard,Wildcard]]) = SOME (TupleT[Anything,IntT])
val test13_4 = typecheck_patterns([], [TupleP[Wildcard,Wildcard],
                                       TupleP[Wildcard, TupleP[Wildcard,Wildcard]]]) =
               SOME (TupleT[Anything,TupleT[Anything,Anything]])
val test13_5 = typecheck_patterns([("a", "score",UnitT),
                                   ("b", "score", UnitT),
                                   ("c", "score", UnitT)],
                                  [ConstructorP("a", UnitP), ConstructorP("b", UnitP)]) = SOME (Datatype "score")
val test13_6 = typecheck_patterns([("a", "score",UnitT),
                                   ("b", "score", UnitT),
                                   ("c", "score", UnitT)],
                                  [ConstructorP("a", UnitP), ConstructorP("d", UnitP)]) = NONE
val test13_7 = typecheck_patterns([("a", "score",UnitT),
                                   ("b", "score", UnitT),
                                   ("c", "score", UnitT)],
                                  [ConstructorP("a", UnitP), ConstructorP("b", ConstP 1)]) = NONE

val test13_8 = typecheck_patterns([], [ConstP 10, Variable "a"]) = SOME IntT
val test13_9 = typecheck_patterns([], [ConstP 10, Variable "a", ConstructorP("SOME", Variable "x")]) = NONE
val test13_10 = typecheck_patterns([], [TupleP[Variable "a", ConstP 10, Wildcard],
                                        TupleP[Variable "b", Wildcard, ConstP 11], Wildcard]) =
                SOME (TupleT[Anything, IntT, IntT])
val test13_11 = typecheck_patterns([("Red", "color", UnitT),("Green", "color", UnitT),("Blue", "color", UnitT)],
                                   [ConstructorP("Red", UnitP), Wildcard]) = SOME (Datatype "color")
val test13_12 = typecheck_patterns([("Sedan", "auto", Datatype "color"),
                                    ("Truck", "auto", TupleT[IntT,Datatype "color"]), ("SUV", "auto", UnitT)],
                                   [ConstructorP("Sedan", Variable "a"),
                                    ConstructorP("Truck", TupleP[Variable "b", Wildcard]),
                                    Wildcard]) = SOME (Datatype "auto")
val test13_13 = typecheck_patterns([("Empty", "list", UnitT), ("List", "list", TupleT[Anything, Datatype "list"])],
                                   [ConstructorP("Empty", UnitP),
                                    ConstructorP("List",TupleP[ConstP 10,ConstructorP("Empty", UnitP)]), Wildcard]) =
                SOME (Datatype "list")
                                   
val test13_14 = typecheck_patterns([("Empty", "list", UnitT), ("List", "list", TupleT[Anything, Datatype "list"])],
                                   [ConstructorP("Empty", UnitP),
                                    ConstructorP("List",TupleP[Variable "k",Wildcard])]) =
                SOME (Datatype "list")
val test13_15 = typecheck_patterns([("Sedan", "auto", Datatype "color"),
                                    ("Truck", "auto", TupleT[IntT,Datatype "color"]), ("SUV", "auto", UnitT),
                                    ("Empty", "list", UnitT), ("List", "list", TupleT[Anything, Datatype "list"])],
                                   [ConstructorP("Empty", UnitP),
                                    ConstructorP("List",TupleP[ConstructorP("Sedan", Variable "c"), Wildcard])]) =
                SOME (Datatype "list")


                     
