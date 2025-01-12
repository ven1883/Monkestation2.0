//Broken Will: Applied by Devour Will, and functions similarly to Kindle. Induces sleep for 30 seconds, broken instantly by taking more than a certain amount of damage. //yogs start: darkspawn
/datum/status_effect/broken_will
	id = "broken_will"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 30 SECONDS
	//examine_text = span_deadsay("SUBJECTPRONOUN is in a deep, deathlike sleep, with no signs of awareness to anything around them.")
	alert_type = /atom/movable/screen/alert/status_effect/broken_will
	///how much damage taken in one hit will wake the holder
	var/wake_threshold = 5

/datum/status_effect/broken_will/on_apply()
	if(owner)
		RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))
		ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
	return ..()

/datum/status_effect/broken_will/on_remove()
	if(owner)
		UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
		owner.SetUnconscious(0) //wake them up
	return ..()

/datum/status_effect/broken_will/tick()
	if(is_team_darkspawn(owner) || owner.stat == DEAD)
		qdel(src)
		return
	owner.Unconscious(15)
	if(owner.health <= HEALTH_THRESHOLD_CRIT)
		owner.heal_ordered_damage(3, list(BURN, BRUTE)) //so if they're left to bleed out, they'll survive, probably?
		if(prob(10))
			to_chat(owner, span_velvet("sleep... bliss...")) //give a notice that they're probably healing because of the sleep

/datum/status_effect/broken_will/proc/on_take_damage(datum/source, damage, damagetype)
	if(damage < wake_threshold)
		return
	owner.visible_message(span_warning("[owner] is jolted awake by the impact!") , span_boldannounce("Something hits you, pulling you towards wakefulness!"))
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, type)
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_NOSOFTCRIT, type), 20 SECONDS)
	ADD_TRAIT(owner, TRAIT_RESIST_DAMAGE_SLOWDOWN, type)
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_RESIST_DAMAGE_SLOWDOWN, type), 20 SECONDS)
	qdel(src)

/atom/movable/screen/alert/status_effect/broken_will
	name = "Broken Will"
	desc = "..."
	icon_state = "broken_will"
	alerttooltipstyle = "alien"

//used to prevent the use of devour will on the target
/datum/status_effect/devoured_will
	id = "devoured_will"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 3 MINUTES
	alert_type = null

/datum/status_effect/time_dilation //used by darkspawn; greatly increases action times etc
	id = "time_dilation"
	duration = 600
	alert_type = /atom/movable/screen/alert/status_effect/time_dilation
	//examine_text = span_warning("SUBJECTPRONOUN is moving jerkily and unpredictably!")

/datum/status_effect/time_dilation/on_apply()
	owner.next_move_modifier *= 0.5
	owner.add_actionspeed_modifier(0.5)
	owner.ignore_slowdown(id)
	return TRUE

/datum/status_effect/time_dilation/on_remove()
	owner.next_move_modifier *= 2
	owner.add_actionspeed_modifier(0.5)
	owner.unignore_slowdown(id)

/datum/actionspeed_modifier
	multiplicative_slowdown = 0.5

/datum/status_effect/speedboost
	id = "speedboost"
	duration = 30 SECONDS
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null //might not even be a speedbuff, so don't show it
	var/speedstrength

/datum/status_effect/speedboost/on_creation(mob/living/new_owner, strength, length, identifier)
	duration = length
	speedstrength = strength
	. = ..()

/datum/status_effect/speedboost/on_apply()
	. = ..()
	if(. && speedstrength)
		owner.add_or_update_variable_movespeed_modifier(speedstrength)

/datum/status_effect/speedboost/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/empowered_thrall)

/datum/movespeed_modifier/empowered_thrall
	variable = TRUE

/datum/status_effect/tagalong //applied to darkspawns while they accompany someone //yogs start: darkspawn
	id = "tagalong"
	tick_interval = 1 //as fast as possible
	alert_type = /atom/movable/screen/alert/status_effect/tagalong
	var/mob/living/shadowing
	var/turf/cached_location //we store this so if the mob is somehow gibbed we aren't put into nullspace

/datum/status_effect/tagalong/on_creation(mob/living/owner, mob/living/tag)
	. = ..()
	if(!.)
		return
	shadowing = tag

/datum/status_effect/tagalong/on_remove()
	if(owner.loc == shadowing)
		owner.forceMove(cached_location ? cached_location : get_turf(owner))
		shadowing.visible_message(span_warning("[owner] breaks away from [shadowing]'s shadow!"), \
		span_userdanger("You feel a sense of freezing cold pass through you!"))
		to_chat(owner, span_velvet("You break away from [shadowing]."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, TRUE)
	owner.setDir(SOUTH)

/datum/status_effect/tagalong/tick()
	if(!shadowing)
		owner.forceMove(cached_location)
		qdel(src)
		return
	cached_location = get_turf(shadowing)
	if(cached_location.get_lumcount() < SHADOW_SPECIES_DIM_LIGHT)
		owner.forceMove(cached_location)
		shadowing.visible_message(span_warning("[owner] suddenly appears from the dark!"))
		to_chat(owner, span_warning("You are forced out of [shadowing]'s shadow!"))
		qdel(src)
	var/obj/item/I = owner.get_active_held_item()
	if(I)
		to_chat(owner, span_userdanger("Equipping an item forces you out!"))
		qdel(src)

/atom/movable/screen/alert/status_effect/tagalong
	name = "Tagalong"
	desc = "You are accompanying TARGET_NAME. Use the Tagalong ability to break away at any time."
	icon_state = "shadow_mend"

/atom/movable/screen/alert/status_effect/tagalong/MouseEntered()
	var/datum/status_effect/tagalong/tagalong = attached_effect
	desc = replacetext(desc, "TARGET_NAME", tagalong.shadowing.real_name)
	..()
	desc = initial(desc) //yogs end

/datum/status_effect/taunt
	id = "taunt"
	alert_type = /atom/movable/screen/alert/status_effect/star_mark
	duration = 5 SECONDS
	tick_interval = CLICK_CD_MELEE
	var/mob/living/taunter

/datum/status_effect/taunt/on_creation(mob/living/new_owner, mob/living/taunter)
	src.taunter = taunter
	return ..()

/datum/status_effect/taunt/on_apply()
	. = ..()
	if(HAS_TRAIT(owner, TRAIT_STUNIMMUNE))
		return FALSE
	if(!taunter)
		return FALSE
	owner.SetImmobilized(5 SECONDS)

/datum/status_effect/taunt/tick(delta_time, times_fired)
	step_towards(owner, taunter)
	owner.SetImmobilized(5 SECONDS)

/datum/status_effect/taunt/on_remove()
	owner.SetImmobilized(0)
