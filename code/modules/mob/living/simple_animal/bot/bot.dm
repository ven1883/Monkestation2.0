// AI (i.e. game AI, not the AI player) controlled bots
/mob/living/simple_animal/bot
	icon = 'icons/mob/silicon/aibots.dmi'
	layer = MOB_LAYER
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	stop_automated_movement = TRUE
	wander = FALSE
	healable = FALSE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)
	bodytemp_heat_damage_limit = INFINITY
	bodytemp_cold_damage_limit = -1
	has_unlimited_silicon_privilege = TRUE
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE //no default canpush
	pass_flags = PASSFLAPS
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	faction = list(FACTION_NEUTRAL, FACTION_SILICON, FACTION_TURRET)
	light_system = OVERLAY_LIGHT
	light_outer_range = 3
	light_power = 0.9

	///Will other (noncommissioned) bots salute this bot?
	var/commissioned = FALSE
	///Cooldown between salutations for commissioned bots
	COOLDOWN_DECLARE(next_salute_check)

	///Access required to access this Bot's maintenance protocols
	var/maints_access_required = list(ACCESS_ROBOTICS)
	///The Robot arm attached to this robot - has a 50% chance to drop on death.
	var/robot_arm = /obj/item/bodypart/arm/right/robot
	///The type of bot it is, for radio control.
	var/bot_type = NONE

	///Additonal access given to player-controlled bots.
	var/list/player_access = list()
	///All initial access this bot started with.
	var/list/prev_access = list()

	///Bot-related mode flags on the Bot indicating how they will act. BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_GHOST_CONTROLLABLE | BOT_MODE_ROUNDSTART_POSSESSION
	var/bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_GHOST_CONTROLLABLE | BOT_MODE_ROUNDSTART_POSSESSION

	///Bot-related cover flags on the Bot to deal with what has been done to their cover, including emagging. BOT_COVER_OPEN | BOT_COVER_LOCKED | BOT_COVER_EMAGGED | BOT_COVER_HACKED
	var/bot_cover_flags = BOT_COVER_LOCKED

	///Small name of what the bot gets messed with when getting hacked/emagged.
	var/hackables = "system circuits"
	///Used by some bots for tracking failures to reach their target.
	var/frustration = 0
	///The speed at which the bot moves, or the number of times it moves per process() tick.
	var/base_speed = 2
	///The end point of a bot's path, or the target location.
	var/turf/ai_waypoint
	///The bot is on a custom set path.
	var/pathset = FALSE
	///List of turfs through which a bot 'steps' to reach the waypoint, associated with the path image, if there is one.
	var/list/path = list()
	///List of unreachable targets for an ignore-list enabled bot to ignore.
	var/list/ignore_list = list()
	///Standardizes the vars that indicate the bot is busy with its function.
	var/mode = BOT_IDLE
	///Number of times the bot tried and failed to move.
	var/tries = 0
	///Links a bot to the AI calling it.
	var/mob/living/silicon/ai/calling_ai
	///The bot's radio, for speaking to people.
	var/obj/item/radio/internal_radio
	///which channels can the bot listen to
	var/radio_key = null
	///The bot's default radio channel
	var/radio_channel = RADIO_CHANNEL_COMMON
	///Turf a bot is summoned to navitage towards.
	var/turf/patrol_target
	///Turf of a user summoning a bot towards their location.
	var/turf/summon_target
	///Pending new destination (waiting for beacon response)
	var/new_destination
	///Destination description tag
	var/destination
	///The next destination in the patrol route
	var/next_destination

	/// the nearest beacon's tag
	var/nearest_beacon
	///The nearest beacon's location
	var/turf/nearest_beacon_loc

	///The type of data HUD the bot uses. Diagnostic by default.
	var/data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	var/datum/atom_hud/data/bot_path/path_hud
	var/path_image_icon = 'icons/mob/silicon/aibots.dmi'
	var/path_image_icon_state = "path_indicator"
	var/path_image_color = "#FFFFFF"
	var/reset_access_timer_id
	var/ignorelistcleanuptimer = 1 // This ticks up every automated action, at 300 we clean the ignore list

	/// If true we will allow ghosts to control this mob
	var/can_be_possessed = FALSE
	/// If true we will offer this
	COOLDOWN_DECLARE(offer_ghosts_cooldown)
	/// Message to display upon possession
	var/possessed_message = "You're a generic bot. How did one of these even get made?"

/mob/living/simple_animal/bot/proc/get_mode()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		return "<b>Autonomous</b>"
	if(!(bot_mode_flags & BOT_MODE_ON))
		return "<span class='bad'>Inactive</span>"
	return "<span class='average'>[mode]</span>"

/**
 * Returns a status string about the bot's current status, if it's moving, manually controlled, or idle.
 */
/mob/living/simple_animal/bot/proc/get_mode_ui()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		return "Autonomous"
	if(!(bot_mode_flags & BOT_MODE_ON))
		return "Inactive"
	return "[mode]"

/mob/living/simple_animal/bot/proc/turn_on()
	if(stat)
		return FALSE
	bot_mode_flags |= BOT_MODE_ON
	remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), POWER_LACK_TRAIT)
	set_light_on(bot_mode_flags & BOT_MODE_ON ? TRUE : FALSE)
	update_appearance()
	balloon_alert(src, "turned on")
	diag_hud_set_botstat()
	return TRUE

