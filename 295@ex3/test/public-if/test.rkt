#lang racket

(require "../../interp-ce.rkt")

(define prog
  '(if #f
       1
       (if #f
           2
           3)))

(print (interp-ce prog))
(with-output-to-file "output"
                     (lambda ()
                       (print (interp-ce prog)))
                     #:exists 'replace)
