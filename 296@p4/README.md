# Church Encoder

Advice: doing things in the right order is *absolutely crucial* for
this project. Start with function application / abstraction (lambdas /
applications, currying)--it is hard to do much of anything without
those. We will demonstrate various forms in class as well.

In this project, you will write a Church encoder: a compiler from a
large subset of Scheme to λ-calculus. In other words, you will
transform inputs like '(let ([x 0]) x) to outputs like '((lambda (x)
x) (lambda (f) (lambda (x) x))). Your output will be quoted data in
the λ-calculus: the test infrastructure will then interpret this into
a Racket λ by using `eval`.

It is crucial to understand that you are *not* building an
interpreter, as in project 3. Instead, you are building a
*compiler*. Your project will translate the input language into the
λ-calculus by removing each Racket form, one-by-one, and encoding them
in the λ-calculus.

To understand the encodings, please look over the posted course
slides, the course videos, and the recorded class lectures on
Blackboard. We have covered many of the forms already: the main
challenge in this project is translating the "on paper" knowledge into
a working compiler.

The central challenge with this project is debugging. You should try
to learn a debugging methodology that works for you. I recommend
calling your compiler on smaller and smaller programs until you
recognize which part is incorrect. Work to gradually whittle down the
test cases until you isolate precisely what is wrong.

Read the advice at the bottom for my recommendations as to the order
you solve the project.

Good luck!

## The Language: Syntax

Below is the full syntax of the language you must support:

```
e ::= (letrec ([x (lambda (x ...) e)]) e)
    | (let ([x e] ...) e)
    | (let* ([x e] ...) e)
    | (lambda (x ...) e)
    | (e e ...)
    | x
    | (and e ...) | (or e ...)
    | (if e e e)
    | (prim e) | (prim e e)
    | datum

datum ::= nat | (quote ()) | #t | #f 
nat ::= 0 | 1 | 2 | ... 
x is a symbol
prim is a primitive operation in list prims
(define prims '(+ * - = add1 sub1 cons car cdr null? not zero?))
The following are *extra credit*: -, =, sub1
```

This input language has semantics identical to Scheme / Racket, except:
  + You will not be provided code that yields *any* kind of error in Racket
  + You do not need to treat non-boolean values as #t at if, and, or forms
    -> Racket allows "truthy" and "falsy" values--we won't handle those
  + primitive operations are either strictly unary (add1 sub1 null? zero? not car cdr), 
    or strictly binary (+ - * = cons)
  + There will be no variadic functions or applications---but any fixed arity is allowed
    -> E.g., `((lambda l (first l)) 1 2 3)` is not allowed but
    `((lambda (x y z) x) 1 2 3)` is

# Output language:

Your output must be a quoted expression in the λ-calculus:

```
e ::= (lambda (x) e)
    | (e e)
    | x
```

# Functions and Builtins

You will primarily implement the `churchify` function, which accepts
an input in the input language above and produces an output in the
λ-calculus. `churchify` recognizes each form in the input language
(using a match pattern) and then calls itself.

To make things easier for you, we have used a trick: the function
`church-compile` calls churchify with a large `let` block to bind each
of the builtins. This allows you to handle builtin operators in a
relatively simple way: you can just translate `(+ e0 e1)` to use
currying `((+ e0') e1')`, where `e0'` and `e1'` are the Church
encodings of `e0` and `e1`. Then, `+` will be given a binding because
it is wrapped in the top-level `let` block in `church-compile`.

Please think about the above paragraph until it makes sense to you: it
makes handling builtins overwhelmingly simpler.

# Advice

- Work on the simplest forms first: translate numbers into
  Church-encoded numbers. We have given solutions to this in previous
  in-class exercises.

- Handle currying and function calls pretty early: it's kind of
  impossible to make any real progress without doing these cases, so
  if you push these off until the end you'll feel like you're making
  no progress.

- Heed the warning about `*` in the course videos: the course video
  gets it wrong, the slides get it right--I am truly sorry about that
  and will refilm the video soon--just didn't have time to do so this
  semester. Please don't let it trip you up.

- If you would like to get some extra credit, look up the definitions
  of `-`, `sub1, etc... on Wikipedia and add them to your `let` block
  in `church-compile`. You can also try to figure them out for
  yourself if you'd like. Note this interesting story:

> "Be this as it may, Kleene did find a way to lambda deﬁne the
> predecessor function in the untyped lambda calculus, by using an
> appropriate data type (pairs of integers) as auxiliary device. In
> [69], he described how he found the solution while being
> anesthetized by laughing gas for the removal of four wisdom teeth."
> -- Henk Barendregt's "Impact of the Lambda calculus"

- Translate booleans, `if`, and `and`/`or` as discussed in the slides.

- To handle `letrec`, see the lecture on fixed-points. If you are
  asking about this one: that whole lecture video is designed to help
  you answer this case exactly. The answer is surprisingly simple: you
  apply the Y combinator to `(lambda (f) ...)`. My solution does
  something like `(let ([f (Y-comb ....)]) ...)`. Then you just need
  `Y-comb` to be in scope.

- Be sure to handle `(let () ,e1)` (which should just be `e1`).

- Be sure to match the empty list literal as ''(), it should be
  translated to the definition of the empty list (given in the
  slides).
