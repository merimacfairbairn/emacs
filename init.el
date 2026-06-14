;; NOTE: init.el is now generated from Emacs.org.  Please edit that file
;;       in Emacs and init.el will be generated automatically!

;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 140)
(defvar efs/default-variable-font-size 140)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(90 . 90))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
					;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable GUI prompts
(setq use-dialog-box nil)
(setq use-file-dialog-box nil)
(setq use-short-answers t)  ;y/n

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil :font "Iosevka" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Iosevka Curly" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Open Sans" :height efs/default-variable-font-size :weight 'regular)

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  ;; Ensure certain faces remain fixed-pitch
  (setq mixed-pitch-fixed-pitch-faces
        '(org-code
          org-block
          org-table
          org-verbatim
          org-meta-line
          org-checkbox
          line-number
          line-number-current-line))
  ;; Optionally adjust the height of variable-pitch text
  (setq mixed-pitch-set-height t))

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;; Completion UI
(use-package vertico
  :ensure t
  :bind (:map vertico-map
	      ("C-j" . vertico-next)
	      ("C-k" . vertico-previous)
	      ("C-f" . vertico-exit)
	      :map minibuffer-local-map
	      ("M-h" . backward-kill-word))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

;; Rich annotations
(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))

;; Better matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))

;; Counsel replacement
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-M-j" . consult-buffer)
         :map minibuffer-local-map
         ("C-r" . consult-history)))

;; Optional but highly recommended
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defconst efs/org-directory
  (expand-file-name "~/Org/")
  "Root directory for Org files.")

;;;; Directories

(defconst efs/org-archives-directory
  (expand-file-name "archives/" efs/org-directory))

(defconst efs/org-projects-directory
  (expand-file-name "projects/" efs/org-directory))

(defconst efs/org-logbooks-directory
  (expand-file-name "logbooks/" efs/org-archives-directory))

(defconst efs/org-archive-projects-directory
  (expand-file-name "projects/" efs/org-archives-directory))

;;;; Files

(defconst efs/org-inbox-file
  (expand-file-name "inbox.org" efs/org-directory))

(defconst efs/org-perso-file
  (expand-file-name "perso.org" efs/org-directory))

(defconst efs/org-habits-file
  (expand-file-name "habits.org" efs/org-directory))

(defconst efs/org-logbook-archive-file
  (expand-file-name "logbook.org_archive"
                    efs/org-logbooks-directory))

(defun efs/org-project-files ()
  "Return all Org files in the projects directory."
  (directory-files-recursively
   efs/org-projects-directory
   "\\.org$"))

(defun efs/org-archive-files ()
  "Return all Org files in the archives directory."
  (directory-files-recursively
   efs/org-archives-directory
   "\\.org$"))

(defun efs/open-org-file (file)
"Open FILE if it exists, otherwise create it and open it."
(interactive "fOrg file: ")
(unless (file-exists-p file)
  (make-directory (file-name-directory file) t)
  (write-region "" nil file))
(find-file file))

