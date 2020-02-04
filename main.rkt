#lang racket

(require "leader.rkt")

(module+ main
  (define sqr `(lambda (x) (* x x)))
  (define nums (create-distributed-range 0 10))
  (define squared-nums (distributed-map nums sqr))
  (define sum (lambda (l) (foldl + 0 l)))
  (define res (collect sum squared-nums))
  (printf "The result is: ~a\n" res))
