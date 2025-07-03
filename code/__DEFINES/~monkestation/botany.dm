#define COMSIG_GROWING_WATER_UPDATE "growing_water_update"
#define COMSIG_PLANT_TRY_POLLINATE "try_pollinate"
#define COMSIG_PLANT_TRY_HARVEST "plant_try_harvest"
#define COMSIG_PLANT_BUILD_IMAGE "plant_build_image"
#define COMSIG_PLANT_ADJUST_WEED "plant_adjust_weeds"
#define COMSIG_PLANT_GROWTH_PROCESS "process_plant_growth"
#define COMSIG_TRY_HARVEST_SEEDS "try_harvest_seeds"
#define COMSIG_TRY_PLANT_SEED "try_plant_seeds"
#define COMSIG_PLANT_CHANGE_PLANTER "plant_change_planter"
#define COMSIG_PLANT_SENDING_IMAGE "plant_sending_image"
#define COMSIG_TRY_POLLINATE "try_pollinate_grower"
#define COMSIG_ADJUST_PLANT_HEALTH "adjust_plant_health"
#define COMSIG_GROWING_ADJUST_TOXIN "adjust_growing_toxicity"
#define COMSIG_GROWING_ADJUST_PEST "adjust_growing_pests"
#define COMSIG_PLANT_UPDATE_HEALTH_COLOR "update_health_color"
#define COMSIG_GROWING_ADJUST_WEED "adjust_growing_weed"
#define COMSIG_GROWER_ADJUST_SELFGROW "adjust_grower_selfgrow"
#define COMSIG_GROWER_INCREASE_WORK_PROCESSES "increase_work_process_grower"
#define COMSIG_NUTRIENT_UPDATE "nutrient_update"
#define COMSIG_TOXICITY_UPDATE "toxicity_update"
#define COMSIG_PEST_UPDATE "pest_update"
#define COMSIG_WEEDS_UPDATE "weeds_update"
#define COMSIG_GROWER_SET_HARVESTABLE "set_harvestable_grower"
#define COMSIG_REMOVE_PLANT "remove_plant_grower"
#define REMOVE_PLANT_VISUALS "remove_plant_visuals"
#define COMSIG_GROWER_CHECK_POLLINATED "check_grower_pollinated"
#define COMSIG_ATTEMPT_BIOBOOST "attempt_bioboost"
#define COMSIG_PLANTER_REMOVE_PLANTS "remove_all_plants"
#define COMSIG_TOGGLE_BIOBOOST "toggle_bioboost"
#define COMSIG_REAGENT_CACHE_ADD_ATTEMPT "reagent_cache_attempt"
#define COMSIG_REAGENT_PRE_TRANS_TO "reagent_pre_trans"
#define COMSIG_GROWING_TRY_SECATEUR "try_secateur"
#define COMSIG_PLANT_TRY_SECATEUR "plant_try_secateur"
#define COMSIG_GROWER_TRY_GRAFT "plant_grower_try_graft"

#define SHOW_WATER (1<<0)
#define SHOW_HEALTH (1<<1)
#define SHOW_WEED (1<<2)
#define SHOW_PEST (1<<3)
#define SHOW_TOXIC (1<<4)
#define SHOW_NUTRIENT (1<<5)
#define SHOW_HARVEST (1<<6)

#define SPECIES_APID "apid"

#define COMSIG_MUTATION_TRIGGER "mutation_trigger"
#define COMSIG_AGE_ADJUSTMENT "age_adjust"
#define COMSIG_AGE_RETURN_AGE "age_return"
#define COMSIG_HAPPINESS_ADJUST "happiness_adjustment"
#define COMSIG_HAPPINESS_CHECK_RANGE "happiness_check_range"
#define COMSIG_HAPPINESS_PASS_HAPPINESS "happiness_pass"

#define COMSIG_MOB_SHEARED "comsig_mob_sheared"


#define TRAIT_TIN_EATER "tin_eater"
#define TRAIT_LIVING_DRUNK "living_drunk"
#define COMSIG_TRY_EAT_TRAIT "try_eat_trait"

/// Returns the potency for a seed, capped at 100.
#define CAPPED_POTENCY(seed) (min(seed.potency, 100))
