require "/scripts/util.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
    local configParameter = function(keyName, defaultValue)
        if parameters[keyName] ~= nil then
            return parameters[keyName]
        elseif config[keyName] ~= nil then
            return config[keyName]
        else
            return defaultValue
        end
    end

    if level and not configParameter("fixedLevel", true) then
        parameters.level = level
    end

    -- select, load and merge abilities
    setupAbility(config, parameters, "alt")
    setupAbility(config, parameters, "primary")

    -- elemental type
    local elementalType = parameters.elementalType or config.elementalType or "physical"
    replacePatternInData(config, nil, "<elementalType>", elementalType)

    -- calculate damage level multiplier
    config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

    config.tooltipFields = {}
    config.tooltipFields.subtitle = parameters.category
    config.tooltipFields.orbTotalLabel = configParameter("orbTotal")
    config.tooltipFields.hitDamageLabel = util.round(((config.projectileParameters.power * config.damageLevelMultiplier) / config.tooltipFields.orbTotalLabel), 1)
    config.tooltipFields.levelLabel = configParameter("level")
    if elementalType ~= "physical" then
        config.tooltipFields.damageKindImage = "/interface/elements/" .. elementalType .. ".png"
    end

    if configParameter("shieldLock") ~= true then
        config.tooltipFields.azSecondaryTitleLabel = "Alt:"
        config.tooltipFields.azSecondaryLabel = configParameter("secondaryName") or "Magshield"
        config.tooltipFields.azSecondaryCostTitleLabel = "Alt Energy Cost:"
        config.tooltipFields.azSecondaryCostLabel = configParameter("shieldEnergyCost") .. "/s"
        if configParameter("noMagnitude") ~= true then
            config.tooltipFields.azSecondaryMagnitudeTitleLabel = "Alt Strength:"
            config.tooltipFields.azSecondaryMagnitudeLabel = configParameter("shieldHealth")
        end
    end

    config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

    return config, parameters
end
