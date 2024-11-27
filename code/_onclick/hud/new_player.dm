/datum/hud/new_player

/datum/hud/new_player/New(mob/owner)
	..()

	if(!owner || !owner.client)
		return

	if (owner.client.interviewee)
		return

	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for(var/button_type in buttons)
		var/atom/movable/screen/lobby/lobbyscreen = new button_type()
		lobbyscreen.SlowInit()
		lobbyscreen.hud = src
		static_inventory += lobbyscreen
		if(istype(lobbyscreen, /atom/movable/screen/lobby/button))
			var/atom/movable/screen/lobby/button/lobby_button = lobbyscreen
			lobby_button.owner = REF(owner)

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_BUTTON_LAYER
	screen_loc = "TOP,CENTER"
	var/here


/// Run sleeping actions after initialize
/atom/movable/screen/lobby/proc/SlowInit()
	return

/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'icons/hud/lobby/background_monke.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	///Is the button currently enabled?
	var/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE
	/// The ref of the mob that owns this button. Only the owner can click on it.
	var/owner
	var/area/misc/start/lobbyarea

/atom/movable/screen/lobby/button/Initialize(mapload)
	. = ..()
	lobbyarea = GLOB.areas_by_type[/area/misc/start]

/atom/movable/screen/lobby/button/Click(location, control, params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()

	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	update_appearance(UPDATE_ICON)
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = TRUE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/MouseExited()
	if(owner != REF(usr))
		return

	if(!usr.client || usr.client.interviewee)
		return

	. = ..()
	highlighted = FALSE
	update_appearance(UPDATE_ICON)

/atom/movable/screen/lobby/button/update_icon(updates)
	. = ..()
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
		return
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"
		return
	icon_state = base_icon_state

/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return FALSE
	enabled = status
	update_appearance(UPDATE_ICON)
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP:-87,CENTER:+100"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(FALSE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))
		else
			set_button_status(FALSE)

/atom/movable/screen/lobby/button/ready/proc/hide_ready_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(show_ready_button))

/atom/movable/screen/lobby/button/ready/proc/show_ready_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(hide_ready_button))

/atom/movable/screen/lobby/button/ready/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	ready = !ready
	if(ready)
		new_player.ready = PLAYER_READY_TO_PLAY
		base_icon_state = "ready"
		var/client/new_client = new_player.client
		if(new_client)
			if(!new_client.readied_store)
				new_client.readied_store = new(new_player)
			new_client.readied_store.ui_interact(new_player)
	else
		new_player.ready = PLAYER_NOT_READY
		base_icon_state = "not_ready"
	update_appearance(UPDATE_ICON)

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	screen_loc = "TOP:-54,CENTER:-35"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"
	enabled = FALSE

/atom/movable/screen/lobby/button/join/Initialize(mapload)
	. = ..()
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))
		if(GAME_STATE_SETTING_UP)
			set_button_status(TRUE)
			RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))
		else
			set_button_status(TRUE)

/atom/movable/screen/lobby/button/join/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!SSticker?.IsRoundInProgress())
		to_chat(hud.mymob, span_boldwarning("The round is either not ready, or has already finished..."))
		return

	if(hud.mymob.client?.check_overwatch())
		to_chat(hud.mymob, span_warning("Kindly wait until your connection has been authenticated before joining"))
		message_admins("[hud.mymob.key] tried to use the Join button but failed the overwatch check.")
		return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(hard_popcap && extreme_popcap)
		relevant_cap = min(hard_popcap, extreme_popcap)
	else
		relevant_cap = max(hard_popcap, extreme_popcap)

	var/mob/dead/new_player/new_player = hud.mymob

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(new_player.key) in GLOB.admin_datums)))
		to_chat(new_player, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

		var/queue_position = SSticker.queued_players.Find(new_player)
		if(queue_position == 1)
			to_chat(new_player, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
		else if(queue_position)
			to_chat(new_player, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
		else
			SSticker.queued_players += new_player
			to_chat(new_player, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
		return

	if(!LAZYACCESS(params2list(params), CTRL_CLICK))
		GLOB.latejoin_menu.ui_interact(new_player)
	else
		to_chat(new_player, span_warning("Opening emergency fallback late join menu! If THIS doesn't show, ahelp immediately!"))
		GLOB.latejoin_menu.fallback_ui(new_player)


/atom/movable/screen/lobby/button/join/proc/show_join_button()
	SIGNAL_HANDLER
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(hide_join_button))

/atom/movable/screen/lobby/button/join/proc/hide_join_button()
	SIGNAL_HANDLER
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP)
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(show_join_button))

/atom/movable/screen/lobby/button/observe
	screen_loc = "TOP:-54,CENTER:+82"
	icon = 'icons/hud/lobby/observe.dmi'
	icon_state = "observe_disabled"
	base_icon_state = "observe"
	enabled = FALSE

/atom/movable/screen/lobby/button/observe/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(enable_observing))

