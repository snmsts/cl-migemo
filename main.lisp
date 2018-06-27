(uiop/package:define-package :cl-migemo/main (:nicknames :cl-migemo) (:use :cl :cffi) (:shadow)
  (:export :query :*utf-8-dictionary*) (:import-from :cl-migemo/cffi) (:intern))
(in-package :cl-migemo/main)
;;don't edit above

(eval-when (:load-toplevel)
  (define-foreign-library libmigemo
    (:unix (:or "libmigemo.so.1"))
    (t (:default "libmigemo")))

  (unless (foreign-library-loaded-p 'libmigemo)
    (use-foreign-library libmigemo)))

(defvar *utf-8-dictionary* "/usr/share/cmigemo/utf-8/migemo-dict")

(let (dict handle)
  (defun utf-8 ()
    (if (and (equal dict *utf-8-dictionary*)
             handle)
        handle
        (progn 
          (when handle 
            (cl-migemo/cffi:migemo-close handle))
          (setf handle nil)
          (setf handle (cl-migemo/cffi:migemo-open (setf dict *utf-8-dictionary*)))))))

(defun query (string)
  (cffi:with-foreign-string (v string)
    (let ((result (cl-migemo/cffi:migemo-query (utf-8) v)))
      (prog1
          (foreign-string-to-lisp result)
        (foreign-string-free result)))))
