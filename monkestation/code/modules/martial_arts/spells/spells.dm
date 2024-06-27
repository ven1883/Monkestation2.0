
//tribal claw
/datum/action/cooldown/spell/aoe/repulse/martial
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "tailsweep"
	panel = "Alien"
	sound = 'sound/magic/tail_swing.ogg'

	//cooldown_time = 15 SECONDS
	spell_requirements = NONE

	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	invocation_type = INVOCATION_NONE
	antimagic_flags = NONE
	aoe_radius = 2

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep

/datum/action/cooldown/spell/aoe/repulse/martial/cast(atom/cast_on)
	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_caster = cast_on
		playsound(get_turf(carbon_caster), 'sound/voice/hiss5.ogg', 80, TRUE, TRUE)
		carbon_caster.spin(6, 1)

	return ..()
