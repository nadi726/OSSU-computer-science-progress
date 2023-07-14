;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname count-odd-even-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

;; count-odd-even-starter.rkt

; PROBLEM:
;
; Previously we have written functions to count the number
;of elements in a list. In this
; problem we want a function that produces separate
;counts of the number of odd and even
; numbers in a list, and we only want to traverse
;the list once to produce that result.
;
; Design a tail recursive function that produces
;the Counts for a given list of numbers.
; Your function should produce Counts, as defined
;by the data definition below.
;
; There are two ways to code this function,
;one with 2 accumulators and one with a single
; accumulator. You should provide both solutions.
;


(define-struct counts (odds evens))
;; Counts is (make-counts Natural Natural)
;; interp. describes the number of even and odd numbers in a list

(define C1 (make-counts 0 0)) ;describes an empty list
(define C2 (make-counts 3 2)) ;describes (list 1 2 3 4 5))

(check-expect (count empty) (make-counts 0 0))
(check-expect (count (list 1)) (make-counts 1 0))
(check-expect (count (list 2)) (make-counts 0 1))
(check-expect (count (list 1 2 3 4 5)) (make-counts 3 2))
(check-expect (count (list -1 -2 3 -4 5)) (make-counts 3 2))

;; using 1 accumulator
#;
(define (count lon0)
  ;; rsf is Counts; a result-so-far accumulator for both odd and even numbers counts
  (local [(define (count lon rsf)
            (cond [(empty? lon) rsf]
                  [(odd? (first lon))
                   (count (rest lon)
                          (make-counts (add1 (counts-odds rsf))
                                       (counts-evens rsf)))]
                  [(even? (first lon))
                   (count (rest lon)
                          (make-counts (counts-odds rsf)
                                       (add1 (counts-evens rsf))))]))]

    (count lon0 C1)))

;; using 2 accumulators
(define (count lon0)
  ;; odds is Natural; a result-so-far accumulator for sum of all odd numbers
  ;; evens is Natural; a result-so-far accumulator for sum of all even numbers
  (local [(define (count lon odds evens)
            (cond [(empty? lon) (make-counts odds evens)]
                  [else
                   (cond [(odd? (first lon)) (count (rest lon) (add1 odds) evens)]
                         [(even? (first lon)) (count (rest lon) odds (add1 evens))])]))]

    (count lon0 0 0)))