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
	
	-- this is the most important thing since the whole script relies on the config for generating treasure
	treasureTables = root.assetJson("/config/srm_treasure.config")
	local treasureType = treasureTables.kind
	local treasureMaterial = treasureTables.material
	local treasureGem = treasureTables.gem
	local treasureState = treasureTables.state

	-- initialize randomization
	seed = configParameter("seed",nil)
	if not configParameter("seed") then
		math.randomseed(util.seedTime())
		seed = math.random(1, 4294967295)
		parameters.seed = seed
	end

	-- select the generation profile to use
	local builderConfig = {}
	if config.builderConfig then
		builderConfig = randomFromList(config.builderConfig, seed, "builderConfig")
	end
	
	-- this entire long shitty section gets the random indexes that will serve for the generation of the treasure
	local treasureTypeUpper = 0
	local treasureMaterialUpper = 0
	local treasureGemUpper = 0
	local treasureStateUpper = 0
	for i=1,#treasureType do
		local currentValue = treasureType[i]
	treasureTypeUpper = treasureTypeUpper + currentValue.weight
	end
	for i=1,#treasureMaterial do
		local currentValue = treasureMaterial[i]
	treasureMaterialUpper = treasureMaterialUpper + currentValue.weight
	end
	for i=1,#treasureGem do
		local currentValue = treasureGem[i]
	treasureGemUpper = treasureGemUpper + currentValue.weight
	end
	for i=1,#treasureState do
		local currentValue = treasureState[i]
	treasureStateUpper = treasureStateUpper + currentValue.weight
	end
	local selectedType = math.random() * treasureTypeUpper
	local selectedMaterial = math.random() * treasureMaterialUpper
	local selectedGem = math.random() * treasureGemUpper
	local selectedState = math.random() * treasureStateUpper
	local indexType = parameters.indexType or 0 -- the end goal
	local indexMaterial = parameters.indexMaterial or 0 -- the end goal
	local indexGem = parameters.indexGem or 0 -- the end goal
	local indexState = parameters.indexState or 0 -- the end goal
	if (indexType == 0) then
		for i=1,#treasureType do
			local currentValue = treasureType[i]
		selectedType = selectedType - currentValue.weight
		if (selectedType <= 0) then indexType = i break end
		end
		parameters.indexType = indexType
	end
	if (indexMaterial == 0) then
		for i=1,#treasureMaterial do
			local currentValue = treasureMaterial[i]
		selectedMaterial = selectedMaterial - currentValue.weight
		if (selectedMaterial <= 0) then indexMaterial = i break end
		end
		parameters.indexMaterial = indexMaterial
	end
	if (indexGem == 0) then
		for i=1,#treasureGem do
			local currentValue = treasureGem[i]
		selectedGem = selectedGem - currentValue.weight
		if (selectedGem <= 0) then indexGem = i break end
		end
		parameters.indexGem = indexGem
	end
	if (indexState == 0) then
		for i=1,#treasureState do
			local currentValue = treasureState[i]
		selectedState = selectedState - currentValue.weight
		if (selectedState <= 0) then indexState = i break end
		end
		parameters.indexState = indexState
	end
	
	-- set type
	local defaultImage = "/objects/treasures/"
	parameters.color = "objects/" .. treasureType[indexType].frame
	parameters.placementImage = defaultImage .. "objects/" .. treasureType[indexType].frame
	parameters.inventoryIcon = defaultImage .. "icons/" .. treasureType[indexType].frame
	parameters.largeImage = defaultImage .. "icons/" .. treasureType[indexType].frame
	
	-- set material & gem
	parameters.color = parameters.color .. treasureMaterial[indexMaterial].directives .. treasureGem[indexGem].directives
	parameters.placementImage = parameters.placementImage .. treasureMaterial[indexMaterial].directives .. treasureGem[indexGem].directives
	parameters.inventoryIcon = parameters.inventoryIcon .. treasureMaterial[indexMaterial].directives .. treasureGem[indexGem].directives
	parameters.largeImage = parameters.largeImage .. treasureMaterial[indexMaterial].directives .. treasureGem[indexGem].directives
	
	-- set rarity & state
	parameters.rarity = treasureState[indexState].rarity
	local stateDirectives = ""
	if (parameters.rarity == "Common") then
		stateDirectives = "?saturation=-33?brightness=-25?blendmult=/objects/treasures/cracks.png;0;0"
	elseif (parameters.rarity == "Uncommon") then
		stateDirectives = "?saturation=-33?brightness=-25?blendmult=/objects/treasures/dust.png;0;0"
	elseif (parameters.rarity == "Rare") then
		stateDirectives = "?saturation=-33?brightness=-25"
	else
		stateDirectives = ""
	end
	parameters.color = parameters.color .. stateDirectives
	parameters.placementImage = parameters.placementImage .. stateDirectives
	parameters.inventoryIcon = parameters.inventoryIcon .. stateDirectives
	parameters.largeImage = parameters.largeImage .. stateDirectives

	-- set price
	parameters.price = (config.price or 1000) 
	 * treasureType[indexType].pricemultiplier 
	 * treasureMaterial[indexMaterial].pricemultiplier 
	 * treasureGem[indexGem].pricemultiplier 
	 * treasureState[indexState].pricemultiplier
	
	local message = ""
	if parameters.price < 1000 then
		message = "This isn't worth much."
	elseif parameters.price < 5000 then
		message = "This may be worth something."
	elseif parameters.price < 15000 then
		message = "This is a great find!"
	elseif parameters.price < 25000 then
		message = "This is worth a small fortune!"
	else
		message = "SO MUCH MONEY!!!"
	end
	
	-- sets the name and description / quantity, opinion, size, age, color, shape, origin, material and purpose
	parameters.shortdescription = "" .. treasureState[indexState].name .. " " .. treasureMaterial[indexMaterial].name .. " " .. treasureType[indexType].name 
	parameters.description = "This " .. treasureState[indexState].name .. " " .. treasureMaterial[indexMaterial].name .. " " .. treasureType[indexType].name .. " has beautiful " .. treasureGem[indexGem].name .. " embedded inside of it. " .. message

	return config, parameters
end