#define COMSIG_MOB_STOP_HUNGER "stop_hunger_mob"
#define COMSIG_MOB_START_HUNGER "start_hunger_mob"
#define COMSIG_MOB_FEED "feed_hunger_mob"
#define COMSIG_MOB_FED_ON "fed_on_mob"
#define COMSIG_MOB_RETURN_HUNGER "return_hunger_mob"
#define COMSIG_MOB_REFUSED_EAT "refused_hunger_mob"
#define COMSIG_MOB_OVERATE "overate_hunger_mob"
#define COMSIG_MOB_EAT_NORMAL "normal_eat_hunger_mob"
#define COMSIG_MOB_STARVING "starving_hunger_mob"
#define COMSIG_MOB_FULLY_STARVING "full_starve_hunger_mob"
#define COMSIG_SECRETION_UPDATE "secretion_update"
#define COMSIG_FEEDING_CHECK "latch_check"
#define COMSIG_HUNGER_UPDATED "update_hunger_mob"
#define COMSIG_LIVING_ATE "living_ate_object"
#define COMSIG_MOB_ADJUST_HUNGER "adjust_hunger_mob"

#define COMSIG_EMOTION_STORE "store_emotion"
#define EMOTION_BUFFER_SPEAK_FROM_BUFFER "release_emotion"
#define COMSIG_EMOTION_HEARD "heard_emotion"
#define EMOTION_BUFFER_UPDATE_OVERLAY_STATES "update_emotion_overlay"

#define COMSIG_ATOM_JOIN_STACK "join_stack"
#define COMSIG_STACK_MOVE "stack_move"
#define COMSIG_CHECK_CAN_ADD_NEW_STACK "check_stack_add"
#define COMSIG_MOBSTACKER_DESTROY "mobstack_destroy_stack"

#define COMSIG_SLIME_REGEN_CALC "slime_regen_calc"

#define COMSIG_MOB_PICKED_UP "mob_picked_up"
#define COMSIG_MOB_DROPPED "mob_dropped"
///from /datum/element/footstep/prepare_step(): (list/steps)
#define COMSIG_MOB_PREPARE_STEP_SOUND "override_mob_stepsound"

#define COMSIG_DRANK_REAGENT "drank_reagent"

#define COMSIG_LIVING_TRACKER_REMOVED "tracker_removed"
#define COMSIG_CLEAR_SEE "clear_see"

/// Carbon is steppin
#define COMSIG_CARBON_STEP "carbon_step"
/// Carbon is steppin on a painful limb
#define COMSIG_CARBON_PAINED_STEP "carbon_pain_step"
	/// Stop the pain from happening
	#define STOP_PAIN (1<<0)

#define COMSIG_LIVING_GIVE_ITEM_CHECK "living_give_item_check"

#define COMSIG_LIVING_ITEM_OFFERED_PRECHECK "living_item_offer_precheck"

/// Initiates a nightmare snuff check (eats dim lights on everything within 2 tiles) with the given args. (turf/start_turf)
#define COMSIG_NIGHTMARE_SNUFF_CHECK "nightmare_snuff_check"

/// From base of /datum/species/zombie/infectious/proc/set_consumed_flesh(): (new_amount, old_amount)
#define COMSIG_ZOMBIE_FLESH_ADJUSTED "zombie_flesh_adjusted"
