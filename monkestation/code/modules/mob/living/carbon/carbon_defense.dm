/mob/living/carbon/is_pepper_proof(check_flags = ALL)
	if(HAS_TRAIT(src, TRAIT_NOBREATH) && is_eyes_covered())
		return src // this returns an object instead of a bool for some reason, even tho nothing uses it, let's be safe
	return ..()

/**
  *	Returns the bodypart that the item is embedded in or returns false if it is not currently embedded
  */
/mob/living/carbon/proc/get_embedded_part(obj/item/embedded)
	if(!embedded)
		return FALSE
	var/obj/item/bodypart/body_part
	for(var/obj/item/bodypart/part in bodyparts)
		if(embedded in part.embedded_objects)
			body_part = part
	if(!body_part)
		return FALSE

	if(embedded.loc != src)
		LAZYREMOVE(body_part.embedded_objects, embedded)
		if(!has_embedded_objects())
			clear_alert("embeddedobject")
			//SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "embedded")
		return FALSE
	return body_part
