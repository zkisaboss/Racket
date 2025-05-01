#lang racket

(require "../../maps-match.rkt")

(displayln (add-n-using-map '(2 3 4) 2))
(displayln (add-n-using-map '(8 4 4) 5))
;; (pretty-print (filter zero? '(1 2 0 5 3 0 0 5 1 0 1 2 0 3)))
;; (pretty-print (filter even? '(1 2 0 5 3 0 0 5 1 0 1 2 0 3)))
;; (displayln (maxof '(-5 1 3 5 1 1 2 3 1 2 5 2 -5 6 3 1 4 4 3)))
;; (displayln (maxof '(17 -5  3 1 -5  5 2 -5 6 3 1 16 4 3)))
;; (displayln (maxof '(3 3 1 -5  5 20 -5 6 3 1 16 4 20 19)))
;; (render-hash (zeroes '(x y z a b c d e f)))
;; (render-hash (add-to-each (hash 'x 0 'y 1 'z 2) 3))
;; (render-hash (interpret-commands '((assign x 0) (assign y 1) (swap x y))))
;; (render-hash (interpret-commands '((assign x 1) (assign y 2) (assign z 3) (assign a 4)
;;                                                 (swap x y) (swap y z) (swap a x)
;;                                                 (add x y z) (add y z x)
;;                                                 (add y y y) (add y z z)
;;                                                 (swap x y) (swap x z) (swap z z))))

(with-output-to-file "output"
  (lambda ()
    (displayln (add-n-using-map '(2 3 4) 2))
    (displayln (add-n-using-map '(8 4 4) 5)))
  #:exists 'replace)
