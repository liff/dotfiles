;; customize faces when not using X
(if (null window-system)
  (progn
    (custom-set-faces
     '(hl-line ((t (:background "white" :foreground "black"))))))
  (progn
    (custom-set-faces
     '(cursor ((t (:background "red"))) t)
     '(highlight ((((class color)
		    (min-colors 88)
		    (background light))
		   (:background "#ede9e3"))))
     '(mode-line ((((class color)
		    (min-colors 88))
		   (:background "#ede9e3"
		    :foreground "black"
		    :box (:line-width -1
			  :style released-button))))))
    (if (string-match "^23" emacs-version)
	(custom-set-faces
	 '(default ((t (:inherit nil
			:stipple nil
			:background "white"
			:foreground "black"
			:inverse-video nil
			:box nil
			:strike-through nil
			:overline nil
			:underline nil
			:slant normal
			:weight normal
			:height 80
			:width normal
			:foundry "unknown"
			:family "Consolas")))))
      (custom-set-faces
       '(default ((t (:stipple nil
		      :background "white"
		      :foreground "black"
		      :inverse-video nil
		      :box nil
		      :strike-through nil
		      :overline nil
		      :underline nil
		      :slant normal
		      :weight normal
		      :height 70
		      :width normal
		      :family "b&h-lucidatypewriter"))))))))
