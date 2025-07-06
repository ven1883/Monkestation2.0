
/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	plaintext_zone = "chest"
	is_dimorphic = TRUE
	px_x = 0
	px_y = 0
	grind_results = null
	wound_resistance = 10
	bodypart_trait_source = CHEST_TRAIT
	///The bodytype(s) allowed to attach to this chest.
	var/acceptable_bodytype = BODYTYPE_HUMANOID

	var/icon/ass_image
	var/list/wing_types = list(/obj/item/organ/external/wings/functional/angel)
	var/obj/item/cavity_item

	/// Offset to apply to equipment worn as a uniform
	var/datum/worn_feature_offset/worn_uniform_offset
	/// Offset to apply to equipment worn on the id slot
	var/datum/worn_feature_offset/worn_id_offset
	/// Offset to apply to equipment worn in the suit slot
	var/datum/worn_feature_offset/worn_suit_storage_offset
	/// Offset to apply to equipment worn on the hips
	var/datum/worn_feature_offset/worn_belt_offset
	/// Offset to apply to overlays placed on the back
	var/datum/worn_feature_offset/worn_back_offset
	/// Offset to apply to equipment worn as a suit
	var/datum/worn_feature_offset/worn_suit_offset
	/// Offset to apply to equipment worn on the neck
	var/datum/worn_feature_offset/worn_neck_offset
	/// Offset to apply to accessories
	var/datum/worn_feature_offset/worn_accessory_offset

/obj/item/bodypart/chest/can_dismember(obj/item/item)
	if(owner.stat < HARD_CRIT || !get_organs())
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	QDEL_NULL(worn_uniform_offset)
	QDEL_NULL(worn_id_offset)
	QDEL_NULL(worn_suit_storage_offset)
	QDEL_NULL(worn_belt_offset)
	QDEL_NULL(worn_back_offset)
	QDEL_NULL(worn_suit_offset)
	QDEL_NULL(worn_neck_offset)
	QDEL_NULL(worn_accessory_offset)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	return ..()

/* //Non-Modular change: Removes Monkey bodyparts, moved to monkestation\code\modules\surgery\bodyparts\monkey_bodyparts.dm
/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	wound_resistance = -10
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY
*/

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_chest"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 500
	acceptable_bodytype = BODYTYPE_HUMANOID

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA_PLACEHOLDER

/* //Non-Modular change: Removes Monkey bodyparts, moved to monkestation\code\modules\surgery\bodyparts\monkey_bodyparts.dm
/obj/item/bodypart/arm/left/monkey
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2 /// monkey punches must be really weak, considering they bite people instead and their bites are weak as hell.
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3
*/

/obj/item/bodypart/arm/left/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/* //Non-Modular change: Removes Monkey bodyparts, moved to monkestation\code\modules\surgery\bodyparts\monkey_bodyparts.dm
/obj/item/bodypart/arm/right/monkey
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3
*/

/obj/item/bodypart/arm/right/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/leg
	name = "leg"
	desc = "This item shouldn't exist. Talk about breaking a leg. Badum-Tss!"
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC
	max_damage = 50
	body_damage_coeff = 0.75
	can_be_disabled = TRUE
	unarmed_attack_effect = ATTACK_EFFECT_KICK
	body_zone = BODY_ZONE_L_LEG
	unarmed_attack_verb = "kick" // The lovely kick, typically only accessable by attacking a grouded foe. 1.5 times better than the punch.
	unarmed_damage_low = 8
	unarmed_damage_high = 8
	unarmed_stun_threshold = 10

	/// Can these legs be digitigrade? See digitigrade.dm
	var/can_be_digitigrade = FALSE
	///Set limb_id to this when in "digi mode". MUST BE UNIQUE LIKE ALL LIMB IDS
	var/digitigrade_id
	/// Used solely by digitigrade limbs to remember what their old limb ID was.
	var/old_limb_id
	/// Used by the bloodysoles component to make footprints
	var/footprint_sprite = FOOTPRINT_SPRITE_SHOES
	///our step sound
	var/list/step_sounds
	biological_state = BIO_STANDARD_JOINTED
	/// Datum describing how to offset things worn on the foot of this leg, note that an x offset won't do anything here
	var/datum/worn_feature_offset/worn_foot_offset

/obj/item/bodypart/leg/Destroy()
	QDEL_NULL(worn_foot_offset)
	return ..()

/obj/item/bodypart/leg/left
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	plaintext_zone = "left leg"
	px_x = -2
	px_y = 12
	can_be_disabled = TRUE
	bodypart_trait_source = LEFT_LEG_TRAIT

/obj/item/bodypart/leg/left/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/leg/left/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [name]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)

/* //Non-Modular change: Removes Monkey bodyparts, moved to monkestation\code\modules\surgery\bodyparts\monkey_bodyparts.dm
/obj/item/bodypart/leg/left/monkey
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
	footprint_sprite =  FOOTPRINT_SPRITE_PAWS
*/

/obj/item/bodypart/leg/left/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are available
	icon_state = "default_human_r_leg"
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	plaintext_zone = "right leg"
	px_x = 2
	px_y = 12
	bodypart_trait_source = RIGHT_LEG_TRAIT

/obj/item/bodypart/leg/right/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/leg/right/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [name]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)

/* //Non-Modular change: Removes Monkey bodyparts, moved to monkestation\code\modules\surgery\bodyparts\monkey_bodyparts.dm
/obj/item/bodypart/leg/right/monkey
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
	footprint_sprite =  FOOTPRINT_SPRITE_PAWS
*/

/obj/item/bodypart/leg/right/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE
