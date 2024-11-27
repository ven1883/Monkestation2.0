/datum/station_trait/announcement_duke
	name = "Announcement Duke"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	report_message = "The Duke himself is your announcer today."
	blacklist = list(/datum/station_trait/announcement_medbot,
	/datum/station_trait/birthday,
	/datum/station_trait/announcement_intern,
	/datum/station_trait/announcement_dagoth
	)

/datum/station_trait/announcement_duke/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/duke

/datum/station_trait/announcement_dagoth
	name = "Announcement Dagoth Ur"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	report_message = "I am bestowing upon you my presence, Nerevar."
	blacklist = list(/datum/station_trait/announcement_medbot,
	/datum/station_trait/birthday,
	/datum/station_trait/announcement_intern,
	/datum/station_trait/announcement_duke
	)

/datum/station_trait/announcement_dagoth/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/dagoth

/* disabled (its not my birthday, this has a weight of 0 and yet somehow still rolls)
/datum/station_trait/announcement_veth_birthday
	name = "Announcement Veth's Birthday"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 0
	show_in_report = TRUE
	report_message = "It's my birthday hehe"
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/birthday, /datum/station_trait/announcement_duke, /datum/station_trait/announcement_dagoth, /datum/station_trait/announcement_intern)

/datum/station_trait/announcement_veth_birthday/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/vethday
*/

