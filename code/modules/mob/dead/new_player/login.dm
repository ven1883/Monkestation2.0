/mob/dead/new_player/Login()
	if(!client)
		return

	if(CONFIG_GET(flag/use_exp_tracking))
		client?.set_exp_from_db()
		client?.set_db_player_flags()
		if(!client)
			// client disconnected during one of the db queries
			return FALSE

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.set_current(src)

	if((client.player_age != -1) && client.player_age <= CONFIG_GET(number/minimum_age) && !(client.ckey in GLOB.interviews.approved_ckeys))
		client.interviewee = TRUE

	// Check if user should be added to interview queue
	if (!client.holder && CONFIG_GET(flag/panic_bunker) && CONFIG_GET(flag/panic_bunker_interview) && !(client.ckey in GLOB.interviews.approved_ckeys))
		var/required_living_minutes = CONFIG_GET(number/panic_bunker_living)
		var/living_minutes = client.get_exp_living(TRUE)
		if(!CONFIG_GET(flag/minimum_account_age))
			if (required_living_minutes >= living_minutes)
				client.interviewee = TRUE
		else
			if(client.account_age <= CONFIG_GET(number/minimum_age))
				client.interviewee = TRUE

	. = ..()
	if(!. || !client)
		return FALSE

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	// MONKESTATION EDIT START - lobby notices
	if (SSticker.current_state != GAME_STATE_STARTUP && length(config.lobby_notices))
		config.ShowLobbyNotices(src)
	// MONKESTATION END
	if(GLOB.admin_notice)
		to_chat(src, span_notice("<b>Admin Notice:</b>\n \t [GLOB.admin_notice]"))

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, span_notice("<b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]"))

	add_sight(SEE_TURFS)

	if(!client.media)
		client.media = new /datum/media_manager(client)
		client.media.open()
		client.media.update_music()

	var/datum/asset/asset_datum = get_asset_datum(/datum/asset/simple/lobby)
	asset_datum.send(client)
	if(QDELETED(client)) // client disconnected during asset transit
		return FALSE

	// The parent call for Login() may do a bunch of stuff, like add verbs.
	// Delaying the register_for_interview until the very end makes sure it can clean everything up
	// and set the player's client up for interview.

	///guh
	client.check_overwatch()
	if(QDELETED(client)) // client disconnected during overwatch check
		return FALSE

	if(client.interviewee)
		register_for_interview()
		return

	if(QDELETED(client)) // client disconnected during- yeah you get the point
		return FALSE

	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [tl > 0 ? "in about [DisplayTimeText(tl)]" : "soon"].")


	addtimer(CALLBACK(client, TYPE_PROC_REF(/client, playtitlemusic)), 4 SECONDS, TIMER_DELETE_ME)
