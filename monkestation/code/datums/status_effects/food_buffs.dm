/datum/status_effect/food
	id = STATUS_EFFECT_ID_ABSTRACT
	duration = 10 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	show_duration = TRUE

/datum/status_effect/food/proc/apply_quality(quality)
	return

/datum/status_effect/food/on_apply()
	if(HAS_TRAIT(owner, TRAIT_GOURMAND))
		duration *= 1.5
	return ..()

/datum/status_effect/food/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		user.applied_food_buffs --

/datum/status_effect/food/stamina_increase
	id = "t1_stamina"
	alert_type = /atom/movable/screen/alert/status_effect/food/stamina_increase_t1
	var/stam_increase = 10

/datum/status_effect/food/stamina_increase/apply_quality(quality)
	stam_increase = stam_increase * (1 + (quality / 50))

/atom/movable/screen/alert/status_effect/food/stamina_increase_t1
	name = "Tiny Stamina Increase"
	desc = "Increases your stamina by a tiny amount"
	icon_state = "stam_t1"

/datum/status_effect/food/stamina_increase/t2
	id = "t2_stamina"
	alert_type = /atom/movable/screen/alert/status_effect/food/stamina_increase_t2
	stam_increase = 20

/atom/movable/screen/alert/status_effect/food/stamina_increase_t2
	name = "Medium Stamina Increase"
	desc = "Increases your stamina by a moderate amount"
	icon_state = "stam_t2"

/datum/status_effect/food/stamina_increase/t3
	id = "t3_stamina"
	alert_type = /atom/movable/screen/alert/status_effect/food/stamina_increase_t3
	stam_increase = 30

/atom/movable/screen/alert/status_effect/food/stamina_increase_t3
	name = "Large Stamina Increase"
	desc = "Increases your stamina greatly"
	icon_state = "stam_t3"

/datum/status_effect/food/stamina_increase/on_apply()
	if(ishuman(owner))
		owner.stamina.maximum += stam_increase
	return ..()

/datum/status_effect/food/stamina_increase/on_remove()
	.=..()
	if(ishuman(owner))
		owner.stamina.maximum -= stam_increase


/datum/status_effect/food/resistance
	id = "resistance_food"
	alert_type = /atom/movable/screen/alert/status_effect/food/resistance

/atom/movable/screen/alert/status_effect/food/resistance
	name = "Damage resistance"
	desc = "Slightly decreases physical damage taken"
	icon_state = "resistance"

/datum/status_effect/food/resistance/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		for(var/obj/item/bodypart/limbs in user.bodyparts)
			limbs.brute_modifier -= 0.1
	return ..()

/datum/status_effect/food/resistance/on_remove()
	.=..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		for(var/obj/item/bodypart/limbs in user.bodyparts)
			limbs.brute_modifier += 0.1


#define DURATION_LOSS 250
#define RANGE 4
/datum/status_effect/food/fire_burps
	id = "fire_food"
	alert_type = /atom/movable/screen/alert/status_effect/food/fire_burps
	var/range = RANGE
	var/duration_loss = DURATION_LOSS

/datum/status_effect/food/fire_burps/apply_quality(quality)
	range = range + round((quality / 40))

/atom/movable/screen/alert/status_effect/food/fire_burps
	name = "Firey Burps"
	desc = "Lets you burp out a line of fire"
	icon_state = "fire_burp"

/datum/status_effect/food/fire_burps/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		ADD_TRAIT(user, TRAIT_FOOD_FIRE_BURPS, "food_buffs")
	return ..()

/datum/status_effect/food/fire_burps/on_remove()
	.=..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		REMOVE_TRAIT(user, TRAIT_FOOD_FIRE_BURPS, "food_buffs")


