/obj/effect/temp_visual/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/temp_visual/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 0.6 SECONDS

/obj/effect/temp_visual/revenant/cracks/glow

/obj/effect/temp_visual/revenant/cracks/glow/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/temp_visual/revenant/cracks/glow/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)
