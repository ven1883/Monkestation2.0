/obj/item/mcobject/collector
	name = "collector component"

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_collector"
	base_icon_state = "comp_collector"

	var/max_transfer = 15
	///the linked storage object for the collector
	var/obj/item/mcobject/messaging/storage/linked_storage

/obj/item/mcobject/collector/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("collect", collect)

/obj/item/mcobject/collector/Destroy(force)
	unset_linked_storage()
	return ..()

/obj/item/mcobject/collector/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	if(!istype(multitool.component_buffer, /obj/item/mcobject/messaging/storage) || QDELING(multitool.component_buffer))
		return
	linked_storage = multitool.component_buffer
	RegisterSignal(linked_storage, COMSIG_QDELETING, PROC_REF(unset_linked_storage))
	say("Successfully linked to storage component")

/obj/item/mcobject/collector/proc/collect(datum/mcmessage/input)
	if(!input || QDELETED(linked_storage))
		return
	var/count = 0
	for(var/obj/item/contained_item in src.loc)
		if(contained_item == src)
			continue
		if(contained_item.anchored)
			continue
		if(istype(contained_item, /obj/item/mcobject))
			continue

		if(count >= max_transfer)
			break
		if(linked_storage.attempt_insert(contained_item, src))
			count ++
	flash()

/obj/item/mcobject/collector/proc/unset_linked_storage(datum/source)
	SIGNAL_HANDLER
	if(!isnull(linked_storage))
		UnregisterSignal(linked_storage, COMSIG_QDELETING)
		linked_storage = null
