function init()
	tileconfig = root.assetJson("/config/srm_brush.config")
	
	currentTileIndex = 0
	currentTile = 1
	currentColor = getColorIndex("none")
	canPlaceMod = false 
	defaultColors = false
	currentMod = root.assetJson(tileconfig.modifier).name
	isPlatform = false
	destroyTiles = false
	
	world.sendEntityMessage(player.id(), "worldbrush_UIisOpened")
	refreshBrushData(isPlatform, currentTileIndex, currentColor, canPlaceMod, currentMod)
	updateData()
	updateDisplay()
end

function update()
	if (player.primaryHandItem() == nil) then
		pane.dismiss()
	elseif (player.primaryHandItem().name ~= "srm_worldbrush" and player.primaryHandItem().name ~= "srm_galaxybrush") then
		pane.dismiss()
	end
end

function uninit()
	world.sendEntityMessage(player.id(), "worldbrush_UIisClosed")
end

function selectColorRegionRadios()
	updateData()
	updateDisplay()
end

function lastTileButton()
	changeTileButton(-1)
	updateData()
	updateDisplay()
end

function nextTileButton()
	changeTileButton(1)
	updateData()
	updateDisplay()
end

function defaultColorsCheck()
	defaultColors = widget.getChecked("defaultColors")
	updateData()
	updateDisplay()
end

function placeEyesCheck()
	canPlaceMod = widget.getChecked("placeEyes")
	updateData()
	updateDisplay()
end

function destroyTilesCheck()
	destroyTiles = widget.getChecked("destroyTiles")
	updateData()
	updateDisplay()
end

function updateData()
	local newTileIndex = 0
	local newColorIndex = 0
	local newMod = root.assetJson(tileconfig.modifier).name .. findEyesColorIndex()
	
	local index = widget.getSelectedOption("selectColorRegion")
	local data = widget.getData(string.format("%s.%s", "selectColorRegion", index))
	if (root.assetJson(tileconfig.tilelist[currentTile]).paletteType == "eye") then
		data = "eye"
	end
	if (data == "bodytop" or data == "bodymid" or data == "bodybottom") then
		newTileIndex = math.floor(findBodyColorIndex() / 2)
	elseif (data == "face") then
		newTileIndex = math.floor(findFaceColorIndex() / 2)
	else
		newTileIndex = math.floor(findEyesColorIndex() / 8)
	end
	
	if (data == "bodytop" or data == "bodymid" or data == "bodybottom") then
		newColorIndex = math.fmod(findBodyColorIndex(), 2) * 4
	elseif (data == "face") then
		newColorIndex = math.fmod(findFaceColorIndex(), 2) * 4
	else
		newColorIndex = math.fmod(findEyesColorIndex(), 8)
	end
	
	if (data == "bodytop") then newColorIndex = newColorIndex
	elseif (data == "bodymid") then newColorIndex = newColorIndex + 1
	elseif (data == "bodybottom") then newColorIndex = newColorIndex + 2
	elseif (data == "face") then newColorIndex = newColorIndex + 3 end
	
	if (hasStatus("srm_eldritchracial") == false) then defaultColors = true end
	if defaultColors then
		if (data == "bodytop") then newColorIndex = 0
		elseif (data == "bodymid") then newColorIndex = 1
		elseif (data == "bodybottom") then newColorIndex = 2
		elseif (data == "face") then newColorIndex = 3
		else newColorIndex = 0 end
		newTileIndex = 0
		newMod = root.assetJson(tileconfig.modifier).name .. 0
	end
	
	if (root.assetJson(tileconfig.tilelist[currentTile]).type == "platform") then isPlatform = true else isPlatform = false end
	currentTileIndex = newTileIndex
	currentColor = getColorIndex(getColorName(newColorIndex))
	currentMod = newMod
	refreshBrushData(isPlatform, currentTileIndex, currentColor, canPlaceMod, currentMod, destroyTiles)
end

function updateDisplay()
	local index = widget.getSelectedOption("selectColorRegion")
	local data = widget.getData(string.format("%s.%s", "selectColorRegion", index))
	if (root.assetJson(tileconfig.tilelist[currentTile]).paletteType == "eye") then
		data = "eye"
	end
	widget.setText("lblTileName", root.assetJson(tileconfig.tilelist[currentTile]).cleanName)
	if defaultColors and canPlaceMod then 
		widget.setImage("currentTile", root.assetJson(tileconfig.tilelist[currentTile]).icon .. ":" .. data)
		widget.setImage("toggleMod", root.assetJson(tileconfig.modifier).icon .. ":" .. data)
	elseif defaultColors and not canPlaceMod then
		widget.setImage("currentTile", root.assetJson(tileconfig.tilelist[currentTile]).icon .. ":" .. data)
		widget.setImage("toggleMod", "/interface/scripted/srm_worldbrush/empty.png")
	elseif not defaultColors and canPlaceMod then 
		widget.setImage("currentTile", root.assetJson(tileconfig.tilelist[currentTile]).icon .. ":" .. data .. getPlayerDirectives())
		widget.setImage("toggleMod", root.assetJson(tileconfig.modifier).icon .. ":" .. data .. getPlayerDirectives())
	else
		widget.setImage("currentTile", root.assetJson(tileconfig.tilelist[currentTile]).icon .. ":" .. data .. getPlayerDirectives())
		widget.setImage("toggleMod", "/interface/scripted/srm_worldbrush/empty.png")
	end
