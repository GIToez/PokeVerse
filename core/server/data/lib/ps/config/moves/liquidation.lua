MOVES["Liquidation"] = {
    description = "The user slams into the target using a full-force blast of water. It has a 20% chance of lowering the target's Defense and Special Defense by one stage each.",
    makeContact = true,
    category = MOVE_CATEGORY.PHYSICAL,
    clientIconId = 29003,
    iconId = 0,
    dType = DAMAGE_TYPE_WATER,
    type = SKILLS_TYPES.TARGET,
    requiredEnergy = 85,
    damage = 85,
    damageType = ELEMENT_WATER,
    effect = EFFECT_WATER_EXPLOSION,
    maxDistance = 1,
    cooldownTime = 12,
    cooldownStorage = 15480
}