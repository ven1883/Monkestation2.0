///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "Milk"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/consumable/milk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/soymilk
	name = "Soy Milk"
	id = "soymilk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/consumable/soymilk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/ethanol
	name = "Ethanol"
	id = "ethanol"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/ethanol
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/cream
	name = "Cream"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/cream
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/black_pepper
	name = "Black Pepper"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/blackpepper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/enzyme
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/flour
	name = "Flour"
	id = "flour_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/flour
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/rice
	name = "Rice"
	id = "rice"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/rice
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/sugar
	name = "Sugar"
	id = "sugar"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/sugar
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/cornmeal
	name = "Cornmeal"
	id = "cornmeal"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 1.2)
	make_reagent = /datum/reagent/consumable/cornmeal
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/yogurt
	name = "Yogurt"
	id = "yogurt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 1.2)
	make_reagent = /datum/reagent/consumable/yoghurt
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 1.2)
	make_reagent = /datum/reagent/consumable/soysauce
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/monkey_cube
	name = "Monkey Cube"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass =SMALL_MATERIAL_AMOUNT*0.5)
	build_path = /obj/item/food/monkeycube
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/seaweed_sheet
	name = "Seaweed Sheet"
	id = "seaweedsheet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 3)
	build_path = /obj/item/food/seaweedsheet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/cow_cube
	name = "Cow Cube"
	id = "cowcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass =SMALL_MATERIAL_AMOUNT*2)
	build_path = /obj/item/food/monkeycube/cow
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/pig_cube
	name = "Pig Cube"
	id = "pigcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass =SMALL_MATERIAL_AMOUNT*2)
	build_path = /obj/item/food/monkeycube/pig
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/water
	name = "water"
	id = "Water"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.1)
	build_path = /datum/reagent/water
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/ez_nut   //easy nut :)
	name = "E-Z Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.1)
	make_reagent = /datum/reagent/plantnutriment/eznutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/l4z_nut
	name = "Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.1)
	make_reagent = /datum/reagent/plantnutriment/left4zednutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/rh_nut
	name = "Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.2)
	make_reagent = /datum/reagent/plantnutriment/robustharvestnutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/end_gro
	name = "Enduro Grow"
	id = "end_gro"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.3)
	make_reagent = /datum/reagent/plantnutriment/endurogrow
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/liq_earth
	name = "Liquid Earthquake"
	id = "liq_earth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.3)
	make_reagent = /datum/reagent/plantnutriment/liquidearthquake
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/weed_killer
	name = "Weed Killer"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.2)
	make_reagent = /datum/reagent/toxin/plantbgone/weedkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/pest_spray
	name = "Pest Killer"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/toxin/pestkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/org_pest_spray
	name = "Organic Pest Killer"
	id = "org_pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/toxin/pestkiller/organic
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/leather
	name = "Sheet of Leather"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 30)
	build_path = /obj/item/stack/sheet/leather
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/cloth
	name = "Sheet of Cloth"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10)
	build_path = /obj/item/stack/sheet/cloth
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/cardboard
	name = "Sheet of Cardboard"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 5)
	build_path = /obj/item/stack/sheet/cardboard
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/paper
	name = "Sheet of Paper"
	id = "paper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 2)
	build_path = /obj/item/paper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/rolling_paper
	name = "Sheet of Rolling Paper"
	id = "rollingpaper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 1)
	build_path = /obj/item/rollingpaper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/strange_seeds
	name = "Strange Seeds"
	id = "strange_seeds"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 2000)
	build_path = /obj/item/seeds/random
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)


/datum/design/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.3)
	make_reagent = /datum/reagent/saltpetre
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/ammonia
	name = "Ammonia"
	id = "ammonia"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.2)
	make_reagent = /datum/reagent/ammonia
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/diethylamine
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)
