#lang racket/base
(require racket/list)

; A chat is a (chat home-path messages)
; where home-path is a string, messages is (listof message)
; mutable flag indicates chat can be mutated
; prefab flag indicates chat can be prexisiting
(struct chat (home-path messages) #:mutable #:prefab)

; A message is a (message sent text received seen)
(struct message (author text sent received seen) #:mutable #:prefab)

; Read existing chat from disk, or create a default one
(define (initialize-chat! home-path)
  (define (missing-file-exn exn)
    (chat
     (path->string home-path)
     (list (message "aaron" "Demo" #f #f #f))))
  (define CHAT
    (with-handlers ([exn? missing-file-exn])
      (with-input-from-file home-path read)))
  (set-chat-home-path! CHAT (path->string home-path))
  CHAT)

; Saves chat to disk
(define (save-chat! chat)
  (define (write-to-chat)
    (write chat))
  (with-output-to-file (chat-home-path chat)
    write-to-chat
    #:exists 'replace))

; Add message to the chat
(define (chat-add-message! chat author text)
  (set-chat-messages!
   chat
   (cons (message author text #f #f #f) (chat-messages chat)))
  (save-chat! chat))


 
(provide chat? chat-messages
         chat-add-message!
         message? message-text message-sent 
         initialize-chat!
         chat-add-message!)