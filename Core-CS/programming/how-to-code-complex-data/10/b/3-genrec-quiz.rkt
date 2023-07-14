;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname genrec-quiz-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)

;  PROBLEM 1:
;
;  In the lecture videos we designed a function
; to make a Sierpinski triangle fractal.
;
;  Here is another geometric fractal that is made
; of circles rather than triangles:
;  Design a function to create this circle fractal of size n and colour c.

(define CUT-OFF 5)

;; Natural String -> Image
;; produce a circle fractal of size n and colour c
(check-expect (circle-fractal CUT-OFF "blue") (circle CUT-OFF "outline" "blue"))
(check-expect (circle-fractal (* 2 CUT-OFF) "blue") (overlay (circle (* 2 CUT-OFF) "outline" "blue")
                                                             (local [(define c/2 (circle CUT-OFF "outline" "blue"))]
                                                               (beside c/2 c/2))))

(define (circle-fractal n c)
  (if (>= CUT-OFF n) (circle n "outline" c)
      (local [(define frac (circle n "outline" c))
              (define frac/2 (circle-fractal (/ n 2) c))]
        (overlay frac
                 (beside frac/2 frac/2)))))


(require racket/list)
;  PROBLEM 2:
;
;  Below you will find some data definitions for a tic-tac-toe solver.
;
;  In this problem we want you to design a function that produces all
;  possible filled boards that are reachable from the current board.
;
;  In actual tic-tac-toe, O and X alternate playing. For this problem
;  you can disregard that. You can also assume that the players keep
;  placing Xs and Os after someone has won. This means that boards that
;  are completely filled with X, for example, are valid.
;
;  Note: As we are looking for all possible boards, rather than a winning
;  board, your function will look slightly
; different than the solve function
;  you saw for Sudoku in the videos, or the one for tic-tac-toe in the
;  lecture questions.
;
;; Value is one of:
;; - false
;; - "X"
;; - "O"
;; interp. a square is either empty
;  (represented by false) or has and "X" or an "O"
#;
(define (fn-for-value v)
  (cond [(false? v) (...)]
        [(string=? v "X") (...)]
        [(string=? v "O") (...)]))



;; Board is (listof Value)
;; a board is a list of 9 Values
(define B0 (list false false false
                 false false false
                 false false false))

(define B1 (list false "X"   "O"   ; a partly finished board
                 "O"   "X"   "O"
                 false false "X"))

(define B2 (list "X"  "X"  "O"     ; a board where X will win
                 "O"  "X"  "O"
                 "X" false "X"))

(define B3 (list "X" "O" "X"       ; a board where Y will win
                 "O" "O" false
                 "X" "X" false))


;; Board -> (listof Bpard)
;; produce all possible solution boards from bd

(check-expect (all-boards B1)
              (list (list "X" "X" "O"
                          "O" "X" "O"
                          "X" "X" "X")
                    (list "X" "X" "O"
                          "O" "X" "O"
                          "X" "O" "X")
                    (list "X" "X" "O"
                          "O" "X" "O"
                          "O" "X" "X")
                    (list "X" "X" "O"
                          "O" "X" "O"
                          "O" "O" "X")
                    (list "O" "X" "O"
                          "O" "X" "O"
                          "X" "X" "X")
                    (list "O" "X" "O"
                          "O" "X" "O"
                          "X" "O" "X")
                    (list "O" "X" "O"
                          "O" "X" "O"
                          "O" "X" "X")
                    (list "O" "X" "O"
                          "O" "X" "O"
                          "O" "O" "X")))

(check-expect (all-boards B2)
              (list (list "X"  "X"  "O"
                          "O"  "X"  "O"
                          "X"  "X"  "X")
                    (list "X"  "X"  "O"
                          "O"  "X"  "O"
                          "X"  "O"  "X")))
(check-expect (all-boards B3)
              (list (list "X" "O" "X"
                          "O" "O" "X"
                          "X" "X" "X")
                    (list "X" "O" "X"
                          "O" "O" "X"
                          "X" "X" "O")
                    (list "X" "O" "X"
                          "O" "O" "O"
                          "X" "X" "X")
                    (list "X" "O" "X"
                          "O" "O" "O"
                          "X" "X" "O")))

;(define (all-boards bd) empty) ;stub

(define (all-boards bd)
  (local [(define (fn-for-board bd)
            (if (full? bd)
                (list bd)
                (fn-for-lobd (fill-one bd))))

          (define (fn-for-lobd lobd)
            (if (empty? lobd) empty
                (append (fn-for-board (first lobd))
                        (fn-for-lobd (rest lobd)))))

          (define (full? bd)
            (= 0 (length (filter false? bd))))]

    (fn-for-board bd)))

;; Board -> Boolean
;; prodcue true if board is full

;; Board -> (listof Board) of size 2
;; fill the given board with the 2 possible next steps, going from upper-left to lower right
;; Assume: board is not full

(check-expect (fill-one B1) (list
                              (list "X" "X"   "O"
                                    "O"   "X"   "O"
                                    false false "X")
                              (list "O" "X"   "O"
                                    "O"   "X"   "O"
                                    false false "X")))
;(define (fill-one bd) empty)

(define (fill-one bd)
  (local [(define (find-first-empty bd)
            (if (false? (first bd)) 0
                (+ 1 (find-first-empty (rest bd)))))
          (define first-empty (find-first-empty bd))]

    (list (fill-square bd first-empty "X")
          (fill-square bd first-empty "O"))))



(define (fill-square bd p nv)
  (append (take bd p)
          (list nv)
          (drop bd (add1 p))))

 
;  PROBLEM 3:
;
;  Now adapt your solution to filter out the boards that are impossible if
;  X and O are alternating turns. You can continue to assume that they keep
;  filling the board after someone has won though.
;
;  You can assume X plays first, so all valid boards will have
; 5 Xs and 4 Os.
;
;  NOTE: make sure you keep a copy of your solution
; from problem 2 to answer
;  the questions on edX.

;; (listof Board) -> (listof Board)
;; filter solution boards to keep only possible boards
(check-expect (filter-boards (all-boards B2))
              (list (list "X"  "X"  "O"
                          "O"  "X"  "O"
                          "X"  "O"  "X")))
(define (filter-boards lobd)
  (filter possible? lobd))

;; Board -> Boolean
;; produce true if bd is a possible solution (has 5Xs and 4 Os)
(check-expect (possible? (list "X" "X" "O"
                               "O" "X" "O"
                               "X" "X" "X")) false)
(check-expect (possible? (list "X" "X" "O"
                               "O" "X" "O"
                               "X" "O" "X")) true)
(define (possible? bd)
  (= 5 (length (filter (lambda (x) (string=? "X" x)) bd))))
