/area
	luminosity = 1
	///List of mutable appearances we underlay to show light
	///In the form plane offset + 1 -> appearance to use
	var/list/mutable_appearance/lighting_effects = null
	///Whether this area has a currently active base lighting, bool
	var/area_has_base_lighting = FALSE
	///alpha 0-255 of lighting_effect and thus baselighting intensity
	var/base_lighting_alpha = 0
	///The colour of the light acting on this area
	var/base_lighting_color = COLOR_WHITE

/area/proc/set_base_lighting(new_base_lighting_color = -1, new_alpha = -1)
	if(base_lighting_alpha == new_alpha && base_lighting_color == new_base_lighting_color)
		return FALSE
	if(new_alpha != -1)
		base_lighting_alpha = new_alpha
	if(new_base_lighting_color != -1)
		base_lighting_color = new_base_lighting_color
	update_base_lighting()
	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, base_lighting_color))
			set_base_lighting(new_base_lighting_color = var_value)
			return TRUE
		if(NAMEOF(src, base_lighting_alpha))
			set_base_lighting(new_alpha = var_value)
			return TRUE
		if(NAMEOF(src, static_lighting))
			if(!static_lighting)
				create_area_lighting_objects()
			else
				remove_area_lighting_objects()

	return ..()

/area/proc/update_base_lighting()
	if(!area_has_base_lighting && (!base_lighting_alpha || !base_lighting_color))
		return

	if(!area_has_base_lighting)
		add_base_lighting()
		return
	remove_base_lighting()
	if(base_lighting_alpha && base_lighting_color)
		add_base_lighting()

/area/proc/remove_base_lighting()
	var/list/z_offsets = SSmapping.z_level_to_plane_offset
	if(length(lighting_effects) > 1)
		for(var/area_zlevel in 1 to get_highest_zlevel())
			if(z_offsets[area_zlevel])
				for(var/turf/T as anything in get_turfs_by_zlevel(area_zlevel))
					T.cut_overlay(lighting_effects[z_offsets[T.z] + 1])
	cut_overlay(lighting_effects[1])
	lighting_effects.Cut()
	area_has_base_lighting = FALSE

/area/proc/add_base_lighting()
	lighting_effects = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		var/mutable_appearance/lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
		SET_PLANE_W_SCALAR(lighting_effect, LIGHTING_PLANE, offset)
		lighting_effect.layer = LIGHTING_PRIMARY_LAYER
		lighting_effect.blend_mode = BLEND_ADD
		lighting_effect.alpha = base_lighting_alpha
		lighting_effect.color = base_lighting_color
		lighting_effect.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
		lighting_effects += lighting_effect
	add_overlay(lighting_effects[1])
	var/list/z_offsets = SSmapping.z_level_to_plane_offset
	for(var/area_zlevel in 1 to get_highest_zlevel())
		// We will only add overlays to turfs not on the first z layer, because that's a significantly lesser portion
		// And we need to do them separate, or lighting will go fuckey
		// This inside loop is EXTREMELY hot because it's run by space tiles, so we do the if check once on the outside
		if(length(lighting_effects) > 1 && z_offsets[area_zlevel])
			var/lighting_effect_to_add = lighting_effects[z_offsets[area_zlevel] + 1]
			for(var/turf/area_turf as anything in get_turfs_by_zlevel(area_zlevel))
				area_turf.luminosity = 1
				area_turf.add_overlay(lighting_effect_to_add)
		else
			for(var/turf/area_turf as anything in get_turfs_by_zlevel(area_zlevel))
				area_turf.luminosity = 1

	area_has_base_lighting = TRUE
