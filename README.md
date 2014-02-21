skewer-livescript
=================

Emacs skewer mode for livescript

Installation
------------

1. Make sure you set the load-path correctly.
1. Add to you init.el:

```lisp
  (require 'skewer-livescript)
  (require 'skewer-livescript-repl)

  (add-hook 'livescript-mode-hook (lambda ()
                                    (skewer-livescript-mode t)
                                    ))
```

1. Start server: `M-x httpd-start`
1. Add skewer to you project index as describe in Skewer documentation or run `M-x run-skewer`

Keybindings
-----------

* `C-c C-e`  run current selection region
* `C-c C-z`  bring you LiveScript REPL
