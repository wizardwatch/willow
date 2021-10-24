;;
;; Package Manager
;;

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;;
;; Use Package
;;

(unless ( package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;
;; Packages
;;


;; selctrum

(use-package selectrum)
(selectrum-mode +1)

;; evil

(use-package evil)
(require 'evil)
(evil-mode 1)

;; undo-tree

(use-package undo-tree)
(require 'undo-tree)

;; treemacs

;; (use-package treemacs
;;   :ensure t
;;   :defer t
;;   :init
;;   (with-eval-after-load 'winum
;;     (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
;;   :config
  ;; (progn
  ;;   (setq treemacs-collapse-dirs		   (if treemacs-python-executable 3 0)
  ;; 	  treemacs-deferred-git-apply-delay	   0.5
  ;; 	  treemacs-directory-name-transformer	   #'identity
  ;; 	  treemacs-display-in-side-window	   t
  ;; 	  treemacs-eldoc-display		   t
  ;; 	  treemacs-file-event-delay		   5000
  ;; 	  treemacs-file-extension-regex		   treemacs-last-period-regex-value
  ;; 	  treemacs-file-follow-delay		   0.2
  ;; 	  treemacs-file-name-transformer	   #'identity
  ;; 	  treemacs-follow-after-init		   t
  ;; 	  treemacs-git-command-pipe		   ""
  ;; 	  treemacs-goto-tag-strategy		   'refetch-index
  ;; 	  treemacs-indentation			   4
  ;; 	  treemacs-indentation-string              " "
  ;; 	  treemacs-is-never-other-window	   nil
  ;; 	  treemacs-max-git-entries		   5000
  ;; 	  treemacs-missing-project-action	   'ask
  ;; 	  treemacs-move-forward-on-expand	   nil
  ;; 	  treemacs-no-png-images		   nil
  ;; 	  treemacs-no-delete-other-windows	   t
  ;; 	  treemacs-project-follow-cleanup	   nil
  ;; 	  treemacs-persist-file			   (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
  ;; 	  treemacs-position			   'left
  ;; 	  treemacs-read-string-input		   'from-child-frame
  ;; 	  treemacs-recenter-distance		   0.1
  ;; 	  treemacs-recenter-after-file-follow	   nil
  ;; 	  treemacs-recenter-after-tag-follow	   nil
  ;; 	  treemacs-recenter-after-project-jump	   'always
  ;; 	  treemacs-recenter-after-project-expand   'on-distance
  ;; 	  treemacs-show-cursor			   nil
  ;; 	  treemacs-show-hidden-files		   nil
  ;; 	  treemacs-silent-filewatch		   nil
  ;; 	  treemacs-silent-refresh		   nil
  ;; 	  treemacs-sorting			   'alphabetic-asc
  ;; 	  treemacs-space-between-root-nodes	   t
  ;; 	  treemacs-tag-follow-cleanup		   t
  ;; 	  treemacs-tag-follow-delay		   1.5
  ;; 	  treemacs-user-mode-line-format	   nil
  ;; 	  treemacs-user-header-line-format	   nil
  ;; 	  treemacs-width			   75
  ;; 	  treemacs-workspace-switch-cleanup	   nil
  ;; 	  )
    
  ;;   ;; The default width and height of the icons is 22 pixels. If you are
  ;;   ;; using a Hi-DPI display, uncomment this to double the icon size.
  ;;   ;; (treemacs-resize-icons 44)
    
  ;;   (treemacs-follow-mode t)
  ;;  ;;  (treemacs-filewatch-mode t)
;;   ;;   (treemacs-fringe-indicator-mode 'a
;; 				    lways)
;;     (pcase (cons (not (null (executable-find "git")))
;; 		 (not (null treemacs-python-executable)))
;;       (`(t . t)
;;        (treemacs-git-mode 'deferred))
;;       (`(t . _)
;;        (treemacs-git-mode 'simple))))
;;   :bind
;;   (:map global-map
;; 	("M-0"		 . treemacs-select-window)
;; 	("C-x t 1"	 . treemacs-delete-other-windows)
;; 	("C-x t t"	 . treemacs)
;; 	("C-x t B"	 . treemacs-bookmark)
;; 	("C-x t C-t" . treemacs-find-file)
;; 	("C-x t M-t" . treemacs-find-tag)))

;; (use-package treemacs-evil
;;   :after (treemacs evil)
;;   :ensure t)

;; (use-package treemacs-projectile
;;   :after (treemacs projectile)
;;   :ensure t)

;; (use-package treemacs-icons-dired
;;   :after (treemacs dired)
;;   :ensure t
;;   :config (treemacs-icons-dired-mode))

;; (use-package treemacs-magit
;;   :after (treemacs magit)
;;   :ensure t)

;; (use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
;;   :after (treemacs persp-mode) ;;or perspective vs. persp-mode
;;   :ensure t
;;   :config (treemacs-set-scope-type 'Perspectives))
;; (treemacs)

;; Centaur Tabs

;; (use-package centaur-tabs
;;   :init
;;   (setq centaur-taba-enable-keyb-bindings t)
;;   :demand
;;   :config
;;   (centaur-tabs-mode t)
;;   (setq centaur-tabs-set-icons t)
;;   (setq centaur-tabs-height 32)
;;   :bind
;;   ("C-<prior>" . centaur-tabs-backward)
;;   ("C-<next>" . centaur-tabs-forward))

;; All The Icons

;; (use-package all-the-icons)

;; buffer names


(setq frame-title-format
    '((:eval (if (buffer-file-name)
                  (abbreviate-file-name (buffer-file-name))
                    "%b"))
      (:eval (if (buffer-modified-p) 
                 " •"))
       " - Emacs")
    )
(defvar ww/original-frame-title-format frame-title-format
  "The original frame title format")
(setq frame-title-format '(:eval (if (eq major-mode 'dired-mode) "dired" ww/original-frame-title-format)))
;; dired



(use-package dired-subtree
  :config
  (bind-keys :map dired-mode-map
             ("<right>" . dired-subtree-insert)
             ("<left>" . dired-subtree-remove)))
;; (add-hook 'dired-mode-hook (lambda () (set-frame-name "dired")))

;; nix-mode

(use-package nix-mode
  :mode "\\.nix\\'")

;; OrgMode

(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(use-package org-roam)
;; ;; (make-directory "~/org-roam")
;;(setq org-roam-directory "~/org-roam")
;;(add-hook 'after-init-hook 'org-roam-mode)
(setq org-pretty-entities t)
(setq org-pretty-entities-include-sub-superscripts t)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
(add-hook 'org-mode-hook 'flyspell-mode)
(use-package org-appear)
(use-package org-fragtog)
(add-hook 'org-mode-hook 'org-appear-mode)
(add-hook 'org-mode-hook 'org-fragtog-mode)
(add-hook 'org-mode-hook 'org-latex-preview)
(setq org-appear-autolinks 1)
;; pdf tools

(use-package pdf-tools
   :pin manual
   :config
   (pdf-tools-install)
   (setq-default pdf-view-display-size 'fit-width)
   (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
   :custom
   (pdf-annot-activate-created-annotations t "automatically annotate highlights"))
(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;; language server protcol

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (java-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;;(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package company)
(require 'lsp-mode)
(use-package lsp-java)

;; pinentry

(use-package pinentry)
(pinentry-start)
(setenv "GPG_AGENT_INFO" nil)

;;magit

(use-package forge
  :after magit)
(use-package ghub)
(ghub-request "GET" "/user" nil
              :forge 'github
              :host "api.github.com"
              :username "wizardwatch"
              :auth 'forge)
(setq auth-sources '("~/.authinfo.gpg"))


;;
;; Graphics
;;

;; Disable stuff
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq use-dialog-box nil)

;; ;; Enable stuff
(global-hl-line-mode t)
(add-to-list 'default-frame-alist '(font . "Iosevka-14"))
(set 'pop-up-frames 'graphic-only)
;; ;; Theme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t	 ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-dracula t)
  
  ;; Enable flashing mode-line on errors
;;  (doom-themes-visual-bell-config)


;;   ;; Treemacs
;;   (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
;;  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))	
(use-package rainbow-identifiers)
(add-hook 'prog-mode-hook 'rainbow-identifiers-mode)


;;
;; frames-only-mode
;;
(use-package frames-only-mode)
;;
;; Behavior
;;
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

;; (global-set-key (kbd "TAB") 'self-insert-command);
(setq-default indent-tabs-mode t)
(setq indent-line-function 'insert-tab)
(setq tab-width 4)
;; (defvaralias 'c-basic-offset 'tab-width)
;; (defvaralias 'cperl-indent-level 'tab-width)
(server-start)

;;(setq evil-shift-width 8)
(setq backward-delete-char-untabify-method 'hungry)
;;
;; debugging
;;
(add-to-list 'after-init-hook
          (lambda ()
            (message (concat "emacs (" (number-to-string (emacs-pid)) ") started in " (emacs-init-time)))))

(defun executable-find (command)
  "Search for COMMAND in `exec-path' and return the absolute file name.
Return nil if COMMAND is not found anywhere in `exec-path'."
  ;; Use 1 rather than file-executable-p to better match the behavior of
  ;; call-process.
  (locate-file command exec-path exec-suffixes 1))


;; Auto insert

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/Documents/agenda.org"))
 '(package-selected-packages
   '(centaur-tabs use-package undo-tree treemacs-projectile treemacs-persp treemacs-magit treemacs-icons-dired treemacs-evil selectrum)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
