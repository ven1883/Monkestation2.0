/obj/item/gun/ballistic/bow/energy
	name = "hardlight bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy."
	icon_state = ""
	inhand_icon_state = ""
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy
	no_pin_required = FALSE
	draw_slowdown = 0
	var/recharge_time = 1 SECONDS

	var/can_fold = FALSE
	var/folded_w_class = WEIGHT_CLASS_NORMAL
	var/folded = FALSE
	//var/stored_ammo ///what was stored in the magazine before being folded?
	var/fold_sound = 'sound/weapons/batonextend.ogg'

/obj/item/gun/ballistic/bow/energy/Initialize(mapload)
	if(folded)
		toggle_folded(TRUE)
	. = ..()

/obj/item/gun/ballistic/bow/energy/examine(mob/user)
	. = ..()
	var/obj/item/ammo_box/magazine/internal/bow/energy/M = magazine
	if(magazine.ammo_type)
		var/obj/item/arrow_type = magazine.ammo_type
		. += "It is current firing mode is \"[initial(arrow_type.name)]\"[M.selectable_types.len > 1 ? ", you can select firing modes by using ALT + CLICK" : ""]."
	if(can_fold)
		. += "[folded ? "It is currently folded, you can unfold it" : "It can be folded into a compact form"] by using CTRL + CLICK."
	if(TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		. += span_warning("It is currently recharging!")

/obj/item/gun/ballistic/bow/energy/update_icon_state()
	. = ..()
	if(folded)
		icon_state = "[initial(icon_state)]_folded"
		inhand_icon_state = "[initial(inhand_icon_state)]_folded"
	else if(get_ammo())
		icon_state = initial(icon_state)
	else
		inhand_icon_state = initial(inhand_icon_state)
		icon_state = initial(icon_state)

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/gun/ballistic/bow/energy/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(folded)
		to_chat(user, span_notice("You must unfold [src] before firing it!"))
		return FALSE
	. = ..()
	if(recharge_time)
		TIMER_COOLDOWN_START(src, "arrow_recharge", recharge_time)
		addtimer(CALLBACK(src, PROC_REF(end_cooldown)), recharge_time)

/obj/item/gun/ballistic/bow/energy/proc/end_cooldown()
	playsound(src, 'sound/effects/sparks4.ogg', 25, 0)

/obj/item/gun/ballistic/bow/energy/attack_self(mob/living/user)
	if(folded)
		toggle_folded(FALSE, user)
	if(..())
		return TRUE
	if(!chambered && !get_ammo() && (!recharge_time || !TIMER_COOLDOWN_CHECK(src, "arrow_recharge")))
		to_chat(user, span_notice("You fabricate an arrow."))
		recharge_arrow()
	//update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/proc/recharge_arrow()
	if(folded || magazine.get_round(TRUE))
		return
	var/ammo_type = magazine.ammo_type
	magazine.give_round(new ammo_type())
	//update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/attackby(obj/item/I, mob/user, params)
	return

/obj/item/gun/ballistic/bow/energy/AltClick(mob/living/user)
	select_projectile(user)
	var/current_round = magazine.get_round(TRUE)
	if(current_round)
		QDEL_NULL(current_round)
	if(!TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		recharge_arrow()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/proc/select_projectile(mob/living/user)
	var/obj/item/ammo_box/magazine/internal/bow/energy/M = magazine
	if(!istype(M) || !M.selectable_types)
		return
	var/list/selectable_types = M.selectable_types

	switch(selectable_types.len)
		if(1)
			M.ammo_type = selectable_types[1]
			to_chat(user, span_notice("\The [src] doesn't have any other firing modes."))
		if(2)
			selectable_types = selectable_types - M.ammo_type
			var/obj/item/ammo_casing/reusable/arrow/energy/new_ammo_type = selectable_types[1]
			M.ammo_type = new_ammo_type
			to_chat(user, span_notice("You switch \the [src]'s firing mode to \"[initial(new_ammo_type.name)]\"."))
		else
			var/list/choice_list = list()
			var/list/radial_list = list()
			for(var/type in M.selectable_types)
				var/obj/item/arrow_type = type
				var/datum/radial_menu_choice/choice = new
				choice.image = image(initial(arrow_type.icon), icon_state = initial(arrow_type.icon_state))
				choice.info = initial(arrow_type.desc)
				choice.active = M.ammo_type == type
				choice_list[initial(arrow_type.name)] = arrow_type
				radial_list[initial(arrow_type.name)] = choice
			var/raw_choice = show_radial_menu(user, user, radial_list, tooltips = TRUE)
			if(!raw_choice || !(raw_choice in radial_list))
				return
			var/obj/item/ammo_casing/reusable/arrow/energy/choice = choice_list[raw_choice]
			if(!choice || !(choice in M.selectable_types))
				return
			M.ammo_type = choice
			to_chat(user, span_notice("You switch \the [src]'s firing mode to \"[initial(choice.name)]\"."))
			QDEL_NULL(choice_list)
			QDEL_NULL(radial_list)
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/CtrlClick(mob/living/user)
	if(!can_fold || !user.is_holding(src))
		return ..()
	if(drawing)
		to_chat(user, span_notice("You can't fold \the [src] while drawing the bowstring."))
	toggle_folded(!folded, user)
	return TRUE

/obj/item/gun/ballistic/bow/energy/proc/toggle_folded(new_folded, mob/living/user)
	if(!can_fold)
		return

	if(folded != new_folded)
		playsound(src.loc, fold_sound, 50, 1)

	folded = new_folded

	if(folded)
		w_class = folded_w_class
		chambered = null
		//stored_ammo = magazine.ammo_list()
		//magazine.stored_ammo = null
		if(user)
			to_chat(user, span_notice("You fold [src]."))
	else
		w_class = initial(w_class)
		//magazine.stored_ammo = stored_ammo
		if(user)
			to_chat(user, span_notice("You extend [src], allowing it to be fired."))
	update_appearance(UPDATE_ICON)