/mob/living/simple_animal/bot/proc/turn_off()
	bot_mode_flags &= ~BOT_MODE_ON
	add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), POWER_LACK_TRAIT)
	set_light_on(bot_mode_flags & BOT_MODE_ON ? TRUE : FALSE)
	bot_reset() //Resets an AI's call, should it exist.
	balloon_alert(src, "turned off")
	update_appearance()

/mob/living/simple_animal/bot/proc/get_bot_flag(checked_mode, checked_flag)
	if(checked_mode & checked_flag)
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/Initialize(mapload)
	. = ..()
	GLOB.bots_list += src

	path_hud = new /datum/atom_hud/data/bot_path()
	for(var/hud in path_hud.hud_icons) // You get to see your own path
		set_hud_image_active(hud, exclusive_hud = path_hud)

	// Give bots a fancy new ID card that can hold any access.
	access_card = new /obj/item/card/id/advanced/simple_bot(src)
	// This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	access_card.set_access(list(ACCESS_ROBOTICS))
	internal_radio = new /obj/item/radio(src)
	if(radio_key)
		internal_radio.keyslot = new radio_key
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0 // anything greater will have the bot broadcast the channel as if it were saying it out loud.
	internal_radio.recalculateChannels()

	//Adds bot to the diagnostic HUD system
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()

	//If a bot has its own HUD (for player bots), provide it.
	if(!isnull(data_hud_type))
		var/datum/atom_hud/datahud = GLOB.huds[data_hud_type]
		datahud.show_to(src)
	if(path_hud)
		path_hud.add_atom_to_hud(src)
		path_hud.show_to(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_BOTS_GLITCHED) && !SSticker.HasRoundStarted()) // monkestation edit: only glitch roundstart bots
		randomize_language_if_on_station()

	if(mapload && is_station_level(z) && bot_mode_flags & BOT_MODE_GHOST_CONTROLLABLE && bot_mode_flags & BOT_MODE_ROUNDSTART_POSSESSION)
		enable_possession(mapload)

/mob/living/simple_animal/bot/Destroy()
	GLOB.bots_list -= src
	QDEL_NULL(internal_radio)
	QDEL_NULL(access_card)
	QDEL_NULL(path_hud)
	return ..()

/// Allows this bot to be controlled by a ghost, who will become its mind
/mob/living/simple_animal/bot/proc/enable_possession(mapload = FALSE)
	can_be_possessed = TRUE
	var/can_announce = !mapload && COOLDOWN_FINISHED(src, offer_ghosts_cooldown)
	AddComponent( \
		/datum/component/ghost_direct_control, \
		ban_type = ROLE_BOT, \
		poll_candidates = can_announce, \
		poll_ignore_key = POLL_IGNORE_BOTS, \
		assumed_control_message = possessed_message, \
		extra_control_checks = CALLBACK(src, PROC_REF(check_possession)), \
		after_assumed_control = CALLBACK(src, PROC_REF(post_possession)), \
	)
	if (can_announce)
		COOLDOWN_START(src, offer_ghosts_cooldown, 30 SECONDS)

/// Disables this bot from being possessed by ghosts
/mob/living/simple_animal/bot/proc/disable_possession(mob/user)
	can_be_possessed = FALSE
	qdel(GetComponent(/datum/component/ghost_direct_control))
	if (mind)
		if (user)
			log_combat(user, src, "ejected from [initial(src.name)] control.")
		to_chat(src, span_warning("You feel yourself fade as your personality matrix is reset!"))
		ghostize(can_reenter_corpse = FALSE)
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		say("Personally matrix reset!", forced = "bot")
		key = null

/// Returns true if this mob can be controlled
/mob/living/simple_animal/bot/proc/check_possession(mob/potential_possessor)
	if (!can_be_possessed)
		to_chat(potential_possessor, span_warning("The bot's personality download has been disabled!"))
	return can_be_possessed

/// Fired after something takes control of this mob
/mob/living/simple_animal/bot/proc/post_possession()
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	say("New personality installed successfully!", forced = "bot")
	rename(src)

/// Allows renaming the bot to something else
/mob/living/simple_animal/bot/proc/rename(mob/user)
	var/new_name = sanitize_name(
		reject_bad_text(tgui_input_text(
			user = user,
			message = "This machine is designated [real_name]. Would you like to update its registration?",
			title = "Name change",
			default = real_name,
			max_length = MAX_NAME_LEN,
		)),
		allow_numbers = TRUE
	)
	if (isnull(new_name) || QDELETED(src))
		return
	if (key && user != src)
		var/accepted = tgui_alert(
			src,
			message = "Do you wish to be renamed to [new_name]?",
			title = "Name change",
			buttons = list("Yes", "No"),
		)
		if (accepted != "Yes" || QDELETED(src))
			return
	fully_replace_character_name(real_name, new_name)

