#lang web-server/insta
 
(require web-server/formlets
         "model.rkt")
 
; start: request -> void
; Takes a request then renders the webpage
(define (start request)
  (render-chat-page
   (initialize-chat!
    (build-path (current-directory)
                "chat-save.db"))
   request))
 
; new-message-formlet : formlet (values string)
; A formlet for adding text of a message
(define new-message-formlet
  (formlet
   (#%# ,{input-string . => . text})
   (values text)))
 
; render-chat-page request -> void
; Produces the chat page itself
(define (render-chat-page chat request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Little Chatter"))
            (body
             (h1 "Chatter")
             ,(render-messages chat)
             (form ([action
                     ,(embed/url add-message-handler)])
                   ,@(formlet-display new-message-formlet)
                   (input ([type "submit"])))))))
 
  (define (add-message-handler request)
    (define-values (text)
      (formlet-process new-message-formlet request))
    (chat-add-message! chat "aaron" text)
    (render-chat-page chat (redirect/get)))
  (send/suspend/dispatch response-generator))

; render-message message (handler -> string) -> xexpr
; Takes a message, produces an xexpr fragment of the message.
(define (render-message chat message)
  `(div ((class "message"))
        (p ,(message-text message))))
 
; render-message chat (handler -> string) -> xexpr
; Takes a chat, produces an xexpr fragment
(define (render-messages chat)
  (define (render-message-thing message)
    (render-message chat message))
  `(div ((class "messages"))
        ,@(map render-message-thing (chat-messages chat))))
