/datum/language_holder/darkspawn
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/darkspawn = list(LANGUAGE_ATOM)
		)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/darkspawn = list(LANGUAGE_ATOM)
		)

//point of note: a lot of the darkspawns' abilities cause them to hear stuff
//this stuff is plain English run through rot22; you can translate it back with rot4
//the darkspeak language doesn't fall under this, though
/datum/language/darkspawn
	name = "Darkspeak"
	desc = "A language used by the darkspawn. Even with harsh syllables, it rolls silkily off the tongue."
	speech_verb = "clicks"
	ask_verb = "chirps"
	exclaim_verb = "chitters"
	syllables = list("ko", "ii", "ma", "an", "sah", "lo", "na")
	flags = NO_STUTTER
	key = "a"
	default_priority = 10
	space_chance = 40
	icon = 'yogstation/icons/misc/language.dmi'
	icon_state = "darkspeak"
