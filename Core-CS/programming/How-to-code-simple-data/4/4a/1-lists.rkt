;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname lists) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)

empty ;empty list

(define L1 (cons "Flames" empty)) ; a list of 1 element
(cons "Leafs" (cons "Flames" empty)) ; a list of 2 elements

; lists contain only the values of the expressions that produce lists:
(cons (string-append "C" "anucks") empty) ; the expression is evaluated

; lists can have all kinds of values in them:
(define L2 (cons 10 (cons 9 (cons 10 empty)))) ; number values

(define L3 (cons (square 10 "solid" "blue")
      (cons (triangle 20 "solid" "green")
            empty)))                       ; image values


;; accessing list elements:
;; first - consumes list with at least 1 element and produce the first one
(first L1) ; >"Flames"
(first L2) ; >10
(first L3) ; >(square 10 "solid" "blue")

;; rest - consumes list with at least 1 element and produce a new list without the first one
(rest L1) ; >empty
(rest L2) ; >(cons 9 (cons 10 empty))
(rest L3) ; >(cons (triangle 20 "solid" "green") empty)

;; We can access every item of the list with those 2 primitives
;; For example, to get the second element of L2:
(first (rest L2)) ; >9

;; Finding out if a list is empty:
(empty? empty) ; >true
(empty? L1) ; >false