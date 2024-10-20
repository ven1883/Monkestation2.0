// All the procs that admins can use to view something like a global list in a cleaner manner than just View Variables are contained in this file.

/datum/admins/proc/list_bombers()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return
	var/data = "<b>Bombing List</b><hr>"
	for(var/entry in GLOB.bombers)
		data += text("[entry]<br>")
	usr << browse(data, "window=bombers;size=800x500")

/datum/admins/proc/list_signalers()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return
	var/data = "<b>Showing last [length(GLOB.lastsignalers)] signalers.</b><hr>"
	for(var/entry in GLOB.lastsignalers)
		data += "[entry]<BR>"
	usr << browse(data, "window=lastsignalers;size=800x500")

/datum/admins/proc/list_law_changes()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return
	var/data = "<b>Showing last [length(GLOB.lawchanges)] law changes.</b><hr>"
	for(var/entry in GLOB.lawchanges)
		data += "[entry]<BR>"
	usr << browse(data, "window=lawchanges;size=800x500")

/datum/admins/proc/list_dna()
	var/data = "<b>Showing DNA from blood.</b><hr>"
	data += "<table cellspacing=5 border=1><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
	for(var/entry in GLOB.human_list)
		var/mob/living/carbon/human/subject = entry
		if(subject.ckey)
			data += "<tr><td>[subject]</td><td>[subject.dna.unique_enzymes]</td><td>[subject.get_blood_type()]</td></tr>"
	data += "</table>"
	usr << browse(data, "window=DNA;size=440x410")

/datum/admins/proc/list_fingerprints() //kid named fingerprints
	var/data = "<b>Showing Fingerprints.</b><hr>"
	data += "<table cellspacing=5 border=1><tr><th>Name</th><th>Fingerprints</th></tr>"
	for(var/entry in GLOB.human_list)
		var/mob/living/carbon/human/subject = entry
		if(subject.ckey)
			data += "<tr><td>[subject]</td><td>[md5(subject.dna.unique_identity)]</td></tr>"
	data += "</table>"
	usr << browse(data, "window=fingerprints;size=440x410")

/datum/admins/proc/show_manifest()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return
	var/data = "<b>Showing Crew Manifest.</b><hr>"
	data += "<table cellspacing=5 border=1><tr><th>Name</th><th>Position</th></tr>"
	for(var/datum/record/crew/entry in GLOB.manifest.general)
		data += "<tr><td>[entry.name]</td><td>[entry.rank][entry.rank != entry.trim ? " ([entry.trim])" : ""]</td></tr>"
	data += "</table>"
	usr << browse(data, "window=manifest;size=440x410")

/datum/admins/proc/output_ai_laws()
	var/law_bound_entities = 0
	for(var/mob/living/silicon/subject as anything in GLOB.silicon_mobs)
		law_bound_entities++

		var/message = ""

		if(isAI(subject))
			message += "<b>AI [key_name(subject, usr)]'s laws:</b>"
		else if(iscyborg(subject))
			var/mob/living/silicon/robot/borg = subject
			message += "<b>CYBORG [key_name(subject, usr)] [borg.connected_ai?"(Slaved to: [key_name(borg.connected_ai)])":"(Independent)"]: laws:</b>"
		else if (ispAI(subject))
			message += "<b>pAI [key_name(subject, usr)]'s laws:</b>"
		else
			message += "<b>SOMETHING SILICON [key_name(subject, usr)]'s laws:</b>"

		message += "<br>"

		if (!subject.laws)
			message += "[key_name(subject, usr)]'s laws are null?? Contact a coder."
		else
			message += jointext(subject.laws.get_law_list(include_zeroth = TRUE), "<br>")

		to_chat(usr, message, confidential = TRUE)

	if(!law_bound_entities)
		to_chat(usr, "<b>No law bound entities located</b>", confidential = TRUE)
