require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

local colorIndices = { none = 0, red = 1, blue = 2, green = 3, yellow = 4, orange = 5, pink = 6, black = 7, white = 8 }
local colorNames = { [0] = "none", [1] = "red", [2] = "blue", [3] = "green", [4] = "yellow", [5] = "orange", [6] = "pink", [7] = "black", [8] = "white" }

-- We do not want to mess with these parts, so we'll do functions to avoid fucking with this part of the code.

function init()
	directives = config.getParameter("color")
	animator.setGlobalTag("color", directives)
	
	animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
	animator.setGlobalTag("directives", "")
	animator.setGlobalTag("bladeDirectives", "")

	self.weapon = Weapon:new()

	self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
	self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

	local primaryAbility = getPrimaryAbility()
	self.weapon:addAbility(primaryAbility)

	local secondaryAttack = getAltAbility()
	if secondaryAttack then
		self.weapon:addAbility(secondaryAttack)
	end

	self.weapon:init()
	
	if (entity.entityType() == "player") then brushInit() end
end

function update(dt, fireMode, shiftHeld)
	self.weapon:update(dt, fireMode, shiftHeld)
	
	if (entity.entityType() == "player") then brushUpdate(dt, fireMode, shiftHeld) end
end

function uninit()
	self.weapon:uninit()
	
	if (entity.entityType() == "player") then brushUninit() end
end



-- Custom code starts here.



function brushInit()
	tileconfig = root.assetJson("/config/srm_brush.config")
	message.setHandler("worldbrush_UIisOpened", function(_, isItMine) 
		if isItMine then 
			self.alreadyOpened = true 
			self.canBuild = true 
			animator.setAnimationState("interfacing", "building", true)
		end 
	end)
	message.setHandler("worldbrush_UIisClosed", function(_, isItMine) 
		if isItMine then 
			self.alreadyOpened = false 
			self.canBuild = false 
			animator.setAnimationState("interfacing", "idle", true)
		end
	end)
	message.setHandler("worldbrush_UIDataUpdate", function(_, isItMine, newTile, newColor, willPlaceMod, newMod, newIsPlatform, newDestroyTiles) 
		if isItMine then 
			currentTile = newTile 
			currentColor = newColor 
			placeMod = willPlaceMod 
			currentMod = newMod 
			isPlatform = newIsPlatform
			destroyTiles = newDestroyTiles
		end
	end)
	message.setHandler("worldbrush_ConsumeRessource", function(_, isItMine) 
		player.consumeItemWithParameter("liquid", "srm_eldritchslime", 1)
		player.cleanupItems()
	end)

	rainbowvalue = 0
	currentTile = "srm_shoggothblock0"
	currentColor = "none"
	placeMod = false
	currentMod = "srm_shoggotheyepatch0"
	isPlatform = false
	destroyTiles = false
	self.alreadyOpened = false
	self.canBuild = false
end

function brushUpdate(dt, fireMode, shiftHeld)
	if (sb.print(fireMode) == "alt" and sb.print(shiftHeld) == "true" and self.alreadyOpened == false) then
		local cfg = root.assetJson("/interface/scripted/srm_worldbrush/srm_worldbrush.config")
		activeItem.interact("ScriptPane", cfg)
	end
	
	-- This is the important part that actually goes through with the building.
	if (self.canBuild) then
		if (sb.print(fireMode) == "primary" and sb.print(shiftHeld) == "false") then
			if destroyTiles then
				tryDestroyTileForeground()
			else
				tryPaintTileForeground()
			end
		end
		if (sb.print(fireMode) == "alt" and sb.print(shiftHeld) == "false") then
			if destroyTiles then
				tryDestroyTileBackground()
			else
				tryPaintTileBackground()
			end
		end
	end
	
	--This is exclusive to the galaxy brush.
	if (item.name() == "srm_galaxybrush") then
		local rainbowvaluetrue = "?hueshift="
		local rainbowvaluefinal = "?hueshift=0"
	
		rainbowvalue = rainbowvalue + 10
		if ( rainbowvalue == 360 ) then rainbowvalue = 0 end
		rainbowvaluefinal = (rainbowvaluetrue .. rainbowvalue)
		animator.setGlobalTag("rainbowDirectives", rainbowvaluefinal)
	end
end

function brushUninit()
end

function tryPaintTileForeground()
	local currentPosition = activeItem.ownerAimPosition()
	if (world.tileIsOccupied(currentPosition, true, false) == false) then
		if (world.isTileProtected(currentPosition) == false) then
			local validSpaces = false
			for i = -1,1,1 do
				for j = -1,1,1 do
					if (world.material({currentPosition[1]+i,currentPosition[2]+j}, "foreground") ~= false) then validSpaces = true end
				end
			end
			if (world.material(currentPosition, "background") ~= false) then validSpaces = true end
			if validSpaces then
				if (player.hasItemWithParameter("liquid", "srm_eldritchslime") or player.isAdmin()) then
					world.spawnStagehand(currentPosition, "srm_blockplacement", { 
						position = currentPosition, 
						layer = "foreground", 
						tile = currentTile,
						color = currentColor, 
						canmod = placeMod, 
						matmod = currentMod,
						playerid = activeItem.ownerEntityId()
					})
				end
			end
		end
	end
end

function tryPaintTileBackground()
	local currentPosition = activeItem.ownerAimPosition()
	if (world.tileIsOccupied(currentPosition, false, false) == false) then
		if (world.isTileProtected(currentPosition) == false) then
			local validSpaces = false
			for i = -1,1,1 do
				for j = -1,1,1 do
					if (world.material({currentPosition[1]+i,currentPosition[2]+j}, "background") ~= false) then validSpaces = true end
				end
			end
			if (world.material(currentPosition, "foreground") ~= false) then validSpaces = true end
			if isPlatform then validSpaces = false end
			if validSpaces then
				if (player.hasItemWithParameter("liquid", "srm_eldritchslime") or player.isAdmin()) then
					world.spawnStagehand(currentPosition, "srm_blockplacement", { 
						position = currentPosition, 
						layer = "background", 
						tile = currentTile,
						color = currentColor, 
						canmod = placeMod, 
						matmod = currentMod,
						playerid = activeItem.ownerEntityId()
					})
				end
			end
		end
	end
end

function tryDestroyTileForeground()
	local currentPosition = activeItem.ownerAimPosition()
	local susTile = world.material(currentPosition, "foreground")
	local match = false
	for i = 1,#tileconfig.tilelist,1 do
		for j = 0,29,1 do
			if (susTile == root.assetJson(tileconfig.tilelist[i]).name .. j) then match = true end			
		end
	end
	if match then world.spawnStagehand(currentPosition, "srm_blockdestruction", {position = currentPosition, layer = "foreground"}) end
end

function tryDestroyTileBackground()
	local currentPosition = activeItem.ownerAimPosition()
	local susTile = world.material(currentPosition, "background")
	local match = false
	for i = 1,#tileconfig.tilelist,1 do
		for j = 0,29,1 do
			if (susTile == root.assetJson(tileconfig.tilelist[i]).name .. j) then match = true end			
		end
	end
	if match then world.spawnStagehand(currentPosition, "srm_blockdestruction", {position = currentPosition, layer = "background"}) end
end