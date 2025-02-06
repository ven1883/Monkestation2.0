/datum/config_entry/string/regular_mentorhelp_webhook_url

/datum/config_entry/string/mentorhelp_webhook_pfp

/datum/config_entry/string/mentorhelp_webhook_name

/datum/config_entry/string/mhelp_message
	default = ""

/datum/config_entry/string/patreon_link_website

/datum/config_entry/string/twitch_link_website

/datum/config_entry/string/regular_roundend_webhook_url

/datum/config_entry/string/roundend_webhook_pfp

/datum/config_entry/string/roundend_webhook_name

/datum/config_entry/string/roundend_webhook_description
	default = @"[Join Server!](http://play.monkestation.com:7420)"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/roundend_webhook_content
	default = "<@&999008528595419278>"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/bot_dump_url

//API key for Github Issues.
/datum/config_entry/string/issue_key
	protection = CONFIG_ENTRY_HIDDEN

//Endpoint for Github Issues, the `owner/repo` part.
/datum/config_entry/string/issue_slug
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/looc_enabled

/datum/config_entry/flag/log_storyteller

/datum/config_entry/flag/disable_sunlight_visuals

/datum/config_entry/flag/disable_particle_weather

/datum/config_entry/flag/disable_storyteller

/datum/config_entry/number/transfer_vote_time
	default = 90 MINUTES
	min_val = 0

/datum/config_entry/number/transfer_vote_time/ValidateAndSet(str_val)
	. = ..()
	if(.)
		config_entry_value *= 600 // documented as minutes

/datum/config_entry/number/subsequent_transfer_vote_time
	default = 30 MINUTES
	min_val = 0

/datum/config_entry/number/subsequent_transfer_vote_time/ValidateAndSet(str_val)
	. = ..()
	if(.)
		config_entry_value *= 600 // documented as minutes

/datum/config_entry/flag/plexora_enabled

/datum/config_entry/string/plexora_url
	default = "http://127.0.0.1:1330"

/datum/config_entry/string/plexora_url/ValidateAndSet(str_val)
	if(!findtext(str_val, GLOB.is_http_protocol))
		return FALSE
	return ..()
