;;; skewer-livescript-repl.el --- create a REPL in a visiting browser -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;;; Commentary:

;; This is largely based on of IELM's code. Run `skewer-livescript-repl' to
;; switch to the REPL buffer and evaluate code. Use
;; `skewer-livescript-repl-toggle-strict-mode' to turn strict mode on and off.

;; If `compilation-search-path' is set up properly, along with
;; `skewer-livescript-path-strip-level', asynchronous errors will provide
;; clickable error messages that will take you to the source file of
;; the error. This is done using `compilation-shell-minor-mode'.

;;; Code:

(require 'comint)
(require 'compile)
(require 'livescript-mode)
(require 'skewer-mode)
(require 'livescript-mode)

(defcustom skewer-livescript-repl-strict-p nil
  "When non-NIL, all REPL evaluations are done in strict mode."
  :type 'boolean
  :group 'skewer)

(defcustom skewer-livescript-repl-prompt "ls> "
  "Prompt string for LiveScript REPL."
  :type 'string
  :group 'skewer)

(defvar skewer-livescript-repl-welcome
  (propertize "*** Welcome to Skewer ***\n"
              'font-lock-face 'font-lock-comment-face)
  "Header line to show at the top of the REPL buffer. Hack
notice: this allows log messages to appear before anything is
evaluated because it provides insertable space at the top of the
buffer.")

(defun skewer-livescript-repl-process ()
  "Return the process for the skewer REPL."
  (get-buffer-process (current-buffer)))

(defface skewer-livescript-repl-log-face
  '((((class color) (background light))
     :foreground "#77F")
    (((class color) (background dark))
     :foreground "#77F"))
  "Face for skewer.log() messages."
  :group 'skewer)

(define-derived-mode skewer-livescript-repl-mode comint-mode "ls-REPL"
  "Provide a REPL into the visiting browser."
  :group 'skewer
  :syntax-table emacs-lisp-mode-syntax-table
  (setq comint-prompt-regexp (concat "^" (regexp-quote skewer-livescript-repl-prompt)))
  (setq comint-input-sender 'skewer-livescript-input-sender)
  (unless (comint-check-proc (current-buffer))
    (insert skewer-livescript-repl-welcome)
    (start-process "skewer-livescript-repl" (current-buffer) nil)
    (set-process-query-on-exit-flag (skewer-livescript-repl-process) nil)
    (goto-char (point-max))
    (set (make-local-variable 'comint-inhibit-carriage-motion) t)
    (comint-output-filter (skewer-livescript-repl-process) skewer-livescript-repl-prompt)
    (set-process-filter (skewer-livescript-repl-process) 'comint-output-filter)))

(defun skewer-livescript-repl-toggle-strict-mode ()
  "Toggle strict mode for expressions evaluated by the REPL."
  (interactive)
  (setq skewer-livescript-repl-strict-p (not skewer-livescript-repl-strict-p))
  (message "REPL strict mode %s"
           (if skewer-livescript-repl-strict-p "enabled" "disabled")))

(defun skewer-livescript-input-sender (_ input)
  "REPL comint handler."
  (let ((javascript-string (shell-command-to-string (concat
                                                     livescript-command
                                                     " -c -b -p -e \""
                                                     input
                                                     "\""))))

       (skewer-eval javascript-string 'skewer-livescript-post-repl
                    :verbose t :strict skewer-livescript-repl-strict-p)))

(defun skewer-livescript-post-repl (result)
  "Callback for reporting results in the REPL."
  (let ((buffer (get-buffer "*skewer-livescript-repl*"))
        (output (cdr (assoc 'value result))))
    (when buffer
      (with-current-buffer buffer
        (comint-output-filter (skewer-livescript-repl-process)
                              (concat output "\n" skewer-livescript-repl-prompt))))))

(defvar skewer-livescript-repl-types
  '(("log" . skewer-livescript-repl-log-face)
    ("error" . skewer-error-face))
  "Faces to use for different types of log messages.")

(defun skewer-log-filename (log)
  "Create a log string for the source file in LOG if present."
  (let ((name (cdr (assoc 'filename log)))
        (line (cdr (assoc 'line log)))
        (column (cdr (assoc 'column log))))
    (when name
      (concat (format "\n    at %s:%s" name line)
              (if column (format ":%s" column))))))

(defun skewer-livescript-post-log (log)
  "Callback for logging messages to the REPL."
  (let* ((buffer (get-buffer "*skewer-livescript-repl*"))
         (face (cdr (assoc (cdr (assoc 'type log)) skewer-livescript-repl-types)))
         (value (or (cdr (assoc 'value log)) "<unspecified error>"))
         (output (propertize value 'font-lock-face face)))
    (when buffer
      (with-current-buffer buffer
        (save-excursion
          (goto-char (point-max))
          (forward-line 0)
          (backward-char)
          (insert (concat "\n" output (skewer-log-filename log))))))))

(defcustom skewer-livescript-path-strip-level 1
  "Number of folders which will be stripped from url when discovering paths.
Use this to limit path matching to files in your filesystem. You
may want to add some folders to `compilation-search-path', so
matched files can be found."
  :type 'number
  :group 'skewer)

(defun skewer-livescript-repl-mode-compilation-shell-hook ()
  "Setup compilation shell minor mode for highlighting files"
  (let ((error-re (format "^[ ]*at https?://[^/]+/\\(?:[^/]+/\\)\\{%d\\}\\([^:?#]+\\)\\(?:[?#][^:]*\\)?:\\([[:digit:]]+\\)\\(?::\\([[:digit:]]+\\)\\)?$" skewer-livescript-path-strip-level)))
    (setq-local compilation-error-regexp-alist `((,error-re 1 2 3 2))))
  (compilation-shell-minor-mode 1))

;;;###autoload
(defun skewer-livescript-repl--response-hook (response)
  "Catches all browser messages logging some to the REPL."
  (let ((type (cdr (assoc 'type response))))
    (when (member type '("log" "error"))
      (skewer-livescript-post-log response))))

;;;###autoload
(defun skewer-livescript-repl ()
  "Start a LiveScript REPL to be evaluated in the visiting browser."
  (interactive)
  (when (not (get-buffer "*skewer-livescript-repl*"))
    (with-current-buffer (get-buffer-create "*skewer-livescript-repl*")
      (skewer-livescript-repl-mode)))
  (pop-to-buffer (get-buffer "*skewer-livescript-repl*")))

;;;###autoload
(eval-after-load 'skewer-mode
  '(progn
     (add-hook 'skewer-response-hook #'skewer-livescript-repl--response-hook)
     (add-hook 'skewer-repl-mode-hook #'skewer-livescript-repl-mode-compilation-shell-hook)
     (define-key skewer-livescript-mode-map (kbd "C-c C-z") #'skewer-livescript-repl)))

(provide 'skewer-livescript-repl)

;;; skewer-livescript-repl.el ends here
