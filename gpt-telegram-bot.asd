(defsystem "gpt-telegram-bot"
  :version "0.0.1"
  :author "Giovanni Crisalfi"
  :license ""
  :depends-on ("cl-telegram-bot"
               "cl-async"
               "cl-json"
               "drakma"
               "blackbird")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "gpt-telegram-bot/tests"))))

(defsystem "gpt-telegram-bot/tests"
  :author "Giovanni Crisalfi"
  :license ""
  :depends-on ("gpt-telegram-bot"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for gpt-telegram-bot"
  :perform (test-op (op c) (symbol-call :rove :run c)))
