;;; skewer-livescript.el --- Skewer support for LiveScript

;; Copyright (C) 2014 Peter Kosov

;; Author: Peter Kosov <11111000000@email.com>
;; Keywords: languages, tools, skewer, livescript
;; Version: DEV
;; Package-Requires: ((skewer-mode "1.5.3"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Minor mode allowing LiveScript eval via `skewer-mode'.

;; Note that this is intended for use in place of `skewer-mode',
;; which does not work with LiveScript.

;; Enable `skewer-livescript-mode' in a ".livescript" buffer. Save the buffer to
;; trigger an update, or hit "C-c C-k" just like in
;; `skewer-mode'.

;;; Code:

(require 'skewer-mode)
(require 'livescript-mode)

(defvar skewer-livescript-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "C-c C-e") 'skewer-livescript-eval-region)
    m)
  "Keymap for `skewer-livescript-mode'.")

;;;###autoload
(define-minor-mode skewer-livescript-mode
  "Minor mode allowing LiveScript manipulation via `skewer-mode'. "
  nil
  "skewer-livescript"
  skewer-livescript-mode-map
  ;; (if skewer-livescript-mode
  ;;     (add-hook 'after-save-hook 'skewer-livescript-eval-buffer nil t)
  ;;   (remove-hook 'after-save-hook 'skewer-livescript-eval-buffer t)))
 )

(defun skewer-livescript-eval-region (start end)
  "Compiles a region, displays the JavaScript in a buffer called
`livescript-compiled-buffer-name', then eval it with skewer."
  (interactive "r")

  (let ((buffer (get-buffer-create livescript-compiled-buffer-name)))
    (when buffer
      (with-current-buffer buffer
        (erase-buffer))))

  ;; TODO to experiment without partial application:
  (apply (apply-partially 'call-process-region start end
                          livescript-command    ; compile
                          nil                     ; don't delete original text
                          (get-buffer-create livescript-compiled-buffer-name) ; output buffer
                          nil)
         (append livescript-args-compile (list "-s" "-p" "-b")))

  (let ((buffer (get-buffer livescript-compiled-buffer-name)))
    ;; (popwin:popup-buffer buffer)
    (with-current-buffer buffer
      (skewer-eval (buffer-string) #'skewer-post-minibuffer)
        )))

(defun skewer-livescript-eval-buffer ()
  "Compiles the current buffer, displays the JavaScript in a buffer
called `livescript-compiled-buffer-name', then eval it with skewer."
  (interactive)
  (save-excursion
    (skewer-livescript-eval-region (point-min) (point-max))))

(provide 'skewer-livescript)
;;; skewer-less.el ends here