/datum/status_effect/food/fire_burps/proc/Burp()
	var/turf/turfs = get_step(owner,owner.dir)
	var/range_check = 1
	while((get_dist(owner, turfs) < range) && (range_check < 20))
		turfs = get_step(turfs, owner.dir)
		range_check ++
	var/list/affected_turfs = get_line(owner, turfs)

	for(var/turf/checking in affected_turfs)
		if(checking.density || istype(checking, /turf/open/space))
			break
		if(checking == get_turf(owner))
			continue
		if(get_dist(owner, checking) > range)
			continue
		create_fire(checking)

	src.duration -= min(duration_loss, src.duration)
	if(src.duration <= 0)
		if(src.owner)
			src.owner.remove_status_effect(STATUS_EFFECT_FOOD_FIREBURPS)

/datum/status_effect/food/fire_burps/proc/create_fire(turf/exposed)
	if(isplatingturf(exposed))
		var/turf/open/floor/plating/exposed_floor = exposed
		if(prob(10 + exposed_floor.burnt + 5*exposed_floor.broken)) //broken or burnt plating is more susceptible to being destroyed
			exposed_floor.ex_act(EXPLODE_DEVASTATE)
	if(isfloorturf(exposed))
		var/turf/open/floor/exposed_floor = exposed
		if(prob(10))
			exposed_floor.make_plating()
		else if(prob(10))
			exposed_floor.burn_tile()
		if(isfloorturf(exposed_floor))
			for(var/turf/open/turf in RANGE_TURFS(1,exposed_floor))
				if(!locate(/obj/effect/hotspot) in turf)
					new /obj/effect/hotspot(exposed_floor)
	if(iswallturf(exposed))
		var/turf/closed/wall/exposed_wall = exposed
		if(prob(10))
			exposed_wall.ex_act(EXPLODE_DEVASTATE)

#undef DURATION_LOSS
#undef RANGE
/datum/status_effect/food/sweaty
	id = "food_sweaty"
	alert_type = /atom/movable/screen/alert/status_effect/food/sweaty
	var/list/sweat = list(/datum/reagent/water = 4, /datum/reagent/sodium = 1.25)
	var/metabolism_increase = 0.5

/atom/movable/screen/alert/status_effect/food/sweaty
	name = "Sweaty"
	desc = "You're feeling rather sweaty"
	icon_state = "sweaty"

/datum/status_effect/food/sweaty/wacky
	id = "food_sweaty_wacky"
	alert_type = /atom/movable/screen/alert/status_effect/food/sweaty_wacky
	sweat = list(/datum/reagent/lube = 5)

/atom/movable/screen/alert/status_effect/food/sweaty_wacky
	name = "Wacky Sweat"
	desc = "You're feeling rather sweaty, and incredibly wacky?"
	icon_state = "sweaty"

/datum/status_effect/food/sweaty/on_apply()
	if(ishuman(owner))
		owner.metabolism_efficiency += metabolism_increase
	return ..()

/datum/status_effect/food/sweaty/on_remove()
	.=..()
	owner.metabolism_efficiency -= metabolism_increase


/datum/status_effect/food/sweaty/tick()
	. = ..()
	if(prob(5))
		var/turf/puddle_location = get_turf(owner)
		puddle_location.add_liquid_list(sweat, FALSE, 300)

/datum/status_effect/food/health_increase
	id = "t1_health"
	alert_type = /atom/movable/screen/alert/status_effect/food/health_increase_t1
	var/health_increase = 10

/datum/status_effect/food/health_increase/apply_quality(quality)
	health_increase = health_increase * (1 + (quality / 50))

/atom/movable/screen/alert/status_effect/food/health_increase_t1
	name = "Small Health Increase"
	desc = "You feel slightly heartier"
	icon_state = "in_love"

/datum/status_effect/food/health_increase/t2
	id = "t1_health"
	alert_type = /atom/movable/screen/alert/status_effect/food/health_increase_t2
	health_increase = 25

/atom/movable/screen/alert/status_effect/food/health_increase_t2
	name = "Small Health Increase"
	desc = "You feel heartier"
	icon_state = "in_love"

/datum/status_effect/food/health_increase/t3
	id = "t1_health"
	alert_type = /atom/movable/screen/alert/status_effect/food/health_increase_t3
	health_increase = 50

/atom/movable/screen/alert/status_effect/food/health_increase_t3
	name = "Large Health Increase"
	desc = "You feel incredibly hearty"
	icon_state = "in_love"

