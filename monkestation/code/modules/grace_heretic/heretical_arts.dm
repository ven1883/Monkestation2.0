//ported directly from Bee, cleaned up and updated to function with TG. thanks bee!

#define COMB1 "DH"
#define COMB2 "HH"
#define COMB3 "HD"
#define COMB4 "DDG"

/datum/martial_art/grace
	name = "Grace"
	id = MARTIALART_GRACE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/grace_help
	var/list/grace_traits = list(TRAIT_HARDLY_WOUNDED, TRAIT_PERFECT_ATTACKER, TRAIT_NOGUNS, TRAIT_THROW_GUNS)

	smashes_tables = TRUE //:3
	display_combos = TRUE

	block_chance = 100  //you can use throw mode to block melee attacks...

	//stuff for heretic growth

/datum/martial_art/grace/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	target.add_traits(grace_traits)
	target.set_armor(target.get_armor().add_other_armor(/datum/armor/scales))

/datum/martial_art/grace/on_remove(mob/living/carbon/human/target)
	target.set_armor(target.get_armor().subtract_other_armor(/datum/armor/scales))
	REMOVE_TRAITS_IN(target, grace_traits)
	. = ..()

/datum/martial_art/grace/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, COMB1))
		reset_streak()
		//tailSweep(attacker, defender)
		return TRUE
	if(findtext(streak, COMB2))
		reset_streak()
		//faceScratch(attacker, defender)
		return TRUE
	if(findtext(streak, COMB3))
		reset_streak()
		//jugularCut(attacker, defender)
		return TRUE
	if(findtext(streak, COMB4))
		reset_streak()
		//tailGrab(attacker, defender)
		return TRUE
	return FALSE

/datum/martial_art/grace/proc/comb1(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/comb2(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/comb3(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/comb4(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/harm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("H",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/disarm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("D",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/grab_act(mob/living/attacker, mob/living/defender)
	add_to_streak("G",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/help_act(mob/living/attacker, mob/living/defender)
	add_to_streak("E",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/grace_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")
