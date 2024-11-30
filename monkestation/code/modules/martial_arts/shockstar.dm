#define COMB1 "DH"
#define COMB2 "HH"
#define COMB3 "HD"
#define COMB4 "DDG"

#define SHOCKSTAR_MAX_CHARGE = 5

/datum/martial_art/shockstar
	name = "Shocking Star"
	id = MARTIALART_SHOCKSTAR
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/shockstar_help

/datum/martial_art/shockstar/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return

/datum/martial_art/shockstar/on_remove(mob/living/carbon/human/target)
	. = ..()

/datum/martial_art/shockstar/proc/check_streak(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(findtext(streak,COMB1))
		streak = ""
		tailSweep(attacker,defender)
		return TRUE
	if(findtext(streak,COMB2))
		streak = ""
		faceScratch(attacker,defender)
		return TRUE
	if(findtext(streak,COMB3))
		streak = ""
		jugularCut(attacker,defender)
		return TRUE
	if(findtext(streak,COMB4))
		streak = ""
		tailGrab(attacker,defender)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to Alien Queen's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/shockstar/proc/tailSweep(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)

//Face Scratch, deals 30 brute to head(reduced by armor), blurs the defender's vision and gives them the confused effect for a short time.
/datum/martial_art/shockstar/proc/faceScratch(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)

/*
Jugular Cut
Deals 15 damage to the target plus 10 seconds of oxygen loss and 10 oxyloss, with an open laceration
If the target is T3 grabbed or sleeping, instead deal 60 damage with a weeping avulsion alongside the previous.
*/
/datum/martial_art/shockstar/proc/jugularCut(mob/living/carbon/attacker, mob/living/carbon/defender)

//Tail Grab, instantly puts your defender in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/shockstar/proc/tailGrab(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if (defender.stat == DEAD)
		to_chat(attacker, span_warning("[defender] is dead. There's no point in trying to stop their heart."))
		return MARTIAL_ATTACK_INVALID


/datum/martial_art/shockstar/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("H",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/shockstar/disarm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("D",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/shockstar/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("G",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/shockstar_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, span_notice("Tail Sweep</span>: Disarm Harm. Pushes everyone around you away and knocks them down."))
	to_chat(usr, span_notice("Face Scratch</span>: Harm Harm. Damages your target's head and confuses them for a short time."))
	to_chat(usr, span_notice("Jugular Cut</span>: Harm Disarm. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition."))
	to_chat(usr, span_notice("Tail Grab</span>: Disarm Disarm Grab. Grabs your target by their neck and makes them unable to talk for a short time."))

#undef SHOCKSTAR_MAX_CHARGE
