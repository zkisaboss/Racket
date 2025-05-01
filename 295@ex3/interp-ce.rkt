#lang racket

;; Exercise 3: A CE (Control and Environment) interpreter for Scheme

;; NOTE: You *MAY* collaborate with other students on this exercise,
;; but *not* the later project. Feel free to work with up to two other
;; students (groups of three) and submit the same code as them. Use
;; that code to begin your solution for p3.

;; Name: Zach Kosove
;; Collaborator 1: ________________________________
;; Collaborator 2: ________________________________
(provide interp-ce)

; Interp-ce must correctly interpret any valid scheme-ir program and yield the same value
; as DrRacket, except for closures which must be represented as `(closure ,lambda ,environment).
; (+ 1 2) can return 3 and (cons 1 (cons 2 '())) can yield '(1 2). For programs that result in a
; runtime error, you should return `(error ,message)---giving some reasonable string error message.
; Handling errors and some trickier cases will give bonus points.
(define (interp-ce exp)
  (define (interp env exp)
    (match exp
      ;; Numbers and booleans evaluate to themselves.
      [(? number?) exp]
      [(? boolean?) exp]

      ;; Desugar let into a lambda application.
      [`(let ([,xs ,rhss] ...) ,body)
       (interp env
               (append (list (list 'lambda xs body))
                       (map (lambda (rhs) (interp env rhs)) rhss)))]

      ;; Lambda expressions.
      [`(lambda ,params ,body)
       `(closure (lambda ,params ,body) ,env)]

      ;; Variables: look them up in the environment.
      [(? symbol? x)
       (hash-ref env x (lambda ()
                         `(error ,(string-append "Unbound variable: " (symbol->string x)))))]

      ;; if expressions: evaluate the condition then branch accordingly.
      [`(if ,ge ,te ,fe)
       (if (interp env ge) (interp env te)
           (interp env fe))]

      ;; Primitive operations clause (unused in my code).
      [`(apply-prim ,op ,x)
       (let ([op-proc (eval op)]
             [arg-val (interp env x)])
         (op-proc arg-val))]

      ;; Function application for known binary primitives.
      [`(,op ,e0 ,e1)
       ((match op
          ['+ +]
          ['- -]
          ['* *]
          [else (error "Unknown operator" op)])
        (interp env e0)
        (interp env e1))]

      [`(,ef ,ea)
       (define clo-for-ef (interp env ef))
       (match clo-for-ef
         [`(closure (lambda (,x) ,e-b) ,env+)
          (let ([v (interp env ea)])
            (interp (hash-set env+ x v) e-b))])]))

  (define starting-env (hash))
  (interp starting-env exp))
