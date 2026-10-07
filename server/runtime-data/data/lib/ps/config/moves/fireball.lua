MOVES["Fireball"] = {
    description = "Flame Burst deals damage and has no secondary effect.",
    category = MOVE_CATEGORY.SPECIAL,
    clientIconId = 34571,
    iconId = 0,
    dType = DAMAGE_TYPE_FIRE,
    functionName = "Fireball",
    type = SKILLS_TYPES.TARGET,
    -- requiredEnergy = 80,
    requiredEnergy = 0,
    requiredLevel = 45,
    damage = 70,
    damageType = ELEMENT_FIRE,
    effect = EFFECT_EXPLOSION,
    maxDistance = 6,
    cooldownTime = 22,
    cooldownStorage = 19146
}