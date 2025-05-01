#lang racket

(provide church-compile
         church->nat
         church->bool
         church->listof)

;; === Church Booleans ===
(define church:true  '(lambda (x) (lambda (y) x)))
(define church:false '(lambda (x) (lambda (y) y)))
;; === Boolean Operations ===
(define church:not `(lambda (b) ((b ,church:false) ,church:true)))
(define church:and '(lambda (p) (lambda (q) ((p q) p))))
;; === Church Numerals ===
(define church:add1 '(lambda (n) (lambda (f) (lambda (x) (f ((n f) x))))))
(define church:sub1 '(lambda (n) (lambda (f) (lambda (x) (((n (lambda (g) (lambda (h) (h (g f))))) (lambda (u) x)) (lambda (u) u))))))
(define church:+ `(lambda (m) (lambda (n) ((n ,church:add1) m))))
(define church:- `(lambda (m) (lambda (n) ((n ,church:sub1) m))))
(define church:* '(lambda (m) (lambda (n) (lambda (f) (lambda (x) ((m (n f)) x))))))
;; === Comparisons ===
(define church:zero? `(lambda (n) ((n (lambda (_) ,church:false)) ,church:true)))
(define church:= `(lambda (m) (lambda (n) ((,church:and (,church:zero? ((,church:- m) n))) (,church:zero? ((,church:- n) m))))))
;; === Church Pairs (Lists) ===
(define church:cons '(lambda (a) (lambda (b) (lambda (c) (lambda (n) ((c a) b))))))
(define church:car '(lambda (p) ((p (lambda (a) (lambda (d) a))) (lambda () (lambda (x) x)))))
(define church:cdr '(lambda (p) ((p (lambda (a) (lambda (d) d))) (lambda () (lambda (x) x)))))
(define church:null? `(lambda (p) ((p (lambda (a) (lambda (d) ,church:false))) ,church:true)))

;; The Y combinator (technically a CBV Y combinator)
(define Y-comb
  '((lambda (u) (u u))
    (lambda (y)
      (lambda (mk)
        (mk (lambda (x) (((y y) mk) x)))))))

;; === Church Primitives ===
(define prims
  (hash
   'Y     Y-comb
   'not   church:not
   'add1  church:add1
   'sub1  church:sub1
   '+     church:+
   '-     church:-
   '*     church:*
   'zero? church:zero?
   'null? church:null?
   '=     church:=
   'cons  church:cons
   'car   church:car
   'cdr   church:cdr))

(define (λ-expr? e)
  (match e
    [(? symbol? x) #t]
    [`(lambda (,(? symbol? x)) ,(? λ-expr? e-b)) #t]
    [`(,(? λ-expr? e0) ,(? λ-expr? e1)) #t]
    [_ #f]))

;; === Compiler ===
(define (churchify e)
  (-> any/c λ-expr?)
  ;;(pretty-print e)
  (match e
    [(or (quote '()) '() `'())  '(lambda (f) (lambda (x) x))]

    [#t '(lambda (x) (lambda (y) x))]
    [#f '(lambda (x) (lambda (y) y))]
    [`(if ,c ,t ,f) `(((,(churchify c) (lambda () ,(churchify t))) (lambda () ,(churchify f))))]
    [`(and) (churchify #t)]
    [`(and ,e0 ,@rest) (churchify `(if ,e0 (and ,@rest) #f))]
    [`(or) (churchify #f)]
    [`(or ,e0 ,@rest) (churchify `(if ,e0 #t (or ,@rest)))]
    
    [`(quote ,x) (churchify x)]

    [(? exact-nonnegative-integer? n)
     `(lambda (f) (lambda (x)
                    ,(for/fold ([r 'x]) ([i (in-range n)])
                       `(f ,r))))]


    [`(let ([,xs ,es] ...) ,body)
     `((lambda ,xs ,(churchify body)) ,@(map churchify es))]
    [`(let* () ,body) (churchify body)]
    [`(let* ([,x ,e0] ,rest ...) ,body)
     (churchify `(let ([,x ,e0]) (let* ,rest ,body)))]
    [`(lambda (,args ...) ,body)
     (foldr (λ (a b) `(lambda (,a) ,b))
            (churchify body)
            args)]
    [`(letrec [(,f ,lam)] ,body)
     (churchify `(let ([,f (Y (lambda (,f) ,lam))]) ,body))]
    [(? symbol? x) (hash-ref prims x x)]
    #;
    [`(,f ,arg0 ,args ...)
     (foldl (λ (a acc) `(,acc ,(churchify a)))
            (churchify f)
            (cons arg0 args))]
    [(list* f args)
     (foldl (λ (arg acc) `(,acc ,(churchify arg)))
            (churchify f)
            args)]
    [(? procedure?) (error "[ERROR] churchify cannot process a procedure: ~a" e)]
    [_ (error 'churchify (format "Unhandled input: ~s" e))]))


(define (church-compile prog)
  ;; Wrap the program in a let binding of all primitives for Church encoding
  ;; This ensures all symbols like +, *, etc. are scoped and available
  #;
  (churchify
   `(let ([Y     ,Y-comb]
          [not   ,church:not]
          [add1  ,church:add1]
          [sub1  ,church:sub1]
          [+     ,church:+]
          [-     ,church:-]
          [*     ,church:*]
          [zero? ,church:zero?]
          [null? ,church:null?]
          [=     ,church:=]
          [cons  ,church:cons]
          [car   ,church:car]
          [cdr   ,church:cdr])
      ,prog))
  (churchify prog))

;; === Test Suite ===
(define test-cases
  ;; Format: (input expected type)
  (list
   ;; === Booleans ===
   ;;'(#t        #t  bool)
   ;;'(#f        #f  bool)
   ;;'((not #t)  #f  bool)
   ;;'((not #f)  #t  bool)
   ;'((if (not #f) 4 (let ([U (lambda (u) (u u))]) (U U))) 4 nat)
  
   ;; === Numbers ===
   ;;'(0         0   nat)
   ;;'(1         1   nat)
   ;;'(3         3   nat)

   ;; === If expressions ===
   ;;'((if #t 1 2) 1   nat)
   ;;'((if #f 1 2) 2   nat)
   ;;'((if (zero? 0) 5 6) 5 nat)
   ;;'((if (zero? 1) 5 6) 6 nat)

   ;; === and ===
   ;;'((and)       #t  bool)
   ;;'((and #t)    #t  bool)
   ;;'((and #f)    #f  bool)
   ;;'((and #t #t) #t  bool)
   ;;'((and #t #f) #f  bool)
   ;;'((and #f #t) #f  bool)

   ;; === or ===
   ;;'((or)        #f  bool)
   ;;'((or #f)     #f  bool)
   ;;'((or #t)     #t  bool)
   ;;'((or #f #t)  #t  bool)
   ;;'((or #f #f)  #f  bool)
   ;;'((or #t #f)  #t  bool)

   ;; === Lambda ===
   ;;'(((lambda (_) 5) #f) 5 nat)
   ;;'(((lambda (x) x) 1)  1 nat)

   ;; === Variables ===
   ;;'((let ([x 1]) x) 1 nat)

   ;; === Arithmetic Primitives ===
   ;;'((add1 0)    1   nat)
   ;;'((add1 1)    2   nat)
   ;;'((sub1 1)    0   nat)
   ;;'((sub1 3)    2   nat)
   ;;'((zero? 0)   #t  bool)
   ;;'((zero? 1)   #f  bool)

   ;; === Application (+) ===
   ;;'((+ 0 0)     0   nat)
   ;;'((+ 1 0)     1   nat)
   ;; Nesting and associativity
   ;;'((+ (+ 1 2) 3)       6 nat)
   ;;'((+ 1 (+ 2 (+ 3 3))) 9 nat)
   ;;'((+ (+ 1 1) (+ 2 2)) 6 nat)
   ;; === Application (*) ===
   ;;'((* 0 5)     0   nat)
   ;;'((* 5 0)     0   nat)
   ;;'((* 1 5)     5   nat)
   ;;'((* 5 1)     5   nat)
   ;;'((* 2 3)     6   nat)
   ;;'((* 3 4)    12   nat)

   ;; === Application (-) ===
   ;;'((- 1 0)     1   nat)
   ;;'((- 1 1)     0   nat)
   ;;'((- 4 2)     2   nat)
   ;;'((- 5 3)     2   nat)
   ;; Note: Church subtraction yields 0 for m<n
   ;;'((- 2 4)     0   nat)

   ;; === Application (=) ===
   ;;'((= 0 0)     #t  bool)
   ;;'((= 3 3)     #t  bool)
   ;;'((= 3 2)     #f  bool)
   ;;'((= 2 3)     #f  bool)

   ;; === let ===
   ;;'((let ([x 1]) x)             1 nat)
   ;;'((let ([x 1] [y 2]) (+ x y)) 3 nat)
   ;; More complex let
   ;;'((let ([a 2] [b 3]) (* a b)) 6 nat)

   ;; === let* ===
   ;;'((let* ([x 1] [y (add1 x)]) y) 2 nat)
   ;;'((let* ([x 5] [y (- x 2)]) (+ y 1)) 4 nat)
   #;
   '((let* ([U (lambda (u) (u u))]
            [Yv (U (lambda (Y) (lambda (f) (f (lambda (x) (((U Y) f) x))))))]
            [len (Yv (lambda (len)
                       (lambda (lst)
                         (if (null? lst)
                             0
                             (add1 (len (cdr lst)))))))])
       (len (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons '() '())))))))) 6 nat)

   ;; === Church Pairs & Lists ===
   ;'(()                                  () list)
   '((cons 1 '())                       (1) list)
   '((cons 3 (cons 2 (cons 1 ())))  (3 2 1) list)

   ;; === car ===
   '((car (cons 1 (cons 2 '()))) 1 nat)
   '((car (cons 5 (cons 7 ()))) 5 nat)
   
   ;; === cdr ===
   '((cdr (cons 1 (cons 2 ())))      (2) list)
   '((cdr (cons 5 (cons 7 ())))      (7) list)
   '((cdr (cdr (cons 5 (cons 7 ())))) () list)

   ;; === Church List Edge Cases ===

   ;; single-element list from raw nil
   '((cons 42 ())                      (42) list)

   ;; list with Church-encoded nested list in tail (should preserve only top layer)
   '((cons 1 (cons (cons 2 ()) ()))  (1 (2)) list)

   ;; improper list (should decode only valid prefix, or raise if desired)
   ;; depending on decoder robustness
   ;; '((cons 1 2))                    ;; optional error test

   ;; empty list car/cdr — should raise error or be safely ignored
   ;; '((car ())                      ;; optional: invalid, no car of nil
   ;; '((cdr ())                      ;; optional: invalid, no cdr of nil

   ;; deeper nesting with trailing nil
   '((cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ()))))) (1 2 3 4 5) list)

   ;; nested cdr sequence
   '((cdr (cdr (cdr (cdr (cdr (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))))))) () list)

   ;; car after nested cdr
   '((car (cdr (cdr (cons 1 (cons 2 (cons 3 ())))))) 3 nat)

   ;; decode list with Church 0 inside
   '((cons 0 (cons 1 (cons 2 ()))) (0 1 2) list)

   ;; mixed numbers (ensure decoder handles Church numerals uniformly)
   '((cons 5 (cons 0 (cons 7 ()))) (5 0 7) list)

   ;; test nil inside cons list
   '((cons '() (cons '() ())) (() ()) list)

   ;; list built manually using nested lambdas (if desired)
   ;; optional: verify that hand-constructed Church lists decode


   ;; === null? ===
   '((null? ())                #t bool)
   '((null? (cons 1 ()))       #f bool)
   '((null? (cdr (cons 1 ()))) #t bool)

   ;; === letrec (factorial) === Requires Y combinator
   '((letrec ([fact (lambda (n) (if (zero? n) 1 (* n (fact (sub1 n)))))]) (fact 0)) 1 nat)
   '((letrec ([fact (lambda (n) (if (zero? n) 1 (* n (fact (sub1 n)))))]) (fact 1)) 1 nat)
   '((letrec ([fact (lambda (n) (if (zero? n) 1 (* n (fact (sub1 n)))))]) (fact 2)) 2 nat)
   '((letrec ([fact (lambda (n) (if (zero? n) 1 (* n (fact (sub1 n)))))]) (fact 3)) 6 nat)

   ))

;; === Decoders ===
(define (church->nat c) ((c add1) 0))
(define (church->bool c) ((c #t) #f))
(define ((church->listof T) c)
  ((c (λ (a)(λ (b)
        (cons ((if (λ-expr? a) (church->listof T) T) a)
              ((church->listof T) b)))))
   '()))

;; === Unchurch ===
(define (unchurch v type)
  (match type
    ['bool (church->bool v)]
    ['nat  (church->nat v)]
    ['list ((church->listof identity) v)]
    [_ (error "Unknown type: ~a" type)]))

;; === Run Tests ===
(define (run-tests test-cases)
  (define (run input expected type)
    (define compiled (churchify input))
    (define result (eval compiled (make-base-namespace)))
    (define final (unchurch result type))
    (define pass? (equal? final expected))
    (printf "▶ ~a\n  ⇒ ~s → ~s → ~s  ~a\n\n"
            input compiled result final
            (if pass? "✓" (string-append "✗ (expected: " (format "~s" expected) ")")))
    pass?)

  (define results (map (λ (t) (apply run t)) test-cases))
  (define passed (count identity results))
  (printf "✅ ~a / ~a tests passed\n" passed (length test-cases)))

(run-tests test-cases)
