/datum/controller/subsystem/ticker/proc/save_tokens()
	rustg_file_write(json_encode(GLOB.saved_token_values), "[GLOB.log_directory]/tokens.json")

/datum/controller/subsystem/ticker/proc/calculate_rewards()
	. = list()
	for(var/client/client as anything in GLOB.clients)
		calculate_rewards_for_client(client, .)
	calculate_station_goal_bonus(.)

/datum/controller/subsystem/ticker/proc/calculate_station_goal_bonus(list/rewards)
	var/total_crew = length(GLOB.joined_player_list)
	if(total_crew < 10) // prevent wrecking the economy on like MRP2
		return
	var/completed = FALSE
	for(var/datum/station_goal/station_goal as anything in GLOB.station_goals)
		if(station_goal.check_completion())
			completed = TRUE
			break
	if(!completed)
		return
	var/amount = CEILING(50000 / total_crew, 50) // nice even number
	for(var/ckey in GLOB.joined_player_list)
		LAZYINITLIST(rewards[ckey])
		rewards[ckey] += list(list(amount, "Station Goal Completion Bonus"))

	message_admins("As a result of the station goal being completed, [total_crew] players were rewarded [amount] monkecoins each.")
	log_game("As a result of the station goal being completed, [total_crew] players were rewarded [amount] monkecoins each.")

/datum/controller/subsystem/ticker/proc/distribute_rewards(list/coin_rewards)
	var/hour = round((world.time - SSticker.round_start_time) / 36000)
	var/minute = round(((world.time - SSticker.round_start_time) - (hour * 36000)) / 600)
	var/added_xp = round(25 + (minute ** 0.85))
	for(var/ckey in coin_rewards)
		distribute_rewards_to_client(ckey, added_xp, coin_rewards[ckey])

/datum/controller/subsystem/ticker/proc/distribute_rewards_to_client(ckey, added_xp, list/rewards)
	var/client/client = GLOB.directory[ckey]
	if(!client)
		return
	for(var/reward in rewards)
		var/amount = reward[1]
		var/reason = reward[2]
		client?.prefs?.adjust_metacoins(ckey, amount, reason)
	if(client?.mob?.mind?.assigned_role)
		add_jobxp(client, added_xp, client?.mob?.mind?.assigned_role?.title)

/datum/controller/subsystem/ticker/proc/calculate_rewards_for_client(client/client, list/queue)
	if(!istype(client) || QDELING(client))
		return
	var/ckey = client?.ckey
	if(!ckey)
		return
	var/datum/persistent_client/details = client.persistent_client
	var/round_end_bonus = 75

	// Patreon Flat Roundend Bonus
	if((details?.patreon?.has_access(ACCESS_ASSISTANT_RANK)))
		round_end_bonus += DONATOR_ROUNDEND_BONUS

	// Twitch Flat Roundend Bonus
	if((details?.twitch?.has_access(ACCESS_TWITCH_SUB_TIER_1)))
		round_end_bonus += DONATOR_ROUNDEND_BONUS

	LAZYINITLIST(queue[ckey])

	queue[ckey] += list(list(round_end_bonus, "Played a Round"))

	if(world.port == MRP2_PORT)
		queue[ckey] += list(list(500, "MRP2 Seeding Subsidies"))
	var/special_bonus = details?.roundend_monkecoin_bonus
	if(special_bonus)
		queue[ckey] += list(list(special_bonus, "Special Bonus"))
	if(client?.is_mentor())
		if(details?.mob?.mind?.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			queue[ckey] += list(list(800, "Mentor Head of Staff Bonus"))
		else
			queue[ckey] += list(list(500, "Mentor Bonus"))

	var/list/applied_challenges = details?.applied_challenges
	if(LAZYLEN(applied_challenges))
		var/mob/living/client_mob = details?.mob
		if(!istype(client_mob) || QDELING(client_mob) || client_mob?.stat == DEAD)
			return
		var/total_payout = 0
		for(var/datum/challenge/listed_challenge as anything in applied_challenges)
			if(listed_challenge.failed)
				continue
			total_payout += listed_challenge.challenge_payout
		if(total_payout)
			queue[ckey] += list(list(total_payout, "Challenge Rewards"))

/datum/controller/subsystem/ticker/proc/refund_cassette()
	if(!length(GLOB.cassette_reviews))
		return

	for(var/id in GLOB.cassette_reviews)
		var/datum/cassette_review/review = GLOB.cassette_reviews[id]
		if(!review || review.action_taken) // Skip if review doesn't exist or already handled (denied / approved)
			continue

		var/ownerckey = review.submitted_ckey // ckey of who made the cassette.
		if(!ownerckey)
			continue

		var/client/client = GLOB.directory[ownerckey] // Use directory for direct lookup (Client might be a differnet mob than when review was made.)
		if(client && !QDELETED(client?.prefs))
			var/prev_bal = client?.prefs?.metacoins
			var/adjusted = client?.prefs?.adjust_metacoins(
				client?.ckey,
				amount = 5000,
				reason = "No action taken on cassette:\[[review.submitted_tape.name]\] before round end",
				announces = TRUE,
				donator_multiplier = FALSE,
			)
			if(!adjusted)
				message_admins("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins]. Issue logged.")
				log_admin("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins].")
			qdel(review)
