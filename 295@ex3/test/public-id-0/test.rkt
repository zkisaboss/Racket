#lang racket

(require "../../interp-ce.rkt")

(print (take (interp-ce '((lambda (x) x) (lambda (y) y))) 2))

(with-output-to-file "output"
                     (lambda ()
                       (print (take (interp-ce '((lambda (x) x) (lambda (y) y))) 2)))
                     #:exists 'replace)
