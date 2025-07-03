/proc/format_mhelp_embed(message, id, ckey)
	var/datum/discord_embed/embed = new()
	embed.title = "Mentor Help"
	embed.description = @"[Join Server!](http://play.monkestation.com:7420)"
	embed.author = key_name(ckey)
	var/round_state
	var/admin_text
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			round_state = "Round has not started"
		if(GAME_STATE_PLAYING)
			round_state = "Round is ongoing."
			if(SSshuttle.emergency.getModeStr())
				round_state += "\n[SSshuttle.emergency.getModeStr()]: [SSshuttle.emergency.getTimerStr()]"
				if(SSticker.emergency_reason)
					round_state += ", Shuttle call reason: [SSticker.emergency_reason]"
		if(GAME_STATE_FINISHED)
			round_state = "Round has ended"
	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	embed.fields = list(
		"MENTOR ID" = id,
		"CKEY" = ckey,
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = ROUND_TIME(),
		"MESSAGE" = message,
		"ADMINS" = admin_text,
	)
	return embed

/client/verb/mentorhelp(msg as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	if(usr?.client?.prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	/// Cleans the input message
	if(!msg)
		return
	/// This shouldn't happen, but just in case.
	if(!mob)
		return

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	var/mentor_msg = "<font color='purple'><span class='mentornotice'><b>MENTORHELP:</b> <b>[key_name_mentor(src, TRUE, FALSE)]</b> : </span><span class='message linkify'>[msg]</span></font>"
	var/mentor_msg_observing = "<span class='mentornotice'><b><span class='mentorhelp'>MENTORHELP:</b> <b>[key_name_mentor(src, TRUE, FALSE)]</b> (<a href='byond://?_src_=mentor;[MentorHrefToken(TRUE)];mentor_friend=[REF(src.mob)]'>IF</a>) : [msg]</span></span>"
	log_mentor("MENTORHELP: [key_name_mentor(src, null, FALSE, FALSE)]: [msg]")

	/// Send the Mhelp to all Mentors/Admins
	for(var/client/honked_clients in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_clients?.mentor_datum) || honked_clients?.mentor_datum?.not_active)
			continue
		SEND_SOUND(honked_clients, sound('sound/items/bikehorn.ogg'))
		if(!isobserver(honked_clients.mob))
			to_chat(honked_clients,
					type = MESSAGE_TYPE_MODCHAT,
					html = mentor_msg,
					confidential = TRUE)
		else
			to_chat(honked_clients,
					type = MESSAGE_TYPE_MODCHAT,
					html = mentor_msg_observing,
					confidential = TRUE)

	/// Also show it to person Mhelping
	to_chat(usr,
		type = MESSAGE_TYPE_MODCHAT,
		html = "<font color='purple'><span class='mentornotice'>PM to-<b>Mentors</b>:</span> <span class='message linkify'>[msg]</span></font>",
		confidential = TRUE)

	GLOB.mentor_requests.mentorhelp(usr.client, msg)


	var/datum/request/request = GLOB.mentor_requests.requests[ckey][length(GLOB.mentor_requests.requests[ckey])]
	if(request)
		SSplexora.mticket_new(request)
	return

/proc/key_name_mentor(whom, include_link = null, include_name = TRUE, include_follow = TRUE, char_name_only = TRUE)
	var/mob/user
	var/client/chosen_client
	var/key
	var/ckey
	if(!whom)
		return "*null*"

	if(istype(whom, /client))
		chosen_client = whom
		user = chosen_client.mob
		key = chosen_client.key
		ckey = chosen_client.ckey
	else if(ismob(whom))
		user = whom
		chosen_client = user.client
		key = user.key
		ckey = user.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		chosen_client = GLOB.directory[ckey]
		if(chosen_client)
			user = chosen_client.mob
	else if(findtext(whom, "Discord"))
		return "<a href='byond://?_src_=mentor;mentor_msg=[whom];[MentorHrefToken(TRUE)]'>"
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = null

	if(key)
		if(include_link != null)
			. += "<a href='byond://?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"

		if(chosen_client && chosen_client.holder && chosen_client.holder.fakekey)
			. += "Administrator"
		else
			. += key
		if(!chosen_client)
			. += "\[DC\]"

		if(include_link != null)
			. += "</a>"
	else
		. += "*no key*"

	if(include_follow)
		. += " (<a href='byond://?_src_=mentor;mentor_follow=[REF(user)];[MentorHrefToken(TRUE)]'>F</a>)"

	return .
