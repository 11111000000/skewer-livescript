skewer-livescript
=================
Emacs Skewer mode and REPL for LiveScript
Installation
------------

0. Install [Skewer mode](https://github.com/skeeto/skewer-mode "Skewer Mode")
0. Clone this repo
0. Make sure you set the *load-path* correctly
0. Add this to you init.el:

  ```lisp
  (require 'skewer-livescript)
  (require 'skewer-livescript-repl)

  (add-hook 'livescript-mode-hook (lambda ()
                                   (skewer-livescript-mode t)))
  ```

0. Start server: `M-x httpd-start`
0. Add skewer to you project index as described in Skewer documentation or run `M-x run-skewer`

Keybindings
-----------

* `C-c C-e`  Eval selected region of LiveScript
* `C-c C-z`  LiveScript REPL
