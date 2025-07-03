GLOBAL_LIST_INIT(jukebox_track_files, list("monkestation/code/modules/cassettes/track_folder/base_tracks.json"))

///Tracks are sorted by genre then by title inside that.
/proc/cmp_media_track_asc(datum/media_track/A, datum/media_track/B)
	var/genre_sort = sorttext(B.genre || "Uncategorized", A.genre || "Uncategorized")
	return genre_sort || sorttext(B.title, A.title)

SUBSYSTEM_DEF(media_tracks)
	name = "Media Tracks"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_MEDIA_TRACKS

	/// Every track, including secret
	var/list/all_tracks = list()
	/// Non-secret jukebox tracks
	var/list/jukebox_tracks = list()
	/// Lobby music tracks
	var/list/lobby_tracks = list()
	///have we picked our lobby song yet?
	var/first_lobby_play = TRUE
	///current picked lobby song
	var/datum/media_track/current_lobby_track

/datum/controller/subsystem/media_tracks/Initialize(timeofday)
	if(!length(GLOB.jukebox_track_files))
		return SS_INIT_NO_NEED
	load_tracks()
	sort_tracks()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/media_tracks/proc/load_tracks()
	for(var/filename in GLOB.jukebox_track_files)
		message_admins("Loading jukebox track(s): [filename]")

		if(!fexists(filename))
			log_runtime("File not found: [filename]")
			continue

		var/list/json_data = json_decode(file2text(filename))

		if(!islist(json_data))
			log_runtime("Failed to read tracks from [filename], json_decode failed.")
			continue

		var/is_json_obj = FALSE
		var/is_json_arr = FALSE
		switch(json_encode(json_data)[1])
			if("{")
				is_json_obj = TRUE
			if("\[")
				is_json_arr = TRUE
		// Some files could be an object, since SSticker adds lobby tracks from jsons that aren't arrays
		if(is_json_obj)
			process_track(json_data, filename)
		else if(is_json_arr)
			for(var/entry in json_data)
				process_track(entry, filename)
		else
			// how did we end up here?
			log_runtime("Failed to read tracks from [filename], is not object or array.")

/datum/controller/subsystem/media_tracks/proc/process_track(var/list/entry, var/filename)
	// Critical problems that will prevent the track from working
	if(!istext(entry["url"]))
		log_runtime("Jukebox entry in [filename]: bad or missing 'url'. Tracks must have a URL.")
		return
	if(!istext(entry["title"]))
		log_runtime("Jukebox entry in [filename]: bad or missing 'title'. Tracks must have a title.")
		return
	if(!isnum(entry["duration"]))
		log_runtime("Jukebox entry in [filename]: bad or missing 'duration'. Tracks must have a duration (in deciseconds).")
		return

	// Noncritical problems, we can keep going anyway, but warn so it can be fixed
	if(!istext(entry["artist"]))
		warning("Jukebox entry in [filename], [entry["title"]]: bad or missing 'artist'. Please consider crediting the artist.")
	if(!istext(entry["genre"]))
		warning("Jukebox entry in [filename], [entry["title"]]: bad or missing 'genre'. Please consider adding a genre.")

	var/datum/media_track/track = new(entry["url"], entry["title"], entry["duration"], entry["artist"], entry["genre"])

	track.secret = entry["secret"]
	track.lobby = entry["lobby"]

	all_tracks += track

/datum/controller/subsystem/media_tracks/proc/sort_tracks()
	message_admins("Sorting media tracks...")
	sortTim(all_tracks, GLOBAL_PROC_REF(cmp_media_track_asc))

	jukebox_tracks.Cut()
	lobby_tracks.Cut()

	for(var/datum/media_track/track as anything in all_tracks)
		if(!track.secret)
			jukebox_tracks += track
		if(track.lobby)
			lobby_tracks += track

	message_admins("Total tracks - Jukebox: [length(jukebox_tracks)] - Lobby: [length(lobby_tracks)]")

