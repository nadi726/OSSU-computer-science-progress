(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* problem 1 solutions *)

fun all_except_option (str, lst) =
    let fun helper (lst) =
            case lst of
                [] => []
              | x::xs => if same_string(str, x) then xs else x::helper(xs)
        val new_lst = helper lst

    in if lst = new_lst
       then NONE
       else SOME new_lst
    end
                           
fun get_substitutions1 (lst, str) =
    case lst of
        [] => []
      | x::xs => let val x' = (case all_except_option(str, x) of NONE => [] | SOME x' => x')
                 in x' @ get_substitutions1(xs, str)
                 end

fun get_substitutions2 (lst, str) =
    let fun helper (lst, acc) =
            case lst of
                [] => acc
              | x::xs => let val x' = (case all_except_option(str, x) of NONE => [] | SOME x' => x')
                         in helper(xs, acc @ x')
                         end
    in helper(lst, [])
    end

fun similar_names (lst, {first=f_name, middle=m_name, last=l_name}) =
    let val firsts = f_name::get_substitutions2 (lst, f_name)
        fun generate_fullnames (firsts) =
            case firsts of
                [] => []
              | f::firsts' => {first=f, middle=m_name, last=l_name}::(generate_fullnames firsts')
    in generate_fullnames firsts
    end
    
(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

(* problem 2 solutions *)

fun card_color crd =
    case crd of
        (Clubs, _) => Black
      | (Spades, _) => Black
      | (Diamonds, _) => Red
      | (Hearts, _) => Red

fun card_value crd =
    case crd of
        (_, Num n) => n
      | (_, Ace) => 11
      | _ => 10

fun remove_card (cs, c, e) =
    case cs of
        [] => raise e
      | c'::cs' => if c' = c then cs' else c'::remove_card(cs', c, e)

fun all_same_color lst =
    case lst of
        [] => true
      | c::[] => true
      | c1::(c2::cs) => (card_color c1 = card_color c2) andalso all_same_color (c2::cs)

fun sum_cards cs =
    let fun helper (cs, acc) =
            case cs of
                [] => acc
              | c::cs' => helper(cs', acc + (card_value c))
    in helper(cs, 0)
    end

fun score (held_cards, goal) =
    let val cards_sum = sum_cards held_cards
        val pre_score = if cards_sum > goal then 3 * (cards_sum - goal) else goal - cards_sum
    in
        if all_same_color held_cards
        then pre_score div 2
        else pre_score
    end
        
fun officiate (card_list, moves, goal) =
    let fun next_move (card_list, held_cards, moves) =
            case (card_list, moves) of
                (_, []) => score(held_cards, goal)
             |  (_, Discard(c)::moves') => next_move(card_list, remove_card(held_cards, c, IllegalMove), moves')
             | ([], Draw::moves') => score(held_cards, goal)
             | (c::card_list', Draw::moves') => if sum_cards(c::held_cards) > goal
                                                   then score(c::held_cards, goal)
                                                   else next_move(card_list', c::held_cards, moves')
    in next_move(card_list, [], moves)
    end

(* challenge problems *)

(* helpers for problem 1 *)
fun replace_ace cs =
    case cs of
        [] => []
      | (rnk, Ace)::cs' => (rnk, Num 1)::cs'
      | c::cs' => c::replace_ace(cs')
                                
fun smallest_sum held_cards =
    let val new_cards = replace_ace held_cards
        val current_sum = sum_cards held_cards
    in if held_cards = new_cards
       then current_sum
       else let val best_rest = smallest_sum new_cards
            in if current_sum < best_rest
               then current_sum
               else best_rest
            end
    end
        
fun score_challenge (held_cards, goal) =
    let val new_cards = replace_ace held_cards
        val current_score = score(held_cards, goal)
    in if held_cards = new_cards
       then current_score
       else let val best_rest = score_challenge(new_cards, goal)
            in if current_score < best_rest
               then current_score
               else best_rest
            end
    end    

fun officiate_challenge (card_list, moves, goal) =
    let fun next_move (card_list, held_cards, moves) =
            case (card_list, moves) of
                (_, []) => score_challenge(held_cards, goal)
             |  (_, Discard(c)::moves') => next_move(card_list, remove_card(held_cards, c, IllegalMove), moves')
             | ([], Draw::moves') => score_challenge(held_cards, goal)
             | (c::card_list', Draw::moves') => if smallest_sum(c::held_cards) > goal
                                                   then score_challenge(c::held_cards, goal)
                                                   else next_move(card_list', c::held_cards, moves')
    in next_move(card_list, [], moves)
    end

fun careful_player (card_list, goal) =
    let fun discard1_draw1_score0 (card_list, held_cards) =
            let fun helper (next_cards, prev_cards) =
                    case (card_list, next_cards) of
                        (_, []) => NONE
                      | ([], _) => NONE
                      | (c1::cs1, c2::cs2) => if score(prev_cards@(c1::cs2), goal) = 0
                                              then SOME (Discard(c2), Draw)
                                              else helper(cs2, c1::next_cards)
            in helper(held_cards, [])
            end

        fun helper (card_list, held_cards) =
            if score(held_cards, goal) = 0
            then []
            else case discard1_draw1_score0(card_list,held_cards) of
                     SOME (m1, m2) => [m1, m2]
                   | NONE => 
                     if goal > (sum_cards held_cards) + 10
                     then case card_list of
                              [] => [Draw]
                            | c::cs => Draw::helper(cs, c::held_cards)
                     else []
                              
    in helper(card_list, [])
    end