/mob/living/simple_animal/bot/proc/check_access(mob/living/user, obj/item/card/id)
	if(user.has_unlimited_silicon_privilege || isAdminGhostAI(user)) // Silicon and Admins always have access.
		return TRUE
	if(!maints_access_required) // No requirements to access it.
		return TRUE
	if(!(bot_cover_flags & BOT_COVER_LOCKED)) // Unlocked.
		return TRUE
	if(!istype(user)) // Non-living mobs shouldn't be manipulating bots (like observes using the botkeeper UI).
		return FALSE

	var/obj/item/card/id/used_id = id || user.get_idcard(TRUE)

	if(!used_id || !used_id.access)
		return FALSE

	for(var/requested_access in maints_access_required)
		if(requested_access in used_id.access)
			return TRUE
	return FALSE

/mob/living/simple_animal/bot/bee_friendly()
	return TRUE

/mob/living/simple_animal/bot/death(gibbed)
	explode()
	return ..()

/mob/living/simple_animal/bot/proc/explode()
	visible_message(span_boldnotice("[src] blows apart!"))
	do_sparks(3, TRUE, src)
	var/atom/location_destroyed = drop_location()

	if(prob(50) && (bot_type != HONK_BOT))
		drop_part(robot_arm, location_destroyed)
	qdel(src)

/mob/living/simple_animal/bot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(bot_cover_flags & BOT_COVER_LOCKED) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		bot_cover_flags &= ~BOT_COVER_LOCKED
		balloon_alert(user, "cover unlocked")
		return TRUE
	if(!(bot_cover_flags & BOT_COVER_LOCKED) && bot_cover_flags & BOT_COVER_OPEN) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		bot_cover_flags |= BOT_COVER_EMAGGED
		bot_cover_flags &= ~BOT_COVER_LOCKED //Manually emagging the bot locks out the panel.
		bot_mode_flags &= ~BOT_MODE_REMOTE_ENABLED //Manually emagging the bot also locks the AI from controlling it.
		bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
		to_chat(src, span_userdanger("(#$*#$^^( OVERRIDE DETECTED"))
		if(user)
			log_combat(user, src, "emagged")
		return TRUE
	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver (or through the UI) yet.
		balloon_alert(user, "open maintenance panel first!")
		return FALSE

/mob/living/simple_animal/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."
	. += span_notice("Its maintenance panel is [bot_cover_flags & BOT_COVER_OPEN ? "open" : "closed"].")
	. += span_info("You can use a <b>screwdriver</b> to [bot_cover_flags & BOT_COVER_OPEN ? "close" : "open"] it.")
	if(bot_cover_flags & BOT_COVER_OPEN)
		. += span_notice("Its control panel is [bot_cover_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"].")
		var/is_sillycone = issilicon(user)
		if(!(bot_cover_flags & BOT_COVER_EMAGGED) && (is_sillycone || user.Adjacent(src)))
			. += span_info("Alt-click [is_sillycone ? "" : "or use your ID on "]it to [bot_cover_flags & BOT_COVER_LOCKED ? "un" : ""]lock its control panel.")

/mob/living/simple_animal/bot/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && prob(10))
		new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/mob/living/simple_animal/bot/updatehealth()
	..()
	diag_hud_set_bothealth()

/mob/living/simple_animal/bot/med_hud_set_health()
	return //we use a different hud

/mob/living/simple_animal/bot/med_hud_set_status()
	return //we use a different hud

/mob/living/simple_animal/bot/handle_automated_action() //Master process which handles code common across most bots.
	diag_hud_set_botmode()

	if (ignorelistcleanuptimer % 300 == 0) // Every 300 actions, clean up the ignore list from old junk
		for(var/ref in ignore_list)
			var/atom/referredatom = locate(ref)
			if (!referredatom || !istype(referredatom) || QDELETED(referredatom))
				ignore_list -= ref
		ignorelistcleanuptimer = 1
	else
		ignorelistcleanuptimer++

	if(!(bot_mode_flags & BOT_MODE_ON) || client)
		return FALSE

	if(commissioned && COOLDOWN_FINISHED(src, next_salute_check))
		COOLDOWN_START(src, next_salute_check, BOT_COMMISSIONED_SALUTE_DELAY)
		for(var/mob/living/simple_animal/bot/B in view(5, src))
			if(!B.commissioned && B.bot_mode_flags & BOT_MODE_ON)
				visible_message("<b>[B]</b> performs an elaborate salute for [src]!")
				break

	switch(mode) //High-priority overrides are processed first. Bots can do nothing else while under direct command.
		if(BOT_RESPONDING) //Called by the AI.
			call_mode()
			return FALSE
		if(BOT_SUMMON) //Called to a location
			summon_step()
			return FALSE
	return TRUE //Successful completion. Used to prevent child process() continuing if this one is ended early.


/mob/living/simple_animal/bot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!(user.istate & ISTATE_HARM))
		ui_interact(user)
	else
		return ..()

/mob/living/simple_animal/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		ui_interact(user)
	else
		to_chat(user, span_warning("[src]'s interface is not responding!"))

/mob/living/simple_animal/bot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SimpleBot", name)
		ui.open()

/mob/living/simple_animal/bot/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	unlock_with_id(user)

