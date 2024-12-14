#define COMB1 "DH"
#define COMB2 "HH"
#define COMB3 "HD"
#define SHOCKGRASP_COMBO "DDG"


/datum/martial_art/shockstar
	name = "Shocking Star"
	id = MARTIALART_SHOCKSTAR
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/shockstar_help

	var/charges = 3
	var/absorptions = 0

	var/max_charges = 5

	var/offensive_mode = FALSE
	var/defensive_mode = TRUE

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

	var/datum/action/innate/shockstar/toggle_offense/_toggle_offense = new /datum/action/innate/shockstar/toggle_offense()
	var/datum/action/innate/shockstar/toggle_defense/_toggle_defense = new /datum/action/innate/shockstar/toggle_defense()

/datum/martial_art/shockstar/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return

	_toggle_offense.Grant(target)
	_toggle_defense.Grant(target)

	START_PROCESSING(SSobj, src)
	RegisterSignal(target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))

/datum/martial_art/shockstar/on_remove(mob/living/carbon/human/target)
	. = ..()

	_toggle_offense.Remove(target)
	_toggle_defense.Remove(target)

	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))

/datum/martial_art/shockstar/proc/check_streak(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(findtext(streak,COMB1))
		streak = ""
		tailSweep(attacker,defender)
		return TRUE
	if(findtext(streak,COMB2))
		streak = ""
		faceScratch(attacker,defender)
		return TRUE
	if(findtext(streak,COMB3))
		streak = ""
		jugularCut(attacker,defender)
		return TRUE
	if(findtext(streak,SHOCKGRASP_COMBO))
		streak = ""
		grasp(attacker,defender)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to Alien Queen's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/shockstar/proc/tailSweep(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)

//Face Scratch, deals 30 brute to head(reduced by armor), blurs the defender's vision and gives them the confused effect for a short time.
/datum/martial_art/shockstar/proc/faceScratch(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)

/*
Jugular Cut
Deals 15 damage to the target plus 10 seconds of oxygen loss and 10 oxyloss, with an open laceration
If the target is T3 grabbed or sleeping, instead deal 60 damage with a weeping avulsion alongside the previous.
*/
/datum/martial_art/shockstar/proc/jugularCut(mob/living/carbon/attacker, mob/living/carbon/defender)

//Tail Grab, instantly puts your defender in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/shockstar/proc/grasp(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)

	if (defender.stat == DEAD)
		to_chat(attacker, span_warning("[defender] is dead. There's no point in trying to stop their heart."))
		return MARTIAL_ATTACK_INVALID

	if (offensive_mode == TRUE && charges > 0)
		decrement_charge()

		defender.apply_damage(30, BURN, BODY_ZONE_CHEST)

		if (defender.can_heartattack() && !defender.undergoing_cardiac_arrest())
			if(!defender.stat)
				defender.visible_message(span_warning("[defender] thrashes wildly, clutching at [defender.p_their()] chest!"),
					span_userdanger("You feel a horrible agony in your chest!"))
			defender.set_heartattack(TRUE)
			defender.emote("scream")
			defender.throw_at(throw_target, 3, 4, attacker)

			playsound(attacker, pick(aggressive_sm), 100)

	defender.electrocute_act(10, attacker)

	defender.apply_damage(10, BURN, BODY_ZONE_CHEST)
	defender.Knockdown(10)
	defender.Paralyze(3 SECONDS)


	playsound(defender, 'sound/machines/defib_zap.ogg', 60)


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

/datum/martial_art/shockstar/proc/increment_charge()
	++charges

/datum/martial_art/shockstar/proc/set_charge(amount)
	charges = amount



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

	to_chat(usr, span_notice("Tail Sweep</span>: Disarm Harm. Pushes everyone around you away and knocks them down."))
	to_chat(usr, span_notice("Face Scratch</span>: Harm Harm. Damages your target's head and confuses them for a short time."))
	to_chat(usr, span_notice("Jugular Cut</span>: Harm Disarm. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition."))
	to_chat(usr, span_notice("SHocking Grasp</span>: Disarm Disarm Grab. Electrocutes your target. You can use a Charge to deliver more power and throw them."))

#undef COMB1
#undef COMB2
#undef COMB3
#undef SHOCKGRASP_COMBO
