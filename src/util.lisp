(defpackage :lispcord.util
  (:use :cl :split-sequence)
  (:export #:mapvec
           #:str-concat
           #:jparse
           #:jmake
           #:doit
           #:sethash
           #:make-nonce
           #:mapf
           #:with-table
           #:instance-from-table
           #:since-unix-epoch
           #:*unix-epoch*
           #:vec-extend
           #:vecrem
           #:recur

           #:split-sequence

           #:snowflake
           #:parse-snowflake
           #:to-string
           #:optimal-id-compare))

(in-package :lispcord.util)

(declaim (inline parse-snowflake
                 to-string
                 str-concat
                 jparse
                 jmake
                 since-unix-epoch
                 sethash
                 vecrem))

;; this type allows us to later potentially convert the IDs to numbers
;; without needing to rewrite all the type declerations!
(deftype snowflake () '(unsigned-byte 64))

(declaim (ftype (function (string) (or fixnum null)) parse-snowflake))
(defun parse-snowflake (snowflake-string)
  "Parses a snowflake string to fixnum or returns nil if snowflake is invalid."
  (parse-integer snowflake-string :junk-allowed t))

(defun to-string (obj)
  (format nil "~a" obj))

(defvar optimal-id-compare #'eql)

(defun str-concat (&rest strings)
  (format nil "~{~a~}" strings))

(defun jparse (payload)
  (jonathan:parse payload :as :hash-table))

(defun jmake (alist)
  (jonathan:to-json alist :from :alist))



(defmacro doit (&rest forms)
  (let ((it (intern (symbol-name 'it))))
    `(let (,it)
       ,@(mapcar (lambda (f)
                   (if (eq :! (car f))
                       (cdr f)
                       `(setf ,it ,f)))
                 forms))))

(defmethod v:format-message ((stream stream) (message v:message))
  (format stream "~&~a" (v:content message)))

(defparameter *unix-epoch* (encode-universal-time 0 0 0 1 1 1970 0)
  "Seconds since until 1970")

(defun since-unix-epoch ()
  (- (get-universal-time)
     *unix-epoch*))


(defun sethash (key hash val)
  (setf (gethash key hash) val))


(let ((cnt 0))
  (defun make-nonce ()
    (declare (type fixnum cnt))
    (format nil "~d" (+ (* (get-universal-time) 1000000)
                        (incf cnt)))))

(defmacro with-table ((table &rest pairs) &body body)
  (labels ((partition (list)
             (declare (type cons list))
             (unless (evenp (length list))
               (error "Uneven pair list!"))
             (loop :for i :from 1
                :for x :in list
                :when (oddp i) :collect x :into lst1
                :when (evenp i) :collect x :into lst2
                :finally (return (values lst1 lst2))))
           (key-vals (list)
             (loop :for i :in list :collect `(gethash ,i ,table))))
    (multiple-value-bind (vars keys) (partition pairs)
      `(let ,(mapcar (lambda (var val)
                        `(,var ,val))
                      vars
                      (key-vals keys))
         ,@body))))


(defmacro instance-from-table ((table class) &body pairs)
  `(make-instance ,class
                  ,@(loop :for e :in pairs :counting e :into c
                       :if (evenp c)
                       :collect (if (listp e)
                                    e
                                    `(gethash ,e ,table))
                       :else :collect e)))

(defun vec-extend (obj vec)
  (declare (type array vec))
  (let ((buf (make-array (1+ (length vec))
                         :element-type (array-element-type vec))))
    (dotimes (i (length vec))
      (if (null (aref vec i))
          (progn (setf (aref vec i) obj)
                 (return-from vec-extend vec))
          (setf (aref buf i) (aref vec i))))
    (setf (aref buf (length vec)) obj)
    buf))

(defun mapvec (conversion-fun seq)
  (declare (type function conversion-fun))
  (if seq
      (map '(simple-array * (*)) conversion-fun seq)
      (make-array '(0) :element-type '(simple-array * (*)))))

(defun vecrem (predicate seq)
  (delete-if predicate seq :from-end t))