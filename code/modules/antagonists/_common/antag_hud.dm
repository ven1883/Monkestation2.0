/// All active /datum/atom_hud/alternate_appearance/basic/has_antagonist instances
GLOBAL_LIST_EMPTY_TYPED(has_antagonist_huds, /datum/atom_hud/alternate_appearance/basic/has_antagonist)

/// An alternate appearance that will only show if you have the antag datum
/datum/atom_hud/alternate_appearance/basic/has_antagonist
	var/antag_datum_type

/datum/atom_hud/alternate_appearance/basic/has_antagonist/New(key, image/I, antag_datum_type, valid_keys) //monkestation edit: adds valid_keys
	src.antag_datum_type = antag_datum_type
	src.valid_keys = valid_keys
	GLOB.has_antagonist_huds += src
	return ..(key, I, NONE)

/datum/atom_hud/alternate_appearance/basic/has_antagonist/Destroy()
	GLOB.has_antagonist_huds -= src
	return ..()

///datum/atom_hud/alternate_appearance/basic/has_antagonist/mobShouldSee(mob/M) //monkestation removal, moved to the modular version of this file
//	return !!M.mind?.has_antag_datum(antag_datum_type) //monkestation removal

/// An alternate appearance that will show all the antagonists this mob has
/datum/atom_hud/alternate_appearance/basic/antagonist_hud
	var/list/antag_hud_images = list()
	var/index = 1

	var/datum/mind/mind

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/New(key, datum/mind/mind)
	src.mind = mind

	antag_hud_images = get_antag_hud_images(mind)

	var/image/first_antagonist = get_antag_image(1) || image(icon('icons/blanks/32x32.dmi', "nothing"), mind.current)

	RegisterSignals(
		mind,
		list(COMSIG_ANTAGONIST_GAINED, COMSIG_ANTAGONIST_REMOVED),
		PROC_REF(update_antag_hud_images)
	)

	check_processing()

	return ..(key, first_antagonist, NONE)

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/Destroy()
	STOP_PROCESSING(SSantag_hud, src)
	mind.antag_hud = null
	mind = null

	return ..()

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/mobShouldSee(mob/mob)
	return Master.current_runlevel >= RUNLEVEL_POSTGAME || (mob.client?.combo_hud_enabled && !isnull(mob.client?.holder))

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/process(seconds_per_tick)
	index += 1
	update_icon()

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/proc/check_processing()
	if (antag_hud_images.len > 1 && !(DF_ISPROCESSING in datum_flags))
		START_PROCESSING(SSantag_hud, src)
	else if (antag_hud_images.len <= 1)
		STOP_PROCESSING(SSantag_hud, src)

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/proc/get_antag_image(index)
	RETURN_TYPE(/image)
	if (antag_hud_images.len)
		return antag_hud_images[(index % antag_hud_images.len) + 1]

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/proc/get_antag_hud_images(datum/mind/mind)
	var/list/final_antag_hud_images = list()

	for (var/datum/antagonist/antagonist as anything in mind?.antag_datums)
		if (isnull(antagonist.antag_hud_name))
			continue
		final_antag_hud_images += antagonist.hud_image_on(mind.current)

	return final_antag_hud_images

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/proc/update_icon()
	if (antag_hud_images.len == 0)
		image.icon = icon('icons/blanks/32x32.dmi', "nothing")
	else
		image.icon = icon(get_antag_image(index).icon, get_antag_image(index).icon_state)

/datum/atom_hud/alternate_appearance/basic/antagonist_hud/proc/update_antag_hud_images(datum/mind/source)
	SIGNAL_HANDLER

	antag_hud_images = get_antag_hud_images(source)
	index = clamp(index, 1, antag_hud_images.len)
	update_icon()
	check_processing()
