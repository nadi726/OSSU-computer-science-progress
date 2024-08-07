(* Homework1 Simple Test *)
(* These are basic test cases. Passing these tests does not guarantee that your code will pass the actual homework grader *)
(* To run the test, add a new line to the top of this file: use "homeworkname.sml"; *)
(* All the tests should evaluate to true. For example, the REPL should say: val test1 = true : bool *)

use "hw1.sml";
(* FIX : oldest,
 *)
(*fun remove_duplicates (xs : int list) =
    (* helper function for challenge problem 1 *)
    let fun is_member (x : int, xs : int list) =
            (* evaluates to true if x is in xs, false otherwise *)
            if null xs
            then false
            else if x = (hd xs)
            then true
            else is_member (x, tl xs)
                           
        fun remove_duplicates_inner (xs1 : int list, xs2 : int list) =
            if null xs1
            then xs2
            else if is_member (hd xs1, xs2)
            then remove_duplicates_inner (tl xs1, xs2)
            else remove_duplicates_inner (tl xs1, xs2 @ [(hd xs1)]) *)
val test1 = is_older ((1,2,3),(2,3,4)) = true
val test1_2 = is_older ((1,1,1),(1,1,1)) = false
val test1_3 = is_older ((1,1,2),(1,1,3)) = true
val test1_4 = is_older ((1,2,1),(1,3,1)) = true
val test1_5 = is_older ((4,5,6),(2,3,4)) = false
val test1_6 = is_older((2012,2,28),(2011,3,31)) = false
                                               
val test2 = number_in_month ([(2012,2,28),(2013,12,1)],2) = 1
val test2_2 = number_in_month ([], 2) = 0
val test2_3 = number_in_month ([(2012,2,28),(2013,12,1)],3) = 0
                                            
val test3 = number_in_months ([(2012,2,28),(2013,12,1),(2011,3,31),(2011,4,28)],[2,3,4]) = 3
val test3_1 = number_in_months ([(2012,2,28),(2013,12,1),(2011,3,31),(2011,4,28)],[]) = 0
                                                                                               
val test4 = dates_in_month ([(2012,2,28),(2013,12,1)],2) = [(2012,2,28)]
val test4_1 = dates_in_month ([],2) = []
                                                               
val test5 = dates_in_months ([(2012,2,28),(2013,12,1),(2011,3,31),(2011,4,28)],[2,3,4]) = [(2012,2,28),(2011,3,31),(2011,4,28)]
val test5_1 = dates_in_months ([(2012,4,4)], []) = []

val test6 = get_nth (["hi", "there", "how", "are", "you"], 2) = "there"

val test7 = date_to_string (2013, 6, 1) = "June 1, 2013"

val test8 = number_before_reaching_sum (10, [1,2,3,4,5]) = 3
val test8_1 = number_before_reaching_sum (10, [5,4,3,2,1]) = 2

val test9 = what_month 70 = 3
val test9_1 = what_month 15 = 1
val test9_2 = what_month 365 = 12
val test9_3 = what_month 100 = 4

val test10 = month_range (31, 34) = [1,2,2,2]
val test10_1 = month_range (35, 34) = []

val test11 = oldest([(2012,2,28),(2011,3,31),(2011,4,28)]) = SOME (2011,3,31)
val test11_1 = oldest([(2011,3,31),(2011,4,28),(2012,2,28)]) = SOME (2011,3,31)
val test11_2 = oldest([(2012,2,28),(2011,4,28),(2011,3,31)]) = SOME (2011,3,31)
val test11_3 = oldest([]) = NONE

val test12_1 = remove_duplicates([]) = []
val test12_2 = remove_duplicates([1,3,5]) = [1,3,5]
val test12_3 = remove_duplicates([1,1,2]) = [1,2]
val test12_4 = remove_duplicates([3,4,5,6,5]) = [3,4,6,5]
val test12_5 = remove_duplicates([1,2,3,3]) = [1,2,3]

val test13 = number_in_months_challenge ([(2012,2,28),(2013,12,1),(2011,3,31),(2011,4,28)],[2,2,3,4,3,4,2]) = 3

val test14 = dates_in_months_challenge ([(2012,2,28),(2013,12,1),(2011,3,31),(2011,4,28)],[2,2,3,4,3,4,2]) = [(2011,3,31),(2011,4,28),(2012,2,28)]

val test15_1 = reasonable_date (2023, 7, 20) = true
val test15_2 = reasonable_date (0, 7, 20) = false
val test15_3 = reasonable_date (~2023, 7, 20) = false
val test15_4 = reasonable_date (2023, 13, 20) = false
val test15_5 = reasonable_date (2023, 0, 20) = false
val test15_6 = reasonable_date (2023, ~7, 20) = false
val test15_7 = reasonable_date (2023, 7, 31) = true
val test15_8 = reasonable_date (2023, 7, 32) = false
val test15_9 = reasonable_date (2023, 4, 0) = false
val test15_10 = reasonable_date (2023, 4, 31) = false
val test15_11 = reasonable_date (2023, 2, 28) = true
val test15_12 = reasonable_date (2023, 2, 29) = false
val test15_13 = reasonable_date (2021, 2, 29) = false
val test15_14 = reasonable_date (2020, 2, 29) = true
val test15_15 = reasonable_date (2020, 2, 30) = false