(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  (unless (eq org-journal-file-type 'daily)
    (org-narrow-to-subtree))
  (goto-char (point-max)))


(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-clock-in-switch-to-state "CURR")

  (setq org-special-ctrl-a/e t)
  (setq org-M-RET-may-split-line nil)

  (setq org-effort-property "EFFORT")

  (setq org-agenda-files
        (append
         (list efs/org-inbox-file
               efs/org-perso-file
               efs/org-habits-file)
         (efs/org-archive-files)
         (efs/org-project-files)))
  
  (setq org-agenda-window-setup 'only-window)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "CURR(c!)" "HOLD(h@)"
                    "|"
                    "DONE(d)" "ABRT(a@)")
          (sequence "MEET(m)"
                    "|"
                    "DONE(d)" "ABRT(a@)")))

  ;; Save Org buffers after refiling
  (advice-add 'org-refile :after #'org-save-all-org-buffers)

  (setq org-tag-alist
        '(("@URGENT" . ?u)
          ("@REFILE" . ?r)
          ("@CURR" . ?c)))

  (setq efs/org-filetags
        '("@PERSO" "@PROJECT" "@WORK"))

  (defun efs/agenda-skip-tags (&rest args)
    "Skip tags passed as ARGS in the agenda view."
    (let (beg end)
      (org-back-to-heading t)
      (setq beg (point)
            end (progn (outline-next-heading)
                       (1- (point))))
      (goto-char beg)
      (setq alltags (prin1-to-string (org-get-tags)))
      (goto-char beg)
      (if (-some (lambda (x)
                   (string-match x alltags))
                 args)
          end)))

  (defun efs/agenda-skip-property (property value)
    "Skip an agenda entry if PROPERTY equals VALUE."
    (let ((subtree-end (save-excursion
                         (org-end-of-subtree t))))
      (if (string=
           (org-entry-get nil property)
           value)
          subtree-end
        nil)))

  (setopt org-agenda-sorting-strategy
          '((agenda time-up deadline-up scheduled-up todo-state-up priority-down)
            (todo todo-state-up priority-down deadline-up)
            (tags todo-state-up priority-down deadline-up)
            (search todo-state-up priority-down deadline-up)))

  (setq org-agenda-prefix-format
        "%-10:c %-12t %-6e %s")

  (setq org-agenda-hide-tags-regexp
        (mapconcat #'identity
                   efs/org-filetags
                   "\\|"))

  (setq efs/org-perso-agenda-views
        '(("p" "Perso agenda"
           (
            (agenda ""
                    ((org-agenda-show-all-dates nil)
                     (org-agenda-use-time-grid nil)
                     (org-agenda-span 14)
                     (org-agenda-start-on-weekday nil)
                     (org-deadline-warning-days 14)
                     (org-agenda-show-log t)
                     (org-agenda-skip-function
                      '(efs/agenda-skip-tags "@WORK"))))

            (tags "@PERSO+@REFILE|@PERSO+@URGENT"
                  ((org-agenda-overriding-header
                    "Inbox || Urgent:")))

            (tags-todo "@PERSO+@CURR|@PERSO+TODO={CURR}|@PERSO+TODO={HOLD}"
                       ((org-agenda-overriding-header
                         "In Progress:")
                        (org-agenda-skip-function
                         '(or
                           (efs/agenda-skip-property
                            "STYLE"
                            "habit")
                           (efs/agenda-skip-tags
                            "monthlygoals")))))

            (tags "@PERSO+monthlygoals-TODO={DONE}"
                  ((org-agenda-overriding-header
                    "Monthly Goals:")))

            (tags-todo "@PERSO+TODO={TODO}-@REFILE"
                       ((org-agenda-overriding-header
                         "Next:")
                        (org-agenda-skip-function
                         '(or
                           (org-agenda-skip-entry-if
                            'scheduled)
                           (org-agenda-skip-entry-if
                            'deadline)
                           (efs/agenda-skip-property
                            "STYLE"
                            "habit")
                           (efs/agenda-skip-tags
                            "monthlygoals")))))

            (todo "DONE|ABRT"
                  ((org-agenda-overriding-header
                    "Completed:")
                   (org-agenda-skip-function
                    '(efs/agenda-skip-tags
                      "@WORK"
                      "monthlygoals"))))))))

  (setq org-agenda-custom-commands
        (append org-agenda-custom-commands
                efs/org-perso-agenda-views))

  (setq org-refile-targets
        `((,efs/org-inbox-file
           :maxlevel . 5)
          (,efs/org-perso-file
           :maxlevel . 5)
          (,(efs/org-project-files)
           :maxlevel . 5)))

  (setq org-capture-templates
        `(("p" "Perso Capture")

          ("pt" "Task"
           entry
           (file ,efs/org-inbox-file)
           "* TODO [#B] %^{task} %^g\n  :LOGBOOK:\n  - CREATED: %U\n  :END:\n%?\n")

          ("pn" "Note"
           entry
           (file ,efs/org-inbox-file)
           "* %^{item} %^g\n  :LOGBOOK:\n  - CREATED: %U\n  :END:\n%?\n")

          ("pm" "Meeting"
           entry
           (file ,efs/org-inbox-file)
           "* MEET [#A] %^{meeting} %^g\n  SCHEDULED: %^T\n  :LOGBOOK:\n  - CREATED: %U\n  :END:\n%?\n")

	  ("pj" "Journal"
	   plain
	   (function org-journal-find-location)
	   "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
	   :jump-to-captured t :immediate-finish t)))

  (efs/org-font-setup))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(use-package org-journal
  :ensure t
  :defer t
  :init
  ;; Change default prefix key (C-c j); needs to be set before loading org-journal
  (setq org-journal-prefix-key "C-c j")
  :config
  (setq org-journal-dir (expand-file-name "diary/" efs/org-directory))
  (setq org-journal-file-format "%Y-%m-%d.org"))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme
   '(navigation
     insert
     textobjects
     additional
     shift
     todo)))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package org-modern
  :ensure t
  :config
  (setopt org-modern-star 'replace)
  (setopt org-modern-replace-stars "◉○●")
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))

