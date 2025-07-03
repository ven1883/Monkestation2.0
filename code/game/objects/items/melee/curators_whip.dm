/obj/item/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon = 'icons/obj/weapons/whip.dmi'
	icon_state = "whip"
	inhand_icon_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	worn_icon_state = "whip"
	slot_flags = ITEM_SLOT_BELT
	force = 15
	pain_damage = 5
	demolition_mod = 0.25
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/melee/curator_whip/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/melee/curator_whip/examine(mob/user)
	. = ..()
	. += span_notice("Target someone's arms in order to yank whatever they're holding out of that hand.")
	. += span_notice("Target someone's legs in order to trip someone who's 2 to 3 tiles away.")

/obj/item/melee/curator_whip/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(isliving(target) && target != user)
		switch(user.zone_selected)
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				if(iscarbon(target))
					context[SCREENTIP_CONTEXT_LMB] = "Disarm"
					return CONTEXTUAL_SCREENTIP_SET
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				var/dist = get_dist(user, target)
				if(ISINRANGE(dist, 2, 3))
					context[SCREENTIP_CONTEXT_LMB] = "Trip"
					return CONTEXTUAL_SCREENTIP_SET
	if(!isturf(target.loc) || !isturf(user.loc))
		return NONE
	if(user.Adjacent(target) && user.CanReach(target))
		context[SCREENTIP_CONTEXT_LMB] = "Attack"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/melee/curator_whip/attack(mob/living/target, mob/living/user, params)
	if(!iscarbon(target) || target == user)
		return ..()

	var/did_something = FALSE
	switch(user.zone_selected)
		if(BODY_ZONE_L_ARM)
			did_something = whip_disarm(user, target, LEFT_HANDS)
		if(BODY_ZONE_R_ARM)
			did_something = whip_disarm(user, target, RIGHT_HANDS)
	if(did_something)
		user.changeNext_move(CLICK_CD_WHIP) // the special attacks result in longer attack cooldown
	else
		return ..()

/obj/item/melee/curator_whip/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(whip_trip(user, target))
		user.changeNext_move(CLICK_CD_WHIP)
		. |= AFTERATTACK_PROCESSED_ITEM

/obj/item/melee/curator_whip/proc/whip_disarm(mob/living/carbon/user, mob/living/target, side)
	var/obj/item/item = target.get_held_items_for_side(side)
	if(istype(item, /obj/item/offhand)) // if it's an offhand, check whatever's in their other hand
		item = target.get_held_items_for_side(side == LEFT_HANDS ? RIGHT_HANDS : LEFT_HANDS)
	if(QDELETED(item) || (item.item_flags & ABSTRACT))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(src, 0, "[user]'s [name]", attack_type = MELEE_ATTACK))
			return TRUE // we still return TRUE so we don't continue the attack chain
	if(!target.dropItemToGround(item))
		return FALSE
	target.visible_message(
		span_danger("[item] is yanked out of [target]'s hands by \the [src]!"),
		span_userdanger("[user] yanks [item] out of your hands with \the [src]!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	to_chat(user, span_notice("You yank [item] towards yourself."))
	log_combat(user, target, "disarmed", src)
	user.do_attack_animation(target, used_item = src)
	playsound(target.loc, hitsound, get_clamped_volume(), TRUE, extrarange = -1, falloff_distance = 0)
	if(!user.get_inactive_held_item())
		user.throw_mode_on(THROW_MODE_TOGGLE)
		user.swap_hand()
		item.throw_at(user, range = 10, speed = 2)
	return TRUE

/obj/item/melee/curator_whip/proc/whip_trip(mob/living/user, mob/living/target)
	if(!isliving(target) || target == user)
		return FALSE
	// you need to be standing up on your own legs in order to be tripped
	if(target.body_position != STANDING_UP || target.buckled || target.num_legs < 1)
		return FALSE
	if(user.zone_selected != BODY_ZONE_L_LEG && user.zone_selected != BODY_ZONE_R_LEG)
		return FALSE
	switch(get_dist(user, target))
		if(0 to 1)
			to_chat(user, span_warning("[target] is too close to trip with \the [src]!"))
			return FALSE
		if(2 to 3)
			if(!CheckToolReach(user, target, 3))
				return FALSE
		if(4 to INFINITY)
			return FALSE
	// this is a horrible hack to make it so tripping doesn't drop items.
	// we just apply nodrop to their held items right before tripping them,
	// and then immediately remove it after the status effect is applied.
	// i'm sorry ~Lucy
	var/list/stupid_horrible_list = list()
	for(var/obj/item/item in target.held_items)
		ADD_TRAIT(item, TRAIT_NODROP, REF(src))
		stupid_horrible_list += item
	target.apply_status_effect(/datum/status_effect/incapacitating/knockdown/tripped, 3 SECONDS)
	for(var/obj/item/item in stupid_horrible_list)
		REMOVE_TRAIT(item, TRAIT_NODROP, REF(src))
	log_combat(user, target, "tripped", src)
	target.visible_message(
		span_danger("[user] knocks [target] off [target.p_their()] feet!"),
		span_userdanger("[user] yanks your legs out from under you!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	user.do_attack_animation(target, used_item = src)
	playsound(loc, hitsound, get_clamped_volume(), TRUE, extrarange = -1, falloff_distance = 0)
	return TRUE
