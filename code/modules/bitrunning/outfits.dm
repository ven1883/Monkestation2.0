/datum/outfit/cyber_police
	name = "Cyber Police"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/cyber_police
	uniform = /obj/item/clothing/under/suit/black_really
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	/// A list of hex codes for blonde, brown, black, and red hair.
	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		"#000000",
		"#8D4A43",
		"#D2B48C",
	)
	/// List of business ready styles
	var/static/list/approved_hairstyles = list(
		/datum/sprite_accessory/hair/business,
		/datum/sprite_accessory/hair/business2,
		/datum/sprite_accessory/hair/business3,
		/datum/sprite_accessory/hair/business4,
		/datum/sprite_accessory/hair/mulder,
	)

/datum/outfit/cyber_police/post_equip(mob/living/carbon/human/user, visualsOnly)
	var/obj/item/clothing/under/officer_uniform = user.w_uniform
	if(officer_uniform)
		officer_uniform.has_sensor = NO_SENSORS
		officer_uniform.sensor_mode = SENSOR_OFF
		user.update_suit_sensors()

/datum/outfit/echolocator
	name = "Bitrunning Echolocator"
	glasses = /obj/item/clothing/glasses/blindfold
//	ears = /obj/item/radio/headset/psyker //Navigating without these is horrible. MONKEYSTATION EDIT ORIGINAL - we still have old psyker headsets
	ears = /obj/item/radio/headset/syndicate/alt/psyker // MONKEYSTATION EDIT NEW
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	id = /obj/item/card/id/advanced

/datum/outfit/echolocator/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()
	user.psykerize()


/datum/outfit/bitductor
	name = "Bitrunning Abductor"
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots


/datum/outfit/beachbum_combat
	name = "Beachbum: Island Combat"
	id = /obj/item/card/id/advanced
	l_pocket = null
	r_pocket = null
	shoes = /obj/item/clothing/shoes/sandal
	uniform = /obj/item/clothing/under/pants/jeans
	/// Available ranged weapons
	var/list/ranged_weaps = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/automatic/mini_uzi,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted,
		/obj/item/gun/ballistic/automatic/ar,

	)
	/// Corresponding ammo
	var/list/corresponding_ammo = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_box/magazine/uzim9mm,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/food/pizzaslice/dank, // more silly, less destructive
		/obj/item/ammo_box/magazine/m223,
	)


/datum/outfit/beachbum_combat/post_equip(mob/living/carbon/human/bum, visuals_only)
	. = ..()

	var/choice = rand(1, length(ranged_weaps))
	var/weapon = ranged_weaps[choice]
	bum.put_in_active_hand(new weapon)

	var/ammo = corresponding_ammo[choice]
	var/obj/item/ammo1 = new ammo
	var/obj/item/ammo2 = new ammo

	if(!bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_LPOCKET))
		ammo1.forceMove(get_turf(bum))
	if(!bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_RPOCKET))
		ammo2.forceMove(get_turf(bum))

	if(prob(50))
		bum.equip_to_slot_if_possible(new /obj/item/clothing/glasses/sunglasses, ITEM_SLOT_EYES)
