;;; key-snps.el --- keybindings for emacs-genome

;; Copyright (C) 2012  Thomas Alexander Gerds

;; Author: Thomas Alexander Gerds <tag@biostat.ku.dk>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(global-set-key [f10] 'undo)
(global-set-key "\M-o" 'other-window)
;; buffer cycling
(global-set-key "\M-p" 'next-mode-buffer-backward)
(global-set-key "\M-n" 'next-mode-buffer)
;; commentary
(global-set-key "\C-c;" 'comment-or-uncomment-line)
(global-set-key "\M-;" 'comment-line)
;; major-mode specific indentation
(global-set-key "\M-q" 'emacs-genome-indent-paragraph) 
(global-set-key "\M-Q" '(lambda () (interactive) (mark-paragraph) (fill-region-as-paragraph (region-beginning) (region-end))))
;; marking text
(global-set-key "\M-l" 'mark-line)
(global-set-key "\M-\C-l" 'mark-end-of-line)
;; expanding text
(global-set-key "\M-e" 'hippie-expand)
(global-set-key "\M-i" 'dabbrev-expand)

(provide 'key-snps)
;;; key-snps.el ends here