/datum/controller/subsystem/media_tracks/proc/manual_track_add(mob/user = usr)
	if(!check_rights(R_DEBUG | R_FUN))
		return

	// Required
	var/url = tgui_input_text(user, "REQUIRED: Provide URL for track, or paste JSON if you know what you're doing. See code comments.", "Track URL", multiline = TRUE)
	if(!url)
		return

	var/list/json
	if(rustg_json_is_valid(url))
		json = json_decode(url)

	/**
	 * Alternatively to using a series of inputs, you can use json and paste it in.
	 * The json base element needs to be an array, even if it's only one song, so wrap it in []
	 * The songs are json object literals inside the base array and use these keys:
	 * "url": the url for the song (REQUIRED) (text)
	 * "title": the title of the song (REQUIRED) (text)
	 * "duration": duration of song in 1/10ths of a second (seconds * 10) (REQUIRED) (number)
	 * "artist": artist of the song (text)
	 * "genre": artist of the song, REALLY try to match an existing one (text)
	 * "secret": only on hacked jukeboxes (true/false)
	 * "lobby": plays in the lobby (true/false)
	 */

	if(islist(json))
		for(var/song in json)
			if(!islist(song))
				to_chat(user, span_warning("Song appears to be malformed."))
				continue
			var/list/songdata = song
			if(!songdata["url"] || !songdata["title"] || !songdata["duration"])
				to_chat(user, span_warning("URL, Title, or Duration was missing from a song. Skipping"))
				continue
			var/datum/media_track/track = new(songdata["url"], songdata["title"], songdata["duration"], songdata["artist"], songdata["genre"], songdata["secret"], songdata["lobby"])
			all_tracks += track

			message_admins("New media track added by [key_name(user)]: [track.title]")
		sort_tracks()
		return

	var/title = tgui_input_text(user, "REQUIRED: Provide title for track", "Track Title")
	if(!title)
		return

	var/duration = tgui_input_number(user, "REQUIRED: Provide duration for track (in deciseconds, aka seconds*10)", "Track Duration")
	if(!duration)
		return

	// Optional
	var/artist = tgui_input_text(user, "Optional: Provide artist for track", "Track Artist")
	if(isnull(artist)) // Cancel rather than empty string
		return

	var/genre = tgui_input_text(user, "Optional: Provide genre for track (try to match an existing one)", "Track Genre")
	if(isnull(genre)) // Cancel rather than empty string
		return

	var/secret = tgui_alert(user, "Optional: Mark track as secret?", "Track Secret", list("Yes", "Cancel", "No"))
	if(secret == "Cancel")
		return
	else if(secret == "Yes")
		secret = TRUE
	else
		secret = FALSE

	var/lobby = tgui_alert(user, "Optional: Mark track as lobby music?", "Track Lobby", list("Yes", "Cancel", "No"))
	if(lobby == "Cancel")
		return
	else if(secret == "Yes")
		secret = TRUE
	else
		secret = FALSE

	var/datum/media_track/track = new(url, title, duration, artist, genre)

	track.secret = secret
	track.lobby = lobby

	all_tracks += track

	message_admins("New media track added by [key_name(user)]: [title]")
	sort_tracks()

/datum/controller/subsystem/media_tracks/proc/manual_track_remove(mob/user = usr)
	if(!check_rights(R_DEBUG|R_FUN))
		return

	var/track_to_remove = tgui_input_text(user, "Input track title or URL to remove (must be exact)", "Remove Track")
	if(!track_to_remove)
		return

	var/found_track = FALSE
	for(var/datum/media_track/track as anything in all_tracks)
		if(track.title != track_to_remove && track.url != track_to_remove)
			continue
		all_tracks -= track
		qdel(track)
		message_admins("Media track removed by [key_name(user)]: [track]")
		found_track = TRUE

	if(found_track)
		sort_tracks()
	else
		to_chat(user, span_warning("Couldn't find a track matching the specified parameters."))

/datum/controller/subsystem/media_tracks/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION("add_track", "Add New Track")
	VV_DROPDOWN_OPTION("remove_track", "Remove Track")

/datum/controller/subsystem/media_tracks/vv_do_topic(list/href_list)
	. = ..()
	if(href_list["add_track"] && check_rights(R_FUN))
		manual_track_add()
		href_list["datumrefresh"] = "\ref[src]"
	if(href_list["remove_track"] && check_rights(R_FUN))
		manual_track_remove()
		href_list["datumrefresh"] = "\ref[src]"
