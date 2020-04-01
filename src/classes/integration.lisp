(in-package :lispcord.classes)

(defclass* account ()
  ((id   :type string)
   (name :type string)))

(define-converters (%to-json from-json) account
  id name)

(defclass* integration (integration-object)
  ((id        :type snowflake)
   (name      :type string)
   (type      :type string)
   (enabled   :type boolean :accessor enabled-p)
   (syncing   :type boolean :accessor syncing-p)
   (role-id   :type snowflake)
   (expire-behavior :type fixnum)
   (expire-grace-period :type fixnum)
   (user      :type user)
   (account   :type account)
   (synced-at :type string)))

(define-converters (%to-json from-json) integration
  (id 'parse-snowflake)
  name type
  (enabled nil (defaulting-writer :false))
  (syncing nil (defaulting-writer :false))
  (role-id '%maybe-sf)
  (expire-behaviour)
  (expire-grace-period)
  (user (caching-reader 'user))
  (account (subtable-reader 'account))
  (synced-at))
