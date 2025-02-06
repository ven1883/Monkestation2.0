/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN)), PROC_REF(on_unknown_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_DWARF), SIGNAL_REMOVETRAIT(TRAIT_DWARF)), PROC_REF(on_dwarf_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_GIANT)), PROC_REF(on_gain_giant_trait))
	RegisterSignals(src, list(SIGNAL_REMOVETRAIT(TRAIT_GIANT)), PROC_REF(on_lose_giant_trait))

/// Gaining or losing [TRAIT_UNKNOWN] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/// Gaining or losing [TRAIT_DWARF] updates our height
/mob/living/carbon/human/proc/on_dwarf_trait(datum/source)
	SIGNAL_HANDLER

	update_mob_height()
/* //Non-Modular change - Remove passtable from dwarves.
	if(HAS_TRAIT(src, TRAIT_DWARF))
		passtable_on(src, TRAIT_DWARF)
	else
		passtable_off(src, TRAIT_DWARF)
*/

/mob/living/carbon/human/proc/on_gain_giant_trait(datum/source)
	SIGNAL_HANDLER

	src.update_transform(1.25)
	src.visible_message(span_danger("[src] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/mob/living/carbon/human/proc/on_lose_giant_trait(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_GIANT)) //They have the trait through another source, cancel out.
		return
	src.update_transform(0.8)
	src.visible_message(span_danger("[src] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))
