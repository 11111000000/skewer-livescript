skewer-livescript-mode
======================

Emacs skewer mode for livescript

Installation
------------

Make sure you set the load-path correctly.

Add to you init.el:

```lisp
  (require 'skewer-livescript)
  (require 'skewer-livescript-repl)

  (add-hook 'livescript-mode-hook (lambda ()
                                    (skewer-livescript-mode t)
                                    ))
```

Start server: `M-x httpd-start`
Add skewer to you project index as describe in Skewer documentation or `M-x run-skewer`

Keybindings
-----------

* **C-c C-e**  run current selection region
* **C-c C-z**  bring you LiveScript REPL
