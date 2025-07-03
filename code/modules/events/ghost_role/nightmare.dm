/datum/round_event_control/nightmare
	name = "Spawn Nightmare"
	typepath = /datum/round_event/ghost_role/nightmare
	max_occurrences = 1
	min_players = 20
	//dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a nightmare, aiming to darken the station."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/nightmare
	minimum_required = 1
	role_name = "nightmare"
	fakeable = FALSE

/datum/round_event/ghost_role/nightmare/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a Nightmare?",
		role = ROLE_NIGHTMARE,
		check_jobban = ROLE_NIGHTMARE,
		poll_time = 20 SECONDS,
		alert_pic = /datum/antagonist/nightmare,
		role_name_text = "nightmare"
	)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/turf/spawn_loc = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)
	if(isnull(spawn_loc))
		return MAP_ERROR

	var/mob/living/carbon/human/S = new (spawn_loc)
	player_mind.transfer_to(S)
	player_mind.add_antag_datum(/datum/antagonist/nightmare)
	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Nightmare by an event.")
	S.log_message("was spawned as a Nightmare by an event.", LOG_GAME)
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
