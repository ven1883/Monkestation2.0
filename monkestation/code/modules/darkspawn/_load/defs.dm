///Darkspawn traits
///lets darkspawns walk through weak light
#define TRAIT_DARKSPAWN_LIGHTRES "darkspawn_lightres"
///lets darkspawns walk through any light
#define TRAIT_DARKSPAWN_CREEP "darkspawn_creep"
///permanently reduces the lucidity gained from future succs
#define TRAIT_DARKSPAWN_DEVOURED "darkspawn_devoured"
///disable psi regeneration (make sure to remove it after some time)
#define TRAIT_DARKSPAWN_PSIBLOCK "darkspawn_psiblock"
///make aoe ally buff abilities also affect allied darkspawns
#define TRAIT_DARKSPAWN_BUFFALLIES "darkspawn_allybuff"
///revives the darkspawn if they're dead and in the dark
#define TRAIT_DARKSPAWN_UNDYING "darkspawn_undying"

#define STATUS_EFFECT_TIME_DILATION /datum/status_effect/time_dilation //Provides immunity to slowdown and halves click-delay/action times //Yogs

#define STATUS_EFFECT_TAGALONG /datum/status_effect/tagalong //allows darkspawn to accompany people's shadows //Yogs

#define STATUS_EFFECT_SPEEDBOOST /datum/status_effect/speedboost //applies a speed boost

/// Sent from /datum/action/cooldown/spell/proc/can_cast_spell(), to the mind of the mob casting the spell: (datum/mind, resource_flag, resource_amount)
#define COMSIG_MIND_CHECK_ANTAG_RESOURCE "check_antag_resource"
/// Sent from /datum/action/cooldown/spell/proc/consume_resource(), to the mind of the mob casting the spell: (datum/mind, list/resource_costs)
#define COMSIG_MIND_SPEND_ANTAG_RESOURCE "spend_antag_resource"
