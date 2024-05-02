
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; 1.
(define (sequence low high stride)
  (if (> low high)
      empty
      (cons low (sequence (+ low stride) high stride))))

;; 2.
(define (string-append-map xs suffix)
  (map (lambda (x) (string-append x suffix)) xs))

;; 3.
(define (list-nth-mod xs n)
  (cond [(< n 0) (error "list-nth-mod: negative number")]
        [(null? xs) (error "list-nth-mod: empty list")]
        [#t (car (list-tail xs
                            (remainder n (length xs))))]))

;; 4.
(define (stream-for-n-steps s n)
  (if (= n 0)
      empty
      (let ([next (s)])
        (cons (car next) (stream-for-n-steps (cdr next) (- n 1))))))

;; 5.
(define funny-number-stream
  (letrec ([f (lambda (n)
                (cons (if (= (remainder n 5) 0) (- n) n)
                      (lambda () (f (+ n 1)))))])
    (lambda () (f 1))))

;; 6.
(define (dan-then-dog)
  (define (f dan/dog)
    (cons dan/dog
          (lambda () (f (if (string=? dan/dog "dan.jpg") "dog.jpg" "dan.jpg")))))
  (f "dan.jpg"))

;; 7.
(define (stream-add-zero s)
  (let ([next (s)])
    (lambda () (cons (cons 0 (car next))
                     (stream-add-zero (cdr next))))))

;; 8.
(define (cycle-lists xs ys)
  (letrec ([f (lambda (n)
                (cons (cons (list-nth-mod xs n)
                            (list-nth-mod ys n))
                      (lambda () (f (+ n 1)))))])
    (lambda () (f 0))))

;; 9.
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
(define (cached-assoc xs n)
  (let ([memo (make-vector n #f)]
        [next-slot 0])
    (lambda (v)
      (let ([cached (vector-assoc v memo)])
        (if cached
            cached
            (let ([ans (assoc v xs)])
              (and ans
                   (begin (vector-set! memo next-slot ans)
                          (set! next-slot (remainder (+ next-slot 1) n))
                          ans))))))))
             
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
