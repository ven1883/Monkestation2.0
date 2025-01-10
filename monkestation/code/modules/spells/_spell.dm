/// Called after the effect happens, whether that's after the button press or after hitting someone with a touch ability
/datum/action/cooldown/spell/proc/consume_resource() //TODO: rework vampire blood use into using this proc (hey lucy)
	if(!bypass_cost && owner.mind && LAZYLEN(resource_costs))
		SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs)
