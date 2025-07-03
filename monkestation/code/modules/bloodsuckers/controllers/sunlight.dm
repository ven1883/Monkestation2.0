///How long Sol will last until it's night again.
#define TIME_BLOODSUCKER_DAY 60
///Base time nighttime should be in for, until Sol rises.
#define TIME_BLOODSUCKER_NIGHT 600
///Time left to send an alert to Bloodsuckers about an incoming Sol.
#define TIME_BLOODSUCKER_DAY_WARN 90
///Time left to send an urgent alert to Bloodsuckers about an incoming Sol.
#define TIME_BLOODSUCKER_DAY_FINAL_WARN 30
///Time left to alert that Sol is rising.
#define TIME_BLOODSUCKER_BURN_INTERVAL 5

///How much time Sol can be 'off' by, keeping the time inconsistent.
#define TIME_BLOODSUCKER_SOL_DELAY 90

SUBSYSTEM_DEF(sol)
	name = "Sol"
	can_fire = FALSE
	wait = 20 // ticks, not seconds (so this runs every second, actually)
	flags = SS_NO_INIT | SS_BACKGROUND | SS_TICKER | SS_KEEP_TIMING

	///If the Sun is currently out our not.
	var/sunlight_active = FALSE
	///The time between the next cycle, randomized every night.
	var/time_til_cycle = TIME_BLOODSUCKER_NIGHT
	///If Bloodsucker levels for the night has been given out yet.
	var/issued_XP = FALSE

/datum/controller/subsystem/sol/Recover()
	can_fire = SSsol.can_fire
	sunlight_active = SSsol.sunlight_active
	time_til_cycle = SSsol.time_til_cycle
	issued_XP = SSsol.issued_XP

/datum/controller/subsystem/sol/fire(resumed = FALSE)
	time_til_cycle--
	if(sunlight_active)
		if(time_til_cycle > 0)
			SEND_SIGNAL(src, COMSIG_SOL_RISE_TICK)
			if(!issued_XP && time_til_cycle <= 15)
				issued_XP = TRUE
				SEND_SIGNAL(src, COMSIG_SOL_RANKUP_BLOODSUCKERS)
		if(time_til_cycle <= 1)
			sunlight_active = FALSE
			issued_XP = FALSE
			//randomize the next sol timer
			time_til_cycle = round(rand((TIME_BLOODSUCKER_NIGHT-TIME_BLOODSUCKER_SOL_DELAY), (TIME_BLOODSUCKER_NIGHT+TIME_BLOODSUCKER_SOL_DELAY)), 1)
			message_admins("BLOODSUCKER NOTICE: Daylight Ended. Resetting to Night (Lasts for [DisplayTimeText(time_til_cycle * 10)])")
			SEND_SIGNAL(src, COMSIG_SOL_END)
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ENDED,
				vampire_warning_message = span_announce("The solar flare has ended, and the daylight danger has passed... for now."),
				vassal_warning_message = span_announce("The solar flare has ended, and the daylight danger has passed... for now."),
			)
		return

	switch(time_til_cycle)
		if(TIME_BLOODSUCKER_DAY_WARN)
			SEND_SIGNAL(src, COMSIG_SOL_NEAR_START)
			warn_daylight(
				danger_level = DANGER_LEVEL_FIRST_WARNING,
				vampire_warning_message = span_danger("Solar Flares will bombard the station with dangerous UV radiation in [DisplayTimeText(TIME_BLOODSUCKER_DAY_WARN * 10)]. <b>Prepare to seek cover in a coffin or closet.</b>"),
			)
		if(TIME_BLOODSUCKER_DAY_FINAL_WARN)
			message_admins("BLOODSUCKER NOTICE: Daylight beginning in [DisplayTimeText(TIME_BLOODSUCKER_DAY_FINAL_WARN * 10)].)")
			warn_daylight(
				danger_level = DANGER_LEVEL_SECOND_WARNING,
				vampire_warning_message = span_userdanger("Solar Flares are about to bombard the station! You have [DisplayTimeText(TIME_BLOODSUCKER_DAY_FINAL_WARN * 10)] to find cover!"),
				vassal_warning_message = span_danger("In [DisplayTimeText(TIME_BLOODSUCKER_DAY_FINAL_WARN * 10)], your master will be at risk of a Solar Flare. Make sure they find cover!"),
			)
		if(TIME_BLOODSUCKER_BURN_INTERVAL)
			warn_daylight(
				danger_level = DANGER_LEVEL_THIRD_WARNING,
				vampire_warning_message = span_userdanger("Seek cover, for Sol rises!"),
			)
		if(NONE)
			sunlight_active = TRUE
			//set the timer to countdown daytime now.
			time_til_cycle = TIME_BLOODSUCKER_DAY
			message_admins("BLOODSUCKER NOTICE: Daylight Beginning (Lasts for [DisplayTimeText(TIME_BLOODSUCKER_DAY * 10)])")
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ROSE,
				vampire_warning_message = span_userdanger("Solar flares bombard the station with deadly UV light! Stay in cover for the next [DisplayTimeText(TIME_BLOODSUCKER_DAY * 10)] or risk Final Death!"),
				vassal_warning_message = span_userdanger("Solar flares bombard the station with UV light!"),
			)

/datum/controller/subsystem/sol/proc/warn_daylight(danger_level, vampire_warning_message, vassal_warning_message)
	SEND_SIGNAL(src, COMSIG_SOL_WARNING_GIVEN, danger_level, vampire_warning_message, vassal_warning_message)

#undef TIME_BLOODSUCKER_SOL_DELAY

#undef TIME_BLOODSUCKER_DAY
#undef TIME_BLOODSUCKER_NIGHT
#undef TIME_BLOODSUCKER_DAY_WARN
#undef TIME_BLOODSUCKER_DAY_FINAL_WARN
#undef TIME_BLOODSUCKER_BURN_INTERVAL
