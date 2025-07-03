/obj/item/meteor_shield_capsule
	name = "meteor defense satellite capsule"
	desc = "A bluespace capsule which a single unit of meteor defense satellite is compressed within. If you activate this capsule, a meteor shield satellite will pop out. You still need to install these."
	icon = 'monkestation/icons/obj/machines/satellite.dmi'
	icon_state = "meteor_sat_capsule"
	w_class = WEIGHT_CLASS_TINY

/obj/item/meteor_shield_capsule/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 0.5 SECONDS, /obj/machinery/satellite/meteor_shield, delete_on_use = TRUE)
