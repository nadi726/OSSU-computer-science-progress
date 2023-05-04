;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname booleans) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Booleans

; predicates - primitives or functions that producde a boolean value
; examples:
; comparing numbers
(require 2htdp/image)
(= 1 1)
(< 1 0)
(>= 3 4)

; comparing strings
(string=? "foo" "bar")

; comparing images width

(define I1 (rectangle 10 20 "solid" "red"))
(define I2 (rectangle 20 10 "solid" "blue"))
(< (image-width I1)
    (image-width I2))
