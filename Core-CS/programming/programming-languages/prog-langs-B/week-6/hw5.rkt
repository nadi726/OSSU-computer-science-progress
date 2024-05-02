;; Programming Languages, Homework 5

#lang racket
(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs but /is/ a MUPL value; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

;; Problem 1

;; a.
(define (racketlist->mupllist rlst)
  (if (null? rlst)
      (aunit)
      (apair (car rlst) (racketlist->mupllist (cdr rlst)))))
;; b.
(define (mupllist->racketlist mlst)
  (if (aunit? mlst)
      null
      (cons (apair-e1 mlst) (mupllist->racketlist (apair-e2 mlst)))))

;; Problem 2

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        [(or (int? e) (closure? e) (aunit? e)) e]
        [(fun? e) (closure env e)]
        [(ifgreater? e)
         (let ([v1 (eval-under-env (ifgreater-e1 e) env)]
               [v2 (eval-under-env (ifgreater-e2 e) env)])
           (cond [(not (and (int? v1)
                            (int? v2)))
                  (error "MUPL ifgreater applied to non-number")]
                 [(> (int-num v1) (int-num v2))
                  (eval-under-env (ifgreater-e3 e) env)]
                 [#t (eval-under-env (ifgreater-e4 e) env)]))]
        [(mlet? e) (let ([new-var (cons (mlet-var e)
                                        (eval-under-env (mlet-e e) env))])
                     (eval-under-env (mlet-body e)
                                     (cons new-var env)))]
        [(call? e)
         (let ([clos (eval-under-env (call-funexp e) env)]
               [arg-value (eval-under-env (call-actual e) env)])
           (if (not (closure? clos))
               (error "MUPL error: not a closure")
               (let* ([fn (closure-fun clos)]
                      [fn-name (fun-nameopt fn)]
                      [arg-pair (cons (fun-formal fn) arg-value)]
                      [env-with-arg (cons arg-pair (closure-env clos))]
                      [full-env (if fn-name
                                    (cons (cons fn-name clos) env-with-arg)
                                    env-with-arg)])
                 (eval-under-env (fun-body fn)
                                 full-env))))]
        [(apair? e)
         (let ([v1 (eval-under-env (apair-e1 e) env)]
               [v2 (eval-under-env (apair-e2 e) env)])
           (apair v1 v2))]
        [(fst? e)
         (let ([e-result (eval-under-env (fst-e e) env)])
           (if (apair? e-result)
               (apair-e1 e-result)
               (error "MUPL fst applied to non-pair")))]
        [(snd? e)
         (let ([e-result (eval-under-env (snd-e e) env)])
           (if (apair? e-result)
               (apair-e2 e-result)
               (error "MUPL snd applied to non-pair")))]        
        [(isaunit? e) (if (aunit? (eval-under-env (isaunit-e e) env))
                          (int 1) (int 0))]
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3

(define (ifaunit e1 e2 e3) (ifgreater (isaunit e1) (int 0) e2 e3))

(define (mlet* lstlst e2)
  (if (null? lstlst)
      e2
      (mlet (caar lstlst) (cdar lstlst)
            (mlet* (cdr lstlst) e2))))

(define (ifeq e1 e2 e3 e4)
  (mlet* (list (cons "_x" e1) (cons "_y" e2))
         (ifgreater (var "_x") (var "_y")
                    e4
                    (ifgreater (var "_y") (var "_x")
                               e4
                               e3))))

;; Problem 4

(define mupl-map
  (fun #f "proc"
       (fun "f" "lst"
            (ifaunit (var "lst")
                     (aunit)
                     (apair (call (var "proc") (fst (var "lst")))
                            (call (var "f") (snd (var "lst"))))))))

(define mupl-mapAddN 
  (mlet "map" mupl-map
        (fun #f "i"
             (call (var "map")
                   (fun #f "x"
                        (add (var "x") (var "i")))))))

;; Challenge Problem

(struct fun-challenge (nameopt formal body freevars) #:transparent) ;; a recursive(?) 1-argument function

;; We will test this function directly, so it must do
;; as described in the assignment
(define (compute-free-vars e)
  (define (f e)
    (cond [(var? e) (cons e (set (var-string e)))]
          [(add? e)
           (let ([r1 (f (add-e1 e))]
                 [r2 (f (add-e2 e))])
             (cons (add (car r1) (car r2))
                   (set-union (cdr r1) (cdr r2))))]
          [(or (int? e) (aunit? e)) (cons e (set))]
          [(fun? e) (let* ([body-r (f (fun-body e))]
                           [fvs (set-remove (set-remove (cdr body-r)
                                                        (fun-formal e)) (fun-nameopt e))])
                      (cons (fun-challenge (fun-nameopt e) (fun-formal e) (car body-r)
                                           fvs) fvs))]
          [(ifgreater? e)
           (let ([e1 (f (ifgreater-e1 e))]
                 [e2 (f (ifgreater-e2 e))]
                 [e3 (f (ifgreater-e3 e))]
                 [e4 (f (ifgreater-e4 e))])
             (cons (ifgreater (car e1) (car e2) (car e3) (car e4))
                   (set-union (cdr e1) (cdr e2) (cdr e3) (cdr e4))))]
          [(mlet? e) (let ([r-e (f (mlet-e e))]
                           [r-body (f (mlet-body e))])
                       (cons (mlet (mlet-var e) (car r-e) (car r-body))
                             (set-union (set-remove (cdr r-body) (mlet-var e))
                                        (cdr r-e))))]
          [(call? e) (let ([r-funexp (f (call-funexp e))]
                           [r-actual (f (call-actual e))])
                       (cons (call (car r-funexp) (car r-actual))
                             (set-union (cdr r-funexp) (cdr r-actual))))]
          [(apair? e) (let ([r1 (f (apair-e1 e))]
                            [r2 (f (apair-e2 e))])
                        (cons (apair (car r1) (car r2))
                              (set-union (cdr r1) (cdr r2))))]
          [(fst? e) (let ([r (f (fst-e e))])
                      (cons (fst (car r)) (cdr r)))]
          [(snd? e) (let ([r (f (snd-e e))])
                      (cons (snd (car r)) (cdr r)))]     
          [(isaunit? e) (let ([r (f (isaunit-e e))])
                          (cons (isaunit (car r)) (cdr r)))]
          ;; closure doesn't really need ro be accounted for,
          ;; its only created internally after running eval-under-env-c
          ))

  (car (f e)))

;; Do NOT share code with eval-under-env because that will make
;; auto-grading and peer assessment more difficult, so
;; copy most of your interpreter here and make minor changes
(define (eval-under-env-c e env)
  (cond [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        [(or (int? e) (closure? e) (aunit? e)) e]
        [(fun-challenge? e) (let* ([fvs (fun-challenge-freevars e)]
                                   [new-env (filter (lambda (var) (set-member? fvs var)) env)])
                              (closure (fun-challenge) new-env))]
        [(ifgreater? e)
         (let ([v1 (eval-under-env (ifgreater-e1 e) env)]
               [v2 (eval-under-env (ifgreater-e2 e) env)])
           (cond [(not (and (int? v1)
                            (int? v2)))
                  (error "MUPL ifgreater applied to non-number")]
                 [(> (int-num v1) (int-num v2))
                  (eval-under-env (ifgreater-e3 e) env)]
                 [#t (eval-under-env (ifgreater-e4 e) env)]))]
        [(mlet? e) (let ([new-var (cons (mlet-var e)
                                        (eval-under-env (mlet-e e) env))])
                     (eval-under-env (mlet-body e)
                                     (cons new-var env)))]
        [(call? e)
         (let ([clos (eval-under-env (call-funexp e) env)]
               [arg-value (eval-under-env (call-actual e) env)])
           (if (not (closure? clos))
               (error "MUPL error: not a closure")
               (let* ([fn (closure-fun clos)]
                      [fn-name (fun-challenge-nameopt fn)]
                      [arg-pair (cons (fun-challenge-formal fn) arg-value)]
                      [env-with-arg (cons arg-pair (closure-env clos))]
                      [full-env (if fn-name
                                    (cons (cons fn-name clos) env-with-arg)
                                    env-with-arg)])
                 (eval-under-env (fun-challenge-body fn)
                                 full-env))))]
        [(apair? e)
         (let ([v1 (eval-under-env (apair-e1 e) env)]
               [v2 (eval-under-env (apair-e2 e) env)])
           (apair v1 v2))]
        [(fst? e)
         (let ([e-result (eval-under-env (fst-e e) env)])
           (if (apair? e-result)
               (apair-e1 e-result)
               (error "MUPL fst applied to non-pair")))]
        [(snd? e)
         (let ([e-result (eval-under-env (snd-e e) env)])
           (if (apair? e-result)
               (apair-e2 e-result)
               (error "MUPL snd applied to non-pair")))]        
        [(isaunit? e) (if (aunit? (eval-under-env (isaunit-e e) env))
                          (int 1) (int 0))]
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; Do NOT change this
(define (eval-exp-c e)
  (eval-under-env-c (compute-free-vars e) null))
