/obj/item/mcobject/messaging/button
	name = "button component"
	desc = "A button. Its red hue entices you to press it."
	icon_state = "comp_button"
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"

/obj/item/mcobject/messaging/button/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	playsound(src, SFX_BUTTON_CLICK, vol = 45, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, mixer_channel = CHANNEL_MACHINERY)
	flick(icon_down, src)
	fire(stored_message)
	log_message("triggered by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/button/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isturf(target) || !proximity_flag)
		return

	if(!user.dropItemToGround(src))
		return
	if(!user.CanReach(target))
		return
	forceMove(target)
	if(isclosedturf(target))
		icon_up = "comp_switch"
		icon_down = "comp_switch2"
	else
		icon_up = "comp_button"
		icon_down = "comp_button2"
		update_icon_state()

/obj/item/mcobject/messaging/button/update_icon_state()
	. = ..()
	icon_state = icon_up
