;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Wyatt Osterling"
      user-mail-address "wyatt.osterling@hotmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
;; find aspell and hunspell automatically
(cond
 ;; try hunspell at first
 ;; if hunspell does NOT exist, use aspell
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  (setq ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
	;; Please note the list `("-d" "en_US")` contains ACTUAL parameters passed to hunspell
	;; You could use `("-d" "en_US,en_US-med")` to check with multiple dictionaries
	'(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8))))

 ((executable-find "aspell")
  (setq ispell-program-name "aspell")
  ;; Please note ispell-extra-args contains ACTUAL parameters passed to aspell
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")
	))
 )
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;;Centaur Tabs
;;
(centaur-tabs-mode 1)
(setq centaur-tabs-set-icons 1)
;;(global-unset-key [M-left])
;;(global-unset-key [M-right])
;;(global-set-key (kbd "<f7>") nil)
(global-set-key (kbd "M-g <left>") 'centaur-tabs-backward)
(global-set-key (kbd "M-g <right>") 'centaur-tabs-forward)
;;
;;Org mode export
;;
(setq org-export-with-toc nil)
;;
;;Treemacs
;;
(treemacs)
(use-package! treemacs
    :config
    (progn
	(
	 setq treemacs-width 40
	 )
	)
    )
;;
;;Auto Indent Mode
;;
(setq auto-indent-on-visit-file 1)
;;(auto-indent-global-mode) causes issues with org mode. Use auto-indent-disabled-modes-list to fix when you have time.
(setq-default indent-tabs-mode 1)
(setq tab-width 4)
(setq auto-indent-assign-indent-level 4)
(setq auto-indent-untabify-on-save-file nil)
(setq auto-indent-backward-delete-char-behavior nil)
(setq auto-indent-mode-untabify-on-yank-or-paste 'tabify)
;;(setq auto-indent-untabify-on-save-file 'tabify)
(setq auto-indent-untabify-on-visit-file 'tabify)
(setq auto-indent-mode-untabify-on-yank-or-paste nil)
;;(setq auto-indent-indent-style 'aggressive)
(setq doom-font (font-spec :family "JetBrains Mono" :size 18))
;;(setq auto-indent-disabled-modes-list 'org-mode) will break everything if uncommented
