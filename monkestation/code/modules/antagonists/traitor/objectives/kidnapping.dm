#define CONTRACTOR_RANSOM_CUT 0.35
/datum/traitor_objective/target_player/kidnapping
	name = "Kidnap %TARGET% the %JOB TITLE% and deliver them to %AREA%"
	description = "%TARGET% %CRIMES% You'll need to kidnap and deliver them to %AREA%, where our transport pod will be waiting. \
		If %TARGET% is delivered alive, you will be rewarded with an additional %TC% telecrystals."

	abstract_type = /datum/traitor_objective/target_player/kidnapping
	valid_uplinks = UPLINK_CONTRACTORS
	given_contractor_rep = 1
	progression_minimum = 0 MINUTES

	/// The jobs that this objective is targetting.
	var/list/target_jobs
	/// Area that the target needs to be delivered to
	var/area/dropoff_area
	/// Have we called the pod yet?
	var/pod_called = FALSE
	/// How much TC do we get from sending the target alive
	var/alive_bonus = 0
	/// All stripped targets belongings
	var/list/target_belongings = list()

/datum/traitor_objective/target_player/kidnapping/common
	progression_reward = list(10 MINUTES, 15 MINUTES)
	telecrystal_reward = list(2, 3)
	target_jobs = list(
		// Cargo
		/datum/job/cargo_technician,
		// Engineering
		/datum/job/atmospheric_technician,
		/datum/job/station_engineer,
		// Medical
		/datum/job/chemist,
		/datum/job/doctor,
		/datum/job/psychologist,
		/datum/job/virologist,
		// Science
		/datum/job/geneticist,
		/datum/job/roboticist,
		/datum/job/scientist,
		// Service
		/datum/job/bartender,
		/datum/job/botanist,
		/datum/job/chaplain,
		/datum/job/clown,
		/datum/job/curator,
		/datum/job/janitor,
		/datum/job/lawyer,
		/datum/job/mime,
		// monkestation addition: barbers and spooktober
		/datum/job/barber,
		/datum/job/yellowclown,
		/datum/job/skeleton,
		/datum/job/candysalesman,
		/datum/job/dietwizard,
		/datum/job/ghost,
		/datum/job/godzilla,
		/datum/job/gorilla,
	)
	alive_bonus = 3

/datum/traitor_objective/target_player/kidnapping/common/assistant
	target_jobs = list(
		/datum/job/assistant
	)
	telecrystal_reward = 3 //go bully the assistants

/datum/traitor_objective/target_player/kidnapping/uncommon //Hard to fish out targets
	progression_reward = list(15 MINUTES, 20 MINUTES)
	telecrystal_reward = list(3, 4)
	given_contractor_rep = 2

	target_jobs = list(
		// Cargo
		/datum/job/quartermaster,
		/datum/job/shaft_miner,
		// Medical
		/datum/job/paramedic,
		// Service
		/datum/job/cook,
		// Monkestation addition: Security
		/datum/job/security_assistant,
		// Monkestation addition: Engineering
		/datum/job/signal_technician,
	)
	alive_bonus = 4

/datum/traitor_objective/target_player/kidnapping/rare
	progression_reward = list(20 MINUTES, 25 MINUTES)
	telecrystal_reward = list(4, 5)
	given_contractor_rep = 3

	target_jobs = list(
		// Heads of staff
		/datum/job/chief_engineer,
		/datum/job/chief_medical_officer,
		/datum/job/head_of_personnel,
		/datum/job/research_director,
		// Security
		/datum/job/detective,
		/datum/job/security_officer,
		/datum/job/warden,
		// Monkestation edit: brig docs
		/datum/job/brig_physician,
	)
	alive_bonus = 5

/datum/traitor_objective/target_player/kidnapping/captain
	progression_reward = list(25 MINUTES, 30 MINUTES)
	telecrystal_reward = list(5, 6)
	given_contractor_rep = 4

	target_jobs = list(
		/datum/job/captain,
		/datum/job/head_of_security,
		// Monkestation edit: Blueshields
		/datum/job/blueshield,
	)
	alive_bonus = 6

