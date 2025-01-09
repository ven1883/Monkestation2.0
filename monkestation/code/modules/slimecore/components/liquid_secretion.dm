/datum/component/liquid_secretion
	///the reagent we secrete
	var/reagent_id
	///the interval of secretion
	var/secretion_interval
	///amount of reagents to spawn
	var/amount
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/pre_secrete_callback
	COOLDOWN_DECLARE(next_secrete)

/datum/component/liquid_secretion/Initialize(reagent_id = /datum/reagent/water, amount = 10, secretion_interval = 1 SECONDS, pre_secrete_callback)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.reagent_id = reagent_id
	src.secretion_interval = secretion_interval
	src.amount = amount
	src.pre_secrete_callback = CALLBACK(parent, pre_secrete_callback)

	START_PROCESSING(SSobj, src)

/datum/component/liquid_secretion/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	pre_secrete_callback = null
	return ..()

/datum/component/liquid_secretion/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SECRETION_UPDATE, PROC_REF(update_information)) //The only signal allowing item -> turf interaction

/datum/component/liquid_secretion/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SECRETION_UPDATE)

/datum/component/liquid_secretion/proc/update_information(datum/source, reagent_id, amount, secretion_interval)
	if(reagent_id)
		src.reagent_id = reagent_id
	if(amount)
		src.amount = amount
	if(secretion_interval)
		src.secretion_interval = secretion_interval

/datum/component/liquid_secretion/process(seconds_per_tick)
	var/atom/movable/parent = src.parent
	if(QDELETED(parent))
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, next_secrete))
		return
	var/turf/open/parent_turf = parent.loc
	if(!isopenturf(parent_turf))
		return
	COOLDOWN_START(src, next_secrete, secretion_interval)
	if(pre_secrete_callback && !pre_secrete_callback.Invoke(parent))
		return
	var/list/reagent_list = list()
	reagent_list[reagent_id] = amount
	parent_turf?.add_liquid_list(reagent_list, FALSE, T20C)
