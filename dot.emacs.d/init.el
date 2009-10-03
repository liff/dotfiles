;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when (load (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;;; Set up load path
(add-to-list 'load-path (concat (getenv "HOME") "/.emacs.d/lisp"))
(add-to-list 'load-path (concat (getenv "HOME") "/.emacs.d/lisp/nav"))
(add-to-list 'load-path (concat (getenv "HOME") "/.emacs.d/lisp/haskell"))
(add-to-list 'load-path (concat (getenv "HOME") "/.emacs.d/lisp/scala-mode"))
(add-to-list 'load-path (concat (getenv "HOME") "/.cabal/share/scion-0.1.0.2/emacs"))

;; Load and configure CEDET
(load-file "~/.emacs.d/lisp/cedet-1.0pre6/common/cedet.el")
(semantic-load-enable-excessive-code-helpers)
(require 'semantic-ia)
(require 'semantic-gcc)

;; Load user-local stuff
(if (require 'haml-mode nil t)
    (add-to-list 'auto-mode-alist '("\\.haml\\'" . haml-mode)))
(if (require 'sass-mode nil t)
    (add-to-list 'auto-mode-alist '("\\.sass\\'" . sass-mode)))
(if (require 'haskell-mode nil t)
    (progn
      (add-to-list 'auto-mode-alist '("\\.[hg]s\\'" . haskell-mode))
      (add-to-list 'auto-mode-alist '("\\.hi\\'" . haskell-mode))
      (add-to-list 'auto-mode-alist '("\\.l[hg]s\\'" . literate-haskell-mode))
      (add-hook 'haskell-mode-hook 'turn-on-haskell-decl-scan)
      (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
      (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)))
(if (require 'hs-lint nil t)
    (add-hook 'haskell-mode-hook 'ojh-haskell-hlint))
(require 'inf-haskell nil t)
(require 'haskell-cabal nil t)
(if (require 'scion nil t)
    (progn
      (add-hook 'haskell-mode-hook 'ojh-haskell-scion)
      (setq scion-completing-read-function 'ido-completing-read)))
(if (require 'sr-speedbar nil t)
    (progn
      (global-set-key "\C-cb" 'sr-speedbar-select-window)))
(require 'nav nil t)
(if (require 'scala-mode nil t)
    (add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode)))

;;; Custom functions
(defun yic-kill-current-buffer ()
  "Kill current buffer, no questions asked"
  (interactive)
  (kill-buffer (current-buffer)))

(defun ojh-autoconf-settings ()
  "Reverse the newline and newline-and-indent in autoconf mode"
  (local-set-key "\C-m" 'newline)
  (local-set-key "\C-j" 'newline-and-indent))

(defun ojh-c-common-settings ()
  (c-subword-mode 1))

(defun ojh-java-settings ()
  "Set proper settings for Java"
  (c-set-style "java"))

(defun ojh-ruby-settings ()
  (local-set-key "\C-m" 'newline-and-indent)
  (local-set-key "\C-j" 'newline))

(defun ojh-haskell-hlint ()
  (local-set-key "\C-cl" 'hs-lint))

(defun ojh-haskell-scion ()
  (scion-mode 1)
  (scion-flycheck-on-save 1))

(defun ojh-remove-if (pred list)
  (delq nil
	(mapcar (lambda (e)
		  (if (funcall pred e) nil e))
		list)))

(defconst ojh-buffer-ignore-rx "^\[ *]")

(defun ojh-valid-buffers (buffers)
  (ojh-remove-if
   (lambda (b)
     (string-match ojh-buffer-ignore-rx (buffer-name b)))
   buffers))

(defun ojh-pick-buffer (reversed)
  (let ((buffers (delq (current-buffer)
		       (ojh-remove-if
			(lambda (b)
			  (string-match ojh-buffer-ignore-rx (buffer-name b)))
			(if reversed (reverse (buffer-list)) (buffer-list))))))
    (unless (null buffers)
      (switch-to-buffer (car buffers)))))

(defun ojh-prev-buffer ()
  (interactive)
  (ojh-pick-buffer t))

(defun ojh-next-buffer ()
  (interactive)
  (bury-buffer (current-buffer))
  (ojh-pick-buffer nil))



;;; Key bindings
(global-set-key "\C-cc"    'compile)
(global-set-key "\C-j"     'newline)
(global-set-key "\C-m"     'newline-and-indent)
(global-set-key "\C-xk"    'yic-kill-current-buffer)
(global-set-key "\C-x\C-b" 'ibuffer)
(global-set-key [C-prior]  'ojh-prev-buffer)
(global-set-key [C-next]   'ojh-next-buffer)
(global-set-key "\C-w"     'clipboard-kill-region)
(global-set-key "\M-w"     'clipboard-kill-ring-save)
(global-set-key "\C-y"     'clipboard-yank)
;; Use regex searches by default.
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\C-\M-s" 'isearch-forward)
(global-set-key "\C-\M-r" 'isearch-backward)
(windmove-default-keybindings 'super)


;;; Other
;; whitespace-mode sucks on tty
(if (not (null window-system))
    (progn
      (global-whitespace-mode)))
;; grab my email address from environment, if available
(if (getenv "EMAIL")
    (setq user-mail-address (getenv "EMAIL")))

;; customize stuff that might not be available
(if (boundp 'ibuffer-default-shrink-to-minimum-size)
    (progn
      (setq ibuffer-default-shrink-to-minimum-size t)
      (setq ibuffer-never-show-predicates '("^\\*"))))
(if (fboundp 'cmake-mode)
    (setq auto-mode-alist
	  (append '(("CMakeLists\\.txt\\'" . cmake-mode)
		    ("\\.cmake\\'" . cmake-mode))
		  auto-mode-alist)))
(setq frame-title-format '(buffer-file-name "%f" ("%b")))


;;; Hooks
(add-hook 'autoconf-mode-hook 'ojh-autoconf-settings)
(add-hook 'c-mode-common-hook 'ojh-c-common-settings)
(add-hook 'java-mode-hook     'ojh-java-settings)
;(add-hook 'haskell-mode-hook  'turn-on-haskell-ghci)
(add-hook 'ruby-mode-hook     'ojh-ruby-settings)
(add-hook 'after-save-hook    'executable-make-buffer-file-executable-if-script-p)
;(add-to-list 'auto-mode-alist '("\\.svgz?\\'" . nxml-mode))
;(add-to-list 'auto-mode-alist '("\\.x[ms]l\\'" . nxml-mode))


;;; Load customize files
(load "~/.emacs.d/customizations.el")
(load "~/.emacs.d/faces.el")

