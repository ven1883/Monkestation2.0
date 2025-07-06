/**
* Respond to our atom being checked by a virus extrapolator
*
* Default behaviour is to send COMSIG_ATOM_EXTRAPOLATOR_ACT and return FALSE
*/
/atom/proc/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXTRAPOLATOR_ACT, user, E, scan))
		return TRUE
	return FALSE

/obj/item/extrapolator
	name = "virus extrapolator"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "extrapolator_scan"
	desc = "A scanning device, used to extract genetic material of potential pathogens."
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	var/using = FALSE
	var/scan = TRUE
	var/cooldown

	var/datum/weakref/user_data

	var/atom/last_attacked_target


/obj/item/extrapolator/Destroy()
	user_data = null
	return ..()

/obj/item/extrapolator/attack(atom/AM, mob/living/user)
	return

/obj/item/extrapolator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag && !scan)
		return
	if(isliving(target) && target != usr)
		user_data = WEAKREF(target)
	if(!scan)
		try_disease_modification(user, target)
	else
		switch(target.extrapolator_act(user, src, scan))
			if(FALSE)
				if(scan)
					to_chat(user, "<span class='notice'>[src] fails to return any data</span>")
			else
				to_chat(user, span_notice("You store \the [target]'s blood sample in [src]."))

/obj/item/extrapolator/attack_self(mob/user)
	. = ..()
	if(scan)
		var/atom/resolved_target = user_data?.resolve()
		if(!resolved_target)
			return
		resolved_target?.extrapolator_act(user, src, scan)

/obj/item/extrapolator/attack_self_secondary(mob/user, modifiers)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	if(scan)
		icon_state = "extrapolator_sample"
		scan = FALSE
		to_chat(user, span_notice("You remove the probe from \the [src] and set it to inject genes into diseases or symptoms."))
	else
		icon_state = "extrapolator_scan"
		scan = TRUE
		to_chat(user, span_notice("You put the probe back in \the [src] and set it to scan for diseases."))

/obj/item/extrapolator/proc/try_disease_modification(mob/user, atom/target)
	if(!isliving(target) && !istype(target, /obj/item/weapon/virusdish))
		return

	last_attacked_target = target
	if(istype(last_attacked_target, /obj/item/weapon/virusdish))
		var/obj/item/weapon/virusdish/dish = last_attacked_target
		if(!dish.contained_virus)
			return
	ui_interact(user, should_open = TRUE)
	last_attacked_target = null


/obj/item/extrapolator/proc/try_symptom_change(mob/user, datum/weakref/choice_ref, datum/symptom_varient/new_varient, datum/weakref/symptom_ref)

	var/datum/symptom/symptom = symptom_ref.resolve()
	if(!symptom)
		return
	var/datum/disease/choice = choice_ref.resolve()

	if(symptom.attached_varient)
		say("ERROR: Symptom is already a varient strain!")
		return

	new_varient = new new_varient(symptom, choice)

	symptom.attached_varient = new_varient
	symptom.update_name()

/obj/item/extrapolator/proc/generate_varient()
	var/list/weighted_list = list()
	for(var/datum/symptom_varient/varient as anything in subtypesof(/datum/symptom_varient))
		weighted_list[varient] = initial(varient.weight)

/obj/item/extrapolator/ui_interact(mob/user, datum/tgui/ui, should_open = FALSE)
	. = ..()
	if(!should_open)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Extrapolator")
		ui.open()

/obj/item/extrapolator/ui_data(mob/user)
	var/list/data = list()

	var/list/named_list = list()

	var/list/diseases = list()
	if(istype(last_attacked_target, /obj/item/weapon/virusdish))
		var/obj/item/weapon/virusdish/dish = last_attacked_target
		if(!dish.contained_virus)
			return
		var/list/symptom_data = list()
		for(var/datum/symptom/symptom as anything in dish.contained_virus.symptoms)
			symptom_data |= list(list("name" = symptom.name, "ref" = ref(WEAKREF(symptom))))
		diseases |= list(list("name" = dish.contained_virus.name(), "ref" = ref(WEAKREF(dish.contained_virus)), "symptoms" = symptom_data))
	else
		var/mob/living/target = last_attacked_target
		for(var/datum/disease/disease as anything in target.diseases)
			var/list/symptom_data = list()
			for(var/datum/symptom/symptom as anything in disease.symptoms)
				symptom_data |= list(list("name" = symptom.name, "ref" = ref(WEAKREF(symptom))))
			diseases |= list(list("name" = disease.name(), "ref" = ref(WEAKREF(disease)), "symptoms" = symptom_data))
	data["varients"] = named_list
	data["diseases"] = diseases

	return data


/obj/item/extrapolator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("add_varient")
			var/datum/symptom_varient/new_varient

			var/datum/weakref/diease_ref = locate(params["disease_ref"])
			var/datum/weakref/symptom_ref = locate(params["symptom_ref"])
			try_symptom_change(usr, diease_ref, new_varient, symptom_ref)
//TODO: Add a UI for the splicing instead of a series of tgui inputs this would make it far nicer
