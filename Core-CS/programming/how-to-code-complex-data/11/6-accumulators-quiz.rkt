;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname accumulators-quiz) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;  PROBLEM 1:
;
;  Assuming the use of at least one accumulator,
;  design a function that consumes a list of strings,
;  and produces the length of the longest string in the list.
;


(check-expect (longest empty) 0)
(check-expect (longest (list "a" "b" "c")) 1)
(check-expect (longest (list "a" "bc")) 2)
(check-expect (longest (list "a" "bc" "de")) 2)
(check-expect (longest (list "a" "bc" "def")) 3)
(check-expect (longest (list "abc" "de" "f")) 3)
(check-expect (longest (list "abc" "def" "nopr" "ghi" "jklm")) 4)

(define (longest los)
  ;; acc is a result-so-far accumulator
  (local [(define (longest los rsf)
            (cond [(empty? los) rsf]
                  [else
                   (local [(define current-length (string-length (first los)))]
                     (if (> current-length rsf)
                         (longest (rest los) current-length)
                         (longest (rest los) rsf)))]))]
    (longest los 0)))


;  PROBLEM 2:
;
;  The Fibbonacci Sequence
;  https://en.wikipedia.org/wiki/Fibonacci_number
;  is the sequence 0, 1, 1, 2, 3, 5, 8, 13,...
;  where the nth element is equal to n-2 + n-1.
;
;  Design a function that given a list of numbers
;  at least two elements long,
;  determines if the list obeys the fibonacci rule,
;  n-2 + n-1 = n, for every
;  element in the list. The sequence does not
;  have to start at zero, so for
;  example, the sequence 4, 5, 9, 14, 23 would follow the rule.
(check-expect (fib? (list 0 0)) true)
(check-expect (fib? (list 5 110)) true)
(check-expect (fib? (list 5 110 115)) true)
(check-expect (fib? (list 0 1 1 2 3 5 8 13)) true)
(check-expect (fib? (list 1 1 2 3 5 8 13)) true)
(check-expect (fib? (list 0 1 1 2 3 8 13)) false)
(check-expect (fib? (list 4 5 9 14 23)) true)
(check-expect (fib? (list 4 5 9 13 24)) false)
(check-expect (fib? (list 5 7 12 19 32)) false)

(define (fib? lon)
  (local [(define (fib? lon n-1 n-2)
            (cond [(empty? lon) true]
                  [else
                   (and (= (+ n-1 n-2) (first lon))
                        (fib? (rest lon) (first lon) n-1))]))]
    
    (fib? (rest (rest lon)) (second lon) (first lon))))


;  PROBLEM 3:
;
;  Refactor the function below to make it tail recursive.
;; Natural -> Natural
;; produces the factorial of the given number
(check-expect (fact 0) 1)
(check-expect (fact 3) 6)
(check-expect (fact 5) 120)

#;
(define (fact n)
  (cond [(zero? n) 1]
        [else
         (* n (fact (sub1 n)))]))

(define (fact n)
  (local [(define (fact n rsf)
            (cond [(zero? n) rsf]
                  [else
                   (fact (sub1 n) (* n rsf))]))]
    (fact n 1)))


;  PROBLEM 4:
;
;  Recall the data definition for Region from the Abstraction Quiz. Use a worklist
;  accumulator to design a tail recursive function that counts the number of regions
;  within and including a given region.
;  So (count-regions CANADA) should produce 7

(define-struct region (name type subregions))
;; Region is (make-region String Type (listof Region))
;; interp. a geographical region

;; Type is one of:
;; - "Continent"
;; - "Country"
;; - "Province"
;; - "State"
;; - "City"
;; interp. categories of geographical regions

(define VANCOUVER (make-region "Vancouver" "City" empty))
(define VICTORIA (make-region "Victoria" "City" empty))
(define BC (make-region "British Columbia" "Province" (list VANCOUVER VICTORIA)))
(define CALGARY (make-region "Calgary" "City" empty))
(define EDMONTON (make-region "Edmonton" "City" empty))
(define ALBERTA (make-region "Alberta" "Province" (list CALGARY EDMONTON)))
(define CANADA (make-region "Canada" "Country" (list BC ALBERTA)))

#;
(define (fn-for-region r)
  (local [(define (fn-for-region r)
            (... (region-name r)
                 (fn-for-type (region-type r))
                 (fn-for-lor (region-subregions r))))

          (define (fn-for-type t)
            (cond [(string=? t "Continent") (...)]
                  [(string=? t "Country") (...)]
                  [(string=? t "Province") (...)]
                  [(string=? t "State") (...)]
                  [(string=? t "City") (...)]))

          (define (fn-for-lor lor)
            (cond [(empty? lor) (...)]
                  [else
                   (... (fn-for-region (first lor))
                        (fn-for-lor (rest lor)))]))]
    (fn-for-region r)))

(check-expect (count-regions VANCOUVER) 1)
(check-expect (count-regions VICTORIA) 1)
(check-expect (count-regions BC) 3)
(check-expect (count-regions CALGARY) 1)
(check-expect (count-regions EDMONTON) 1)
(check-expect (count-regions ALBERTA) 3)
(check-expect (count-regions CANADA) 7)

(define (count-regions r)
  (local [(define (fn-for-region r todo rsf)
         (fn-for-lor (append todo (region-subregions r)) (add1 rsf)))

          (define (fn-for-lor todo rsf)
            (cond [(empty? todo) rsf]
                  [else
                   (fn-for-region (first todo) (rest todo) rsf)]))]
    
    (fn-for-region r empty 0)))
