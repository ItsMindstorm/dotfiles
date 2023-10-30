(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(defun reload-init-file ()
  "Reload the `init.el` configuration file."
  (interactive)
  (load-file (expand-file-name "~/.emacs.d/init.el")))

(use-package evil
  :init
  (setq evil-want-C-u-scroll t
        evil-want-keybinding nil) ;; Enable C-u for scrolling
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo))

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "RET") nil))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-nerd-commenter
  :after evil)

(use-package toc-org
  :defer
  :commands toc-org-enable
  :hook (org-mode . toc-org-enable))

(use-package org-superstar
  :defer
  :hook
  (org-mode . (lambda () (org-superstar-mode 1)))
  :config
  (setq org-ellipsis "⤵"
        org-superstar-special-todo-items t
        org-superstar-todo-bullet-alist
        '(("TODO" . ?☐)
          ("DONE" . ?✔))))

(use-package org-tree-slide
  :defer
  :commands (org-tree-slide-mode)
  :bind
  ("<f8>" . org-tree-slide-move-previous-tree)
  ("<f9>" . org-tree-slide-move-next-tree)
  )

(org-babel-do-load-languages
 'org-babel-load-languages
 '((js . t)
   (C . t)
   (java . t)
   (python . t)))

(nconc org-babel-default-header-args:java
       '((:dir . "/tmp/")))

(setq org-babel-default-header-args:js
             '((:exports . "both") (:results . "output")))

(setq org-latex-listings 'minted
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
	"pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

(setq org-confirm-babel-evaluate nil)

(use-package org-auto-tangle
  :defer
  :hook (org-mode . org-auto-tangle-mode))

(setq org-directory "~/org")
(setq org-agenda-files '("Todos.org"))

(setq
 ;; org-fancy-priorities-list '("[A]" "[B]" "[C]")
 ;; org-fancy-priorities-list '("❗" "[B]" "[C]")
 org-fancy-priorities-list '("🟥" "🟧" "🟨")
 org-priority-faces
 '((?A :foreground "#ff6c6b" :weight bold)
   (?B :foreground "#98be65" :weight bold)
   (?C :foreground "#c678dd" :weight bold))
 org-agenda-block-separator 8411)

(setq org-agenda-custom-commands
      '(("v" "A better agenda view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (tags "PRIORITY=\"B\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Medium-priority unfinished tasks:")))
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority unfinished tasks:")))
          (tags "customtag"
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Tasks marked with customtag:")))

          (agenda "")
          (alltodo "")))))

(setq org-agenda-timegrid-use-ampm 1)

(use-package org-roam
  :defer
  :after org
  :commands (org-roam-buffer-toggle
             org-roam-node-find
             org-roam-node-insert
             org-roam-node-insert-immediate)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n I" . org-roam-node-insert-immediate))
  :config
  (setq org-roam-v2-ack t)
  (org-roam-setup)
  )

;; Bind this to C-c n I
(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(use-package org-roam-ui
  :commands (org-roam-ui-open)
  )

(use-package org-fragtog
  :defer
  :hook (org-mode . org-fragtog-mode))

(use-package org-download)

(setq org-hide-emphasis-markers t)

(use-package org-appear
  :defer
  :hook (org-mode . org-appear-mode))

(setq org-return-follows-link t)

(setq org-startup-indented t
      org-startup-with-inline-images t
      org-pretty-entities t
      org-image-actual-width '(300))

(use-package auctex-latexmk
  :hook (latex-mode . auctex-latexmk-setup)
  :config
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(setq tab-width 2)
(setq-default ident-tabs-mode nil)

(use-package projectile
  :defer 
  :config
  (projectile-mode +1))

(use-package counsel-projectile
  :after projectile
  :defer
  :commands
  (counsel-projectile-find-file
   counsel-projectile-grep
   counsel-projectile-switch-project
   counsel-projectile-switch-to-buffer)
  :config
  (counsel-projectile-mode 1))

(use-package magit
  :commands magit
  )
(elpaca-wait)

(use-package neotree
  :defer
  :commands neotree-toggle
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)
      neo-window-width 25
      neo-smart-open t
      neo-show-hidden-files t)
  :bind
  (:map evil-normal-state-map
        ("C-n" . neotree-toggle))
  )

(use-package tmux-pane
  :defer 1
  :config
  (tmux-pane-mode)
  )

(use-package centaur-tabs
  :defer 2
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-headline-match)
  (setq centaur-tabs-height 40
        centaur-tabs-style "wave"
        centaur-tabs-set-icons t
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-set-bar 'under
        x-underline-at-descent-line t
        centaur-tabs-set-modified-marker t))

(use-package avy
  :defer
  :commands (avy-goto-char-2))

(use-package yasnippet-snippets
    :after yasnippet)

  (use-package yasnippet
    :defer 1
    :config
    (yas-global-mode 1)
    )

(use-package ivy-yasnippet
  :defer
  :commands (ivy-yasnippet)
  :bind (:map evil-insert-state-map 
  ("C-c y" . ivy-yasnippet)))

(use-package eglot
  :defer
  :hook
  (c++-mode . eglot-ensure)
  (tsx-ts-mode . eglot-ensure)
  (js-mode . eglot-ensure)
  (js-jsx-mode . eglot-ensure)
  :config
  (setq lsp-prefer-flymake nil
        lsp-prefer-capf t
        gc-cons-threshold 100000000
        read-process-output-max (* 1024 1024)
        lsp-idle-delay 0.5
        eglot-events-buffer-size 0
        lsp-log-io nil)
  )

(use-package dap-mode
  :after eglot
  :config
  (setq dap-auto-configure-mode t))

(use-package corfu
  :defer
  ;; Optional customizations
  :hook
  (prog-mode . corfu-mode)
  (org-mode . corfu-mode)
  (corfu-mode . corfu-history-mode)
  (corfu-mode . corfu-echo-mode)
  :config
  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-prefix 1
        corfu-auto-delay 0.0
        corfu-preview-current nil
        )
  :bind (:map corfu-map ("TAB" . corfu-next)
              ("S-TAB" . corfu-previous)
              ("RET" . nil)
              )
  )

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)
  )

