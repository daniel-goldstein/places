#lang racket

(require "protocol.rkt")
(provide place-main)

(define (place-main pch)
  (define worker-index (place-channel-get pch))
  (serve-requests pch worker-index))

(define (serve-requests place-ch worker-index)
  (let loop ()
    (define payload (place-channel-get place-ch))
    (unless (shutdown? payload)
      (place-channel-put place-ch (execute payload worker-index))    
      (loop))))

(define (execute f worker-index)
  (define ns (make-base-namespace))
  (eval `(,f ,worker-index) ns))
