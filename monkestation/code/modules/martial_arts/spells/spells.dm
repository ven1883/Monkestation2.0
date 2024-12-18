
//tribal claw
/datum/action/cooldown/spell/aoe/repulse/martial/lizard
	name = "martial Tail Sweep"
	desc = "You should probably tell an admin if you can see this."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "tailsweep"
	panel = "Alien"
	sound = 'sound/magic/tail_swing.ogg'

	cooldown_time = 0
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

// shockstar
/datum/action/cooldown/spell/charged/beam/tesla/shockstar
	name = "martial Tesla Blast"
	desc = "You should probably tell an admin if you can see this."

	cooldown_time = 0
	cooldown_reduction_per_rank = 0
	channel_time = 1 SECOND
	charge_sound = null
	invocation_type = INVOCATION_NONE
	invocation = ""
	spell_requirements = SPELL_REQUIRES_MIND
	owner_has_control = FALSE //yeah funny business

	var/aggressive_sm = list(
		'sound/machines/sm/accent/delam/3.ogg',
		'sound/machines/sm/accent/delam/4.ogg',
		'sound/machines/sm/accent/delam/10.ogg',
		'sound/machines/sm/accent/delam/11.ogg',
		'sound/machines/sm/accent/delam/19.ogg',
		'sound/machines/sm/accent/delam/20.ogg',
		'sound/machines/sm/accent/delam/21.ogg',
		'sound/machines/sm/accent/delam/24.ogg',
		'sound/machines/sm/accent/delam/30.ogg',
		'sound/machines/sm/accent/delam/31.ogg',
		'sound/machines/sm/accent/delam/32.ogg'
	)

/datum/action/cooldown/spell/charged/beam/tesla/shockstar/send_beam(atom/origin, mob/living/carbon/to_beam, bolt_energy = 30, bounces = 5)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)

	to_beam.electrocute_act(bolt_energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)
	if (bounces < 1)
		return
	var/mob/living/carbon/to_beam_next = get_target(to_beam)
	if (isnull(to_beam_next))
		return
	send_beam(to_beam, to_beam_next, max(bolt_energy - energy_lost_per_bounce, energy_lost_per_bounce), bounces - 1)