(use-package cape
  :config
  (add-to-list 'completion-at-point-functions #'cape-file ))

(use-package yasnippet-capf
  :elpaca (:host github :repo "elken/yasnippet-capf")
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf)
  (setq yasnippet-capf-lookup-by 'key)
  )

(use-package tree-sitter 
  :hook
  (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (global-tree-sitter-mode)
  )

(use-package tree-sitter-langs
  :after tree-sitter)

(use-package format-all
  :hook (format-all-ensure-formatter . format-all-mode)
  (prog-mode . format-all-mode)
)

;; Indent blankline
(use-package highlight-indent-guides
  :defer
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character
      highlight-indent-guides-responsive 'top)
  )

(use-package rainbow-delimiters
  :defer
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :defer
  :hook (prog-mode . rainbow-mode))

(use-package smartparens
  :hook
  (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))

(use-package emmet-mode
  :defer
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode) 
  (add-hook 'css-mode-hook  'emmet-mode)
  (add-hook 'emmet-jsx-major-modes 'js-mode 'typescript-mode)
  )

(use-package direnv
  :defer
  :hook (prog-mode . direnv-mode)
  )

(use-package tsx-ts-mode
  :elpaca nil
  :mode
  "\\.tsx\\'"
  "\\.ts\\'")

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package prisma-mode
  :mode "\\.prisma\\'"
  :elpaca (:host github :repo "pimeys/emacs-prisma-mode" :branch "main"))

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :config (setq markdown-command "pandoc")
  )

(use-package arduino-mode
  :mode ("\\.ino\\'" . arduino-mode)
  )

(use-package eshell-toggle
  :elpaca (:host github :repo "4DA/eshell-toggle")
  :config
  (setq eshell-toggle-size-fraction 3))

(use-package which-key
  :defer 1
  :config
  (which-key-mode 1)
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t))

