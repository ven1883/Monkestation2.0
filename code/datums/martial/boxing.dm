/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/attacker, mob/living/defender)
	to_chat(attacker, span_warning("Can't disarm while boxing!"))
	return TRUE

/datum/martial_art/boxing/grab_act(mob/living/attacker, mob/living/defender)
	if(defender.body_position == LYING_DOWN)
		return
	else
		to_chat(attacker, span_warning("They need to be down first!"))
		return TRUE

/datum/martial_art/boxing/harm_act(mob/living/attacker, mob/living/defender)

	var/mob/living/carbon/human/attacker_human = attacker
	var/obj/item/bodypart/arm/active_arm = attacker_human.get_active_hand()

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = 25
	if(!damage)
		playsound(defender.loc, active_arm.unarmed_miss_sound, 25, TRUE, -1)
		defender.visible_message(span_warning("[attacker]'s [atk_verb] misses [defender]!"), \
						span_danger("You avoid [attacker]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_warning("Your [atk_verb] misses [defender]!"))
		log_combat(attacker, defender, "attempted to hit", atk_verb)
		return FALSE


	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE)

	playsound(defender.loc, active_arm.unarmed_attack_sound, 25, TRUE, -1)

	defender.visible_message(span_danger("[attacker] [atk_verb]ed [defender]!"), \
					span_userdanger("You're [atk_verb]ed by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You [atk_verb]ed [defender]!"))

	defender.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(attacker_human, defender, "punched (boxing) ")
	if(defender.stamina.loss > 235 && istype(defender.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = 10 // 10% chance to win by knockout when they are around one hit from stam crit anyways
		if((defender.stat != DEAD) && prob(knockout_prob))
			defender.visible_message(span_danger("[attacker_human] knocks [defender] out with a haymaker!"), \
							span_userdanger("You're knocked unconscious by [attacker_human]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker_human)
			to_chat(attacker_human, span_danger("You knock [defender] out with a haymaker!"))
			defender.apply_effect(20 SECONDS,EFFECT_KNOCKDOWN,armor_block)
			defender.SetSleeping(10 SECONDS)
			log_combat(attacker_human, defender, "knocked out (boxing) ")
	return TRUE

/datum/martial_art/boxing/can_use(mob/living/owner)
	if(!ishuman(owner))
		return FALSE
	return ..()

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	..()
	// boxing requires human
	if(!ishuman(user))
		return
	if(slot & ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
