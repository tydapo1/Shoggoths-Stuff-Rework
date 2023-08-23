function init()
	techConfig = root.assetJson("/tech/srm_extraarmstech/srm_extraarmstech.tech")
	armsList = mergeArrays(techConfig.extraarmstech_leftOrder, techConfig.extraarmstech_rightOrder)
	armsScripts = mergeArrays(techConfig.extraarmstech_leftOptions, techConfig.extraarmstech_rightOptions)
	
	currentArm = 1
	updateData()
end

function update()
end

function uninit()
end

function lastArmButton()
	changeArmButton(-1)
	updateData()
end

function nextArmButton()
	changeArmButton(1)
	updateData()
end

function equippedLeftCheck()
	player.setProperty("extraarms_enabled_left_" .. armsList[currentArm], widget.getChecked("isLeftEquipped"))
	updateData()
end

function equippedRightCheck()
	player.setProperty("extraarms_enabled_right_" .. armsList[currentArm], widget.getChecked("isRightEquipped"))
	updateData()
end

function updateData()
	widget.setText("lblArmName", "^shadow;" .. cleanString(armsList[currentArm]) .. "Arm^reset;")
	local leftOrRight = "left"
	if (techConfig.extraarmstech_rightOptions[armsList[currentArm]]) then
		leftOrRight = "right"
	end
	widget.setImage("currentArm", "/tech/srm_extraarmstech/" .. leftOrRight .. "/" .. armsList[currentArm] .. ".png:idle" .. fetchMechDirectives())
	local leftEquipped = "Unequipped"
	if (player.getProperty("extraarms_enabled_left_" .. armsList[currentArm], true)) then leftEquipped = "Equipped" end
	widget.setChecked("isLeftEquipped", player.getProperty("extraarms_enabled_left_" .. armsList[currentArm], false))
	widget.setText("lblIsLeftEquipped", "^shadow;" .. leftEquipped .. "^reset;")
	local rightEquipped = "Unequipped"
	if (player.getProperty("extraarms_enabled_right_" .. armsList[currentArm], true)) then rightEquipped = "Equipped" end
	widget.setChecked("isRightEquipped", player.getProperty("extraarms_enabled_right_" .. armsList[currentArm], false))
	widget.setText("lblIsRightEquipped", "^shadow;" .. rightEquipped .. "^reset;")
end

function changeArmButton(indexChange)
	currentArm = currentArm + indexChange
	if (currentArm<1) then currentArm = #armsList end
	if (currentArm>#armsList) then currentArm = 1 end
	while (not player.getProperty("extraarms_unlock_" .. armsList[currentArm], false)) do
		if indexChange == 0 then indexChange = 1 end
		currentArm = currentArm + indexChange
		if (currentArm<1) then currentArm = #armsList end
		if (currentArm>#armsList) then currentArm = 1 end
	end
end

-- UTILITY FUNCTIONS
function mergeArrays(leftArms, rightArms)
	local indexTotal = #leftArms + #rightArms
	local mergedArray = {}
	for i=1,indexTotal do
		if i > #leftArms then
			mergedArray[i] = rightArms[(i-#leftArms)]
		else
			mergedArray[i] = leftArms[i]
		end
	end
	local sortedArray = {}
	for i=1,#mergedArray do
		if i == 1 then
			sortedArray[#sortedArray+1] = mergedArray[i]
		else
			local unique = true
			for j=1,#sortedArray do
				if mergedArray[i] == sortedArray[j] then unique = false end
			end
			if unique then sortedArray[#sortedArray+1] = mergedArray[i] end
		end
	end
	return sortedArray
end

function cleanString(str)
	local stringArray = split(str, "_")
	local cleanedStr = ""
	for i=1,#stringArray do
		cleanedStr = cleanedStr .. firstToUpper(stringArray[i]) .. " "
	end
	return cleanedStr
end

function firstToUpper(str)
	return string.upper(string.sub(str,1,1)) .. string.sub(str,2,string.len(str))
end

function split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

function fetchMechDirectives()
	local getColorIndexesMessage = world.sendEntityMessage(player.id(), "getMechColorIndexes")
	if getColorIndexesMessage:finished() and getColorIndexesMessage:succeeded() then
		local res = getColorIndexesMessage:result()
		self.primaryColorIndex = res.primary
		self.secondaryColorIndex = res.secondary
	else
		sb.logError("Mech assembly interface unable to fetch player mech paint colors!")
	end
	local directives = ""
	if (self.primaryColorIndex) then
		local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
		local toColors = paletteConfig.swapSets[self.primaryColorIndex]
		for i, fromColor in ipairs(paletteConfig.primaryMagicColors) do
			if (toColors == nil) then 
				directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
			else
				directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
			end
		end
		--`directives` would be ?replace=111=222?replace=333=444...
	end
	if (self.secondaryColorIndex) then
		local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
		local toColors = paletteConfig.swapSets[self.secondaryColorIndex]
		for i, fromColor in ipairs(paletteConfig.secondaryMagicColors) do
			if (toColors == nil) then 
				directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
			else
				directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
			end
		end
		--`directives` would be ?replace=111=222?replace=333=444...
	end
	return directives
end