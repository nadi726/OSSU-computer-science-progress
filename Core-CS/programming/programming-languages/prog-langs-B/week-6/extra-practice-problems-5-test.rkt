#lang racket
;; Programming Languages Homework 5 Simple Test
;; Save this file to the same directory as your homework file
;; These are basic tests. Passing these tests does not guarantee that your code will pass the actual homework grader

;; Be sure to put your homework file in the same folder as this test file.
;; Uncomment the line below and, if necessary, change the filename
(require "extra-practice-problems-5.rkt")
(require "hw5.rkt")

(require rackunit)

(define tests
  (test-suite
   "Sample tests for Extra practice problems"

   ;; =====================
   ;; Dynamic typing
   
   (check-equal? (crazy-sum (list 1 2 3)) 6 "crazy sum test")
   (check-equal? (crazy-sum (list 1 2 3 /)) 6 "crazy sum test")
   (check-equal? (crazy-sum (list 1 2 3 / 3)) 2 "crazy sum test")
   (check-equal? (crazy-sum (list 10 * 6 / 5 - 3)) 9 "crazy sum test")

   ;; Flatten
   (check-equal? (flatten '()) '() "flatten test")
   (check-equal? (flatten '(1 2 3 4)) '(1 2 3 4) "flatten test")
   (check-equal? (flatten (list 1 2 (list (list 3 4) 5 (list (list 6) 7 8)) 9 (list 10)))
                 (list 1 2 3 4 5 6 7 8 9 10) "flatten test")

   ;; ======================
   ;; Lambda calculus

   ;; remove-lets
   (check-equal? (remove-lets (int 5)) (int 5) "remove-lets test")
   (check-equal? (remove-lets (mlet "x" (int 5) (add (var "x") (int 1))))
                 (call (fun #f "x" (add (var "x") (int 1))) (int 5)) "remove-lets test")
   (check-equal? (remove-lets (apair (aunit) (mlet "x" (int 5) (add (var "x") (int 1)))))
                 (apair (aunit) (call (fun #f "x" (add (var "x") (int 1))) (int 5))) "remove-lets test")

   ;; remove-lets-and-pairs
   (check-equal? (remove-lets-and-pairs (int 5)) (int 5) "remove-lets-and-pairs test")
   (check-equal? (remove-lets-and-pairs (mlet "x" (int 5) (add (var "x") (int 1))))
                 (call (fun #f "x" (add (var "x") (int 1))) (int 5)) "remove-lets-and-pairs test")
   (check-equal? (remove-lets-and-pairs (apair (int 1) (int 2)))
                 (call (fun #f "_x"
                            (call (fun #f "_y"
                                          (fun #f "_f" (call (call (var "_f") (var "_x")) (var "_y")))) (int 2)))
                       (int 1))
                 "remove-lets-and-pairs test")
   (check-equal? (remove-lets-and-pairs (fst (snd (var "x"))))
                 (call (call (var "x") (fun #f  "_x" (fun #f "_y" (var "_y"))))
                       (fun #f  "_x" (fun #f "_y" (var "_x"))))
                 "remove-lets-and-pairs test")

   ;; mupl-all
   (check-equal? (eval-exp (call mupl-all (aunit))) (int 1) "mupl-all test")
   (check-equal? (eval-exp (call mupl-all (racketlist->mupllist (list (int 1) (int 1) (int 1)))))
                 (int 1) "mupl-all test")
   (check-equal? (eval-exp (call mupl-all (racketlist->mupllist (list (int 4) (int 1) (int 1)))))
                 (int 0) "mupl-all test")
   (check-equal? (eval-exp (call mupl-all (racketlist->mupllist (list (int 1) (int 0) (int 1)))))
                 (int 0) "mupl-all test")

   ;; mupl-append
   (check-equal? (eval-exp (call (call mupl-append (aunit)) (aunit))) (aunit)
                 "mupl-append test")
   (check-equal? (eval-exp (call (call mupl-append (aunit)) (apair (int 4) (aunit))))
                 (apair (int 4) (aunit)) "mupl-append test")
   (check-equal? (eval-exp (call (call mupl-append (apair (int 4) (aunit))) (aunit)))
                 (apair (int 4) (aunit)) "mupl-append test")
   (check-equal? (eval-exp (call (call mupl-append (racketlist->mupllist (list (int 1) (int 2) (int 3))))
                                 (racketlist->mupllist (list (int 4) (int 5) (int 6)))))
                 (racketlist->mupllist (list (int 1) (int 2) (int 3) (int 4) (int 5) (int 6))) "mupl-append test")

   ;; mupl-zip
   (check-equal? (eval-exp (call (call mupl-zip (racketlist->mupllist (list (int 1) (int 2) (int 3))))
                                 (racketlist->mupllist (list (int 4) (int 5) (int 6)))))
                 (racketlist->mupllist (list (apair (int 1) (int 4)) (apair (int 2) (int 5))
                                             (apair (int 3) (int 6)))) "mupl-zip test")
   (check-equal? (eval-exp (call (call mupl-zip (racketlist->mupllist (list (int 1) (int 2) (int 3))))
                                 (racketlist->mupllist (list (int 4) (int 5)))))
                 (racketlist->mupllist (list (apair (int 1) (int 4)) (apair (int 2) (int 5)))) "mupl-zip test")

   ;; mupl-append & mupl-zip, apair-form
   (check-equal? (eval-exp (call mupl-append2 (apair (apair (int 4) (aunit)) (aunit))))
                 (apair (int 4) (aunit)) "mupl-append2 test")
   (check-equal? (eval-exp (call mupl-append2 (apair (racketlist->mupllist (list (int 1) (int 2) (int 3)))
                                                    (racketlist->mupllist (list (int 4) (int 5) (int 6))))))
                 (racketlist->mupllist (list (int 1) (int 2) (int 3) (int 4) (int 5) (int 6))) "mupl-append2 test")
   (check-equal? (eval-exp (call mupl-zip2 (apair (racketlist->mupllist (list (int 1) (int 2) (int 3)))
                                                  (racketlist->mupllist (list (int 4) (int 5) (int 6))))))
                 (racketlist->mupllist (list (apair (int 1) (int 4)) (apair (int 2) (int 5))
                                             (apair (int 3) (int 6)))) "mupl-zip2 test")

   ;; mupl-curry
   (check-equal? (eval-exp (call (call (call mupl-curry mupl-append2) (racketlist->mupllist (list (int 1) (int 2) (int 3))))
                                 (racketlist->mupllist (list (int 4) (int 5) (int 6)))))
                 (racketlist->mupllist (list (int 1) (int 2) (int 3) (int 4) (int 5) (int 6))) "mupl-curry test")

   ;; mupl-uncurry
   (check-equal? (eval-exp (call (call mupl-uncurry mupl-zip) (apair (racketlist->mupllist (list (int 1) (int 2) (int 3)))
                                                  (racketlist->mupllist (list (int 4) (int 5) (int 6))))))
                 (racketlist->mupllist (list (apair (int 1) (int 4)) (apair (int 2) (int 5))
                                             (apair (int 3) (int 6)))) "mupl-uncurry test")

   ;; ======================
   ;; More MUPL macros
   
   ;; if-greater3
   (check-equal? (eval-exp (if-greater3 (int 3) (int 2) (int 1) (int 10) (var "x")))
                 (int 10) "if-greater3 test")
   (check-equal? (eval-exp (if-greater3 (int 3) (int 1) (int 1) (var "x") (int 10)))
                 (int 10) "if-greater3 test")

   ;; call-curried
   (check-equal? (call-curried (var "x") (list (int 1) (int 2) (int 3)))
                 (call (call (call (var "x") (int 1)) (int 2)) (int 3))
                 "call-curried test") 

   ))

(require rackunit/text-ui)
;; runs the test
(run-tests tests)
