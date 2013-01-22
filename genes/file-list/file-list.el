;;{{{ Header

;;; file-list.el --- working with alist of filenames
;;
;; Copyright (C) 2002-2011, Thomas A. Gerds <tag@biostat.ku.dk>
;; Version: 1.1.2 (24 Mar 2011)
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;;}}}
;;{{{ Description:
;; The aim is to create a facility which allows to interactively
;; find and work with files, which does not require repeated and
;; time-consuming calls to the unix-command `find'.
;;
;; One of the best features is that the file-list-alist is automatically
;; updated when a new file was added to the listed directories.
;; 
;; An alist with entries of the form (filename . /path/to/filename)
;; enables the following features
;;
;; 1. find files without TYPING and without KNOWING the path (iswitchf).
;; 
;; Examples: M-x file-list-iswitchf RET .emacs RET
;;           M-x file-list-iswitchf RET README RET
;;
;; 2. select and display files in a buffer. then operate on the files
;;    file-list: sorting (by time, name, or size), move, delete, copy, grep, dired, ...
;;
;; Examples: M-x file-list-by-name RET *\.tex$ RET
;;           M-x file-list-by-size-below-directory RET ~/Mail/ RET 1000000 RET
;;
;; and there are some other useful things ...
;;
;; 3. file-list-clear-home: frequently we want to clean a (the HOME)
;;    directory from unwanted files (needs confirmation!):
;;
;;    M-x file-list-clear-home RET
;;
;; 4. find non-human-readable files magically by calling appropriate
;;    programs depending on file-name-extension
;;
;;    Examples: M-x file-list-iswitchf-magic word.doc RET 
;;              C-u M-x file-list-iswitchf-magic tmp.pdf RET gv RET
;;
;;}}}
;;{{{ Usage:
;;; ----------------------------------------------------------------
;; unpack the tar file somewhere in the  (x)emacs-path
;; 
;; (require 'file-list)
;; (file-list-initialize)
;;
;; if this takes too long abort (e.g. `C-g') and set the
;; variable file-list-exclude-dirs, for example:
;;
;; (setq file-list-exclude-dirs
;;      (list
;;       (cons file-list-home-directory
;;	     "\\(^\\\.[a-w]\\|^#\\|^auto$\\|^source$\\|mail$\\)")))
;;
;; you may also try
;;
;; (file-list-default-keybindings)
;;
;; this binds commands to keys as follows:
;; 
;;C-x f		<< Prefix Command >>
;;C-x f L		file-list-by-name-below-directory
;;C-x f P		file-list-by-path-below-directory
;;C-x f U		file-list-update-below-dir
;;C-x f d		file-list-iswitchf-below-directory
;;C-x f f		file-list-iswitchf-file
;;C-x f l		file-list-by-name
;;C-x f m		file-list-iswitchf-magic
;;C-x f p		file-list-by-path
;;C-x f s		file-list-by-size
;;C-x f t		file-list-by-time
;;C-x f u		file-list-update
;;C-x f 4		<< Prefix Command >>
;;C-x f 5		<< Prefix Command >>
;;C-x f 4 d	file-list-iswitchf-below-directory-other-window
;;C-x f 4 f	file-list-iswitchf-file-other-window
;;C-x f 5 d	file-list-iswitchf-below-directory-other-frame
;;C-x f 5 f	file-list-iswitchf-file-other-frame
;;}}}
;;{{{ TODO
;;
;; connect file-list-find-magic to system wide mime type handling
;; file-list-grep: restrict file-list to files with (or without) hits
;; handling of tar files
;;; BUGS
;;; ----------------------------------------------------------------
;;
;;
;;
;;}}}
;;{{{ how it works



;;}}}
;;{{{ autoload
(require 'file-list-display)
(require 'file-list-vars)
(require 'file-list-iswitchf)
(require 'file-list-list)
(require 'file-list-keymap)
(require 'file-list-action)
(require 'file-list-util)
;;}}}
;;{{{ functions that create and modify the file-list-alist 

(defvar file-list-list-files-regexp "^.*[^\.]+$")

(defun file-list-replace-in-string (str regexp newtext &optional literal)
  (if (featurep 'xemacs)
      (replace-in-string str regexp newtext)
    (replace-regexp-in-string regexp newtext str nil literal)))

(defun file-list-list-internal (dir &optional dont-exclude recursive exclude-handler)
  "Lists filenames below DIR and subdirectories of DIR.
The value is an alist of file-names where each entry has the form (filename . path-to-filename).

The directory DIR and its subdirectories with their last modification time are added 
to the variable file-list-dir-list in order to be able later to test if updating is necessary.

If DONT-EXCLUDE is nil, then the function EXCLUDE-HANDLER is called to decide
if the directory should be listed. If EXCLUDE-HANDLER is nil
then the build-in function file-list-exclude-p is used. If RECURSIVE is nil, then
subdirectories of DIR are not listed. If MATCH is non-nil, then only those subdirectories
of DIR are listed that match the regular expression MATCH."
  (let ((dir-list (directory-files dir t file-list-list-files-regexp nil))
	file-list
	(exclude-handler (or exclude-handler 'file-list-exclude-p)) 
	(oldentry (assoc dir file-list-dir-list)))
    ;; update the file-list-dir-list
    (if oldentry
	(setcdr oldentry (nth 5 (file-attributes dir)))
      (add-to-list 'file-list-dir-list
		   (cons (file-name-as-directory dir)
			 (nth 5 (file-attributes dir)))))
    ;;
    (while dir-list
      (let ((entry (car dir-list)))
	(if (file-directory-p entry)
	    (if (and (not dont-exclude)
		     (funcall exclude-handler entry dir))
		(add-to-list
		 'file-list-excluded-dir-list
		 (cons entry "matched file-list-exclude-dirs"))
	      (let ((exists
		     (assoc
		      (setq
		       entry
		       (file-name-as-directory entry))
		      file-list-dir-list)))
		(if file-list-verbose
		    (message "file-list: expanding %s (abort: C-g)" entry))
		(cond
		 ;; directory not accessible
		 ((not (file-accessible-directory-p entry))
		  (add-to-list
		   'file-list-excluded-dir-list
		   (cons entry "not accessible"))
		  nil)
		 ;; directory not readable
		 ((not (file-readable-p entry))
		  (add-to-list
		   'file-list-excluded-dir-list
		   (cons entry "not readable"))
		  nil)
		 ;; directory name is a link
		 ((and (file-symlink-p entry)
		       (not file-list-follow-links))
		  (add-to-list 'file-list-excluded-dir-list
			       (cons entry
				     (format "symlink to %s"
					     (file-symlink-p entry))))
		  nil)
		 ;;
		 ((and (not recursive) exists) nil)
		 ;; 
		 (t
		  (setq file-list
			(append
			 file-list (file-list-list-internal
				    entry dont-exclude recursive exclude-handler)))
; 		    (message "length dir %i" (length file-list))
; 		    (sit-for 1)
		  (when (> (length file-list) file-list-max-length)
		    (error (format "file-list below %s reached maximum length %i (user-option file-list-max-length) " dir file-list-max-length)))
		  ))))
	  ;; 
;	  (when (not (string-match file-list-exclude-files fname))
	  (setq file-list
		(append file-list
			(list
			 (list (file-name-nondirectory entry)
			       (file-name-directory entry))))))
	(setq dir-list (cdr dir-list))))
;    (message "%s files listed below '%s'" (length file-list) dir)
    file-list))

(defun file-list-remove-dir (entry)
  "Argument ENTRY is an element of file-list-dir-list.
Remove all filenames below dir (car entry) from file-list-alist and ENTRY from file-list-dir-list."
  (let* ((dir (car entry))
	 (dir-list (file-list-assoc-dir dir file-list-alist)))
    ;; remove dir from file-list-dir-list
    (setq file-list-dir-list (delq entry file-list-dir-list))
    ;; remove files from file-list-alist
    (setcdr dir-list (delq nil
			   (mapcar
			    (lambda (entry)
			      (if (not (string= dir (cadr entry)))
				  entry nil))
			    (cdr dir-list))))))


(defun file-list-list (dir &optional update dont-exclude recursive remove exclude-handler)
  "Builds and updates the variable file-list-alist entry for directory DIR.

If UPDATE is nil, then existing list is returned. If DONT-EXCLUDE is nil then
subdirectories below DIR are excluded depending on what file-list-exclude-p returns."
  ;; check if dir is assessable 
  (when (not (and (file-readable-p dir)
		  (file-accessible-directory-p dir)))
    (error "Directory %s is either not accessible or not readable." dir))
  ;; initialize the file-list-alist 
  (when  (not file-list-alist)
    (setq file-list-alist
	  (append
	   file-list-alist
	   (list
	    (cons
	     file-list-home-directory nil))))
    ;; (when (y-or-n-p (concat "Read files below" file-list-home-directory "?"))
    ;; (file-list-initialize))
    )
  (let* ((gc-cons-threshold file-list-gc-cons-threshold)
	 (dir (file-name-as-directory (expand-file-name dir)))
	 (dir-list (file-list-assoc-dir dir file-list-alist))
	 (dir-headp (if dir-list
			(string= dir (file-name-as-directory (car dir-list)))))
	 file-list)
    (cond ((not dir-list)
	   (when file-list-verbose
	   (message "file-list: reading %s ... (abort: C-g)" dir))
	   (setq file-list-alist
		 (append
		  file-list-alist
		  (list
		   (cons
		    dir
		    (setq file-list
			  (file-list-list-internal
			   dir dont-exclude 'recursive exclude-handler)))))))
	  ((and dir-headp recursive)
	   (if update
	       (progn
		 (when file-list-verbose
		   (message "file-list: updating %s ..." dir))
		 (setcdr dir-list
			 (setq file-list
			       (file-list-list-internal
				dir dont-exclude recursive exclude-handler))))
	     (setq file-list (cdr dir-list))))
	  ((and update recursive)
	   (when file-list-verbose
	     (message "file-list: updating %s ..." dir))
	   (setcdr dir-list
		   (append
		    (delq nil
			  (mapcar
			   (lambda (entry)
			     (if (not (string-match dir (cadr entry)))
				 ;;FIXME (string= dir (substring (cadr entry) 0 (length dir)))
				 entry nil))
			   (cdr dir-list)))
		    (setq file-list (file-list-list-internal dir dont-exclude recursive exclude-handler)))))
	  (update
	   (when file-list-verbose
	     (message "file-list: updating %s ..." dir))
	   ;; not recursive!!
	   (setcdr dir-list
		   (append
		    (delq nil
			  (mapcar
			   (lambda (entry)
			     (if (not (string= dir (cadr entry)))
				 entry nil))
			   (cdr dir-list)))
		    (setq file-list (file-list-list-internal dir dont-exclude nil exclude-handler)))))
	  ((not
	    (setq file-list
		  (delq nil
			(mapcar
			 (lambda (entry)
			   (if (string-match dir (cadr entry))
			       entry nil))
			 (cdr dir-list)))))
	   (when file-list-verbose
	     (message "file-list: reading %s ... (abort: C-g)" dir)	   )
	   (setcdr dir-list
		   (append (cdr dir-list)
			   (setq file-list (file-list-list-internal dir dont-exclude 'recursive exclude-handler))))))
    (when file-list-verbose
      (message "%s files %s below '%s'" (length file-list) "listed" dir))
    file-list))


(defun file-list-initialize ()
  "Initialize the file-list-home-directory entry to file-list-alist,
by listings all the entries of file-list-default-directories."
  (interactive)
  ;; idea: first initialize an empty file-list-alist, then
  ;; list the subdirs specified by file-list-default-directories.
  (setq file-list-alist (list (cons file-list-home-directory nil)))
  ;; initialize all files sitting in the home directory
  (file-list-list file-list-home-directory 'yes nil nil nil nil)
  ;; adding the home directory to the dir-list
  (add-to-list 'file-list-dir-list
	       (cons (file-name-as-directory file-list-home-directory)
		     (nth 5 (file-attributes file-list-home-directory))))
  (let ((initDirs file-list-default-directories)
	subDir)
    (while initDirs
      (setq subDir (car initDirs))
      (file-list-update-below-dir subDir)
;       (file-list-list subDir 'update nil 'recursive nil)
      (setq initDirs (cdr initDirs)))))


(defun file-list-update (&optional dir force dont-exclude recursive)
  "Re-read filenames below dir from disk if changed on disk."
  (interactive "i\nP")
  (let* ((gc-cons-threshold file-list-gc-cons-threshold)
	 (dir (if dir (file-name-as-directory
		       (expand-file-name dir)) file-list-home-directory))
	 (dirinlist (assoc dir file-list-dir-list))
	 (dlist (delq nil (mapcar
			   (lambda (x)
			     (if (string-match dir (car x)) x nil))
			   file-list-dir-list)))
	 update-info)
    (if (or (not dirinlist) force)
	(file-list-list dir t dont-exclude recursive nil)
      (while dlist
	(let* ((dircons (car dlist))
	       (fis (file-exists-p (car dircons))))
	  (if (not fis)
	      ;; remove
	      (progn
		(file-list-remove-dir dircons)
		(setq update-info (append (list (concat (car dircons) " *removed* ")))))
	    ;; check modification time of dir 
	    (when (file-list-time-less-p (cdr dircons) (nth 5 (file-attributes (car dircons))))
	      ;; update
	      (file-list-list (car dircons) t nil nil)
	      (setq update-info (append (list (car dircons)) update-info))))
	  (setq dlist (cdr dlist))))
      (if (> (length update-info) 0)
	  (if (= (length update-info) 1)
	      (when file-list-verbose
		(message "%s updated" (car update-info)))
	    (save-window-excursion
	      (pop-to-buffer (get-buffer-create "*file-list-update*"))
	      (erase-buffer)
	      (insert "Updated directories: \n\n")
	      (mapcar (lambda (x) (insert x "\n")) update-info)))
	(when file-list-verbose
	(message "No directory below %s has changed" dir))))))

(defun file-list-update-below-dir (dir)
  "Re-read filenames below dir from disk."
  (interactive "DUpdate filenames below dir ")
  (let ((gc-cons-threshold file-list-gc-cons-threshold))
	(file-list-update dir t)))


(defun file-list-update-file-alist (&optional file delete)
  (let* ((gc-cons-threshold file-list-gc-cons-threshold)
	 (file-name (expand-file-name
		     (or file
			 (buffer-file-name (current-buffer)))))
	 (file-cons (file-list-make-entry file-name))
	 (file-dir (cadr file-cons)))
    (dolist (dir-list file-list-alist)
      (when (string-match (car dir-list) file-dir)
	(if delete (delete file-cons dir-list)
	  (when (not (member file-cons dir-list))
	    (setcdr dir-list (cons file-cons (cdr dir-list)))))))))

;;(add-hook 'after-save-hook 'file-list-update)	

(defun file-list-update-current-file-list (oldname newname)
  (let ((oldentry (find-if (lambda (item) (string= oldname (file-list-make-file-name item))) file-list-current-file-list))
	(newentry (file-list-make-entry newname)))
    (setcar oldentry (car newentry))
    (setcdr oldentry (cdr newentry))))


;;}}}
;;{{{ internal functions that alter the file-list-alist

(defun file-list-assoc-dir (dir list)
  (assoc-if '(lambda (entry)
	       (or (string-match entry dir)
		   (string-match (file-list-replace-in-string
				  (file-list-replace-in-string entry "\\[" "\\[")
				  "\\]" "\\]") dir)))
	    list))

(defun file-list-include-p (subdir dir regexp)
  (file-list-exclude-p subdir dir regexp t))

(defun file-list-exclude-p (subdir dir &optional regexp include)
  "Decide if the directory SUBDIR below DIR should be excluded
from listing. If REGEXP is given then the SUBDIR is excluded if 
REGEXP matches the part of the path between DIR and SUBDIR.

For example, SUBDIR = /home/aUser/research/oldStuff/ below DIR
/home/aUser/ would match the REGEXP \"^old\".
If REGEXP is nil, then use the first matching entry of DIR in the
alist file-list-exclude-dirs.

If INCLUDE is non-nil, then SUBDIR is excluded if it does not match REGEXP."
  (let* ((regexp
	  (or regexp
	      (cdr (assoc-if (lambda (entry)
			       (string-match entry dir))
			     file-list-exclude-dirs))))
	 (subDir (file-name-as-directory (expand-file-name subdir)))
	 decision)
    (when regexp
      (setq decision (string-match regexp subDir)))
    (if include (not decision) decision)))
    

(defun file-list-extract-sublist (file-list regexp-or-test &optional dont-match)
  ;; if regexp-or-test is not a string it must be a function taking one argument
  ;; which is then applied to each entry in file-list.
  ;; default is string-match regexp against filename
  (let ((test (if (stringp regexp-or-test)
		  '(lambda (entry)
		     (let ((match-p (string-match regexp-or-test (car entry))))
		       (if dont-match
			   (when (not match-p) entry)
			 (when match-p entry))))
		regexp-or-test)))
    (delete nil (mapcar test file-list))))


;;mapcar this function on a file-list ...
(defun file-list-make-file-name (entry)
  "Concats path-name and file-name of entry."
  (concat  (cadr entry) (car entry)))


(defun file-list-make-entry (filename)
  "Returns a cons where the car equals the nondirectory part of filename
and the cdr is the directory of filename."
  (list (file-name-nondirectory filename)
	(file-name-directory filename)))


(defun file-list-concat-file-names (file-list)
  "Returns a string consisting of all absolut filenames in file-list separated by blanks."
  (let (file-names-as-string)
    (dolist (file file-list file-names-as-string)
      (setq file-names-as-string
	    (concat file-names-as-string
		    "\'" (file-list-make-file-name file) "\' ")))
    file-names-as-string))

;;}}}

;;{{{ unused
;; (defun file-list-length ()
;; (let ((llist (mapcar 'length file-list-alist))
;; (len 0))
;; (dolist (entry llist len)
;; (setq len (+ entry len)))))
;;}}}

(provide 'file-list)

;; file-list.el ends here

