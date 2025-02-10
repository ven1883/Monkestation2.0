/*
* # Path of grace.
*
* Tree:
*
*	Beginning
*	Grasp
*	Dash
*		>Ashen Eyes
*		>Flesh (gloves)
*	Martial Mark
*	Ritual of Knowledge
*	Dash (upgrade)
*	Armor
*		>Mask of Madness
*		>Wave of Desparation
*	Martial Arts Improvement
*	Crush
*		>Ashen Ritual
*		>Apetra Vulnera
*	Ascension
*/
/datum/heretic_knowledge/limited_amount/starting/grace
	name = "martial placeholder"
	desc = "Sphynx of black quartz, judge my vow."
	gain_text = "the placeholder placeholder placeholder placeholder"
	next_knowledge = list(/datum/heretic_knowledge/graceful_grasp)
	required_atoms = list(
		/obj/item/pen,
		list(/obj/item/paperwork, /obj/item/book) = 2,
	)
	result_atoms = list(/obj/item/book/granter/martial/grace)
	limit = 1
	route = PATH_GRACE

/datum/heretic_knowledge/graceful_grasp
	name = "Graceful Grasp"
	desc = "Your Mansus Grasp will burn the eyes of the victim, causing damage and blindness."
	gain_text = "The Nightwatcher was the first of them, his treason started it all. \
		Their lantern, expired to ash - their watch, absent."
	//next_knowledge = list(/datum/heretic_knowledge/spell/dash)
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/graceful_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/graceful_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/graceful_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.is_blind())
		return

	if(!target.get_organ_slot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("[source] picks you up by the throat and lifts you into the air!"))
	target.grabbedby(source, TRUE)
	source.setGrabState(GRAB_NECK)
	target.adjustOxyLoss(30)
	target.set_eye_blur_if_lower(20 SECONDS)
