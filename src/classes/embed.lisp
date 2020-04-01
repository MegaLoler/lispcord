(in-package :lispcord.classes)

(defclass* embed-footer ()
  ((text           :type string)
   (icon-url       :type (or null string))
   (proxy-icon-url :type (or null string))))

(define-converters (%to-json from-json) embed-footer
  text icon-url proxy-icon-url)

(defclass* embed-generic ()
  ((url       :type (or null string))
   (proxy-url :type (or null string))
   (height    :type (or null fixnum))
   (width     :type (or null fixnum))))

(define-converters (%to-json from-json) embed-generic
  url proxy-url height width)

(export-pub make-embed-generic)
(defun make-embed-generic (&key url)
  (make-instance 'embed-generic
                 :url url
                 :proxy-url nil
                 :height nil
                 :width nil))

(deftype embed-image () 'embed-generic)
(deftype embed-thumbnail () 'embed-generic)

(defclass* embed-video ()
  ((url    :type (or null string))
   (height :type (or null fixnum))
   (width  :type (or null fixnum))))

(define-converters (%to-json from-json) embed-video
  url height width)

(defclass* embed-provider ()
  ((name :type (or null string))
   (url  :type (or null string))))

(define-converters (%to-json from-json) embed-video
  name url)

(defclass* embed-author ()
  ((name           :type (or null string))
   (url            :type (or null string))
   (icon-url       :type (or null string))
   (proxy-icon-url :type (or null string))))

(define-converters (%to-json from-json) embed-author
  name url icon-url proxy-icon-url)

(defclass* embed-field ()
  ((name   :type string)
   (value  :type string)
   (inline :type boolean :accessor inline-p)))

(define-converters (%to-json from-json) embed-field
  name value
  (inline nil (defaulting-writer :false)))

(defclass* embed ()
  ((title       :type (or null string))
   (type        :type (or null string))
   (description :type (or null string))
   (url         :type (or null string))
   (timestamp   :type (or null string))
   (color       :type (or null fixnum))
   (footer      :type (or null embed-footer))
   (image       :type (or null embed-generic))
   (thumbnail   :type (or null embed-generic))
   (video       :type (or null embed-video))
   (provider    :type (or null embed-provider))
   (author      :type (or null embed-author))
   (fields      :type (vector embed-field))))

(export-pub make-embed)
(defun make-embed (&key title type description url timestamp color footer image thumbnail video provider author fields)
  (make-instance 'embed
                 :title title
                 :type type
                 :description description
                 :url url
                 :timestamp timestamp
                 :color color
                 :footer footer
                 :image image
                 :thumbnail thumbnail
                 :video video
                 :provider provider
                 :author author
                 :fields fields))

(define-converters (%to-json from-json) embed
  title type description url timestamp color
  (footer    (subtable-reader 'embed-footer))
  (image     (subtable-reader 'embed-generic))
  (thumbnail (subtable-reader 'embed-generic))
  (video     (subtable-reader 'embed-video))
  (provider  (subtable-reader 'embed-provider))
  (author    (subtable-reader 'embed-author))
  (fields    (subtable-vector-reader 'embed-field)))
