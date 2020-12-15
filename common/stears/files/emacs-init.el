;; -----------------------------------------------------------------------------
;; Package System Initialization
;; -----------------------------------------------------------------------------
(require 'package)
(setq package-archives nil) ;; makes unpure packages archives unavailable
(setq package-enable-at-startup nil)
(package-initialize)

;; -----------------------------------------------------------------------------
;; Splash screen
;; -----------------------------------------------------------------------------
(setq inhibit-splash-screen t
      inhibit-startup-screen t
      initial-scratch-message nil)

;; -----------------------------------------------------------------------------
;; Trailing newline
;; -----------------------------------------------------------------------------
(setq require-final-newline t)

;; -----------------------------------------------------------------------------
;; Show Indent Guides
;; -----------------------------------------------------------------------------
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

;; -----------------------------------------------------------------------------
;; Evil, because why would you do anything else? }-)
;; -----------------------------------------------------------------------------
(use-package
  evil
  :init (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  ;;(defalias #'forward-evil-word #'forward-evil-symbol)
  )

;; -----------------------------------------------------------------------------
;; ag
;; -----------------------------------------------------------------------------
(defalias 'ack 'helm-ag)
(require 'helm-ag)

;; -----------------------------------------------------------------------------
;; Complete Anything
;; -----------------------------------------------------------------------------
(use-package company)

;; -----------------------------------------------------------------------------
;; Themes
;; -----------------------------------------------------------------------------
;; Outdoor use
(use-package pastelmac-theme)

;; Indoor use
(use-package monokai-theme)

(defun outdoors() (interactive) (load-theme 'pastelmac))
(defun indoors() (interactive) (load-theme 'monokai))

;; -----------------------------------------------------------------------------
;; Erlang
;; -----------------------------------------------------------------------------
(use-package
  erlang
  :init
  (setq erlang-electric-commands t)
  )
;; -----------------------------------------------------------------------------
;; EDTS (Erlang) - note that we use a custom version of EDTS so this is more
;; involved than if we could just use the version on MELPA
;; -----------------------------------------------------------------------------

;; EDTS requirements
(use-package auto-highlight-symbol)
(use-package eproject)
(use-package auto-complete)

;; Stop EDTS complaining about the fact that it's being loaded directly
(setq edts-inhibit-package-check t)

;; Load it
(if (locate-file "erl" exec-path)
  (use-package edts-start
               :load-path "stears/edts" ;; Relative to emacs.d/
               )
  )

(add-hook 'erlang-mode-hook
	  (lambda ()
	    (define-key evil-normal-state-local-map (kbd "C-]") 'edts-find-source-under-point)
	    (define-key evil-insert-state-local-map (kbd "C-]") 'edts-find-source-under-point)
      (modify-syntax-entry ?_ "w")))

;; -----------------------------------------------------------------------------
;; Elm
;; -----------------------------------------------------------------------------
(use-package elm-mode)
(add-to-list 'company-backends 'company-elm)
(setq elm-format-on-save t)

;; -----------------------------------------------------------------------------
;; Typescript
;; -----------------------------------------------------------------------------
(use-package typescript-mode)

;; -----------------------------------------------------------------------------
;; Rust
;; -----------------------------------------------------------------------------
(use-package rust-mode)
(use-package cargo)
(use-package toml-mode)

;; -----------------------------------------------------------------------------
;; Purescript
;; -----------------------------------------------------------------------------
(use-package purescript-mode)
(use-package psc-ide)
(use-package dhall-mode)

(add-hook
  'purescript-mode-hook
  (lambda ()
    (psc-ide-mode)
    (company-mode)
    ;;(flycheck-mode)
    (turn-on-purescript-indentation)))

(add-hook 'psc-ide-mode-hook
	  (lambda ()
	    (define-key evil-normal-state-local-map (kbd "C-]") 'psc-ide-goto-definition)
	    (define-key evil-insert-state-local-map (kbd "C-]") 'psc-ide-goto-definition)))

;; -----------------------------------------------------------------------------
;; Indentation Settings
;; -----------------------------------------------------------------------------
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)
(defvaralias 'erlang-indent-level 'tab-width)
(defvaralias 'js-indent-level 'tab-width)

;; -----------------------------------------------------------------------------
;; Neotree
;; -----------------------------------------------------------------------------
(use-package
  neotree
  :init
  ;; Fixed width window is an utterly horrendous idea
  (setq neo-window-fixed-size nil)
  (setq neo-window-width 35)
  ;; When neotree is opened, find the active file and
  ;; highlight it
  (setq neo-smart-open t)
  )

(defun neotree-project-dir ()
  (interactive)
  (let ((project-dir (projectile-project-root))
	(file-name (buffer-file-name)))
    (if project-dir
      (progn
	(neotree-dir project-dir)
	(neotree-find file-name))
      (message "Could not find git project root."))))

(add-hook 'neotree-mode-hook
	  (lambda ()

	    ;; Line numbers are pointless in neotree
	    (linum-mode 0)

	    ;; Neotree keybindings to override evil mode
	    (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
	    (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-enter)
	    (define-key evil-normal-state-local-map (kbd "m a") 'neotree-create-node)
	    (define-key evil-normal-state-local-map (kbd "m c") 'neotree-copy-node)
	    (define-key evil-normal-state-local-map (kbd "m d") 'neotree-delete-node)
	    (define-key evil-normal-state-local-map (kbd "m m") 'neotree-rename-node)
	    (define-key evil-normal-state-local-map (kbd "r") 'neotree-refresh)
	    (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
	    (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))

(define-key evil-normal-state-map (kbd "C-n") 'neotree-project-dir)

;; -----------------------------------------------------------------------------
;; Projectile
;; -----------------------------------------------------------------------------
(use-package
  projectile
  :init
  (setq projectile-enable-caching t)
  :config
  (projectile-global-mode)
  )
(define-key evil-normal-state-map (kbd "C-p") 'projectile-find-file)

;; -----------------------------------------------------------------------------
;; General
;; -----------------------------------------------------------------------------

;; Multiple Major Modes for web content
(use-package web-mode)
(add-to-list 'auto-mode-alist '("\\.hbs$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html$" . web-mode))

(use-package terraform-mode)

(use-package
  rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
  )

(use-package
  editorconfig
  :config
  (editorconfig-mode 1)
  )

(use-package ag)

(use-package
  linum-relative
  :config
  (setq linum-relative-format "%3s ")
  (linum-relative-global-mode)
  )

;; Random Stuff
(setq confirm-nonexistent-file-or-buffer 1)
(setq-default indicate-empty-lines t)
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(defalias 'yes-or-no-p 'y-or-n-p)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; -----------------------------------------------------------------------------
;; Backups
;; -----------------------------------------------------------------------------
(setq
  backup-by-copying t      ; don't clobber symlinks
  backup-directory-alist '(("." . "~/tmp/emacs-saves"))    ; don't litter my fs tree
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t) ; use versioned backups

;; -----------------------------------------------------------------------------
;; Emacs-maintained Stuff
;; -----------------------------------------------------------------------------
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(custom-safe-themes
     (quote
       ("a566448baba25f48e1833d86807b77876a899fc0c3d33394094cf267c970749f" "9d9fda57c476672acd8c6efeb9dc801abea906634575ad2c7688d055878e69d6" "3a3de615f80a0e8706208f0a71bbcc7cc3816988f971b6d237223b6731f91605" "8891c81848a6cf203c7ac816436ea1a859c34038c39e3cf9f48292d8b1c86528" "f78de13274781fbb6b01afd43327a4535438ebaeec91d93ebdbba1e3fba34d3c" "9d4787fa4d9e06acb0e5c51499bff7ea827983b8bcc7d7545ca41db521bd9261" "f81a9aabc6a70441e4a742dfd6d10b2bae1088830dc7aba9c9922f4b1bd2ba50" "715fdcd387af7e963abca6765bd7c2b37e76154e65401cd8d86104f22dd88404" "3b0a350918ee819dca209cec62d867678d7dac74f6195f5e3799aa206358a983" "1012cf33e0152751078e9529a915da52ec742dabf22143530e86451ae8378c1a" default)))
  '(package-selected-packages
     (quote
       (zoom-frm yoshi-theme yaml-mode web-mode use-package typescript-mode toml-mode textmate terraform-mode smex scion rainbow-delimiters railscasts-theme purescript-mode psc-ide projectile pastelmac-theme neotree multi-web-mode monokai-theme magit linum-relative lfe-mode kerl intero helm-swoop hamburg-theme flx-ido evil eproject elm-mode edts editorconfig doom-themes cider cargo ag)))
  '(safe-local-variable-values (quote ((psc-ide-codegen "corefn") (allout-layout . t)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  )
