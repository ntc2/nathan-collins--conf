;; -*- emacs-lisp -*-
;;
;; * Custom set variables.
;;
;; Multiple `custom-set-variables' calls can be confusing [1], but
;; having a single monolithic call is not modular.  Solution: use
;; multiple calls, but comment each variable with a comment indicating
;; where it was set.  The comment is shown when using the customize
;; interface to customize the variable.
;;
;; See `./extensions/white-space.el' for example usage.
;;
;; Note: `setq' does not always work as a replacement for a
;; `custom-set-variables' entry.  E.g. `(setq tab-width 2)' has no
;; effect. The following do work:
;;
;;   (custom-set-default 'tab-width 2)
;;   (setq-default tab-width 2)
;;   (custom-set-variables '(tab-width 2))
;;
;;
;; On the other hand, it's not necessarily a good idea to use
;; `custom-set-variables' on a variable that isn't hooked into the
;; customize interface (you get a warning from customize, but I'm not
;; sure if there are any pitfalls).

;; [1]: http://www.dotemacs.de/custbuffer.html

(defun nc:custom-set-warning ()
  "Warning to insert in comment field of `custom-set-variable' entries."
  (format "!!! CAREFUL: CUSTOM-SET IN %s !!!" load-file-name))

(defmacro nc:custom-set-variable (var value)
  "Call `custom-set-variables' with a comment warning about
customizing using the customize GUI.

XXX: does not support setting the optional NOW and
REQUEST (dependency) fields."
  (custom-set-variables
    ;; 'load-file-name' is set by 'load':
    ;; http://stackoverflow.com/a/1971376/470844
    `(,var ,value nil nil ,(nc:custom-set-warning))))

(defmacro nc:custom-set-face (face spec)
  "XXX: untested.

See `nc:custom-set-variable'."
  (custom-set-faces
    `(,face ,spec nil ,(nc:custom-set-warning))))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(current-language-environment "English")
 '(global-font-lock-mode t nil (font-lock))
 '(inhibit-startup-screen t)
 '(iswitchb-default-method (quote maybe-frame))
 '(jit-lock-defer-time 0.25)
 '(js2-auto-indent-flag nil)
 '(js2-bounce-indent-flag t)
 '(js2-highlight-level 3)
 '(js2-mirror-mode nil)
 '(mouse-wheel-follow-mouse t)
 '(mouse-wheel-mode t nil (mwheel))
 '(ps-black-white-faces (quote ((font-lock-builtin-face "black" nil bold underline) (font-lock-comment-face "gray20" nil italic) (font-lock-constant-face "black" nil bold) (font-lock-function-name-face "black" nil bold) (font-lock-keyword-face "black" nil bold underline) (font-lock-string-face "black" nil italic) (font-lock-type-face "black" nil italic) (font-lock-variable-name-face "black" nil bold italic) (font-lock-warning-face "black" nil bold italic))))
 '(ps-line-number t)
 '(ps-print-color-p (quote black-white))
 '(rst-level-face-base-color "not-a-color-so-ill-get-black")
 '(save-place t nil (saveplace))
 '(show-paren-mode t nil (paren))
 '(standard-indent 2)
 '(tags-case-fold-search nil)
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;;; Load customizations
;;;
;;; Use a defvar to guard any configurable code, e.g. for code you
;;; only want to run conditionally, set the variable to nil in the
;;; system-custom.el to disable the guarded code. See
;;; extensions/flyspell.el for an example.

;; Add my custom lib dir to the path.
(add-to-list 'load-path "~/.emacs.d/") ;(push "~/.emacs.d" load-path)
;; System (e.g. math.wisc.edu vs uoregon.edu) *specific* code.  In
;; practice I symlink a system specific versioned file here.
(load "~/.emacs.d/system-custom.el" t)
;; Common extensions to load on *all* systems.
(mapc 'load-file (file-expand-wildcards "~/.emacs.d/extensions/*.el"))

;;; Mouse
;; use SHIFT+<arrow> to navigate windows
(windmove-default-keybindings)
;; like focus follows mouse in gnome
;(setq mouse-autoselect-window t)

;;; disable tool bar (DISABLED IN ~/.Xresources NOW)
; some mode might use this in a useful way, e.g. debuggers or web
; browsers.  special case those as necessary ... or only disable for
; specific modes ...

; e.g., something like
; (add-hook 'coq-mode-hook
;           (lambda () (tool-bar-mode t)))

;(if (functionp 'tool-bar-mode)
;    (tool-bar-mode 0))

; less direct way: tool-bar-mode only def in graphics
;(when window-system
;  (tool-bar-mode nil))

;; java
;;
;; make arguments indented only 4 spaces past function, when all
;; function args on subsequent lines.  Good for
;; reallyLongJavaMethodNames.
;;
;; setting the c-style messes up the indent distance (c-basic-offset),
;; so reset after setting c-style.
(add-hook 'java-mode-hook
          (lambda ()
            (progn
              (c-set-style "linux")
              (setq c-basic-offset 4))))

 ; removed
 ;'(desktop-save-mode 1)

; Make M-x apropos, and maybe C-h a, show more results. This var has
; documentation *after* apropos.el loads, e.g. after using M-x
; apropos.
(setq apropos-do-all t)

; Make backspace work more often.
;
; Causes problems in text-only emacs that isn't already broken :P
; (normal-erase-is-backspace-mode 1)

; Soft wrap lines in split frames.  Lines in full width frames are
; soft wrapped by default, and lines in split frames are truncated by
; default.
(setq truncate-partial-width-windows nil)

; Make svn commits hapen in text mode. SVN commit tmp files have names
; like svn-commit.2.tmp or svn-commit.tmp.  NB: it seems the file name
; that the auto-mode regexps match against is a *full* path, so it
; doesn't work to anchor at the beginning (^).
(add-to-list 'auto-mode-alist '("svn-commit\\(\\.[0-9]+\\)?\\.tmp$" . text-mode))

; vi/less style jk navigation in view-mode.  Kind of pointless because
; du keys scroll half page.  But the default <enter>y for <down><up>
; were too annoying.
(when (boundp 'view-mode-map)
  (mapc (lambda (kv) (define-key view-mode-map (car kv) (cadr kv)))
        '(("j" View-scroll-line-forward)
          ("k" View-scroll-line-backward))))

; Make it darker
;(set-foreground-color "grey")
;(set-background-color "black")

;; Enable math-mode by default, i.e. the ` escapes in auctex.
;(require 'latex)                ; defines LaTeX-math-mode
(add-hook 'TeX-mode-hook 'LaTeX-math-mode)

;;; Some customization from the UW CSL .emacs
(column-number-mode t)
(display-time)

;; If you would like smooth scrolling, uncomment this line
(setq scroll-step 1)

;; For a much better buffer list:
(global-set-key "\C-x\C-b" 'electric-buffer-list)

; Not sure which modes become more decorated?
(setq font-lock-maximum-decoration t)

; The default history length, at least in sml-run, is apparently 30,
; which is pretty worthless for an interpreter.
(setq history-length 5000)

;; Make emacs shell display ascii color escapes properly.
(ansi-color-for-comint-mode-on)

; A useful looking snippet for setting up custom colors...

;        (font-lock-make-faces t)
;        (setq font-lock-face-attributes
;              '((font-lock-comment-face "Firebrick")
;                (font-lock-string-face "RosyBrown")
;                (font-lock-keyword-face "Purple")
;                (font-lock-function-name-face "Blue")
;                (font-lock-variable-name-face "DarkGoldenrod")
;                (font-lock-type-face "DarkOliveGreen")
;                (font-lock-reference-face "CadetBlue")))

;;; End CSL stuff

;;; Some customization from
;;; http://www.xsteve.at/prg/emacs/power-user-tips.html

(desktop-load-default) ; From the ``desktop'' docs.

;; save a list of open files in ~/.emacs.desktop
;; save the desktop file automatically if it already exists
;(setq desktop-save 'if-exists)
;;(when (boundp 'desktop-save-mode) ; Not defined on UW CS machines.
;;  (desktop-save-mode 1))

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

;(desktop-read) ; From the ``desktop'' docs.

;; Use M-x desktop-save once to save the desktop.  When it exists,
;; Emacs updates it on every exit.  The desktop is saved in the
;; directory where you started emacs, i.e. you have per-project
;; desktops.  If you ever save a desktop in your home dir, then that
;; desktop will be the default in the future when you start emacs in a
;; dir with no desktop.  See the ``desktop'' docs for more info.

;;; End xsteve stuff.

;;; linum-mode, new in emacs 23
;;
;;; this got annoying on my small screen, and made org-mode slooooow.
;;; need to enable only on large monitor, and not in org-mode ...
;; (when (require 'linum nil t)
;;   (global-linum-mode t)
;;   ;; linum in terminal has no margin after numbers.  don't add the
;;   ;; margin in x11 since then you get two margins.
;;   (when (null (window-system))
;;     (setq linum-format "%d ")))

;;; default font

;; NB: also def in nc:ex command.
;; Variations: terminus:bold terminus-20:bold
(add-to-list 'default-frame-alist '(font . "terminus"))

;;; version control

;; Stop emacs from asking: "Symbolic link to SVN-controlled source
;; file; follow link?" every time I open a symlink to a versioned
;; file.
(setq vc-follow-symlinks t)

;; control-lock
;(require 'control-lock) ; already loaded above
(control-lock-keys)
