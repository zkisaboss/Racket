#lang racket

;; Project 0 Tic-tac-toe with Racket
;; Please immediately read README.md

(provide board?
         next-player
         valid-move?
         make-move
         winner?
         calculate-next-move)

;; Useful utility functions

;; Returns the number of elements in l for which the predicate f
;; evaluates to #t. For example:
;; (count (lambda (x) (> x 0)) '(-5 0 1 -3 3 4)) => 3
;; (count (lambda (x) (= x 0)) '(-5 0 1 -3 3 4)) => 1
;; This function is useful for later parts, especially winner?, where
;; you can use it to count if the length of the row is equal to the
;; number of elements in the row containing 'X (or 'O).
(define (count f l)
  (cond
    [(empty? l) 0]
    [(f (car l)) (add1 (count f (cdr l)))]
    [else (count f (cdr l))]))

;; (define (count-empty l) (count (lambda (x) (equal? x 'E)) l))
;; (count-empty '(E X E E O X X))

(define (andmap f lst)
  (cond
    [(empty? lst) #t]
    [(f (first lst)) (andmap f (rest lst))]
    [else #f]))

(define (ormap f lst)
  (cond
    [(empty? lst) #f]
    [(f (first lst)) #t]
    [else (ormap f (rest lst))]))

;; Checks if a number is a perfect square [helper]
(define (perfect-square? x)
  (integer? (sqrt x)))

;; Counts the number of elements in a list [helper]
(define (length l)
  (if (empty? l)
      0
      (+ 1 (length (cdr l)))))

;; Checks if a list contains only 'X', 'O', or 'E', returns a truthy value
(define (contains-only-XOE? b)
  (if (empty? b)
      #t
      (and (or (equal? (car b) 'X)
               (equal? (car b) 'O)
               (equal? (car b) 'E))
           (contains-only-XOE? (cdr b)))))

;; Check whether a list is a valid board
(define (board? b)
  (let ([x-count (count (lambda (x) (equal? x 'X)) b)]
        [o-count (count (lambda (x) (equal? x 'O)) b)])
    (and (not (empty? b))
         (perfect-square? (length b))
         (contains-only-XOE? b)
         (or (equal? x-count o-count)
             (equal? x-count (+ o-count 1))))))


;; From the board, calculate who is making a move this turn
(define (next-player board)
  (cond
    [(< (count (lambda (x) (equal? x 'O)) board)
        (count (lambda (x) (equal? x 'X)) board))
     'O]
    [else 'X]))

;; Returns the element at (col, row) in the board [helper]
(define (get-element b r c)
  (define s (sqrt (length b)))
  (define i (+ (* r s) c))
  (cond
    ;;Check for valid row and col indices
    [(or (empty? b)
         (< r 0)
         (< c 0)
         (> r (- s 1))
         (> c (- s 1)))
     #f]  ;; Return #f if out-of-bounds
    [else
     (list-ref b i)]))

;; Checks if the position is empty [helper]
(define (pos-empty? board row col)
  (equal? (get-element board row col) 'E))

;; If player ('X or 'O) wants to make a move, check whether it's this
;; player's turn and the position on the board is empty ('E)
(define (valid-move? b r c player)
  (and (board? b)
       (equal? (next-player b) player)
       (pos-empty? b r c)))

;; To make a move, replace the position at (row,col) with the player's symbol
(define (make-move board row col player)
  (let ([target-idx (+ (* (sqrt (length board)) row) col)])
    (list-set board target-idx player)))

;; Determine whether or not there is a winner
;; Hint: write a function to grab all rows, all columns, and the
;; diagonals. Then check if any of them (consider using `ormap`)
;; has the property that the count of cells with 'X (or 'O) is
;; equal to its length.

(define (rows b)
  (define s (sqrt (length b)))
  (define (h b)
    (cond
      [(empty? b) '()]
      [else
       (cons (take b s)
             (h (drop b s)))]))
  (h b))

(define (get-column b i)
  (define s (sqrt (length b)))
  (define l (range s))
  (map (lambda (x) (list-ref b (+ (* x s) i))) l))

(define (cols b)
  (define s (sqrt (length b)))
  (map (lambda (i) (get-column b i))
       (range s)))

(define (diag b)
  (define s (sqrt (length b)))
  (define l (range s))
  (list
    (map (lambda (i) (list-ref b (+ (* i s) i))) l)
    (map (lambda (i) (list-ref b (* (+ i 1) (- s 1)))) l)))

(define (x-wins? lines)
  (ormap
   (lambda (line)
     (andmap (lambda (x) (equal? x 'X)) line))
   lines))

(define (o-wins? lines)
  (ormap
   (lambda (line)
     (andmap (lambda (x) (equal? x 'O)) line))
   lines))

(define (winner? board)
  (cond
    [(or (x-wins? (rows board))
         (x-wins? (cols board))
         (x-wins? (diag board))) 'X]
    [(or (o-wins? (rows board))
         (o-wins? (cols board))
         (o-wins? (diag board))) 'O]
    [else #f]))

;; The board is a list containing E O X
;; Player will always be 'O
;; Returns a pair of x and y
(define (calculate-next-move board player)
  'todo)

;; (lambda (x) - x))