/atom/movable/screen/lobby/button/observe/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.make_me_an_observer()

/atom/movable/screen/lobby/button/observe/proc/enable_observing()
	SIGNAL_HANDLER
	flick("[base_icon_state]_enabled", src)
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME)

/atom/movable/screen/lobby/button/patreon_link
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "patreon"
	base_icon_state = "patreon"
	screen_loc = "TOP:-126,CENTER:86"

/atom/movable/screen/lobby/button/patreon_link/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!CONFIG_GET(string/patreon_link_website))
		return
	hud.mymob.client << link("[CONFIG_GET(string/patreon_link_website)]?ckey=[hud.mymob.client.ckey]")

/atom/movable/screen/lobby/button/intents
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "intents"
	base_icon_state = "intents"
	screen_loc = "TOP:-126,CENTER:62"

/atom/movable/screen/lobby/button/intents/Click(location, control, params)
	. = ..()
	if(!hud.mymob.client.challenge_menu)
		var/datum/challenge_selector/new_tgui = new(hud.mymob)
		new_tgui.ui_interact(hud.mymob)
	else
		hud.mymob.client.challenge_menu.ui_interact(hud.mymob)
/atom/movable/screen/lobby/button/discord
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "discord"
	base_icon_state = "discord"
	screen_loc = "TOP:-126,CENTER:38"

/atom/movable/screen/lobby/button/discord/Click(location, control, params)
	. = ..()
	if(!.)
		return
	hud.mymob.client << link("https://discord.gg/monkestation")

/atom/movable/screen/lobby/button/twitch
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "info"
	base_icon_state = "info"
	screen_loc = "TOP:-126,CENTER:14"

/atom/movable/screen/lobby/button/twitch/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!CONFIG_GET(string/twitch_link_website))
		return
	hud.mymob.client << link("[CONFIG_GET(string/twitch_link_website)]?ckey=[hud.mymob.client.ckey]")

/atom/movable/screen/lobby/button/settings
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "settings"
	base_icon_state = "settings"
	screen_loc = "TOP:-126,CENTER:-10"

/atom/movable/screen/lobby/button/settings/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/atom/movable/screen/lobby/button/volume
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "volume"
	base_icon_state = "volume"
	screen_loc = "TOP:-126,CENTER:-34"

/atom/movable/screen/lobby/button/volume/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/datum/preferences/preferences = hud.mymob.client.prefs
	if(!preferences.pref_mixer)
		preferences.pref_mixer = new
	preferences.pref_mixer.open_ui(hud.mymob)

/atom/movable/screen/lobby/button/changelog_button
	icon = 'icons/hud/lobby/changelog.dmi'
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc ="TOP:-98,CENTER:+45"


/atom/movable/screen/lobby/button/crew_manifest
	icon = 'icons/hud/lobby/manifest.dmi'
	icon_state = "manifest"
	base_icon_state = "manifest"
	screen_loc = "TOP:-98,CENTER:-9"

/atom/movable/screen/lobby/button/crew_manifest/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.ViewManifest()

/atom/movable/screen/lobby/button/changelog_button/Click(location, control, params)
	. = ..()
	usr.client?.changelog()

/atom/movable/screen/lobby/button/poll
	icon = 'icons/hud/lobby/poll.dmi'
	icon_state = "poll"
	base_icon_state = "poll"
	screen_loc = "TOP:-98,CENTER:-40"

	var/new_poll = FALSE

/atom/movable/screen/lobby/button/poll/SlowInit(mapload)
	. = ..()
	if(!usr)
		return
	var/mob/dead/new_player/new_player = usr
	if(is_guest_key(new_player.key))
		set_button_status(FALSE)
		return
	if(!SSdbcore.Connect())
		set_button_status(FALSE)
		return
	var/isadmin = FALSE
	if(new_player.client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = new_player.ckey))
	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		set_button_status(FALSE)
		return
	if(query_get_new_polls.NextRow())
		new_poll = TRUE
	else
		new_poll = FALSE
	update_appearance(UPDATE_OVERLAYS)
	qdel(query_get_new_polls)
	if(QDELETED(new_player))
		set_button_status(FALSE)
		return