(use-package general
  :defer 2 
  :config
  (general-evil-setup)
  (general-create-definer ys/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")


  (ys/leader-keys
    "f" '(:ignore t :wk "projectile")
    "ff" '(counsel-projectile-find-file :wk "Find file")
    "fb" '(counsel-projectile-switch-to-buffer :wk "Switch to buffer")
    "fp" '(counsel-projectile-switch-project :wk "Switch project")
    "fg" '(counsel-projectile-grep :wk "Grep for file")
    )

  (ys/leader-keys
    "x" '(kill-this-buffer :wk "Kill buffer"))

  (ys/leader-keys
    "j" '(avy-goto-char-2 :wk "Search buffer"))

  (ys/leader-keys
    "s" '(:ignore t :wk "window")
    "sh" '(evil-window-split :wk "Horizontal split")
    "sv" '(evil-window-vsplit :wk "Vertical split")
    "sp" '(langtool-check :wk "Check with langtool")
    "sc" '(:ignore t :wk "Correct")
    "scp" '(langtool-correct-at-point :wk "Correct at point")
    "scb" '(langtool-correct-buffer :wk "Correct buffer"))

  (ys/leader-keys
    "b" '(evilnc-comment-or-uncomment-lines :wk "Comment"))


  (ys/leader-keys
    "t" '(eshell-toggle :wk "vterm")
    )

  (ys/leader-keys
    "e" '(emmet-expand-line :wk "emmet"))

  (ys/leader-keys
    "c" '(centaur-tabs-ace-jump :wk "Jump to tab")
    )

  (ys/leader-keys
    "l" '(:ignore t :wk "Lsp")
    "lr" '(eglot-rename :wk "Rename reference")
    "lf" '(format-all-buffer
           :wk "Formats buffer"))

  (ys/leader-keys
    "o" '(:ignore t :wk "Org")
    "oa" '(org-agenda :wk "Org agenda")
    "oe" '(org-export-dispatch :wk "Org export")
    "oi" '(org-toggle-item :wk "Org toggle Item")
    "ot" '(org-todo :wk "Org Todo")
    "oT" '(org-todo-list :wk "Org Todo List")
    "op" '(org-tree-slide-mode :wk "Present")
    )

  (ys/leader-keys
    "g" '(magit :wk "Open magit"))
  )

(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-modeline
  :defer 1
  :config (doom-modeline-mode 1))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
(setq dashboard-banner-logo-title "Welcome to Emacs")
(setq dashboard-startup-banner 'logo)
(setq dashboard-center-content t)

;; Sets which dashboard items should show
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)))

(setq dashboard-set-file-icons t)
(setq dashboard-set-heading-icons t)
(setq dashboard-display-icons-p t
      dashboard-icon-type 'all-the-icons)
(setq dashboard-heading-icons '((recents   . "history")
                                (bookmarks . "bookmark")
                                (agenda    . "calendar")
                                (projects  . "rocket")
                                (registers . "database"))))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
      doom-modeline-enable-word-count t
      )
  (load-theme 'doom-dracula t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(add-to-list 'default-frame-alist '(font . "JetBrainsMono NF-15"))
(setq display-line-numbers-type 'relative 
      display-line-numbers-current-absolute t)

(use-package display-line-numbers-mode
  :elpaca nil
  :defer
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq display-line-numbers-type 'relative
        display-line-numbers-current-absolute t))

(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
  	      neotree-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda() (display-line-numbers-mode 0))))

(use-package ligature
  :hook (prog-mode . ligature-mode)
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://")))

(use-package beacon
  :defer 2
  :config
  (setq beacon-blink-when-window-scrolls t)
  (beacon-mode 1))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(set-frame-parameter nil 'alpha-background 70) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 70)) ; For all new frames henceforth

(use-package centered-window
  :defer
  :hook
  (org-mode . centered-window-mode))

(use-package langtool
  :commands (langtool-check
	     langtool-check-done
	     langtool-show-message-at-point
	     langtool-correct-buffer)
  :init (setq langtool-default-language "en-US")
  :config
  (unless (or langtool-bin
	      langtool-language-tool-jar
	      langtool-java-classpath)
    (cond ((setq langtool-bin
		 (or (executable-find "languagetool-commandline")
		     (executable-find "languagetool")))))))  ; for nixpkgs.languagetool

;; Automatically reverts buffers for changed files
(global-auto-revert-mode 1)

;; Reverts dired as well
(setq global-auto-revert-non-file-buffers t)

;; Remembers the last place you visited in a file
(save-place-mode 1)

;; Disable unrelated warnings
(setq warning-minimum-level :error)

;; Disable lock file creation
(setq create-lockfiles nil)

;; Removes annoying prompts
(setq use-short-answers t)