/datum/status_effect/food/health_increase/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		user.maxHealth += health_increase
	return ..()

/datum/status_effect/food/health_increase/on_remove()
	.=..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		user.maxHealth -= health_increase


/datum/status_effect/food/belly_slide
	id = "food_slide"
	alert_type = /atom/movable/screen/alert/status_effect/food/belly_slide
	var/sliding = FALSE

/atom/movable/screen/alert/status_effect/food/belly_slide
	name = "Slippery Belly"
	desc = "You feel like you could slide really fast"
	icon_state = "paralysis"

/datum/status_effect/food/belly_slide/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		ADD_TRAIT(user, TRAIT_FOOD_SLIDE, "food_buffs")
	return ..()

/datum/status_effect/food/belly_slide/on_remove()
	.=..()
	if(HAS_TRAIT(owner, TRAIT_FOOD_SLIDE))
		REMOVE_TRAIT(owner, TRAIT_FOOD_SLIDE, "food_buffs")
		if(owner.has_movespeed_modifier(/datum/movespeed_modifier/belly_slide))
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/belly_slide)


/datum/status_effect/food/stam_regen
	id = "t1_stam_regen"
	alert_type = /atom/movable/screen/alert/status_effect/food/stam_regen_t1
	var/regen_increase = 0.5

/datum/status_effect/food/stam_regen/apply_quality(quality)
	regen_increase = regen_increase * (1 + (quality / 20))

/atom/movable/screen/alert/status_effect/food/stam_regen_t1
	name = "Small Stamina Regeneration Increase"
	desc = "You feel slightly more energetic"
	icon_state = "stam_t1"

/datum/status_effect/food/stam_regen/t2
	id = "t2_stam_regen"
	alert_type = /atom/movable/screen/alert/status_effect/food/stam_regen_t2
	regen_increase = 1.5

/atom/movable/screen/alert/status_effect/food/stam_regen_t2
	name = "Moderate Stamina Regeneration Increase"
	desc = "You feel more energetic"
	icon_state = "stam_t2"

/datum/status_effect/food/stam_regen/t3
	id = "t2_stam_regen"
	alert_type = /atom/movable/screen/alert/status_effect/food/stam_regen_t3
	regen_increase = 3

/atom/movable/screen/alert/status_effect/food/stam_regen_t3
	name = "Large Stamina Regeneration Increase"
	desc = "You feel full of energy"
	icon_state = "stam_t3"

/datum/status_effect/food/stam_regen/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		user.stamina.regen_rate += regen_increase


/datum/status_effect/food/stam_regen/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		user.stamina.regen_rate += regen_increase




/////JOB BUFFS

/datum/status_effect/food/botanist
	id = "job_botanist_food"
	alert_type = /atom/movable/screen/alert/status_effect/food/botanist

/atom/movable/screen/alert/status_effect/food/botanist
	name = "Green Thumb"
	desc = "Plants just seem to flourish in your hands."
	icon_state = "job_effect_blank"

/datum/status_effect/food/botanist/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		ADD_TRAIT(user, TRAIT_FOOD_JOB_BOTANIST, "food_buffs")
	return ..()

/datum/status_effect/food/botanist/on_remove()
	.=..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		REMOVE_TRAIT(user, TRAIT_FOOD_JOB_BOTANIST, "food_buffs")


/datum/status_effect/food/miner
	id = "job_miner_food"
	alert_type = /atom/movable/screen/alert/status_effect/food/miner

/atom/movable/screen/alert/status_effect/food/miner
	name = "Lucky Break"
	desc = "With your luck ores just seem to fall out of rocks."
	icon_state = "job_effect_blank"

/datum/status_effect/food/miner/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		ADD_TRAIT(user, TRAIT_FOOD_JOB_MINER, "food_buffs")
	return ..()

/datum/status_effect/food/miner/on_remove()
	.=..()
	if(ishuman(owner))
		var/mob/living/carbon/user = owner
		REMOVE_TRAIT(user, TRAIT_FOOD_JOB_MINER, "food_buffs")