/atom/movable/screen/lobby/button/poll/update_overlays()
	. = ..()
	if(new_poll)
		. += mutable_appearance('icons/hud/lobby/poll_overlay.dmi', "new_poll")

/atom/movable/screen/lobby/button/poll/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.handle_player_polling()

//This is the changing You are here Button
/atom/movable/screen/lobby/youarehere
	var/vanderlin = 0
	screen_loc = "TOP:-81,CENTER:+177"
	icon = 'icons/hud/lobby/location_indicator.dmi'
	icon_state = "you_are_here"
	screen_loc = "TOP,CENTER:-61"

//Explanation: It gets the port then sets the "here" var in /movable/screen/lobby to the port number
// and if the port number matches it makes clicking the button do nothing so you dont spam reconnect to the server your in
/atom/movable/screen/lobby/youarehere/Initialize(mapload)
	. = ..()
	var/port = world.port
	switch(port)
		if(1342) //HRP
			screen_loc = "TOP:-32,CENTER:+215"
		if(1337) //MRP
			screen_loc = "TOP:-65,CENTER:+215"
		if(2102) //NRP
			screen_loc = "TOP:-98,CENTER:+215"

		else     //Sticks it in the middle, "TOP:0,CENTER:+128" will point at the MonkeStation logo itself.
			screen_loc = "TOP:0,CENTER:+128"


//HRP MONKE
/atom/movable/screen/lobby/button/hrp
	screen_loc = "TOP:-44,CENTER:+173"
	icon = 'icons/hud/lobby/sister_server_buttons.dmi'
	icon_state = "hrp_disabled"
	base_icon_state = "hrp"
	enabled = FALSE

/atom/movable/screen/lobby/button/hrp/Initialize(mapload)
	. = ..()
	if((time2text(world.realtime, "DDD") == "Sat") && (time2text(world.realtime, "hh") >= 12) && (time2text(world.realtime, "hh") <= 18))
		flick("[base_icon_state]", src)
		set_button_status(TRUE)

/atom/movable/screen/lobby/button/hrp/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!(world.port == 1342))
		if((time2text(world.realtime, "DDD") == "Sat") && (time2text(world.realtime, "hh") >= 12) && (time2text(world.realtime, "hh") <= 18))
			hud.mymob.client << link("byond://198.37.111.92:1342")

//MAIN MONKE
/atom/movable/screen/lobby/button/mrp
	screen_loc = "TOP:-77,CENTER:+173"
	icon = 'icons/hud/lobby/sister_server_buttons.dmi'
	icon_state = "mrp"
	base_icon_state = "mrp"

/atom/movable/screen/lobby/button/mrp/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!(world.port == 0))
		hud.mymob.client << link("byond://play.monkestation.com:1337")

//NRP MONKE
/atom/movable/screen/lobby/button/nrp
	screen_loc = "TOP:-110,CENTER:+173"
	icon = 'icons/hud/lobby/sister_server_buttons.dmi'
	icon_state = "nrp"
	base_icon_state = "nrp"

/atom/movable/screen/lobby/button/nrp/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!(world.port == 2102))
		hud.mymob.client << link("byond://198.37.111.92:2102")

//The Vanderlin Project
/atom/movable/screen/lobby/button/vanderlin
	screen_loc = "TOP:-140,CENTER:+177"
	icon = 'icons/hud/lobby/vanderlin_button.dmi'
	icon_state = "vanderlin_disabled"
	base_icon_state = "vanderlin"
	enabled = FALSE

/atom/movable/screen/lobby/button/vanderlin/Initialize(mapload)
	. = ..()
	var/current_day = time2text(world.realtime, "DDD")
	var/current_time = time2text(world.realtime, "hh")
	var/enabled = FALSE
	switch(current_day)
		if("Fri")
			if(current_time >= 15)
				vanderlin_enable()
		if("Sat", "Sun")
			vanderlin_enable()

/atom/movable/screen/lobby/button/vanderlin/proc/vanderlin_enable()
	flick("[base_icon_state]", src)
	set_button_status(TRUE)
	enabled = TRUE

/atom/movable/screen/lobby/button/vanderlin/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!(world.port == 1541))
		if(enabled)
			hud.mymob.client << link("198.37.111.92:1541")

//Monke button
/atom/movable/screen/lobby/button/ook
	screen_loc = "TOP:-126,CENTER:110"
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "monke"
	base_icon_state = "monke"

/atom/movable/screen/lobby/button/ook/Click(location, control, params)
	. = ..()
	if(!.)
		return
	SEND_SOUND(usr, 'monkestation/sound/misc/menumonkey.ogg')