/datum/traitor_objective/target_player/kidnapping/generate_objective(datum/mind/generating_for, list/possible_duplicates)

	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue

		if(possible_target in already_targeting)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(HAS_TRAIT(possible_target, TRAIT_HAS_BEEN_KIDNAPPED))
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		if(!(possible_target.assigned_role.type in target_jobs))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/target_player/objective as anything in possible_duplicates)
		if(!objective.target) //the old objective was already completed.
			continue
		possible_targets -= objective.target.mind

	if(!length(possible_targets))
		return FALSE

	var/datum/mind/target_mind = pick(possible_targets)
	target = target_mind.current
	AddComponent(/datum/component/traitor_objective_register, target, fail_signals = list(COMSIG_QDELETING))
	var/static/list/forbidden_areas = typecacheof(list(/area/station/hallway, /area/station/security, /area/station/science/ordnance))
	var/list/possible_areas = list()
	for(var/area/possible_area as anything in GLOB.the_station_areas)
		if(is_type_in_typecache(possible_area, forbidden_areas) || initial(possible_area.outdoors) || !GLOB.areas_by_type[possible_area])
			continue
		possible_areas |= GLOB.areas_by_type[possible_area]

	dropoff_area = pick(possible_areas)
	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	replace_in_name("%AREA%", dropoff_area.get_original_area_name())
	replace_in_name("%TC%", alive_bonus)
	var/base = pick_list(WANTED_FILE, "basemessage")
	var/verb_string = pick_list(WANTED_FILE, "verb")
	var/noun = pick_list_weighted(WANTED_FILE, "noun")
	var/location = pick_list_weighted(WANTED_FILE, "location")
	replace_in_name("%CRIMES%", "[base] [verb_string] [noun] [location].")
	return TRUE

/datum/traitor_objective/target_player/kidnapping/ungenerate_objective()
	target = null
	dropoff_area = null

/datum/traitor_objective/target_player/kidnapping/on_objective_taken(mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(generate_holding_area))

/datum/traitor_objective/target_player/kidnapping/proc/generate_holding_area()
	// Let's load in the holding facility ahead of time
	// even if they fail the objective  it's better to get done now rather than later
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)

/datum/traitor_objective/target_player/kidnapping/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!pod_called)
		buttons += add_ui_button("Call Extraction Pod", "Pressing this will call down an extraction pod.", "rocket", "call_pod")
	return buttons

/datum/traitor_objective/target_player/kidnapping/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("call_pod")
			if(pod_called)
				return
			var/area/user_area = get_area(user)
			var/area/target_area = get_area(target)

			if(user_area != dropoff_area)
				to_chat(user, span_warning("You must be in [dropoff_area.get_original_area_name()] to call the extraction pod."))
				return

			if(target_area != dropoff_area)
				to_chat(user, span_warning("[target.real_name] must be in [dropoff_area.get_original_area_name()] for you to call the extraction pod."))
				return

			call_pod(user)

/datum/traitor_objective/target_player/kidnapping/proc/call_pod(mob/living/user)
	pod_called = TRUE
	var/obj/structure/closet/supplypod/extractionpod/new_pod = new()
	RegisterSignal(new_pod, COMSIG_ATOM_ENTERED, PROC_REF(enter_check))
	new /obj/effect/pod_landingzone(get_turf(user), new_pod)

