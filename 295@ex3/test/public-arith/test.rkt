#lang racket

(require "../../interp-ce.rkt")

(define prog
  '(+ (* 2 3) (- 5 1)))

(print (interp-ce prog))

(with-output-to-file "output"
                     (lambda ()
                       (print (interp-ce prog)))
                     #:exists 'replace)
