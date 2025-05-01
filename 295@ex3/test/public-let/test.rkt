#lang racket

(require "../../interp-ce.rkt")


(define prog
  '(let ([x 5])
     (let ([y x])
       (let ([z (- x y)])
         (+ z (+ x y))))))

(print (interp-ce prog))
(with-output-to-file "output"
                     (lambda ()
                       (print (interp-ce prog)))
                     #:exists 'replace)
