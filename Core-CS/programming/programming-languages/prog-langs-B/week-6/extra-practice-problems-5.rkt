;; Programming Languages, Homework 5

#lang racket
(require "hw5.rkt")
(provide (all-defined-out)) ;; so we can put tests in a second file

;; Dynamic typing

;; 1.
(define (crazy-sum xs)
  (letrec ([f (lambda (xs0 sum op)
                (cond [(null? xs0) sum]
                      [(integer? (car xs0)) (f (cdr xs0) (op sum (car xs0)) op)]
                      [#t (f (cdr xs0) sum (car xs0))]))])
    (f xs 0 +)))

;; 3.
(define (flatten lst)
  (cond [(null? lst) null]
        [(list? (first lst)) (append (flatten (first lst))
                                     (flatten (rest lst)))]
        [#t (cons (first lst) (flatten (rest lst)))]))


;; Lambda calculus

;; 1.
(define (remove-lets e)
  (define (f e)
    (cond [(var? e) e]
          [(add? e) (add (f (add-e1 e)) (f (add-e2 e)))]
          [(or (int? e) (aunit? e)) e]
          [(fun? e) (fun (fun-nameopt e) (fun-formal e) (f (fun-body e)))]
          [(ifgreater? e)
           (let ([e1 (f (ifgreater-e1 e))]
                 [e2 (f (ifgreater-e2 e))]
                 [e3 (f (ifgreater-e3 e))]
                 [e4 (f (ifgreater-e4 e))])
             (ifgreater e1 e2 e3 e4))]
          [(call? e) (call (call-funexp e) (f (call-actual e)))]
          [(apair? e) (apair (f (apair-e1 e)) (f (apair-e2 e)))]
          [(fst? e) (fst (f (fst-e e)))]
          [(snd? e) (snd (f (snd-e e)))]  
          [(isaunit? e) (isaunit (f (isaunit-e e)))]
          [(mlet? e) (call (fun #f (mlet-var e) (f (mlet-body e))) (f (mlet-e e)))]
          ;; closure doesn't really need to be accounted for,
          ;; its only created internally after running eval-under-env-c
          ))
  (f e))

;; 2.
(define (remove-lets-and-pairs e)
  (define (f e)
    (cond [(var? e) e]
          [(add? e) (add (f (add-e1 e)) (f (add-e2 e)))]
          [(or (int? e) (aunit? e)) e]
          [(fun? e) (fun (fun-nameopt e) (fun-formal e) (f (fun-body e)))]
          [(ifgreater? e)
           (let ([e1 (f (ifgreater-e1 e))]
                 [e2 (f (ifgreater-e2 e))]
                 [e3 (f (ifgreater-e3 e))]
                 [e4 (f (ifgreater-e4 e))])
             (ifgreater e1 e2 e3 e4))]
          [(call? e) (call (call-funexp e) (f (call-actual e)))]
          [(isaunit? e) (isaunit (f (isaunit-e e)))]
          [(apair? e) (f (mlet "_x" (apair-e1 e)
                               (mlet "_y" (apair-e2 e)
                                     (fun #f "_f"
                                          (call (call (var "_f") (var "_x")) (var "_y"))))))]
          [(fst? e) (call (f (fst-e e)) (fun #f  "_x" (fun #f "_y" (var "_x"))))]
          [(snd? e) (call (f (snd-e e)) (fun #f  "_x" (fun #f "_y" (var "_y"))))]
          [(mlet? e) (call (fun #f (mlet-var e) (f (mlet-body e))) (f (mlet-e e)))]
          ;; closure doesn't really need to be accounted for,
          ;; its only created internally after running eval-under-env-c
          ))
  (f e))


;; More MUPL functions

;; 1.
(define mupl-all ;; only for lists of ints
  (fun "f" "lst"
       (ifaunit (var "lst") (int 1)
                (ifeq (fst (var "lst")) (int 1)
                      (call (var "f") (snd (var "lst")))
                      (int 0)))))

;; 2.
(define mupl-append
  (fun "f" "lst1"
       (fun #f "lst2"
            (ifaunit (var "lst1") (var "lst2")
                     (apair (fst (var "lst1"))
                            (call (call (var "f") (snd (var "lst1"))) (var "lst2")))))))

;; 3.
(define mupl-zip
  (fun "f" "lst1"
       (fun #f "lst2"
            (ifaunit (var "lst1") (aunit)
                     (ifaunit (var "lst2") (aunit)
                              (apair (apair (fst (var "lst1")) (fst (var "lst2")))
                                     (call (call (var "f") (snd (var "lst1")))
                                           (snd (var "lst2")))))))))

;; 4.
(define mupl-append2
  (fun "f" "lsts"
            (ifaunit (fst (var "lsts")) (snd (var "lsts"))
                     (apair (fst (fst (var "lsts")))
                            (call (var "f") (apair (snd (fst (var "lsts"))) (snd (var "lsts"))))))))

(define mupl-zip2
  (fun "f" "lsts"
            (ifaunit (fst (var "lsts")) (aunit)
                     (ifaunit (snd (var "lsts")) (aunit)
                              (apair (apair (fst (fst (var "lsts"))) (fst (snd (var "lsts"))))
                                     (call (var "f") (apair (snd (fst (var "lsts")))
                                                            (snd (snd (var "lsts"))))))))))

;; 5.
(define mupl-curry
  (fun #f "f"
       (fun #f "x"
            (fun #f "y"
                 (call (var "f") (apair (var "x") (var "y")))))))

;; 6.
(define mupl-uncurry
  (fun #f "f"
       (fun #f "pr"
            (call (call (var "f") (fst (var "pr"))) (snd (var "pr"))))))


;; More MUPL macros

;; 1.
(define (if-greater3 e1 e2 e3 e4 e5)
  (mlet* (list (cons "e1" e1) (cons "e2" e2) (cons "e3" e3)) ;; to evaluate e1,e2,e3 only once
         (ifgreater (var "e1") (var "e2")
                    (ifgreater (var "e2") (var "e3")
                               e4
                               e5)
                    e5)))

;; 2.
(define (call-curried e1 e2)
  (letrec ([f (lambda (rsf e2)
                (if (null? e2)
                    rsf
                    (f (call rsf (car e2)) (cdr e2))))])
    (f e1 e2)))