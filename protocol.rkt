#lang racket

(provide
  SHUTDOWN
  shutdown?
  WORKER-FILE
  WORKER-METHOD)

(define SHUTDOWN 'shutdown)
(define WORKER-FILE "worker.rkt")
(define WORKER-METHOD 'place-main)


#; { Any -> Boolean }
(define (shutdown? x)
  (and (symbol? x) (symbol=? x SHUTDOWN)))
