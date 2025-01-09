#define CRACK_COMBO "DH"
#define STRIKE_COMBO "HH"
#define KNOCK_COMBO "HD"
#define GRASP_COMBO "DDG"

/datum/martial_art/shockstar/debug
	name = "debug Shocking Star"
	charges = 50
	max_charges = 50

/datum/martial_art/shockstar
	name = "Shocking Star"
	id = MARTIALART_SHOCKSTAR
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/shockstar_help
	display_combos = TRUE

	var/charges = 3
	var/absorptions = 0

	var/max_charges = 5

	var/offensive_mode = FALSE
	var/defensive_mode = TRUE

	//this is used to generate charges. when it reaches two, we add a charge.
	var/combo_count = 0

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

	var/crystal_pops = list(
		'sound/effects/structure_stress/pop1.ogg',
		'sound/effects/structure_stress/pop2.ogg',
		'sound/effects/structure_stress/pop3.ogg'
	)

	var/list/absorb_list = list()
	var/damage_mult = 1

	var/datum/action/innate/shockstar/toggle_offense/_toggle_offense = new /datum/action/innate/shockstar/toggle_offense()
	var/datum/action/innate/shockstar/toggle_defense/_toggle_defense = new /datum/action/innate/shockstar/toggle_defense()
	var/datum/action/cooldown/spell/charged/beam/tesla/shockstar/tesla_field = new /datum/action/cooldown/spell/charged/beam/tesla/shockstar()

/datum/martial_art/shockstar/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return

	_toggle_offense.Grant(target)
	_toggle_defense.Grant(target)
	tesla_field.Grant(target)

	target.set_armor(/datum/armor/shockstar)
	target.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/sepia)

	START_PROCESSING(SSobj, src)
	RegisterSignal(target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))

	calculate_mults()

/datum/martial_art/shockstar/on_remove(mob/living/carbon/human/target)
	. = ..()

	_toggle_offense.Remove(target)
	_toggle_defense.Remove(target)
	tesla_field.Remove(target)

	target.set_armor(/datum/armor)
	target.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/sepia)

	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))

/datum/martial_art/shockstar/proc/check_streak(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(findtext(streak,CRACK_COMBO))
		reset_streak()
		crack(attacker,defender)
		return TRUE
	if(findtext(streak,STRIKE_COMBO))
		reset_streak()
		strike(attacker,defender)
		return TRUE
	if(findtext(streak,KNOCK_COMBO))
		reset_streak()
		knock(attacker,defender)
		return TRUE
	if(findtext(streak,GRASP_COMBO))
		reset_streak()
		grasp(attacker,defender)
		return TRUE
	return FALSE


// HH
// Strike; bread & butter primary attack combo.
/datum/martial_art/shockstar/proc/strike(mob/living/attacker, mob/living/defender)
	defender.apply_damage(10 * damage_mult, BURN, BODY_ZONE_HEAD)
	defender.adjust_dizzy_up_to(1, 10)

	playsound(defender, 'sound/effects/wounds/crack2.ogg', 70)
	playsound(attacker, pick(crystal_pops), 80)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	increment_counter()

// DH
// Crack; disarms the target and temporarily blinds them.
// On offensive mode: Uses a charge to light the target on fire as well and severely burning them.
// On defensive mode: Uses a charge to generate an EMP on the target.
/datum/martial_art/shockstar/proc/crack(mob/living/attacker, mob/living/defender)
	if (defender.stat == DEAD)
		to_chat(attacker, span_warning("[defender] is dead. There's nothing here to do."))
		return MARTIAL_ATTACK_INVALID

	if (defensive_mode || offensive_mode)
		playsound(attacker, pick(aggressive_sm), 100)
		//this is kinda ugly but eh

	if (offensive_mode == TRUE && charges > 0)
		var/datum/wound/burn/flesh/burns = new /datum/wound/burn/flesh/severe()
		decrement_charge()

		defender.set_fire_stacks(3) //hellfire be upon ye
		defender.ignite_mob()
		defender.apply_damage(5 * damage_mult, BURN, BODY_ZONE_EVERYTHING)
		burns.apply_wound(defender.get_bodypart(BODY_ZONE_HEAD))

		playsound(defender, 'sound/magic/fireball.ogg', 50)

	if (defensive_mode == TRUE && charges > 0)
		decrement_charge()
		empulse(get_turf(defender), 2, 2)

		playsound(defender, 'sound/effects/empulse.ogg', 60)


	defender.drop_all_held_items()
	defender.adjust_temp_blindness_up_to(3, 10)
	defender.adjust_dizzy_up_to(3, 10)
	defender.stamina.adjust(-50)

	increment_counter()
	playsound(attacker, 'sound/effects/bamf.ogg', 50)
	playsound(attacker, 'sound/weapons/contractorbatonextend.ogg', 80)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)

