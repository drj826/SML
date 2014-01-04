;; -------------------------------------------------------------------
;; use aspell as the spell checker
;;
(setq-default ispell-program-name "../../Aspell/bin/aspell.exe")
(setq text-mode-hook '(lambda()	(flyspell-mode t)))

;; -------------------------------------------------------------------
;; font-lock-mode
;;
;;     Turn on and customize font-lock-mode to see what colornames are
;;     available, execute the lisp command:
;;
;;     list-colors-display
;;
(cond ((fboundp 'global-font-lock-mode)
       ;; Turn on font-lock in all modes that support it
       (global-font-lock-mode t)
       ;; Maximum colors
       (setq font-lock-maximum-decoration t)))

;; -------------------------------------------------------------------
;; transient-mark-mode
;;
;;     Turn on transient mark mode to highlight region between point
;;     and mark.
;;
(transient-mark-mode t)

;; -------------------------------------------------------------------
;; show-paren-mode
;;
;;     Turn on show paren mode.
;;
(show-paren-mode 1)

;; -------------------------------------------------------------------
;; printing
;;
(require 'printing)

;; -------------------------------------------------------------------
;; psvn
;;
;;     Start psvn interface with M-x svn-status
;;
(require 'psvn)

(put 'downcase-region 'disabled nil)

;; -------------------------------------------------------------------
;; disable emacs splash screen
;;
(setq inhibit-splash-screen t)

;; -------------------------------------------------------------------
;; linum mode displays line numbers in the left margin
;;
(global-linum-mode 1)

;; -------------------------------------------------------------------
;; auto-fill-mode
;;
;;     Turn on Auto Fill mode automatically in Text mode and related
;;     modes.

(add-hook 'text-mode-hook '(lambda () (auto-fill-mode 1)))