/datum/traitor_objective/target_player/kidnapping/proc/enter_check(obj/structure/closet/supplypod/extractionpod/source, entered_atom)
	if(!istype(source))
		CRASH("Kidnapping objective's enter_check called with source being not an extraction pod: [source ? source.type : "N/A"]")

	if(!ishuman(entered_atom))
		return

	var/mob/living/carbon/human/sent_mob = entered_atom

	if(sent_mob.mind)
		ADD_TRAIT(sent_mob.mind, TRAIT_HAS_BEEN_KIDNAPPED, TRAIT_GENERIC)

	for(var/obj/item/belonging in gather_belongings(sent_mob))
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue

		var/unequipped = sent_mob.transferItemToLoc(belonging)
		if (!unequipped)
			continue
		target_belongings.Add(belonging)

	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

	if(cargo_account) //Just in case
		var/ransom = rand(5000, 10000) //technically the contractor can get overpayed even if cargo cant pay, but lets just say CC covers the tab, we will see if this is too much
		cargo_account.adjust_money(-min(ransom, cargo_account.account_balance))
		var/obj/item/card/id/owner_id = handler.owner.current?.get_idcard(TRUE)
		if(owner_id?.registered_account.account_id) //why do we check for account id? because apparently unset agent IDs have existing bank accounts that can't be accessed. this is suboptimal
			owner_id.registered_account.adjust_money(ransom * CONTRACTOR_RANSOM_CUT)

			owner_id.registered_account.bank_card_talk("We've processed the ransom, agent. Here's your cut - your balance is now \
			[owner_id.registered_account.account_balance] credits.", TRUE)
		else
			to_chat(handler.owner.current, span_notice("A briefcase appears at your feet!"))
			var/obj/item/storage/secure/briefcase/case = new(get_turf(handler.owner.current))
			for(var/i in 1 to (round((ransom * CONTRACTOR_RANSOM_CUT) / 1000))) // Gets slightly less/more but whatever
				new /obj/item/stack/spacecash/c1000(case)

	priority_announce("One of your crew was captured by a rival organisation - we've needed to pay their ransom to bring them back. \
					As is policy we've taken a portion of the station's funds to offset the overall cost.", "Nanotrasen Asset Protection", has_important_message = TRUE)

	addtimer(CALLBACK(src, PROC_REF(handle_target), sent_mob), 1.5 SECONDS)

	if(sent_mob != target)
		fail_objective(penalty_cost = telecrystal_penalty)
		source.startExitSequence(source)
		return

	if(sent_mob.stat != DEAD)
		telecrystal_reward += alive_bonus

	succeed_objective()
	source.startExitSequence(source)

/datum/traitor_objective/target_player/kidnapping/proc/handle_target(mob/living/carbon/human/sent_mob)
	addtimer(CALLBACK(src, PROC_REF(return_target), sent_mob), 3 MINUTES)
	if(sent_mob.stat == DEAD)
		return

	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)
	sent_mob.dna.species.give_important_for_life(sent_mob) // so plasmamen do not get left for dead
	sent_mob.reagents?.add_reagent(/datum/reagent/medicine/omnizine, 20) //if people end up going with contractors too often(I doubt they will) we can port skyrats wounding stuff
	to_chat(sent_mob, span_hypnophrase(span_reallybig("A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
		we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
		so it's only a matter of time before we ship you back...\"</i>")))

/datum/traitor_objective/target_player/kidnapping/proc/return_target(mob/living/carbon/human/sent_mob)
	if(!sent_mob || QDELETED(sent_mob)) //suicided and qdeleted themselves
		return

	var/list/possible_turfs = list()
	for(var/turf/open/open_turf in dropoff_area)
		if(open_turf.is_blocked_turf() || isspaceturf(open_turf))
			continue
		possible_turfs += open_turf

	var/turf/return_turf = get_safe_random_station_turf_equal_weight()
	if(!return_turf) //SOMEHOW
		to_chat(sent_mob, span_hypnophrase(span_reallybig("A million voices echo in your head... <i>\"Seems where you got sent here from won't \
			be able to handle our pod... You will die here instead.\"</i></span>")))
		if (sent_mob.can_heartattack())
			sent_mob.set_heartattack(TRUE)
		return

	var/obj/structure/closet/supplypod/return_pod = new()
	return_pod.bluespace = TRUE
	return_pod.explosionSize = list(0,0,0,0)
	return_pod.style = STYLE_SYNDICATE

	do_sparks(8, FALSE, sent_mob)
	sent_mob.visible_message(span_notice("[sent_mob] vanishes!"))
	for(var/obj/item/belonging in gather_belongings(sent_mob))
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue
		sent_mob.dropItemToGround(belonging) // No souvenirs, except shoes and t-shirts

	for(var/obj/item/belonging in target_belongings)
		belonging.forceMove(return_pod)

	sent_mob.forceMove(return_pod)
	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)
	sent_mob.dna.species.give_important_for_life(sent_mob) // so plasmamen do not get left for dead

	new /obj/effect/pod_landingzone(return_turf, return_pod)

/// Returns a list of things that the provided mob has which we would rather that they do not have
/datum/traitor_objective/target_player/kidnapping/proc/gather_belongings(mob/living/carbon/human/kidnapee)
	var/list/belongings = kidnapee.get_all_gear()
	for (var/obj/item/implant/storage/internal_bag in kidnapee.implants)
		belongings += internal_bag.contents
	return belongings

#undef CONTRACTOR_RANSOM_CUT
