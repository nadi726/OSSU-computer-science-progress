
(* this is in the global scope because its used in 2 seperate places *)
val days_in_each_month = [31,28,31,30,31,30,31,31,30,31,30,31] (* for a non-leap year *)

fun is_older (date1 : int*int*int, date2 : int*int*int) =
    let
        val y1 = #1 date1
        val y2 = #1 date2
        val m1 = #2 date1
        val m2 = #2 date2
        val d1 = #3 date1
        val d2 = #3 date2
    in
        (y1 < y2) orelse
        ((y1 = y2) andalso (m1 < m2)) orelse
        ((y1 = y2) andalso (m1 = m2) andalso (d1 < d2))
    end
        
fun number_in_month (dates : (int*int*int) list, month : int) =
    if null dates
    then 0
    else (if (#2 (hd dates) = month) then 1 else 0) +
         number_in_month(tl dates, month)

fun number_in_months (dates : (int*int*int) list, months : int list) =
    if null months
    then 0
    else number_in_month(dates, hd months) + number_in_months(dates, tl months)

fun dates_in_month (dates : (int*int*int) list, month : int) =
    if null dates
    then []
    else if #2 (hd dates) = month
    then (hd dates) :: dates_in_month(tl dates, month)
    else dates_in_month(tl dates, month)

fun dates_in_months (dates : (int*int*int) list, months: int list) =
    if null months
    then []
    else dates_in_month(dates, hd months) @ dates_in_months(dates, tl months)
                                                           
fun get_nth (xs : string list, n : int) =
    if n = 1
    then hd xs
    else get_nth(tl xs, n-1)

fun date_to_string (date : int*int*int) =
    let val month_names = ["January", "February", "March", "April", "May", "June",
                            "July", "August", "September", "October", "November", "December"]
        val month_name = get_nth(month_names, #2 date)
    in
        month_name ^ " " ^ Int.toString(#3 date) ^ ", " ^ Int.toString(#1 date)
    end

fun number_before_reaching_sum (sum : int, xs : int list) =
    if (hd xs) >= sum
    then 0
    else 1 + number_before_reaching_sum(sum-(hd xs), tl xs)

fun what_month (day_of_year : int) =
    number_before_reaching_sum(day_of_year, days_in_each_month) + 1

fun month_range (day1 : int, day2 : int) =
    if day1 > day2
    then []
    else what_month(day1) :: month_range (day1+1, day2)

fun oldest (dates : (int*int*int) list) =
    if null dates
    then NONE
    else let
        fun oldest_inner (dates : (int*int*int) list) =
            if null (tl dates)
            then hd dates
            else let val rest_ans = oldest_inner(tl dates)
                 in if is_older (hd dates, rest_ans)
                    then hd dates
                    else rest_ans
                 end
                     
    in SOME (oldest_inner (dates))
    end
             
(* helper functions for challenge problem 1 *)
fun is_member (x : int, xs : int list) =
    (* evaluates to true if x is in xs, false otherwise *)
    (not (null xs)) andalso ((x = hd xs) orelse is_member(x, tl xs))         
fun remove_duplicates (xs : int list) =
    if (null xs)
    then xs
    else let val rest_ans = remove_duplicates(tl xs)           
         in if is_member(hd xs, rest_ans)
            then rest_ans
            else (hd xs) :: rest_ans
         end
        
fun number_in_months_challenge (dates : (int*int*int) list, months : int list) =
    number_in_months (dates, remove_duplicates months)

fun dates_in_months_challenge (dates : (int*int*int) list, months: int list) =
    dates_in_months (dates, remove_duplicates months)

fun reasonable_date (date : int*int*int) =
    let
        val y = #1 date
        val m = #2 date
        val d = #3 date
        fun get_nth_int (xs : int list, n : int) =
            if n = 1
            then hd xs
            else get_nth_int(tl xs, n-1)
    in
        (* check year and month *)
        (y > 0) andalso
        ((m > 0) andalso (m < 13)) andalso

        (* check day. in a leap year, account for the extra day in the second month *)
        let val is_leap_year = ((y mod 400) = 0) orelse
                               (((y mod 4) = 0) andalso ((y mod 100) <> 0))
            val is_leap_day = is_leap_year andalso (m = 2)
            val max_day = (get_nth_int (days_in_each_month, m)) + (if is_leap_day then 1 else 0)
                                                                      
        in
            ((d > 0) andalso (d <= max_day))
        end
    end