// HD
// Knock; kicks the target three tiles away and temporarily stuns them. Serves a similar role to Tail Sweep from Trbial Claw.
// On defensive mode: Uses a charge to project a tesla field that shocks nearby targets.
/datum/martial_art/shockstar/proc/knock(mob/living/attacker, mob/living/defender)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)

	if (defender.stat == DEAD)
		to_chat(attacker, span_warning("[defender] is dead. There's no point in trying to throw them around."))
		return MARTIAL_ATTACK_INVALID

	defender.apply_damage(10 * damage_mult, BURN, BODY_ZONE_CHEST)
	defender.Knockdown(10)
	defender.Paralyze(1.5 SECONDS)
	defender.throw_at(throw_target, 3, 4, attacker)

	if (defensive_mode == TRUE && charges > 0)
		decrement_charge()

		playsound(attacker, pick(aggressive_sm), 100)
		tesla_field.Trigger() // evil goblin noises

	increment_counter()
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_SLASH)


// DDG
// Grasp; electrocutes the target, does 20 burn damage to the chest, and temporarily stuns them.
// On offesnive mode: Uses one charge to deal an additional 20 damage (40 total), as well as casuing severe heart damage.
/datum/martial_art/shockstar/proc/grasp(mob/living/attacker, mob/living/defender)
	var/mob/living/carbon/human/carbon_target = defender

	if (defender.stat == DEAD)
		to_chat(attacker, span_warning("[defender] is dead. There's no point in trying to stop their heart."))
		return MARTIAL_ATTACK_INVALID

	if (offensive_mode == TRUE && charges > 0)
		decrement_charge()

		defender.apply_damage(20, BURN, BODY_ZONE_CHEST)

		if (istype(carbon_target))
			if (carbon_target.can_heartattack() && !carbon_target.undergoing_cardiac_arrest())
				if(!carbon_target.stat)
					carbon_target.visible_message(span_warning("[carbon_target] thrashes wildly, clutching at [carbon_target.p_their()] chest!"),
						span_userdanger("You feel a horrible agony in your chest!"))
				carbon_target.set_heartattack(TRUE)
				carbon_target.emote("scream")

				//insurance policy since heart attacks seem to be broken
				carbon_target.adjustOrganLoss(ORGAN_SLOT_HEART, 60, 100)

			playsound(attacker, pick(aggressive_sm), 100)


	defender.electrocute_act(10, attacker)
	defender.apply_damage(10 * damage_mult, BURN, BODY_ZONE_CHEST)
	defender.Knockdown(10)
	defender.Paralyze(3 SECONDS)

	increment_counter()
	playsound(defender, 'sound/machines/defib_zap.ogg', 60)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_SMASH)


/datum/martial_art/shockstar/help_act(mob/living/attacker, mob/living/defender)
	if (defender.health <= defender.crit_threshold || (attacker.pulling == defender && attacker.grab_state >= GRAB_NECK) || defender.IsSleeping())
		if (do_after(attacker, 5 SECONDS) && !is_absorbed(defender) && istype(defender, /mob/living/carbon/human))
			defender.adjustOxyLoss(60)
			absorb_target(defender)

/datum/martial_art/shockstar/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("H",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/shockstar/disarm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("D",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/shockstar/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("G",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

//these procs exist so you have more functionality than ++charges
/datum/martial_art/shockstar/proc/decrement_charge()
	--charges
	calculate_mults()

/datum/martial_art/shockstar/proc/increment_charge()
	if (charges < max_charges)
		++charges
		calculate_mults()

/datum/martial_art/shockstar/proc/set_charge(amount)
	charges = amount
	calculate_mults()

/datum/martial_art/shockstar/proc/calculate_mults()
	damage_mult = 1 + (charges * 0.2)

	//fuck it we do this the bad way
	if (charges >= 8)
		usr.set_armor(/datum/armor/shockstar/tier3)
		usr.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/shockstar, multiplicative_slowdown = -0.3)
	else if (charges >= 5)
		usr.set_armor(/datum/armor/shockstar/tier2)
		usr.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/shockstar, multiplicative_slowdown = -0.2)
	else if (charges >= 3)
		usr.set_armor(/datum/armor/shockstar/tier1)
		usr.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/shockstar, multiplicative_slowdown = -0.1)
	else
		usr.set_armor(/datum/armor/shockstar)
		usr.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/shockstar, multiplicative_slowdown = 0)

