/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	/// The maximum amount of stamina this container has.
	/// Don't touch this directly, it is set using set_maximum().
	var/maximum = 0
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = 10
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Every tick, remove this much stamina
	var/decrement = 0
	///Are we regenerating right now?
	var/is_regenerating = TRUE
	//unga bunga
	var/process_stamina = TRUE

	///cooldowns
	///how long until we can lose stamina again
	COOLDOWN_DECLARE(stamina_grace_period)
	///how long stamina is paused for
	COOLDOWN_DECLARE(paused_stamina)

/datum/stamina_container/New(parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	if(maximum <= 0)
		stack_trace("Attempted to initialize stamina container with an invalid maximum limit of [maximum], defaulting to [STAMINA_MAX]")
		maximum = STAMINA_MAX
	src.parent = parent
	src.maximum = maximum
	src.regen_rate = regen_rate
	src.current = maximum
	START_PROCESSING(SSstamina, src)

/datum/stamina_container/Destroy()
	parent?.stamina = null
	parent = null
	STOP_PROCESSING(SSstamina, src)
	return ..()

/datum/stamina_container/proc/update(seconds_per_tick = 1)
	if(process_stamina == TRUE)
		if(!is_regenerating)
			if(!COOLDOWN_FINISHED(src, paused_stamina))
				return
			is_regenerating = TRUE

		if(seconds_per_tick)
			current = min(current + (regen_rate*seconds_per_tick), maximum)
		if(seconds_per_tick && decrement)
			current = max(current + (-decrement*seconds_per_tick), 0)
		loss = maximum - current
		loss_as_percent = loss ? (loss == maximum ? 0 : loss / maximum * 100) : 0

	if(seconds_per_tick && current == maximum)
		process_stamina = FALSE
	else if(!(current == maximum))
		process_stamina = TRUE

	parent.on_stamina_update()

///Pause stamina regeneration for some period of time. Does not support doing this from multiple sources at once because I do not do that and I will add it later if I want to.
/datum/stamina_container/proc/pause(time)
	is_regenerating = FALSE
	COOLDOWN_START(src, paused_stamina, time)

///Stops stamina regeneration entirely until manually resumed.
/datum/stamina_container/proc/stop()
	is_regenerating = FALSE

///Resume stamina processing
/datum/stamina_container/proc/resume()
	is_regenerating = TRUE

///adjust the grace period a mob has usually used after stam crit to prevent infinite stamina locking
/datum/stamina_container/proc/adjust_grace_period(time)
	COOLDOWN_START(src, stamina_grace_period, time)

///Adjust stamina by an amount.
/datum/stamina_container/proc/adjust(amt as num, forced, base_modify = FALSE)
	if((!amt || !COOLDOWN_FINISHED(src, stamina_grace_period)) && !forced)
		return
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)
	if(base_modify)
		modify = amt
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	update()
	if((amt < 0) && is_regenerating)
		pause(STAMINA_REGEN_TIME)
	return amt

/// Revitalize the stamina to the maximum this container can have.
/datum/stamina_container/proc/revitalize(forced = FALSE)
	return adjust(maximum, forced)

/datum/stamina_container/proc/adjust_to(amount, lowest_stamina_value, forced = FALSE)
	if((!amount || !COOLDOWN_FINISHED(src, stamina_grace_period)) && !forced)
		return

	var/stamina_after_loss = current + amount
	if(stamina_after_loss < lowest_stamina_value)
		amount = current - lowest_stamina_value

	current = round(clamp(current + amount, 0, maximum), DAMAGE_PRECISION)
	update()
	if((amount < 0) && is_regenerating)
		pause(STAMINA_REGEN_TIME)
	return amount

/// Sets the maximum amount of stamina.
/// Always use this instead of directly setting the stamina var, as this has sanity checks, and immediately updates afterwards.
/datum/stamina_container/proc/set_maximum(value = STAMINA_MAX)
	if(!IS_SAFE_NUM(value) || value <= 0)
		maximum = STAMINA_MAX
		update()
		CRASH("Attempted to set maximum stamina to invalid value ([value]), resetting to the default maximum of [STAMINA_MAX]")
	if(value == maximum)
		return
	maximum = value
	update()
	return TRUE
