GLOBAL_LIST_EMPTY(wonderland_marks)

/area/ruin/space/has_grav/wonderland
	name = "Wonderland"
	icon_state = "green"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA | NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE
	static_lighting = FALSE
	base_lighting_alpha = 255

/datum/map_template/wonderland
	name = "Wonderland"
	mappath = "_maps/~monkestation/hunter_events/wonderland.dmm"

/obj/effect/mob_spawn/corpse/rabbit
	mob_type = /mob/living/basic/rabbit
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white_dead"


/obj/effect/landmark/wonderland_mark
	name = "Wonderland landmark"
	icon_state = "x"

/obj/effect/landmark/wonderchess_mark
	name = "Wonderchess landmark"
	icon_state = "x"

/obj/effect/landmark/wonderland_mark/Initialize(mapload)
	. = ..()
	GLOB.wonderland_marks[name] = src


/obj/effect/landmark/wonderchess_mark/Initialize(mapload)
	. = ..()
	GLOB.wonderland_marks[name] = src

/obj/effect/landmark/wonderland_mark/Destroy()
	GLOB.wonderland_marks[name] = null
	return ..()

/obj/effect/landmark/wonderchess_mark/Destroy()
	GLOB.wonderland_marks[name] = null
	return ..()

/obj/structure/chess/redqueen
	name = "\improper Red Queen"
	desc = "What is this doing here?"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "red_queen"