/mob/living/simple_animal/bot/proc/unlock_with_id(mob/user)
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		to_chat(user, span_danger("ERROR"))
		return
	if(bot_cover_flags & BOT_COVER_OPEN)
		to_chat(user, span_warning("Please close the access panel before [bot_cover_flags & BOT_COVER_LOCKED ? "un" : ""]locking it."))
		return
	if(!check_access(user))
		to_chat(user, span_warning("Access denied."))
		return
	bot_cover_flags ^= BOT_COVER_LOCKED
	to_chat(user, span_notice("Controls are now [bot_cover_flags & BOT_COVER_LOCKED ? "locked" : "unlocked"]."))
	return TRUE

/mob/living/simple_animal/bot/screwdriver_act(mob/living/user, obj/item/tool)
	if(bot_cover_flags & BOT_COVER_LOCKED)
		to_chat(user, span_warning("The maintenance panel is locked!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(src)
	bot_cover_flags ^= BOT_COVER_OPEN
	to_chat(user, span_notice("The maintenance panel is now [bot_cover_flags & BOT_COVER_OPEN ? "opened" : "closed"]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/simple_animal/bot/welder_act(mob/living/user, obj/item/tool)
	user.changeNext_move(CLICK_CD_MELEE)
	if((user.istate & ISTATE_HARM))
		return FALSE

	if(health >= maxHealth)
		to_chat(user, span_warning("[src] does not need a repair!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!(bot_cover_flags & BOT_COVER_OPEN))
		to_chat(user, span_warning("Unable to repair with the maintenance panel closed!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(tool.use_tool(src, user, 0 SECONDS, volume=40))
		adjustHealth(-10)
		user.visible_message(span_notice("[user] repairs [src]!"),span_notice("You repair [src]."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/mob/living/simple_animal/bot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.GetID())
		unlock_with_id(user)
		return
	return ..()

/mob/living/simple_animal/bot/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if (!.)
		return
	do_sparks(5, TRUE, src)

/mob/living/simple_animal/bot/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if(prob(25) || . != BULLET_ACT_HIT)
		return
	if(hitting_projectile.damage_type != BRUTE && hitting_projectile.damage_type != BURN)
		return
	if(!hitting_projectile.is_hostile_projectile() || hitting_projectile.damage <= 0)
		return
	do_sparks(5, TRUE, src)

/mob/living/simple_animal/bot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/was_on = bot_mode_flags & BOT_MODE_ON ? TRUE : FALSE
	stat |= EMPED
	new /obj/effect/temp_visual/emp(loc)

	if(prob(70/severity))
		var/datum/language_holder/bot_languages = get_language_holder()
		bot_languages.selected_language = bot_languages.get_random_spoken_language()

	if(bot_mode_flags & BOT_MODE_ON)
		turn_off()
	addtimer(CALLBACK(src, PROC_REF(emp_reset), was_on), severity * 30 SECONDS)

/mob/living/simple_animal/bot/proc/emp_reset(was_on)
	stat &= ~EMPED
	if(was_on)
		turn_on()

/mob/living/simple_animal/bot/proc/speak(message,channel) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!(bot_mode_flags & BOT_MODE_ON)) || (!message))
		return
	if(channel && internal_radio.channels[channel])// Use radio if we have channel key
		internal_radio.talk_into(src, message, channel)
	else
		say(message)

/mob/living/simple_animal/bot/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(.)
		return

	if(message_mods[MODE_HEADSET])
		internal_radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT)
		internal_radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		internal_radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE

/mob/living/simple_animal/bot/proc/drop_part(obj/item/drop_item, dropzone)
	var/obj/item/item_to_drop
	if(ispath(drop_item))
		item_to_drop = new drop_item(dropzone)
	else
		item_to_drop = drop_item
		item_to_drop.forceMove(dropzone)

	if(istype(item_to_drop, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/dropped_cell = item_to_drop
		dropped_cell.charge = 0
		dropped_cell.update_appearance()

	else if(istype(item_to_drop, /obj/item/storage))
		var/obj/item/storage/storage_to_drop = item_to_drop
		storage_to_drop.contents = list()

	else if(istype(item_to_drop, /obj/item/gun/energy))
		var/obj/item/gun/energy/dropped_gun = item_to_drop
		dropped_gun.cell.charge = 0
		dropped_gun.update_appearance()

//Generalized behavior code, override where needed!

GLOBAL_LIST_EMPTY(scan_typecaches)
/**
 * Attempt to scan tiles near [src], first by checking adjacent, then if a target is still not found, nearby.
 *
 * scan_types - list (of typepaths) that nearby tiles are being scanned for.
 * old_target - what has already been scanned, and will early return at checkscan.
 * scan_range - how far away from [src] will be scanned, if nothing is found directly adjacent.
 */
/mob/living/simple_animal/bot/proc/scan(list/scan_types, old_target, scan_range = DEFAULT_SCAN_RANGE)
	var/key = scan_types.Join(",")
	var/list/scan_cache = GLOB.scan_typecaches[key]
	if(!scan_cache)
		scan_cache = typecacheof(scan_types)
		GLOB.scan_typecaches[key] = scan_cache
	if(!get_turf(src))
		return
	// Nicer behavior, ensures we don't conflict with other bots quite so often
	var/list/adjacent = list()
	for(var/turf/to_walk in view(1, src))
		adjacent += to_walk

	adjacent = shuffle(adjacent)

	var/list/turfs_to_walk = list()
	for(var/turf/victim in view(scan_range, src))
		turfs_to_walk += victim

	turfs_to_walk = turfs_to_walk - adjacent
	// Now we prepend adjacent since we want to run those first
	turfs_to_walk = adjacent + turfs_to_walk

	for(var/turf/scanned as anything in turfs_to_walk)
		// Check bot is inlined here to save cpu time
		//Is there another bot there? Then let's just skip it so we dont all atack on top of eachother.
		var/bot_found = FALSE
		for(var/mob/living/simple_animal/bot/buddy in scanned.contents)
			if(istype(buddy, type) && (buddy != src))
				bot_found = TRUE
				break
		if(bot_found)
			continue

		for(var/atom/thing as anything in scanned)
			if(!scan_cache[thing.type]) //Check that the thing we found is the type we want!
				continue //If not, keep searching!
			if(thing == old_target || (REF(thing) in ignore_list)) //Filter for blacklisted elements, usually unreachable or previously processed oness
				continue

			var/scan_result = process_scan(thing) //Some bots may require additional processing when a result is selected.
			if(!isnull(scan_result))
				return scan_result

//When the scan finds a target, run bot specific processing to select it for the next step. Empty by default.
/mob/living/simple_animal/bot/proc/process_scan(scan_target)
	return scan_target

/mob/living/simple_animal/bot/proc/check_bot(targ)
	var/turf/target_turf = get_turf(targ)
	if(!target_turf)
		return FALSE
	for(var/mob/living/simple_animal/bot/buddy in target_turf.contents)
		if(istype(buddy, type) && (buddy != src))
			return TRUE
	return FALSE

/mob/living/simple_animal/bot/proc/add_to_ignore(subject)
	if(ignore_list.len < 50) //This will help keep track of them, so the bot is always trying to reach a blocked spot.
		ignore_list += REF(subject)
	else  //If the list is full, insert newest, delete oldest.
		ignore_list.Cut(1,2)
		ignore_list += REF(subject)

/*
Movement proc for stepping a bot through a path generated through A-star.
Pass a positive integer as an argument to override a bot's default speed.
*/
/mob/living/simple_animal/bot/proc/bot_move(dest, move_speed)
	if(!dest || !path || path.len == 0) //A-star failed or a path/destination was not set.
		set_path(null)
		return FALSE
	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(src) == dest) //We have arrived, no need to move again.
		return TRUE
	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE
	var/step_count = move_speed ? move_speed : base_speed //If a value is passed into move_speed, use that instead of the default speed var.

	if(step_count >= 1 && tries < BOT_STEP_MAX_RETRIES)
		for(var/step_number in 1 to step_count)
			addtimer(CALLBACK(src, PROC_REF(bot_step)), BOT_STEP_DELAY*(step_number-1))
	else
		return FALSE
	return TRUE

/// Performs a step_towards and increments the path if successful. Returns TRUE if the bot moved and FALSE otherwise.
/mob/living/simple_animal/bot/proc/bot_step()
	if(!length(path))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_MOB_BOT_PRE_STEP) & COMPONENT_MOB_BOT_BLOCK_PRE_STEP)
		return FALSE

	if(!step_towards(src, path[1]))
		tries++
		return FALSE

	increment_path()
	tries = 0
	SEND_SIGNAL(src, COMSIG_MOB_BOT_STEP)
	return TRUE


/mob/living/simple_animal/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		access_card.set_access(prev_access)

/mob/living/simple_animal/bot/proc/call_bot(user, turf/waypoint, message = TRUE)
	if(isAI(user) && calling_ai && calling_ai != src) //Prevents an override if another AI is controlling this bot.
		return FALSE

	bot_reset() //Reset a bot before setting it to call mode.

	//For giving the bot temporary all-access. This method is bad and makes me feel bad. Refactoring access to a component is for another PR.
	//Easier then building the list ourselves. I'm sorry.
	var/static/obj/item/card/id/all_access = new /obj/item/card/id/advanced/gold/captains_spare()
	set_path(get_path_to(src, waypoint, max_distance=200, access = all_access.GetAccess()))
	calling_ai = user //Link the AI to the bot!
	ai_waypoint = waypoint

	if(path?.len) //Ensures that a valid path is calculated!
		var/end_area = get_area_name(waypoint)
		if(!(bot_mode_flags & BOT_MODE_ON))
			turn_on() //Saves the AI the hassle of having to activate a bot manually.
		access_card.set_access(REGION_ACCESS_ALL_STATION) //Give the bot all-access while under the AI's command.
		if(client)
			reset_access_timer_id = addtimer(CALLBACK (src, PROC_REF(bot_reset)), 60 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE) //if the bot is player controlled, they get the extra access for a limited time
			to_chat(src, span_notice("[span_big("Priority waypoint set by [icon2html(calling_ai, src)] <b>[user]</b>. Proceed to <b>[end_area]</b>.")]<br>[path.len-1] meters to destination. You have been granted additional door access for 60 seconds."))
		if(message)
			to_chat(calling_ai, span_notice("[icon2html(src, calling_ai)] [name] called to [end_area]. [path.len-1] meters to destination."))
		pathset = TRUE
		mode = BOT_RESPONDING
		tries = 0
	else
		if(message)
			to_chat(calling_ai, span_danger("Failed to calculate a valid route. Ensure destination is clear of obstructions and within range."))
		calling_ai = null
		set_path(null)

	return TRUE

/mob/living/simple_animal/bot/proc/call_mode() //Handles preparing a bot for a call, as well as calling the move proc.
//Handles the bot's movement during a call.
	var/success = bot_move(ai_waypoint, 3)
	if(!success)
		if(calling_ai)
			to_chat(calling_ai, "[icon2html(src, calling_ai)] [get_turf(src) == ai_waypoint ? span_notice("[src] successfully arrived to waypoint.") : span_danger("[src] failed to reach waypoint.")]")
			calling_ai = null
		bot_reset()

/mob/living/simple_animal/bot/proc/bot_reset()
	if(calling_ai) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		to_chat(calling_ai, span_danger("Call command to a bot has been reset."))
		calling_ai = null
	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null
	set_path(null)
	summon_target = null
	pathset = FALSE
	if(QDELETED(access_card))
		access_card = new /obj/item/card/id/advanced/simple_bot(src)
	access_card.set_access(prev_access)
	tries = 0
	mode = BOT_IDLE
	ignore_list = list()
	diag_hud_set_botstat()
	diag_hud_set_botmode()




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/mob/living/simple_animal/bot/proc/bot_patrol()
	patrol_step()
	addtimer(CALLBACK(src, PROC_REF(do_patrol)), 5)

/mob/living/simple_animal/bot/proc/do_patrol()
	if(mode == BOT_PATROL)
		patrol_step()

/mob/living/simple_animal/bot/proc/start_patrol()

	if(tries >= BOT_STEP_MAX_RETRIES) //Bot is trapped, so stop trying to patrol.
		bot_mode_flags &= ~BOT_MODE_AUTOPATROL
		tries = 0
		speak("Unable to start patrol.")

		return

	if(!(bot_mode_flags & BOT_MODE_AUTOPATROL)) //A bot not set to patrol should not be patrolling.
		mode = BOT_IDLE
		return

	if(patrol_target) // has patrol target
		INVOKE_ASYNC(src, PROC_REF(target_patrol))
	else // no patrol target, so need a new one
		speak("Engaging patrol mode.")
		find_patrol_target()
		tries++
	return

/mob/living/simple_animal/bot/proc/target_patrol()
	calc_path() // Find a route to it
	if(!path.len)
		patrol_target = null
		return
	mode = BOT_PATROL
// perform a single patrol step

/mob/living/simple_animal/bot/proc/patrol_step()

	if(client) // In use by player, don't actually move.
		return

	if(loc == patrol_target) // reached target
		//Find the next beacon matching the target.
		if(!get_next_patrol_target())
			find_patrol_target() //If it fails, look for the nearest one instead.
		return

	else if(path.len > 0 && patrol_target) // valid path
		if(path[1] == loc)
			increment_path()
			return


		var/moved = bot_move(patrol_target)//step_towards(src, next) // attempt to move
		if(!moved) //Couldn't proceed the next step of the path BOT_STEP_MAX_RETRIES times
			addtimer(CALLBACK(src, PROC_REF(patrol_step_not_moved)), 2)

	else // no path, so calculate new one
		mode = BOT_START_PATROL

/mob/living/simple_animal/bot/proc/patrol_step_not_moved()
	calc_path()
	if(!length(path))
		find_patrol_target()
	tries = 0

// finds the nearest beacon to self
/mob/living/simple_animal/bot/proc/find_patrol_target()
	nearest_beacon = null
	new_destination = null
	find_nearest_beacon()
	if(nearest_beacon)
		patrol_target = nearest_beacon_loc
		destination = next_destination
	else
		bot_mode_flags &= ~BOT_MODE_AUTOPATROL
		mode = BOT_IDLE
		speak("Disengaging patrol mode.")

/mob/living/simple_animal/bot/proc/get_next_patrol_target()
	// search the beacon list for the next target in the list.
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		if(NB.location == next_destination) //Does the Beacon location text match the destination?
			destination = new_destination //We now know the name of where we want to go.
			patrol_target = NB.loc //Get its location and set it as the target.
			next_destination = NB.codes[NAVBEACON_PATROL_NEXT] //Also get the name of the next beacon in line.
			return TRUE

/mob/living/simple_animal/bot/proc/find_nearest_beacon()
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		var/dist = get_dist(src, NB)
		if(nearest_beacon) //Loop though the beacon net to find the true closest beacon.
			//Ignore the beacon if were are located on it.
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = NB.location
				nearest_beacon_loc = NB.loc
				next_destination = NB.codes[NAVBEACON_PATROL_NEXT]
			else
				continue
		else if(dist > 1) //Begin the search, save this one for comparison on the next loop.
			nearest_beacon = NB.location
			nearest_beacon_loc = NB.loc
	patrol_target = nearest_beacon_loc
	destination = nearest_beacon

//PDA control. Some bots, especially MULEs, may have more parameters.
/mob/living/simple_animal/bot/proc/bot_control(command, mob/user, list/user_access = list())
	if(!(bot_mode_flags & BOT_MODE_ON) || bot_cover_flags & BOT_COVER_EMAGGED || !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return TRUE //ACCESS DENIED
	if(client)
		bot_control_message(command, user)
	// process control input
	switch(command)
		if("patroloff")
			bot_reset() //HOLD IT!! //OBJECTION!!
			bot_mode_flags &= ~BOT_MODE_AUTOPATROL

		if("patrolon")
			bot_mode_flags |= BOT_MODE_AUTOPATROL

		if("summon")
			bot_reset()
			summon_target = get_turf(user)
			if(user_access.len != 0)
				access_card.set_access(user_access + prev_access) //Adds the user's access, if any.
			mode = BOT_SUMMON
			speak("Responding.", radio_channel)
	return


/mob/living/simple_animal/bot/proc/bot_control_message(command, user)
	switch(command)
		if("patroloff")
			to_chat(src, "<span class='warning big'>STOP PATROL</span>")
		if("patrolon")
			to_chat(src, "<span class='warning big'>START PATROL</span>")
		if("summon")
			to_chat(src, "<span class='warning big'>PRIORITY ALERT:[user] in [get_area_name(user)]!</span>")
		if("stop")
			to_chat(src, "<span class='warning big'>STOP!</span>")

		if("go")
			to_chat(src, "<span class='warning big'>GO!</span>")

		if("home")
			to_chat(src, "<span class='warning big'>RETURN HOME!</span>")
		if("ejectpai")
			return
		else
			to_chat(src, span_warning("Unidentified control sequence received:[command]"))

// calculates a path to the current destination
// given an optional turf to avoid
/mob/living/simple_animal/bot/proc/calc_path(turf/avoid)
	check_bot_access()
	set_path(get_path_to(src, patrol_target, max_distance=120, access=access_card.GetAccess(), exclude=avoid, diagonal_handling=DIAGONAL_REMOVE_ALL))

/mob/living/simple_animal/bot/proc/calc_summon_path(turf/avoid)
	check_bot_access()
	var/datum/callback/path_complete = CALLBACK(src, PROC_REF(on_summon_path_finish))
	SSpathfinder.pathfind(src, summon_target, max_distance=150, access=access_card.GetAccess(), exclude=avoid, diagonal_handling=DIAGONAL_REMOVE_ALL, on_finish=list(path_complete))

/mob/living/simple_animal/bot/proc/on_summon_path_finish(list/path)
	set_path(path)
	if(!length(path)) //Cannot reach target. Give up and announce the issue.
		speak("Summon command failed, destination unreachable.",radio_channel)
		bot_reset()

/mob/living/simple_animal/bot/proc/summon_step()

	if(client) // In use by player, don't actually move.
		return

	if(loc == summon_target) // Arrived to summon location.
		bot_reset()
		return

	else if(path.len > 0 && summon_target) //Proper path acquired!
		if(path[1] == loc)
			increment_path()
			return

		var/moved = bot_move(summon_target, 3) // Move attempt
		if(!moved)
			addtimer(CALLBACK(src, PROC_REF(summon_step_not_moved)), 2)

	else // no path, so calculate new one
		calc_summon_path()

/mob/living/simple_animal/bot/proc/summon_step_not_moved()
	calc_summon_path()
	tries = 0

/mob/living/simple_animal/bot/Bump(atom/A) //Leave no door unopened!
	. = ..()
	if((istype(A, /obj/machinery/door/airlock) || istype(A, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = A
		if(D.check_access(access_card))
			D.open()
			frustration = 0

/mob/living/simple_animal/bot/ui_data(mob/user)
	var/list/data = list()
	data["can_hack"] = (issilicon(user) || isAdminGhostAI(user))
	data["custom_controls"] = list()
	data["emagged"] = bot_cover_flags & BOT_COVER_EMAGGED
	data["has_access"] = check_access(user)
	data["locked"] = bot_cover_flags & BOT_COVER_LOCKED
	data["settings"] = list()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["settings"]["allow_possession"] = bot_mode_flags & BOT_MODE_GHOST_CONTROLLABLE
		data["settings"]["possession_enabled"] = can_be_possessed
		data["settings"]["airplane_mode"] = !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED)
		data["settings"]["maintenance_lock"] = !(bot_cover_flags & BOT_COVER_OPEN)
		data["settings"]["power"] = bot_mode_flags & BOT_MODE_ON
		data["settings"]["patrol_station"] = bot_mode_flags & BOT_MODE_AUTOPATROL
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!check_access(usr))
		to_chat(usr, span_warning("Access denied."))
		return

	if(action == "lock")
		bot_cover_flags ^= BOT_COVER_LOCKED

	switch(action)
		if("power")
			if(bot_mode_flags & BOT_MODE_ON)
				turn_off()
			else
				turn_on()
		if("maintenance")
			bot_cover_flags ^= BOT_COVER_OPEN
		if("patrol")
			bot_mode_flags ^= BOT_MODE_AUTOPATROL
			bot_reset()
		if("airplane")
			bot_mode_flags ^= BOT_MODE_REMOTE_ENABLED
		if("hack")
			if(!(issilicon(usr) || isAdminGhostAI(usr)))
				return
			if(!(bot_cover_flags & BOT_COVER_EMAGGED))
				bot_cover_flags |= (BOT_COVER_EMAGGED|BOT_COVER_HACKED|BOT_COVER_LOCKED)
				to_chat(usr, span_warning("You overload [src]'s [hackables]."))
				message_admins("Safety lock of [ADMIN_LOOKUPFLW(src)] was disabled by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)]")
				usr.log_message("disabled safety lock of [src]", LOG_GAME)
				bot_reset()
			else if(!(bot_cover_flags & BOT_COVER_HACKED))
				to_chat(usr, span_boldannounce("You fail to repair [src]'s [hackables]."))
			else
				bot_cover_flags &= ~(BOT_COVER_EMAGGED|BOT_COVER_HACKED)
				to_chat(usr, span_notice("You reset the [src]'s [hackables]."))
				usr.log_message("re-enabled safety lock of [src]", LOG_GAME)
				bot_reset()
		if("toggle_personality")
			if (can_be_possessed)
				disable_possession(usr)
			else
				enable_possession()
		if("rename")
			rename(usr)

/mob/living/simple_animal/bot/update_icon_state()
	icon_state = "[isnull(base_icon_state) ? initial(icon_state) : base_icon_state][get_bot_flag(bot_mode_flags, BOT_MODE_ON)]"
	return ..()

/mob/living/simple_animal/bot/proc/topic_denied(mob/user) //Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH))
		return TRUE
	// 0 for access, 1 for denied.
	if(bot_cover_flags & BOT_COVER_EMAGGED) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!(bot_cover_flags & BOT_COVER_HACKED)) //Manually emagged by a human - access denied to all.
			return TRUE
		else if(!issilicon(user) && !isAdminGhostAI(user)) //Bot is hacked, so only silicons and admins are allowed access.
			return TRUE
	return FALSE

/mob/living/simple_animal/bot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	// If we have any bonus player accesses, add them to our internal ID card.
	if(length(player_access))
		access_card.add_access(player_access)
	diag_hud_set_botmode()

/mob/living/simple_animal/bot/Logout()
	. = ..()
	bot_reset()

/mob/living/simple_animal/bot/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	update_appearance()

/mob/living/simple_animal/bot/sentience_act()
	faction -= FACTION_SILICON

/mob/living/simple_animal/bot/proc/set_path(list/newpath)
	path = newpath ? newpath : list()
	if(!path_hud)
		return
	var/list/path_huds_watching_me = list(GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED])
	if(path_hud)
		path_huds_watching_me += path_hud
	for(var/datum/atom_hud/hud as anything in path_huds_watching_me)
		hud.remove_atom_from_hud(src)

	var/list/path_images = active_hud_list[DIAG_PATH_HUD]
	LAZYCLEARLIST(path_images)
	if(length(newpath))
		var/mutable_appearance/path_image = new /mutable_appearance()
		path_image.icon = path_image_icon
		path_image.icon_state = path_image_icon_state
		path_image.layer = BOT_PATH_LAYER
		path_image.appearance_flags = RESET_COLOR|RESET_TRANSFORM
		path_image.color = path_image_color
		for(var/i in 1 to newpath.len)
			var/turf/T = newpath[i]
			if(T == loc) //don't bother putting an image if it's where we already exist.
				continue
			var/direction = get_dir(src, T)
			if(i > 1)
				var/turf/prevT = path[i - 1]
				var/image/prevI = path[prevT]
				direction = get_dir(prevT, T)
				if(i > 2 && prevI) // make sure we actually have an image to manipulate at index > 2
					var/turf/prevprevT = path[i - 2]
					var/prevDir = get_dir(prevprevT, prevT)
					var/mixDir = direction|prevDir
					if(ISDIAGONALDIR(mixDir))
						prevI.dir = mixDir
						if(prevDir & (NORTH|SOUTH))
							var/matrix/ntransform = matrix()
							ntransform.Turn(90)
							if((mixDir == NORTHWEST) || (mixDir == SOUTHEAST))
								ntransform.Scale(-1, 1)
							else
								ntransform.Scale(1, -1)
							prevI.transform = ntransform

			SET_PLANE(path_image, GAME_PLANE, T)
			path_image.dir = direction
			var/image/I = image(loc = T)
			I.appearance = path_image
			path[T] = I
			path_images += I

	for(var/datum/atom_hud/hud as anything in path_huds_watching_me)
		hud.add_atom_to_hud(src)

/mob/living/simple_animal/bot/proc/increment_path()
	if(!length(path))
		return
	var/image/I = path[path[1]]
	if(I)
		animate(I, alpha = 0, time = 3)
	path.Cut(1, 2)

	if(!length(path))
		addtimer(CALLBACK(src, PROC_REF(set_path), null), 0.6 SECONDS) // Enough time for the animate to finish

/mob/living/simple_animal/bot/rust_heretic_act()
	adjustBruteLoss(400)
