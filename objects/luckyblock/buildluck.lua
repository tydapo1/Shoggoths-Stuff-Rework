require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/scripts/staticrandom.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level)
	local configParameter = function(keyName, defaultValue)
		if parameters[keyName] ~= nil then
			return parameters[keyName]
		elseif config[keyName] ~= nil then
			return config[keyName]
		else
			return defaultValue
		end
	end

	if level and not configParameter("fixedLevel", false) then
		parameters.level = level
	end

	-- select the generation profile to use
	local builderConfig = {}
	if config.builderConfig then
		builderConfig = randomFromList(config.builderConfig, seed, "builderConfig")
	end

	-- sets luck description	
	local message = config.message
	if not parameters.luck then parameters.luck = 0 end
	if parameters.luck >= 90 then
		message = config.messageBlessed
	elseif parameters.luck >= 30 then
		message = config.messageLucky
	elseif parameters.luck <= -90 then
		message = config.messageCursed
	elseif parameters.luck <= -30 then
		message = config.messageUnlucky
	end
	parameters.description = message
	
	-- check if debug cube
	if parameters.debugOutcome then
		parameters.inventoryIcon = "srm_debugblockicon.png"
		parameters.shortdescription = "^green;Perfectly Generic Block^reset;"
		parameters.description = "This lucky block has a pre-selected outcome for debugging purposes."
	end

	return config, parameters
end