(defpackage gpt-telegram-bot
  (:use :cl)
  (:use :drakma)
  (:use :json)
  (:local-nicknames (:ctb :cl-telegram-bot)
                    (:ctb/message :cl-telegram-bot/message)
                    (:bb :blackbird)
                    (:async :cl-async))
  (:export #:main))

(in-package :gpt-telegram-bot)

(ctb:defbot gpt-telegram-bot)

(let ((token nil))
(setf *gpt-telegram-bot*
      ;; Dear Unknown,
      ;; you have to understand that I'm not crazy (not this crazy)
      ;; the point of this passage is that
      ;; `token` could be defined via org-mode facilities
      (let* ((token (if token token
                        (uiop:getenv "GPTBOT_TOKEN")))
             (token (if token token
                        (error "Define GPTBOT_TOKEN env var."))))
        (make-gpt-telegram-bot token))))

(defun ask-gpt (prompt)
  (let* ((token nil)
         (token (if token token
                    (uiop:getenv "GPTAI_TOKEN")))
         (token (if token token
                    (error "Define GPTAI_TOKEN env var.")))
         (drakma:*text-content-types*
           (list*
            (cons "application" "json")
            drakma:*text-content-types*))
         (url "https://api.openai.com/v1/chat/completions")
         (data
           `((MODEL . "gpt-3.5-turbo-0125")
             (MESSAGES ((ROLE . user)
                        (CONTENT . ,prompt)))
             (TEMPERATURE . 0.7)))
         (data (json:encode-json-to-string data))
         (response
           (drakma:http-request
            url
            :method :post
            :content-type "application/json"
            :content data
            :accept "application/json"
            :additional-headers
            `(("Authorization" . ,(format nil "Bearer ~a" token))))))
    (json:decode-json-from-string response)))

(defmethod ctb:on-message
    ((bot gpt-telegram-bot) text)
  (let* ((raw-data (ctb/message:get-raw-data
                    ctb/message::*current-message*))
         (text (getf raw-data ':|text|))
         ;; abolish double quotes
         (text (substitute #\' #\" text))
         ;; trim double original quotes wrapper (obsolete)
         ;; (text (string-trim "\"" text))
         ;; abolish newline whitespaces
         (text (substitute #\Space #\Newline text))
         ;; wrap in double quotes
         (text (format nil "\"~A\"" text))
         (response (ask-gpt text))
         (choices (cdr (assoc :CHOICES response)))
         (content (cdr (cadr (cdadar choices)))))
    (ctb:reply content)))

(defun main ()
  (ctb:start-processing *gpt-telegram-bot*))