//these are for charge generation
/datum/martial_art/shockstar/proc/increment_counter()
	++combo_count
	if (combo_count >= 3)
		increment_charge()
		combo_count = 0


//these are for absorptions
/datum/martial_art/shockstar/proc/absorb_target(mob/living/target)
	++absorptions
	++max_charges
	set_charge(max_charges)
	absorb_list.Add(target)

/datum/martial_art/shockstar/proc/is_absorbed(mob/living/carbon/human/target)
	return absorb_list?.Find(target)

//evil effects
/datum/movespeed_modifier/shockstar
	variable = TRUE

//innate armor
/datum/armor/shockstar
	bomb = 40
	bullet = 20
	consume = 0
	energy = 20
	laser = 20
	fire = 30
	melee = 20
	wound = 25

/datum/armor/shockstar/tier1
	bullet = 30
	energy = 30
	laser = 30
	melee = 30

/datum/armor/shockstar/tier2
	bullet = 40
	energy = 40
	laser = 40
	melee = 40

/datum/armor/shockstar/tier3
	bullet = 50
	energy = 50
	laser = 50
	melee = 50


//thanks gboster :)

/datum/action/innate/shockstar/toggle_offense
	name = "Toggle Offensive Mode"
	desc = "Toggles offensive use of charges and blood."

	button_icon = 'icons/hud/guardian.dmi'
	button_icon_state = "standard"

/datum/action/innate/shockstar/toggle_offense/Activate()
	var/datum/martial_art/shockstar/real_deal = owner.mind.martial_art
	if(!istype(real_deal)) // check if its the real deal or not
		return
	if (real_deal.offensive_mode == TRUE)
		real_deal.offensive_mode = FALSE
	else
		real_deal.offensive_mode = TRUE


/datum/action/innate/shockstar/toggle_defense
	name = "Toggle Defensive Mode"
	desc = "Toggles defensive use of charges and blood."

	button_icon = 'icons/hud/guardian.dmi'
	button_icon_state = "protector"

/datum/action/innate/shockstar/toggle_defense/Activate()
	var/datum/martial_art/shockstar/real_deal = owner.mind.martial_art
	if(!istype(real_deal)) // check if its the real deal or not
		return
	if (real_deal.defensive_mode == TRUE)
		real_deal.defensive_mode = FALSE
	else
		real_deal.defensive_mode = TRUE



/datum/martial_art/shockstar/proc/get_status_tab_items(mob/living/carbon/human/target, list/items)
	SIGNAL_HANDLER
	items += "[absorptions > 0 ? "Nioelecrtic Absorptions: [absorptions]" : "No nioelectric signatures absorbed."]"
	items += "[charges > 0 ? "Composite Charges: [charges]" : "Composite discharged."]"
	items += "[offensive_mode == TRUE ? "Offensive Mode Enabled" : "Offensive Mode Disabled"]"
	items += "[defensive_mode == TRUE ? "Defensive Mode Enabled" : "Defensive Mode Disabled"]"

/mob/living/carbon/human/proc/shockstar_help()
	set name = "Commune"
	set desc = "Commune with the beyond."
	set category = "Stellar Child"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, span_notice("Strike</span>: Harm Harm. Empower your body with the power of the supermatter. Deal damage."))
	to_chat(usr, span_notice("Crack</span>: Disarm Harm. Clasp your hands together and ignite a ball of plasma to unleash on your target, disarming them and blinding them temporarily. Can use an Offensive charge to light them ablaze, and a defensive charge to produce an electromagnetic pulse."))
	to_chat(usr, span_notice("Knock</span>: Harm Disarm. Kick your target away, or using a defensive Charge, hijack your target's nioelectric signature to generate a tesla field around yourself."))
	to_chat(usr, span_notice("Grasp</span>: Disarm Disarm Grab. Electrocutes your target. You can use an offensive Charge to deliver more power and throw them."))

#undef CRACK_COMBO
#undef STRIKE_COMBO
#undef KNOCK_COMBO
#undef GRASP_COMBO