end

function refreshBrushData(isPlatform, newTileIndex, newColor, willPlaceMod, newMod)
	world.sendEntityMessage(player.id(), "worldbrush_UIDataUpdate", root.assetJson(tileconfig.tilelist[currentTile]).name .. newTileIndex, newColor, willPlaceMod, newMod, isPlatform, destroyTiles)
end

function changeTileButton(indexChange)
	currentTile = currentTile + indexChange
	if (currentTile<1) then currentTile = #tileconfig.tilelist end
	if (currentTile>#tileconfig.tilelist) then currentTile = 1 end
end

-- UTILITY FUNCTIONS

-- Lookup tables
local colorIndices = { none = 0, red = 1, blue = 2, green = 3, yellow = 4, orange = 5, pink = 6, black = 7, white = 8 }
local colorNames = { [0] = "none", [1] = "red", [2] = "blue", [3] = "green", [4] = "yellow", [5] = "orange", [6] = "pink", [7] = "black", [8] = "white" }

-- This hurts but it works trust me
-- Gets the index of the player's selected color option for the Eyes
function findEyesColorIndex()
	directives = root.assetJson("/species/shoggoth.species:undyColor")
	s = getPlayerDirectives()
	a = "f9f0c5fe" --this value is present in all possible color options
	--b = s:find(a.."=")
	b, c = string.find(s, a .. "=")
	local step1 = string.sub(s, b, string.len(s))
	useless, step2 = string.find(step1, ";")
	b = string.sub(step1, string.len(a)+2, step2-1)
	for i = 1, #directives do
		if directives[i][a] == b then return i-1 end
	end
end

-- This hurts but it works trust me
-- Gets the index of the player's selected color option for the Face
function findFaceColorIndex()
	directives = root.assetJson("/species/shoggoth.species:bodyColor")
	s = getPlayerDirectives()
	a = "bcbce0" --this value is present in all possible color options
	--b = s:find(a .. "=")
	b, c = string.find(s, a .. "=")
	local step1 = string.sub(s, b, string.len(s))
	useless, step2 = string.find(step1, ";")
	b = string.sub(step1, string.len(a)+2, step2-1)
	for i = 1, #directives do
		if directives[i][a] == b then return i-1 end
	end
end

-- This hurts but it works trust me
-- Gets the index of the player's selected color option for the Body
function findBodyColorIndex()
	directives = root.assetJson("/species/shoggoth.species:hairColor")
	s = getPlayerDirectives()
	a = "515384" --this value is present in all possible color options
	--b = s:find(a.."=")
	b, c = string.find(s, a .. "=")
	local step1 = string.sub(s, b, string.len(s))
	useless, step2 = string.find(step1, ";")
	b = string.sub(step1, string.len(a)+2, step2-1)
	for i = 1, #directives do
		if directives[i][a] == b then return i-1 end
	end
end

-- Gets the player directives from the portraits
function getPlayerDirectives()
	local bodyDirectives = ""
	local portrait = world.entityPortrait(player.id(), "full")
	for key, value in pairs(portrait) do
		if (string.find(portrait[key].image, "body.png")) then
			local body_image =	portrait[key].image
			local directive_location = string.find(body_image, "replace")
			bodyDirectives = string.sub(body_image,directive_location)
		end
	end
	bodyDirectives = "?" .. bodyDirectives
	return bodyDirectives
end

--- Retrieves the color index of a color.
-- This color index can be used by functions such as world.setMaterialColor.
-- The index 0 represents no selected color or an invalid selection.
-- @param color Case insensitive name of the color.
-- @return Color index number.
function getColorIndex(color)
	if type(color) ~= "string" then return 0 end
	return colorIndices[color:lower()] or 0
end

--- Retrieves the color name of a color index.
-- The name "none" represents no color selection.
-- @param index Index of the color.
-- @return Lowercase color name.
function getColorName(index)
	if type(index) ~= "number" then return "none" end
	return colorNames[index] or "none"
end

--- Returns if the player has a specific status.
function hasStatus(theStatusInQuestion)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == theStatusInQuestion) then
				return true
			end
		end		 
	end
	return false
end