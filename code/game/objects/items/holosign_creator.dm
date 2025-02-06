/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/list/signs
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag, click_parameters)

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	if(!signs)
		return
	. += span_notice("It is currently maintaining <b>[signs.len]/[max_signs]</b> projections.")

/obj/item/holosign_creator/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!check_allowed_items(target, not_inside = TRUE))
		return .
	var/turf/target_turf = get_turf(target)
	var/obj/structure/holosign/target_holosign = locate(holosign_type) in target_turf
	if(target_holosign)
		qdel(target_holosign)
		return .
	if(target_turf.is_blocked_turf(TRUE)) //can't put holograms on a tile that has dense stuff
		return .
	if(holocreator_busy)
		to_chat(user, span_notice("[src] is busy creating a hologram."))
		return .
	if(LAZYLEN(signs) >= max_signs)
		balloon_alert(user, "max capacity!")
		return .
	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = target))
			holocreator_busy = FALSE
			return .
		holocreator_busy = FALSE
		if(LAZYLEN(signs) >= max_signs)
			return .
		if(target_turf.is_blocked_turf(TRUE)) //don't try to sneak dense stuff on our tile during the wait.
			return .
	target_holosign = create_holosign(target, user)
	return .

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/proc/create_holosign(atom/target, mob/user)
	var/atom/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	return new_holosign

/obj/item/holosign_creator/attack_self(mob/user)
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "holograms cleared")

/obj/item/holosign_creator/Destroy()
	. = ..()
	if(LAZYLEN(signs))
		for(var/H in signs)
			qdel(H)


/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	creation_time = 20
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers. You can remotely open barriers with it."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 2 SECONDS
	max_signs = 6

/obj/item/holosign_creator/security/afterattack(atom/target, mob/user)
	var/obj/structure/holosign/barrier/barrier
	if(target.type == holosign_type)
		barrier = target
		if(barrier.openable)
			barrier.open(user)
	return ..()

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers. You can remotely open barriers with it."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 2 SECONDS
	max_signs = 6

/obj/item/holosign_creator/engineering/afterattack(atom/target, mob/user)
	var/obj/structure/holosign/barrier/engineering/barrier
	if(target.type == holosign_type)
		barrier = target
		if(barrier.openable)
			barrier.open(user)
	return ..()


/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0
	max_signs = 6
	/// Clearview holograms don't catch clicks and are more transparent
	var/clearview = FALSE
	/// Timer for auto-turning off clearview
	var/clearview_timer

/obj/item/holosign_creator/atmos/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/holosign_creator/atmos/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(LAZYLEN(signs))
		context[SCREENTIP_CONTEXT_RMB] = "[clearview ? "Turn off" : "Temporarily activate"] clearview"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/holosign_creator/atmos/create_holosign(atom/target, mob/user)
	var/obj/structure/holosign/barrier/atmos/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	if(clearview)
		new_holosign.clearview_transparency()
	return new_holosign

/obj/item/holosign_creator/atmos/attack_self_secondary(mob/user, modifiers)
	if(clearview)
		reset_hologram_transparency()
		balloon_alert(user, "turned off clearview")
		return
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.clearview_transparency()
		clearview = TRUE
		balloon_alert(user, "turned on clearview")
		clearview_timer = addtimer(CALLBACK(src, PROC_REF(reset_hologram_transparency)), 40 SECONDS, TIMER_STOPPABLE)
	return ..()

/obj/item/holosign_creator/atmos/proc/reset_hologram_transparency()
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.reset_transparency()
		clearview = FALSE
		deltimer(clearview_timer)

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	creation_time = 30
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, span_notice("You clear all active holograms, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			for(var/sign in signs)
				qdel(sign)
			shock = 0
			return
		if(R.emagged && !shock)
			to_chat(user, span_warning("You clear all active holograms, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			for(var/sign in signs)
				qdel(sign)
			shock = 1
			return
	for(var/sign in signs)
		qdel(sign)
	balloon_alert(user, "holograms cleared")