(use-package org-appear
  :commands (org-appear-mode)
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-hide-emphasis-markers t)
  (setq org-appear-autoemphasis t
	org-appear-autolinks    t
	org-appear-autosubmarkers t))

(use-package jinx
  :hook (text-mode . jinx-mode)
  :bind ([remap ispell-word] . jinx-correct)
  :custom
  (jinx-languages "en_GB"))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :states '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
  (general-create-definer efs/local-leader-keys
    :states '(normal visual motion)
    :prefix ","
    :global-prefix "C-,")
  
  (efs/local-leader-keys
    :keymaps 'org-mode-map

    ;; Checkboxes
    "SPC" '(org-toggle-checkbox :wk "toggle checkbox")

    ;; TODOs
    "t"  '(org-todo :wk "todo")

    ;; Dates
    "d"  '(org-deadline :wk "deadline")
    "s"  '(org-schedule :wk "schedule")
    "T"  '(org-time-stamp :wk "timestamp")

    ;; Edit source
    "'" '(org-edit-src-code :wk "edit source")

    ;; Headings
    "h"  '(:ignore t :wk "heading")
    "hh" '(org-insert-heading :wk "insert")
    "ht" '(org-insert-todo-heading :wk "todo heading")
    "hu" '(org-up-element :wk "up")
    "hn" '(org-next-visible-heading :wk "next")
    "hp" '(org-previous-visible-heading :wk "prev")

    ;; Subtree
    "x"  '(:ignore t :wk "subtree")
    "xa" '(org-archive-subtree :wk "archive")
    "xr" '(org-refile :wk "refile")
    "xk" '(org-cut-subtree :wk "cut")
    "xy" '(org-copy-subtree :wk "copy")

    ;; Priority
    "p"  '(:ignore t :wk "priority")
    "pp" '(org-priority :wk "set")

    ;; Links
    "l"  '(:ignore t :wk "links")
    "li" '(org-insert-link :wk "insert")
    "ls" '(org-store-link :wk "store")
    "lo" '(org-open-at-point :wk "open")

    ;; Tables
    "b"  '(:ignore t :wk "table")
    "ba" '(org-table-align :wk "align")
    "br" '(org-table-recalculate :wk "recalc")

    ;; Clocking
    "c"  '(:ignore t :wk "clock")
    "ci" '(org-clock-in :wk "in")
    "co" '(org-clock-out :wk "out")
    "cr" '(org-clock-report :wk "report")

    ;; Navigation
    "g"  '(:ignore t :wk "goto")
    "gc" '(org-goto :wk "goto")
    "gi" '(org-id-get-create :wk "create id")

    ;; Visibility
    "v"  '(:ignore t :wk "visibility")
    "vc" '(org-cycle :wk "cycle")
    "va" '(org-cycle-global :wk "global cycle")

    ;; Export
    "e"  '(:ignore t :wk "export")
    "eh" '(org-html-export-to-html :wk "html")
    "ep" '(org-latex-export-to-pdf :wk "pdf")

    ;; Babel
    "r"  '(:ignore t :wk "run")
    "rb" '(org-babel-execute-src-block :wk "block")
    "ra" '(org-babel-execute-buffer :wk "buffer")
    )

  (efs/leader-keys
    ;; M-x
    "SPC" '(execute-extended-command :which-key "M-x")
    "/" '(consult-ripgrep :which-key "Search Project")
    "!" '(shell-command :which-key "shell")
    
    ;; HELP
    "h" '(:ignore t :which-key "help")
    "hf" '(describe-function :which-key "describe function")
    "hm" '(describe-mode :which-key "describe mode")
    "hb" '(describe-bindings :which-key "describe bindings")
    "hv" '(describe-variable :which-key "describe variable")
    "hk" '(describe-key :which-key "describe key")
    "hx" '(describe-command :which-key "describe command")
    "ho" '(describe-symbol :which-key "describe symbol")
    "hs" '(describe-syntax :which-key "describe syntax")
    "hrr" '((lambda () (interactive) (load-file user-init-file)) :which-key "reload config")

    ;; PROJECTILE
    "p" '(projectile-command-map :which-key "projectile")

    ;; GIT
    "g" '(:ignore t :which-key "git")
    "gs" '(magit-status :which-key "status")
    "gi" '(magit-init :which-key "init")

    ;; TOGGLES
    "t"  '(:ignore t :which-key "toggles")
    "ts" '(hydra-text-scale/body :which-key "scale text")

    ;; BUFFERS
    "b" '(:ignore t :which-key "bufs")
    "bb" '(consult-buffer  :which-key "switch")
    "bk" '(kill-this-buffer :which-key "kill")
    "be" '(erase-buffer :which-key "erase")
    "bs" '(scratch-buffer :which-key "scratch")

    ;; CAPTURES
    "c" '(:ignore t :wk "captures")
    "cc" '(org-capture :wk "menu")

    ;; WINDOWS
    "w" '(:ignore t :wk "windows")
    "wh" '(evil-window-left :wk "left")
    "wj" '(evil-window-down :wk "down")
    "wk" '(evil-window-up :wk "up")
    "wl" '(evil-window-right :wk "right")
    "ww" '(evil-window-next :wk "next")

    "wH" '(evil-window-move-far-left :wk "move left")
    "wJ" '(evil-window-move-very-bottom :wk "move down")
    "wK" '(evil-window-move-very-top :wk "move up")
    "wL" '(evil-window-move-far-right :wk "move right")

    "w+" '((lambda () (interactive)
             (evil-window-increase-height 5))
           :which-key "increase height")

    "w-" '((lambda () (interactive)
             (evil-window-decrease-height 5))
	   :which-key "decrease height")

    "w>" '((lambda () (interactive)
             (evil-window-increase-width 5))
	   :which-key "increase width")

    "w<" '((lambda () (interactive)
             (evil-window-decrease-width 5))
	   :which-key "decrease width")

    "ws" '(evil-window-split :wk "split")
    "wv" '(evil-window-vsplit :wk "vsplit")

    "wq" '(evil-window-delete :wk "quit")

    ;; AGENDA
    "a" '(org-agenda :which-key "Agenda")

    ;; FILES
    "." '(find-file :which-key "find file")
    "f" '(:ignore t :which-key "files")
    "fp" '(:ignore t :wk "perso agenda")
    "fpp" '(lambda () (interactive) (efs/open-org-file efs/org-perso-file))
    "fpi" '(lambda () (interactive) (efs/open-org-file efs/org-inbox-file))
    "fpl" '(lambda () (interactive) (efs/open-org-file efs/org-logbook-archive-file) "logbook.org")
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.config/emacs/init.org")))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
   :keymaps 'lsp-mode-map
   :prefix lsp-keymap-prefix
   "d" '(dap-hydra t :wk "debugger")))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :after python-mode
  :config
  (pyvenv-mode 1))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 3)
  (corfu-auto-delay 0.2)
  (corfu-cycle t)
  (corfu-preview-current t)
  (corfu-preselect 'prompt)

  :bind
  (:map corfu-map
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)
        ("RET" . corfu-insert))

  :init
  (global-corfu-mode))

(use-package emacs
  :custom
  (tab-always-indent 'complete))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters
               #'kind-icon-margin-formatter))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init

  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/")
    (setq projectile-project-search-path '("~/Projects/")))
  (when (file-directory-p "~/Org/")
    (setq projectile-project-search-path '("~/Org/")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package consult-projectile
  )

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package javelin
  :ensure t
  :config
  (global-javelin-minor-mode 1))

(use-package term
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(when (eq system-type 'windows-nt)
  (setq explicit-shell-file-name "powershell.exe")
  (setq explicit-powershell.exe-args '()))

(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
