;;-----------------------------------------------------------------------------
;; Face settings
;;-----------------------------------------------------------------------------
;; turn off toolbar
(tool-bar-mode -1)

;; this highlights the corresponding parenthese
(show-paren-mode 1)

;; highlight the current region
(transient-mark-mode t)

;; prevent extraneous tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; frame title
(setq frame-title-format "%f")

;; for standing out the environment keywords
(global-font-lock-mode t)

;; load color-theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-classic)

;; line / column number
(line-number-mode t)
(column-number-mode t)

;; set the font
(set-frame-font "-outline-Bitstream Vera Sans Mono-normal-r-normal-normal-11-82-96-96-c-*-iso8859-1")

;;-----------------------------------------------------------------------------
;; Various settings
;;-----------------------------------------------------------------------------
;; turn off jumpy scroll
(setq scroll-step 1
      scroll-conservatively 10000)

;; display the time on modeline
(display-time)

;; changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;; to open a file for editing in an already running Emacs
(server-start)

;; to delete `server' while exit
(add-hook 'kill-emacs-hook
  (lambda()
    (if (file-exists-p "~/.emacs.d/server/server")
      (delete-file "~/.emacs.d/server/server"))))

;; don't show initial Emacs-logo and info
(setq inhibit-splash-screen t)

;; to utilize left window key
(setq w32-pass-lwindow-to-system nil)
(setq w32-lwindow-modifier 'hyper)

;; to stop automatic backup cpies
(setq-default make-backup-files nil)
(setq auto-save-mode nil)

;; to jump between windows
(windmove-default-keybindings)

;; set the fill column
(setq-default fill-column 80)

;; cygwin
(require 'setup-cygwin)

;; aspell
(setq-default ispell-program-name "C:\\Program Files\\Aspell\\bin\\aspell.exe")

;;-----------------------------------------------------------------------------
;; Tools
;;-----------------------------------------------------------------------------
;; for switching buffers
(iswitchb-mode t)

(require 'anything-config)
(require 'anything-gtags)
(global-set-key [(meta a)] 'anything)

;;-----------------------------------------------------------------------------
;; Key bindings
;;-----------------------------------------------------------------------------
;; goto line#
(global-set-key [(meta g)] 'goto-line)
;; undo
(global-set-key [(control z)] 'undo)
;; refresh
(global-set-key [f5] (lambda() (interactive) (revert-buffer t (not (buffer-modified-p)) t)))

;;-----------------------------------------------------------------------------
;; Programming
;;-----------------------------------------------------------------------------
;; tags
(require 'switch-dir)
(autoload 'gtags-mode "gtags" "" t)
(setq gtags-mode-hook
    '(lambda ()
        (define-key gtags-mode-map [(control /)] 'gtags-find-rtag)
        (define-key gtags-mode-map [(control .)] 'gtags-find-tag)
        (define-key gtags-mode-map [(control \')] 'gtags-find-symbol)
        (define-key gtags-mode-map [(control \,)] 'gtags-pop-stack)
        (switch-dir-mode t)
))
(setq gtags-select-mode-hook
    '(lambda ()
        (define-key gtags-select-mode-map [(control \,)] 'gtags-pop-stack)
))

;; cc
(setq c-default-style "bsd")
(setq c-basic-offset 4)
(add-hook 'c-mode-common-hook
    (lambda ()
        (require 'google-c-style)
        (google-make-newline-indent)
        (gtags-mode 1)
))

;; java
(add-to-list 'auto-mode-alist '("\\.cjava\\'" . java-mode))
(add-to-list 'auto-mode-alist '("\\.mm?\\'" . objc-mode))

;; c#
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(setq auto-mode-alist
   (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))
