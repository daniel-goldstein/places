#lang racket

(require racket/place)
(require "protocol.rkt")

(provide
  collect
  create-distributed-range
  distributed-map)


;; A [DArray X] is a
;; (d-array SExpr Nat)
(struct d-array [f n-partitions])


#; { (X Y) [List-of X] [DArray X] -> Y }
;; Collect the values of a distributed array into a single value
(define (collect combine arr)
  (combine (compute (d-array-f arr) (d-array-n-partitions arr))))


#; { [X -> Y] [DArray X] -> [DArray Y] }
;; Map g over the distributed elements of arr
(define (distributed-map arr g)
  (d-array `(lambda (i) (,g (,(d-array-f arr) i)))
           (d-array-n-partitions arr)))


#; { Nat Nat -> [DArray Nat] }
;; Create a distributed range of [start, stop)
(define (create-distributed-range start stop)
  (d-array `(lambda (i) (+ i ,start)) (- stop start)))


#; { (X Y) [Nat -> X] Nat -> [List-of Y] }
;; Evaluate the function f on n-ways workers
(define (compute f n-ways)
  (define workers (spawn-workers n-ways))
  (define res (distribute f workers))
  (shutdown workers)
  res)


#; { Nat -> Place }
(define (spawn-workers n)
  (for/list ([index (in-range n)])
    (define worker (dynamic-place WORKER-FILE WORKER-METHOD))
    (place-channel-put worker index)
    worker))


#; { (X) [Nat -> X] [List-of Place] -> [List-of X] }
;; Execute f on each worker and retrieve the results
(define (distribute f workers)
  (for/list ([worker-ch (in-list workers)])
    (place-channel-put worker-ch f)
    (place-channel-get worker-ch)))


#; { [List-of Place] -> Void }
(define (shutdown workers)
  (for ([worker-ch (in-list workers)])
    (place-channel-put worker-ch SHUTDOWN)))
