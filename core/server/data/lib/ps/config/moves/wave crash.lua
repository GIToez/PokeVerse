MOVES["Wave Crash"] = {
    description = "The user shrouds itself in water and slams into the target. This also damages the user quite a lot.",
    makeContact = true,
    makeRecoil = true,
    category = MOVE_CATEGORY.PHYSICAL,
    clientIconId = 29000,
    iconId = 0,
    dType = DAMAGE_TYPE_WATER,
    type = SKILLS_TYPES.TARGET,
    requiredEnergy = 125,
    damage = 120,
    damageType = ELEMENT_WATER,
    effect = EFFECT_BIG_SPLASH,
    projectile = PROJECTILE_BUBBLES,
    maxDistance = 6,
    cooldownTime = 27,
    cooldownStorage = 15477
}