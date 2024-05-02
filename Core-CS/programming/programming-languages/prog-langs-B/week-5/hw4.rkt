
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; 1.
;; Int Int Int[1, ...] -> (listof Int)
;; produce a list of numbers from low to high, jumping up by stride at each number
;; don't include any result bigger than high

(define (sequence low high stride)
  (if (> low high)
      empty
      (cons low (sequence (+ low stride) high stride))))

;; 2.
;; (listof String) String -> (listof String)
;; append suffix to each element of xs

(define (string-append-map xs suffix)
  (map (lambda (x) (string-append x suffix)) xs))

;; 3.
;; (listof x) Number -> x
(define (list-nth-mod xs n)
  (cond [(< n 0) (error "list-nth-mod: negative number")]
        [(null? xs) (error "list-nth-mod: empty list")]
        [#t (car (list-tail xs
                            (remainder n (length xs))))]))

;; 4.
;; (Streamof x) Number -> (listof x)
;; produce a list of the first n values produced by s
(define (stream-for-n-steps s n)
  (if (= n 0)
      empty
      (let ([ans (s)])
        (cons (car ans) (stream-for-n-steps (cdr ans) (- n 1))))))

;; 5.
;; () -> (cons Int ())
;; a stream of all natural numbers, with numbers divisible by 5 negated
(define funny-number-stream
  (letrec ([f (lambda (n)
                (cons (if (= (remainder n 5) 0) (- n) n)
                      (lambda () (f (+ n 1)))))])
    (lambda () (f 1))))

;; 6.
;; () -> (cons String ())
;; a stream that alternates between "dan.jpg" and "dog.jpg", starting with "dan.jpg"
(define (dan-then-dog)
  (define (f dan/dog)
    (cons dan/dog
          (lambda () (f (if (string=? dan/dog "dan.jpg") "dog.jpg" "dan.jpg")))))
  (f "dan.jpg"))

;; 7.
;; (Streamof x) -> (streamof (cons Int x))
;; given a stream s, produce a new stream where each element x is replaced by (cons 0 x)
(define (stream-add-zero s)
  (let ([ans (s)])
    (lambda () (cons (cons 0 (car ans))
                     (stream-add-zero (cdr ans))))))

;; 8.
;; (listof x) (listof y) -> (Streamof (cons x y))
;; given lists xs and ys, produce a stream which elements
;; are pairs of elements of xs and ys cycled through independently of one another
(define (cycle-lists xs ys)
  (letrec ([f (lambda (n)
                (cons (cons (list-nth-mod xs n)
                            (list-nth-mod ys n))
                      (lambda () (f (+ n 1)))))])
    (lambda () (f 0))))

;; 9.
;; X (Vectorof X) -> (cons X Y) | False
;; produce the first element of vec which is a pair whose car matches v
;; skip elements that aren't pairs. if none is found produce false
(define (vector-assoc v vec)
  (letrec ([vec-len (vector-length vec)]
           [f (lambda (n)
                     (if (= n vec-len)
                         #f
                         (let ([current (vector-ref vec n)])
                           (cond [(not (pair? current)) (f (+ n 1))]
                                 [(equal? v (car current)) current]
                                 [#t (f (+ n 1))]))))])
    (f 0)))

;; 10.
;; (listof X) Int -> (X -> (cons X Y) | false)
;; given a list xs, return a function that returns the same thing as (assoc v xs)
;; and has a cache of n recent results
(define (cached-assoc xs n)
  (letrec ([memo (make-vector n #f)]
           [next-slot 0]
           [f (lambda (v)
                (let ([cached (vector-assoc v memo)])
                  (if cached
                      cached
                      (let ([ans (assoc v xs)])
                        (if ans
                            (begin (vector-set! memo next-slot ans)
                                   (set! next-slot (remainder (+ next-slot 1) n))
                                   ans)
                            #f)))))])
    f))

;; 11.
(define-syntax while-less
  (syntax-rules (do)
    [(while-less e1 do e2)
     (letrec ([e1r e1]
              [th (lambda ()
                    (if (> e1r e2)
                        (th)
                        #t))])
       (th))]))
