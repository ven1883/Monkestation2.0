//yes I did redefine this much behaviour for soul

/obj/item/book/granter/martial/shockstar
	martial = /datum/martial_art/shockstar
	name = "Glowing Autoinjector"
	martial_name = "Shocking Star"
	desc = "A dese machine covered in tubes with a scary looking needle potruding from it. You can hear a faint groan and see a pale yellow glow from within. This doesn't feel safe."
	greet = span_sciradio("You feel the dull warmth of radiation flow through your blood as the supermatter composite is carried to your core. \
	You can finally implement Shocking Star. Use the Stellar Child panel to review.")
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "combat_hypo"
	pages_to_mastery = 0

/obj/item/book/granter/martial/shockstar/on_reading_finished(mob/living/carbon/user)
	var/datum/martial_art/martial_to_learn = new martial()
	martial_to_learn.teach(user)
	user.log_message("learned the martial art [martial_name] ([martial_to_learn])", LOG_ATTACK, color = "orange")

	to_chat(user, span_userdanger("You hear a hiss and feel a jolt of pain as a massive needle punctures your skin!"))
	playsound(user, 'sound/effects/wounds/blood1.ogg', 100)
	playsound(user, 'sound/effects/wounds/crack1.ogg', 100)
	playsound(user, 'sound/items/hypospray.ogg', 200)
	user.emote("scream")
	to_chat(user, "[greet]")
	update_appearance()

/obj/item/book/granter/martial/shockstar/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty autoinjector"
		desc = "It's completely empty. The air around it is warm."
	else
		name = initial(name)
		desc = initial(desc)

/obj/item/book/granter/martial/shockstar/can_learn(mob/user)
	if(!isethereal(user))
		to_chat(user, span_warning("Whatever's inside of there, you don't want to find out. Best you leave it alone."))
		return FALSE
	else
		return TRUE

/obj/item/book/granter/martial/shockstar/attack_self(mob/living/user)
	if(reading)
		to_chat(user, span_warning("You're already using this!"))
		return FALSE
	if(!isliving(user) || !user.can_read(src))
		return FALSE
	if(!can_learn(user))
		return FALSE

	if(uses <= 0)
		recoil(user)
		return FALSE

	on_reading_start(user)
	reading = TRUE
	for(var/i in 1 to pages_to_mastery)
		if(!turn_page(user))
			on_reading_stopped()
			reading = FALSE
			return
	if(do_after(user, 5 SECONDS, src))
		uses--
		on_reading_finished(user)
	reading = FALSE

	return TRUE

/obj/item/book/granter/martial/shockstar/on_reading_start(mob/living/user)
	to_chat(user, span_boldbig("Let's get it over with..."))
	to_chat(user, span_notice("You wrestle with your thoughts as you press the [name] against your flesh..."))

	playsound(user, 'sound/effects/seedling_chargeup.ogg', 50, TRUE)
	user.emote("gasp")

/obj/item/book/granter/martial/shockstar/on_reading_stopped(mob/living/user)
	to_chat(user, span_notice("You stop, and pull the device away from your body."))

/obj/item/book/granter/martial/shockstar/turn_page(mob/living/user)

	if(!do_after(user, 2 SECONDS, src))
		return FALSE

	to_chat(user, span_notice("[length(remarks) ? pick(remarks) : "You keep reading..."]"))
	return TRUE
