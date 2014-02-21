skewer-livescript
=================
This is a Emacs Skewer mode and REPL for LiveScript
Installation
------------

1. Make sure you set the load-path correctly.
2. Add to you init.el:

  ```lisp
  (require 'skewer-livescript)
  (require 'skewer-livescript-repl)

  (add-hook 'livescript-mode-hook (lambda ()
                                   (skewer-livescript-mode t)))
  ```

3. Start server: `M-x httpd-start`
4. Add skewer to you project index as describe in Skewer documentation or run `M-x run-skewer`

Keybindings
-----------

* `C-c C-e`  run current selection region
* `C-c C-z`  bring you LiveScript REPL
