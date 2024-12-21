/datum/species/calico
	// Reptilian humanoids with scaled skin and tails.
	name = "\improper Calico"
	plural_form = "Calicos"
	id = SPECIES_CALICO
	visual_gender = FALSE
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_DWARF
	)
	external_organs = list()

	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/calico,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/calico,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/calico,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/calico,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/calico,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/calico,
	)

/*
/datum/species/calico/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname
*/

/datum/species/calico/get_species_description()
	return "The militaristic Cat People:tm: hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."
