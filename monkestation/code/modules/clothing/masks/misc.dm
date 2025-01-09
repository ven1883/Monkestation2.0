/obj/item/clothing/mask/kitsuneblack
	name = "Black Kitsune Mask"
	desc = "An oriental styled porcelain mask, this one is black and gold."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "blackkitsunemask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/kitsuneblack/attack_self(mob/user)
    adjustmask(user)

/obj/item/clothing/mask/kitsuneblack/AltClick(mob/user)
    . = ..()
    adjustmask(user)
    return TRUE

/obj/item/clothing/mask/kitsunewhite
	name = "White Kitsune Mask"
	desc = "An oriental styled porcelain mask, this one is white and red."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "whitekitsunemask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/kitsunewhite/attack_self(mob/user)
    adjustmask(user)

/obj/item/clothing/mask/kitsunewhite/AltClick(mob/user)
    . = ..()
    adjustmask(user)
    return TRUE

/obj/item/clothing/mask/ookmask
	name = "Paper Monkey Mask"
	desc = "One shudders to imagine the inhuman thoughts that lie underneath that mask."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	icon_state = "ook"
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	alternative_screams = list(	'sound/creatures/monkey/monkey_screech_1.ogg',
								'sound/creatures/monkey/monkey_screech_2.ogg',
								'sound/creatures/monkey/monkey_screech_3.ogg',
								'sound/creatures/monkey/monkey_screech_4.ogg',
								'sound/creatures/monkey/monkey_screech_5.ogg',
								'sound/creatures/monkey/monkey_screech_6.ogg',
								'sound/creatures/monkey/monkey_screech_7.ogg')

	alternative_laughs = list(	'monkestation/sound/voice/laugh/misc/big_laugh0.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh1.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh2.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh3.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh4.ogg')

/obj/item/clothing/mask/breath/sec_bandana
	desc = "An incredibly dense synthetic thread bandana that can be used as an internals mask."
	name = "sec bandana"
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	icon_state = "sec_bandana_default"
	var/obj/item/clothing/suit/armor/secduster/suit
	actions_types = null

/obj/item/clothing/mask/breath/sec_bandana/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_MASK)
		if(suit)
			suit.RemoveMask()
		else
			qdel(src)

/obj/item/clothing/mask/breath/sec_bandana/AltClick(mob/user)
	suit.RemoveMask()
	return

/obj/item/clothing/mask/breath/sec_bandana/medical
	icon_state = "sec_bandana_medical"

/obj/item/clothing/mask/breath/sec_bandana/engineering
	icon_state = "sec_bandana_engi"

/obj/item/clothing/mask/breath/sec_bandana/cargo
	icon_state = "sec_bandana_medical"

/obj/item/clothing/mask/breath/sec_bandana/science
	icon_state = "sec_bandana_science"

/obj/item/clothing/mask/knightmask
	name = "Knight Mask"
	desc = "A stark white mask with gaping eyes, adorned with pinsir like horns."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "knight_mask"
	worn_icon_state = "knight_mask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/hornetmask
	name = "Hornet Mask"
	desc = "A stark white mask with gaping eyes, adorned with curved horns."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "hornet_mask"
	worn_icon_state = "hornet_mask"
	worn_y_offset = 16
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/grimmmask
	name = "Grimm Mask"
	desc = "A black mask with a stark white faceplate."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "grimm_mask"
	worn_icon_state = "grimm_mask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/gas/atp
	name = "\improper A.T.P. engineer mask"
	desc = "Not rated for bullets, stop trying. Also not rated for killer clowns with stop signs."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "atp_mask"
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
//	inhand_icon_state = "gas_alt"
	modifies_speech = TRUE
	COOLDOWN_DECLARE(spamcheck)

/obj/item/clothing/mask/gas/atp/handle_speech(datum/source, list/speech_args)
	if(COOLDOWN_FINISHED(src, spamcheck))
		var/speaksound = pick('monkestation/sound/items/atp_speak1.ogg', 'monkestation/sound/items/atp_speak2.ogg', 'monkestation/sound/items/atp_speak3.ogg', 'monkestation/sound/items/atp_speak4.ogg', 'monkestation/sound/items/atp_speak5.ogg')
		playsound(src, speaksound, 35, FALSE, SHORT_RANGE_SOUND_EXTRARANGE-2, falloff_exponent = 0, ignore_walls = FALSE, use_reverb = FALSE)
		COOLDOWN_START(src, spamcheck, 3 SECONDS)

/obj/item/clothing/mask/gas/atp/equipped(mob/living/equipee, slot)
	. = ..()
	if(slot & ITEM_SLOT_MASK)
		RegisterSignal(equipee, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(item_removed))
		RegisterSignal(equipee, COMSIG_LIVING_DEATH, PROC_REF(death_sound))
		if(istype(equipee))
			equipee.bubble_icon = "atp"

/obj/item/clothing/mask/gas/atp/proc/item_removed(mob/living/wearer, obj/item/dropped_item)
	SIGNAL_HANDLER
	if(dropped_item != src)
		return
	UnregisterSignal(wearer, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_LIVING_DEATH))
	if(istype(wearer))
		wearer.bubble_icon = initial(wearer.bubble_icon)

/obj/item/clothing/mask/gas/atp/proc/death_sound(mob/living/equipee)
	SIGNAL_HANDLER
	playsound(src, 'monkestation/sound/items/atp_death_sound.ogg', 20, FALSE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
