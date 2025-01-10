/datum/component/shadow_step
	var/datum/movespeed_modifier/speedboost = /datum/movespeed_modifier/shadow_step
	var/mob/living/carbon/human/owner

/datum/component/shadow_step/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent

/datum/component/shadow_step/Destroy(force, silent)
	. = ..()
	owner = null

/datum/component/shadow_step/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(apply_darkness_speed))

/datum/component/shadow_step/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE)
	owner.remove_movespeed_modifier(type)

/datum/component/shadow_step/proc/apply_darkness_speed()
	var/turf/current_turf = get_turf(owner)
	var/light_amount = current_turf.get_lumcount()
	if(light_amount < SHADOW_SPECIES_BRIGHT_LIGHT)
		owner.add_movespeed_modifier(speedboost)
	else
		owner.remove_movespeed_modifier(speedboost)

/datum/movespeed_modifier/shadow_step
	multiplicative_slowdown = -0.7
