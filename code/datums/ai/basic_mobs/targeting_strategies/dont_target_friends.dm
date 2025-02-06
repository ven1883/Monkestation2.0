/// Don't target an atom in our friends list (or turfs), anything else is fair game
/datum/targeting_strategy/basic/not_friends
	/// Stop regarding someone as a valid target once they pass this stat level, setting it to DEAD means you will happily attack corpses
	var/attack_until_past_stat = HARD_CRIT
	/// If we can try to closed turfs or not
	var/attack_closed_turf = FALSE

///Returns true or false depending on if the target can be attacked by the mob
/datum/targeting_strategy/basic/not_friends/can_attack(mob/living/living_mob, atom/target, vision_range)
	if(attack_closed_turf && isclosedturf(target))
		return TRUE

	if (ismob(target))
		var/mob/mob_target = target
		if (HAS_TRAIT(mob_target, TRAIT_GODMODE))
			return FALSE
		if (mob_target.stat > attack_until_past_stat)
			return FALSE

	if (living_mob.see_invisible < target.invisibility)
		return FALSE
	if (isturf(target.loc) && living_mob.z != target.z) // z check will always fail if target is in a mech
		return FALSE
	if (!living_mob.ai_controller) // How did you get here?
		return FALSE

	if (!(target in living_mob.ai_controller.blackboard[BB_FRIENDS_LIST]))
		// We don't have any friends, anything's fair game
		// OR This is not our friend, fire at will
		return TRUE

///friends dont care about factions
/datum/targeting_strategy/basic/not_friends/faction_check(mob/living/living_mob, mob/living/the_target)
	return FALSE

/datum/targeting_strategy/basic/not_friends/attack_closed_turfs
	attack_closed_turf = TRUE

/// Subtype that allows us to target items while deftly avoiding attacking our allies. Be careful when it comes to targeting items as an AI could get trapped targeting something it can't destroy.
/datum/targeting_strategy/basic/not_friends/allow_items

/datum/targeting_strategy/basic/not_friends/allow_items/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(isitem(the_target))
		// trust fall exercise
		return TRUE
