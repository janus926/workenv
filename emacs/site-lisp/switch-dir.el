;;; switch-dir.el --- switch current directory easily from directory list.

;; Copyright (C) 2008 Free Software Foundation, Inc.

;; Author:        Kazuo YAGI <[EMAIL PROTECTED]>
;; Maintainer:    Kazuo YAGI <[EMAIL PROTECTED]>
;; Created:       2008-07-06
;; Last-Updated:  Tue Jul  8 03:11:53 2008
;; Version:       0.9.1
;; Keywords:      cd, directory, tools, gtags, switch-dir
;; Compatibility: GNU Emacs 21.x, GNU Emacs 22.x

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Provides a local minor mode (toggled by M-x switch-dir-mode) to change
;; a directory from directory list.
;;
;; You could make the directory list for using varialbe `switch-dir-alist'
;; to show and select these easily and interactively.
;;
;; This was implemented to satisfy a request for GNU GLOBAL to change
;; a directory easily and interactively where the tag file(GTAGS) is located.

;; `switch-dir-mode' is implemented as a minor mode so that it can work with
;; other major modes. `switch-dir-select-mode' is implemented as a major mode.
;;
;; From now, you can switch directory easily and interactively.
;; It is useful to work with other major modes, for example, GNU GLOBAL.
;;
;; Please copy this file into emacs lisp library directory,
;; and then modify your $HOME/.emacs as follows:
;;
;; If you hope to creat a directory list to show and select,
;; please add the following code to your $HOME/.emacs .
;;
;; ------ $HOME/.emacs ------------------------------------------------
;; (require 'switch-dir)
;; (setq switch-dir-alist
;;       '(("linux source-2.6.25.10" . "/usr/src/linux-2.6.25.10")
;;         ("linux source-2.4.36.6 " . "/usr/src/linux-2.4.36.6")
;;         ("linux source-2.2.26"    . "/usr/src/linux-2.2.26")
;;         ("emacs 23"     . "/home/kyagi/src/emacs-23")
;;         ("emacs 22.2"   . "/home/kyagi/src/emacs-22.2")
;;         ("emacs 22.1"   . "/home/kyagi/src/emacs-22.1")
;;         ("global 5.7.1" . "/home/kyagi/src/global-5.7.1")
;;         ))
;; --------------------------------------------------------------------
;;
;; You can call `switch-dir-mode' and `switch-dir-select' to show and select
;; a diretory from your directory list.
;;
;; If you hope to use `switch-dir-mode' with GNU GLOBAL `gtags-mode', 
;; please add the following code to your $HOME/.emacs .
;;
;; ------ $HOME/.emacs ------------------------------------------------
;; (setq gtags-mode-hook '(lambda () (switch-dir-mode t)))
;; --------------------------------------------------------------------
;;
;; I hope this is useful for you, and ENJOY YOUR HAPPY HACKING!
;;

;;; Code:
(require 'hl-line)

;;
;; switch-dir-mode initialization
;;
(defvar switch-dir-mode nil
  "Non-nil if switch-dir-mode is enabled.")
(make-variable-buffer-local 'switch-dir-mode)

(defvar switch-dir-mode-map (make-sparse-keymap)
  "Keymap used in switch-dir-mode")
(define-key switch-dir-mode-map "\M-~" 'switch-dir-select-mode)
(defvar switch-dir-alist nil
  "Root directory alist of source trees.")
(defconst switch-dir-alist-buffer-name "*SWITCH-DIR-SELECT*"
  "Buffer name for showing and hiding switch-dir-alist.")
;(defvar switch-rootdir nil
;  "The directory you want to go.")
;(defvar switch-currentdir default-directory
;  "Current directory.")

;;
;; switch-dir-select-mode initialization
;;
(defvar switch-dir-select-mode nil
  "Non-nil if switch-dir-select-mode is enabled.")
(make-variable-buffer-local 'switch-dir-select-mode)

(defvar switch-dir-select-mode-map (make-sparse-keymap)
  "Keymap used in switch-dir-select-mode")
(define-key switch-dir-select-mode-map [return] 'switch-change-dir)
(define-key switch-dir-select-mode-map "\^?"    'scroll-down)
(define-key switch-dir-select-mode-map " "      'scroll-up)
(define-key switch-dir-select-mode-map "\C-b"   'scroll-down)
(define-key switch-dir-select-mode-map "\C-f"   'scroll-up)
(define-key switch-dir-select-mode-map "k"      'previous-line)
(define-key switch-dir-select-mode-map "j"      'next-line)
(define-key switch-dir-select-mode-map "p"      'previous-line)
(define-key switch-dir-select-mode-map "n"      'next-line)
(defalias 'switch-dir-select 'switch-dir-select-mode)

;;
;; switch-dir-mode definition
;;
(define-minor-mode switch-dir-mode
  "`switch-dir-mode' is to let you change a directory easily and interactively.
With ARG, turn `switch-dir-mode' on if ARG is positive, off otherwise.

You could create a directory list for using varialbe `switch-dir-alist'
to show and select your list easily and interactively.

`switch-dir-mode' automatically load `hl-line-mode' to make it easier
to select a candidate from list."
  :global     nil
  :group      'programming
  :init-value nil
  :lighter    " SwDir"
  :keymap     switch-dir-mode-map
  :require    'hl-line
  :version    "0.9.1"
  (if switch-dir-mode
      (run-hooks 'switch-dir-mode-hook)))

;;
;; switch-dir-select-mode definition
;;
(defun switch-dir-select-mode ()
  "Switch the switch-dir and change the directory to it."
  (interactive)
  (switch-split-window-for-alist))

;;
;; Utility functions
;;
; Unused currently.
(defun switch-dir-alist-buffer-name-existp ()
  "Check the buffer already exist or not."
  (let ((b))
    (if (catch 'found
          (dolist (b (mapcar (function buffer-name) (buffer-list)))
            (if (string= b switch-dir-alist-buffer-name)
                (throw 'found t))))
        t
      nil)))

; This function is migrated from GNU Emacs 22.1.1 `simpe.el' to here,
; so that GNU Emacs 21.x.y has not it.
(defun line-number-at-pos (&optional pos)
  "Return (narrowed) buffer line number at position POS.
If POS is nil, use current buffer location.
Counting starts at (point-min), so the value refers
to the contents of the accessible portion of the buffer."
  (let ((opoint (or pos (point))) start)
    (save-excursion
      (goto-char (point-min))
      (setq start (point))
      (goto-char opoint)
      (forward-line 0)
      (1+ (count-lines start (point))))))

(defun switch-split-window-for-alist ()
  "Split the current window and show the switch-dir-alist."
  (split-window-vertically)
  (other-window 1)
  (switch-to-buffer switch-dir-alist-buffer-name)
  (kill-all-local-variables)
  (setq truncate-lines t
        major-mode 'switch-dir-select-mode
        mode-name "Switch-Dir-Select")
  (use-local-map switch-dir-select-mode-map)
  (hl-line-mode t)
  (let ((n 0) (dir-alist) (m 1))
    (dolist (dir-conscell switch-dir-alist)
      (insert (format "%2d %-30s %-60s\n" n (car dir-conscell) (cdr 
dir-conscell)))
      (setq n (1+ n)))
    (toggle-read-only t)
    (setq n 0)
    ; If finding current direcoty from the list, move the cursor to this line. 
    (dolist (dir-conscell switch-dir-alist)
      (if (string=
           (expand-file-name (directory-file-name default-directory))
           (expand-file-name (cdr dir-conscell)))
          (setq m (1+ n))
        (setq n (1+ n))))
    (goto-line m))
  (message "Please select a directory you want to switch, and press RETURN.")
  (run-hooks 'switch-dir-select-mode-hook))

(defun switch-change-dir ()
  (interactive)
  (let ((dir) (n))
    (setq n (1- (line-number-at-pos)))
    (setq dir (cdr (nth n switch-dir-alist)))
    (switch-delete-window-for-alist)
    (cd dir)
    (message (format "Now, Switching Directory to %s" dir))))

(defun switch-delete-window-for-alist ()
  "Delete the window of the switch-dir-alist."
  (hl-line-mode -1)
  (kill-buffer switch-dir-alist-buffer-name)
  (other-window 1)
  (delete-other-windows))

(provide 'switch-dir)
