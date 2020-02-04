#lang racket

(require "protocol.rkt")
(provide place-main)

#; { Place -> Void }
;; Entrypoint to act as a worker in a distributed computation
(define (place-main pch)
  (define worker-index (place-channel-get pch))
  (serve-requests pch worker-index))

#; { Place Nat -> Void }
;; Evaluate incoming computations until told to shut down
(define (serve-requests place-ch worker-index)
  (let loop ()
    (define payload (place-channel-get place-ch))
    (unless (shutdown? payload)
      (place-channel-put place-ch (execute payload worker-index))    
      (loop))))

#; { SExpr Nat -> Any }
;; Evaluate the computation given the index of this worker
(define (execute f worker-index)
  (define ns (make-base-namespace))
  (eval `(,f ,worker-index) ns))
