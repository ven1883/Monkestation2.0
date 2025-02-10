// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch/martial
	name = "ominous hood"
	icon = 'monkestation/code/modules/martial_heretic/armor.dmi'
	worn_icon = 'monkestation/code/modules/martial_heretic/armor.dmi'
	icon_state = "hood"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."

/obj/item/clothing/suit/hooded/cultrobes/eldritch/martial
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon = 'monkestation/code/modules/martial_heretic/armor.dmi'
	worn_icon = 'monkestation/code/modules/martial_heretic/armor.dmi'
	icon_state = "armor_hood"
	hood_up_affix = "_up"
	hood_down_overlay_suffix = ""
	inhand_icon_state = null
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/martial
	// Slightly better than normal cult robes
	armor_type = /datum/armor/cultrobes_eldritch/martial

/datum/armor/cultrobes_eldritch/martial
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 35
	bio = 20
	fire = 20
	acid = 20
	wound = 20



/obj/item/book/granter/martial/grace
	martial = /datum/martial_art/grace
	name = "eldritch book"
	martial_name = "grace"
	desc = "A book filled with unknowable language. Your eyes burn."
	greet = span_brass("")
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	remarks = list(
		"I must prove myself worthy to the masters of the Knoises clan...",
		"Use your tail to surprise any enemy...",
		"Your sharp claws can disorient them...",
		"I don't think this would combine with other martial arts...",
		"Ooga Booga..."
	)

	var/after_use_message = ""

/obj/item/book/granter/martial/grace/on_reading_finished(mob/living/user)
	. = ..()

/obj/item/book/granter/martial/grace/can_learn(mob/user)
	if(!IS_HERETIC_OR_MONSTER(user) && !istype(user.mind.martial_art, martial))
		to_chat(user, span_warning("You try to read the book but can't comprehend any of it."))
		return FALSE
	else if (istype(user.mind.martial_art, martial))
		break_and_run(user)

	else
		return FALSE

/obj/item/book/granter/martial/grace/proc/break_and_run(mob/living/user)
	//1:1 copy of blade break code

	var/turf/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)
	if(IS_HERETIC_OR_MONSTER(user))
		if(do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user, span_warning("As you burn [src], you feel a gust of energy flow through your body. [after_use_message]"))
		else
			to_chat(user, span_warning("You burn [src], but your plea goes unanswered."))
	else
		to_chat(user, span_warning("You burn [src]."))
	playsound(src, SFX_SHATTER, 70, TRUE)
	qdel(src)
	return FALSE
