(in-package :lispcord.http)



(defgeneric from-id (snowflake from &optional bot)
  (:documentation "Retrieves the given object via ID, either from the cache or through a REST call.
FROM can be one of :CHANNEL, :GUILD, :USER, :EMOJI, :ROLE or a
discord-place like a channel, a guild and so on"))

;; (defmethod from-id ((s string) any &optional (bot *client*))
;;   (from-id (parse-snowflake s) any bot))

(defgeneric create (content destination &optional bot)
  (:documentation "Sends a POST-request to create the given object."))

(defgeneric edit (content destination &optional bot)
  (:documentation "Sends a PUT or PATCH request to modify the given object"))

(defgeneric erase (object &optional bot)
  (:documentation "Sends a DELETE request to remove the given object"))

(defmethod erase ((n null) &optional (bot *client*))
  (declare (ignore n bot))
  nil)
