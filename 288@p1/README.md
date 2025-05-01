# Project 1: Tic-tac-toe in Racket

In this project, you will implement several racket functions to
implement a game of tic-tac-toe in Racket. All of your code will be
written in p0.rkt, please modify only that code. We encourage you to
read the GUI's implementation in gui.rkt if you are interested.

You will implement the following five (or six) functions:

- (board? lst) -- checks whether a list l is a valid board
- (next-move board) -- checks which player moves next
- (valid-move? board row col player) -- checks whether a move is valid
- (make-move board row col player) -- updates a board
- (winner? board) -- checks whether a board has a winner
- (choose-next-move board) -- OPTIONAL (bonus) -- implements an AI

Grading is based on testcases. Most of the testcases are public, but
theere are six hidden testcases. The hidden testcases stress your
winner? function for boards that are not just 3x3.

`choose-next-move` is optional. There are no testcases for it on the
autograder. It is included as an optional extra credit assignment for
students who wish to explore symbolic AI via the minimax algorithm. If
you attempt this part and believe you have a correct solution (which
correctly implements minimax), please notify me and we can set up a
time to chat: I am happy to offer .5-1% in the "extra credit" course
category for your efforts here, depending on how complete and correct
I feel your implementation is.

## Useful functions

This project assumes you are using at leeast the following:

* Basic functions on lists: car, cdr, cons, append
* Control constructs: if, cond
* Logic operation: or, and
* Recursion

Our solution uses roughly the following functions / forms:
{car, cdr, and, or, equal?, null?, if, cons}

You MAY NOT USE any mutable functions, including set!, vector-set!,
etc... As such, constructs such as `loop` will likely be irrelevant.

## 1. Intro

```
| O| O |X |
| X| X |O |
| O| X |X |
```

Tic-tac-toe is a paper-and-pencil game for two players, X and O, who
take turns marking the spaces in a 3×3 grid. To find some more info
about Tic-tac-toe, you can look at the
[Wikipedia](https://en.wikipedia.org/wiki/Tic-tac-toe) In this
project, we will have you implement several functions to complete the
implementation of tic-tac-toe.

## 2. Representing boards

Board games are represented as a list of symbols of length n=k*k for
some k. Each row of the board is stored sequentially, so a 3*3 board
would be represented as a list of length 9, where the first three
elements represent the first three columns in the first row of the
board. Each element of a game board is one of three symbols: 'X, 'O,
or 'E (for empty).

For example, a 3*3 size initial game board:

```
| E| E |E |
| E| E |E |
| E| E |E |
```

is represented in Racket as the list '(E E E E E E E E E)

If we place a X at the middle of the board:

```
| E| E |E |
| E| X |E |
| E| E |E |
```

The board be represented by the list '(E E E E X E E E E)


## 3. Task and Specification

> **_NOTE:_** You only need to modify p0.rkt for this project. The
    file gui.rkt uses the functions in p0.rkt.

### 3.0 (board? lst) -> boolean?

This is a Racket predicate to determine if a board is valid. A board is valid if and only if:

- Its length is a square of some integer
- It contains only the symbols 'X 'O 'E
- The number of Xs and Os differ by at most 1
- X moves first

Recall that Racket predicates return either #t or #f.


### 3.1 (next-move lst)

This function accepts a board (satisfying board?) and returns either
'X or 'O based on who should make the next move. Player X makes the
first move.

For example, a board like this

```
| E| E |E |
| E| X |E |
| E| E |E |
```

will be represented as '(E E E E X E E E E), once you call
`(who-move? '(E E E E X E E E E))` it's supposed to return 'O

### 3.2 (valid-move? lst row col player) -> boolean?
lst is a list?  
row, col are both number?  
are either 'X or 'O
returns a boolean?

This function takes in a board, and returns whether it is valid for
player it the player want to make a move at (row, col), determine
whether it's valid.  A move is valid when:

- It is player's turn to move
- The specified position (row,col) is currently empty (holds 'E)

> **_HINT:_** In order to pass hidden tests, you need to consider the
    case when the game board is some arbitrary N*N size.


### 3.3 (make-move brd row col player) -> board?
brd : board?
row, col: nonnegative-integer?
p: {'X, 'O}

This function updates brd to make a move for player at position
(row,col). You may assume the move is valid and the board is
structured correctly (satisfies board?).

For example, before the move the board may look like this  

||||
|:-|:-:|-:|
| E| E |E |
| E| X |E |
| E| E |E |

Which is represented as '(E E E E X E E E E) 

In this case, (make-move '(E E E E X E E E E) 0 0 'O)  
should return, '(O E E E X E E E E) illustrated below:

||||
|:-|:-:|-:|
| O| E |E |
| E| X |E |
| E| E |E |



### 3.4 (winner? board) -> {'X, 'O, #f}
board: board?
returns either 'X, 'O, or #f

This checks whether a board has a winner and (if so) returns either 'X
or 'O as appropriate. A board has a winner when it has a row full of
'X, column full of 'X, or whose main diagonal is 'X, and mutatis
mutandi for 'O.

For example:

||||
|:-|:-:|-:|
| O| E |E |
| E| X |E |
| E| E |E |

Should return #f as there is no winner yet. But:

||||
|:-|:-:|-:|
| O| X |O |
| E| X |E |
| E| X |E |

will return 'X as the player 'X has a col with 3 connected marks.

The following:

|||||
|:-|:-:|-:|-:|
| O| E |X | E|
| E| X |O | E|
| X| X |E | E|
| E| E |E | E|

Returns #f: even though there's a length-three diagonal (of X), it
would have to be the longest diagonal.

### 3.5 (calculate-next-move board player) -> (cons x y)
board: board?
player is either 'X or 'O
returns a cons cell of x and y.

This is for an Excellent mark, and thus this part of the project is a
bit harder and more open-ended. Tic-tac-toe has a precise brute-force
solution: you can *always* not-lose if you play correctly. In this
part of the project, you will implement a computer AI to beat your
opponent at tic-tac-toe.

To implement your AI, you should use the [MiniMax
algorithm](https://en.wikipedia.org/wiki/Minimax). MiniMax, in
general, says this:

- Every player should choose the move that will maximally bound the
  worst-case thing that could happen to them.

For tic-tac-toe, this means that we think carefully and consider all
different possible moves we might make, and then possible reponses to
those moves, and so on. You should then choose the move (which, for
tic-tac-toe, will always exist if you play this strategy from the
start) that makes it impossible for the other player to win. In other
words, you are *maximizing* your action under the (pessimistic?)
assumption that the other player will *minimize* your winnings (by
maximizing their own!).

We discuss some examples in the video.

For grading of this part of the assignment (i.e., to get an excellent
mark) you will talk to one of the TAs (or instructor) and present your
solution. You must still submit it to the autograder (for archival and
cheat-detection purposes).

## 4. Play the Game

Once you have implemented these functions correctly, you can play the
game with it.  Open a terminal in the proper directory and run:

```
racket gui.rkt <args>
```
where args are:

* -v: verbose mode, it will print the board as list after each move, helpful when you want to debug
* -a: AI mode, you will play as 'X first, then an AI will play with you as player 'O
* -k size: specify the size of the board, default is set to 3

For example, if you want to play with AI, simply run:
```
racket gui.rkt -a
```

or enable verbose output on a 4*4 size board
```
racket gui.rkt -v -k 4
```

or simply play within a 3*3 table
```
racket gui.rkt
```
