(* Homework2 Simple Test *)
(* All the tests should evaluate to true. For example, the REPL should say: val test1 = true : bool *)
use "hw2.sml";

val test1 = all_except_option ("string", ["string"]) = SOME []
val test1_1 = all_except_option ("string", []) = NONE
val test1_2 = all_except_option ("string", ["hey"]) = NONE
val test1_3 = all_except_option ("string", ["string","hey","bye"]) = SOME ["hey","bye"]
val test1_4 = all_except_option ("string", ["hey","string","bye"]) = SOME ["hey","bye"]
val test1_5 = all_except_option ("string", ["hey","bye","string"]) = SOME ["hey","bye"]
                                                            
val test2_1 = get_substitutions1 ([["foo"],["there"]], "foo") = []
val test2_2 = get_substitutions1 ([], "foo") = []
val test2_3 = get_substitutions1 ([["foo", "bar"],["there"]], "foo") = ["bar"]
val test2_4 = get_substitutions1([["Fred","Fredrick"],["Elizabeth","Betty"],
                                ["Freddie","Fred","F"]],"Fred") = ["Fredrick","Freddie","F"]
val test2_5 = get_substitutions1([["Fred","Fredrick"],["Jeff","Jeffrey"],
                                ["Geoff","Jeff","Jeffrey"]],"Jeff") = ["Jeffrey","Geoff","Jeffrey"]
                                                                          
val test3_1 = get_substitutions2 ([["foo"],["there"]], "foo") = []
val test3_2 = get_substitutions2 ([], "foo") = []
val test3_3 = get_substitutions2 ([["foo", "bar"],["there"]], "foo") = ["bar"]
val test3_4 = get_substitutions2([["Fred","Fredrick"],["Elizabeth","Betty"],
                                ["Freddie","Fred","F"]],"Fred") = ["Fredrick","Freddie","F"]
val test3_5 = get_substitutions2([["Fred","Fredrick"],["Jeff","Jeffrey"],
                                ["Geoff","Jeff","Jeffrey"]],"Jeff") = ["Jeffrey","Geoff","Jeffrey"]

val test4 = similar_names ([["Fred","Fredrick"],["Elizabeth","Betty"],["Freddie","Fred","F"]], {first="Fred", middle="W", last="Smith"}) =
	    [{first="Fred", last="Smith", middle="W"}, {first="Fredrick", last="Smith", middle="W"},
	     {first="Freddie", last="Smith", middle="W"}, {first="F", last="Smith", middle="W"}]
val test4_1 = similar_names ([], {first="Fredrick", last="Smith", middle="W"}) =
              [{first="Fredrick", last="Smith", middle="W"}]

val test5_1 = card_color (Clubs, Num 2) = Black
val test5_2 = card_color (Spades, Queen) = Black
val test5_3 = card_color (Diamonds, Jack) = Red
val test5_4 = card_color (Hearts, Num 7) = Red

val test6_1 = card_value (Clubs, Num 2) = 2
val test6_2 = card_value (Clubs, Ace) = 11
val test6_3 = card_value (Clubs, Queen) = 10

val test7_1 = remove_card ([(Hearts, Ace)], (Hearts, Ace), IllegalMove) = []
val test7_2 = remove_card ([(Hearts, Ace), (Hearts, Num 4), (Hearts, Ace)], (Hearts, Ace), IllegalMove) = [(Hearts, Num 4), (Hearts, Ace)]
val test7_3 = ((remove_card ([], (Hearts, Ace), IllegalMove)) handle IllegalMove => [(Hearts, Num 15)]) = [(Hearts, Num 15)]

val test8_1 = all_same_color [] = true
val test8_2 = all_same_color [(Hearts, Ace), (Hearts, Ace)] = true
val test8_3 = all_same_color [(Hearts, Ace), (Diamonds, Ace)] = true
val test8_4 = all_same_color [(Hearts, Ace), (Clubs, Ace)] = false
val test8_5 = all_same_color [(Hearts, Ace), (Hearts, Ace), (Spades, Ace)] = false

val test9_1 = sum_cards [] = 0
val test9_2 = sum_cards [(Clubs, Num 2),(Clubs, Num 2)] = 4

val test10_1 = score ([(Hearts, Num 2),(Clubs, Num 4)],10) = 4
val test10_2 = score([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 16) = 1
val test10_3 = score([(Hearts, Num 3), (Diamonds, Num 6), (Spades, Num 5)], 10) = 12
val test10_4 = score([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 10) = 6
val test10_5 = score([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 14) = 0
                                                                                                                    
                                                                                  

val test11 = officiate ([(Hearts, Num 2),(Clubs, Num 4)],[Draw], 15) = 6

val test12 = officiate ([(Clubs,Ace),(Spades,Ace),(Clubs,Ace),(Spades,Ace)],
                        [Draw,Draw,Draw,Draw,Draw],
                        42)
             = 3

val test13 = ((officiate([(Clubs,Jack),(Spades,Num(8))],
                         [Draw,Discard(Hearts,Jack)],
                         42);
               false) (* throw away the function evaluation and produce type bool, then check if it handles error
                         (which it should raise anyway) *)
              handle IllegalMove => true)
             
             
val test14_1 = score_challenge([(Hearts, Ace)], 11) = 0
val test14_2 = score_challenge([(Hearts, Ace), (Spades, Num 9)], 11) = 1
val test14_3 = score_challenge ([(Hearts, Num 2),(Clubs, Num 4)],10) = 4
val test14_4 = score_challenge([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 16) = 1
val test14_5 = score_challenge([(Hearts, Num 3), (Diamonds, Num 6), (Spades, Num 5)], 10) = 12
val test14_6 = score_challenge([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 10) = 6
val test14_7 = score_challenge([(Hearts, Num 3), (Diamonds, Num 6), (Hearts, Num 5)], 14) = 0

val test15_1 = officiate_challenge ([(Hearts, Num 2),(Clubs, Num 4)],[Draw], 15) = 6

val test15_2 = officiate_challenge ([(Clubs,Ace),(Spades,Ace),(Clubs,Ace),(Spades,Ace)],
                        [Draw,Draw,Draw,Draw,Draw],
                        42)
             = 3

val test15_3 = ((officiate_challenge([(Clubs,Jack),(Spades,Num(8))],
                         [Draw,Discard(Hearts,Jack)],
                         42);
               false) (* throw away the function evaluation and produce type bool, then check if it handles error
                         (which it should raise anyway) *)
              handle IllegalMove => true)                                                                   
val test15_4 = officiate_challenge ([(Clubs,Ace),(Spades,Ace),(Clubs,Ace),(Spades,Ace)],
                        [Draw,Draw,Draw,Draw,Draw],
                        18)
               = 2
                     
val test16_1 = careful_player([(Clubs, Num 5)], 10) = []
val test16_2 = careful_player([], 11) = [Draw]
val test16_3 = careful_player([(Clubs, Num 5), (Spades, Num 3), (Hearts, Num 9)], 16) = [Draw, Draw]
val test16_4 = careful_player([(Clubs, Ace)], 11) = [Draw]
val test16_5 = careful_player([(Clubs, Num 6),(Spades, Num 1), (Hearts, Ace)], 17) = [Draw, Draw, Discard(Spades, Num 1), Draw]
val test16_6 = careful_player([(Clubs, Ace), (Spades, Ace)], 11) = [Draw]
                                               
