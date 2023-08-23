require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
	player.lounge(pane.sourceEntity())
	
	organConfig = root.assetJson("/config/srm_organs.config")
	organList = "organScrollArea.itemList"
	organListArray = {}
	suitImagePath = config.getParameter("suitImagePath")
	organLockedIcon = config.getParameter("organLockedIcon")
	
	defaultOrgan = {name="",parameters={},count=1}
	readyToSubsume = false
	local directives = "?replace;73daff=ede19a;27abff=dcc253;117ee4=ca8d30;1f45d4=8f3a15"
	widget.setImage("imgSuit", string.format(suitImagePath, player.species(), player.gender()) .. directives)
	
	organs = {Head={},Back={},Chest={},Gut={}}
	for i=1,#organConfig do
		--if ((player.blueprintKnown(organConfig[i].name)) or (isOrganUnlocked(organConfig[i].name))) then
			local currentOrgan = defaultOrgan
			currentOrgan.name = organConfig[i].name
			local currentItemParameters = root.itemConfig(currentOrgan).config
			organs[currentItemParameters.slot][organConfig[i].name] = root.itemConfig(currentOrgan).config
		--end
	end
	
	setSelectedSlot("Head")
end

function update(dt)
	if widget.itemSlotItem("organSubsumeSlot") ~= nil then
		local newItem = widget.itemSlotItem("organSubsumeSlot")
		if isRelevantItem(newItem.name) then
			readyToSubsume = true
		else
			readyToSubsume = false
		end
	else
		readyToSubsume = false
	end

	local head = "head"
	local back = "back"
	local chest = "chest"
	local gut = "gut"
	if player.getProperty("organEquipped_Head", "head") ~= nil then head = player.getProperty("organEquipped_Head", "head") end
	if player.getProperty("organEquipped_Back", "back") ~= nil then back = player.getProperty("organEquipped_Back", "back") end
	if player.getProperty("organEquipped_Chest", "chest") ~= nil then chest = player.getProperty("organEquipped_Chest", "chest") end
	if player.getProperty("organEquipped_Gut", "gut") ~= nil then gut = player.getProperty("organEquipped_Gut", "gut") end
	widget.setImage("organIconHead", "/items/generic/specialorgans/" .. head .. ".png")
	widget.setImage("organIconBack", "/items/generic/specialorgans/" .. back .. ".png")
	widget.setImage("organIconChest", "/items/generic/specialorgans/" .. chest .. ".png")
	widget.setImage("organIconGut", "/items/generic/specialorgans/" .. gut .. ".png")
	
	if readyToSubsume then
		widget.setButtonImages("btnEnable", {
			base = "/interface/scripted/srm_organselection/doupgrade.png:subsume",
			hover = "/interface/scripted/srm_organselection/doupgrade.png:subsume",
			pressed = "/interface/scripted/srm_organselection/doupgrade.png:subsume",
			disabled = "/interface/scripted/srm_organselection/doupgrade.png:disabled",
		})
		widget.setButtonEnabled("btnEnable", true)
	else
		local listItem = widget.getListSelected(organList)
		local organName = widget.getData(string.format("%s.%s", organList, listItem))
		if (organName == player.getProperty("organEquipped_" .. widget.getSelectedData("organSlotGroup"), "")) then
			widget.setButtonImages("btnEnable", {
				base = "/interface/scripted/srm_organselection/doupgrade.png:remove",
				hover = "/interface/scripted/srm_organselection/doupgrade.png:remove",
				pressed = "/interface/scripted/srm_organselection/doupgrade.png:remove",
				disabled = "/interface/scripted/srm_organselection/doupgrade.png:disabled",
			})
		else
			widget.setButtonImages("btnEnable", {
				base = "/interface/scripted/srm_organselection/doupgrade.png:install",
				hover = "/interface/scripted/srm_organselection/doupgrade.png:install",
				pressed = "/interface/scripted/srm_organselection/doupgrade.png:install",
				disabled = "/interface/scripted/srm_organselection/doupgrade.png:disabled",
			})
		end
		widget.setButtonEnabled("btnEnable", isOrganUnlocked(organName))
	end
end

function uninit()
	if widget.itemSlotItem("organSubsumeSlot") ~= nil then
		player.giveItem(widget.itemSlotItem("organSubsumeSlot"))
	end
end

function doEnable()
	if readyToSubsume then
		local slot = "organSubsumeSlot"
		local subsumedOrgan = widget.itemSlotItem(slot).name
		widget.playSound("/sfx/objects/organsubsumed.ogg")
		unlockOrgan(subsumedOrgan)
		widget.setItemSlotItem(slot,nil)
		local currentOrgan = defaultOrgan
		currentOrgan.name = subsumedOrgan
		local currentItemParameters = root.itemConfig(currentOrgan).config
		equipOrgan(subsumedOrgan)
		widget.setSelectedOption("organSlotGroup", getIndex(currentItemParameters.slot))
		widget.setListSelected(organList, organListArray[subsumedOrgan])
		local shortdescription = string.sub(currentItemParameters.shortdescription, 23, -1)
		widget.setText(string.format("%s.%s.organName", organList, widget.getListSelected(organList)), shortdescription)
		widget.setImage(string.format("%s.%s.organIcon", organList, widget.getListSelected(organList)), "/items/generic/specialorgans/" .. currentItemParameters.inventoryIcon .. "?scalebilinear=0.5")
	else
		equipOrgan(widget.getData(string.format("%s.%s", organList, widget.getListSelected(organList))))
		widget.playSound("/sfx/objects/organswap.ogg")
	end
end

function organSelected()
	local listItem = widget.getListSelected(organList)
	if listItem then
		local organName = widget.getData(string.format("%s.%s", organList, listItem))
		setSelectedOrgan(organName)
	end
end

function organSlotGroup(button, slot)
	setSelectedSlot(slot)
	--sb.logInfo(sb.printJson(slot .. " : " .. widget.getSelectedOption("organSlotGroup")))
end

function organSubsumeSlot(slot)
	--sb.logInfo(slot)
	if (player.swapSlotItem() or widget.itemSlotItem(slot)) then
		local toSwapSlot = widget.itemSlotItem(slot)
		local toWidgetSlot = player.swapSlotItem()
		widget.setItemSlotItem(slot,toWidgetSlot)
		player.setSwapSlotItem(toSwapSlot)
	end
end





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--INTERFACE FUNCTIONS---------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getListOrgan(organName)
	widget.getData(string.format("%s.%s", organList, listItem))
end

function equipOrgan(organName)
	local currentItemParameters = root.itemConfig(organName).config
	if player.getProperty("organEquipped_" .. currentItemParameters.slot, "") == organName then
		player.setProperty("organEquipped_" .. currentItemParameters.slot, nil)
	else
		player.setProperty("organEquipped_" .. currentItemParameters.slot, organName)
	end
end

function setSelectedOrgan(organName)
	local currentItemParameters = root.itemConfig(organName).config
	if (isOrganUnlocked(organName) or player.blueprintKnown(organName)) then
		widget.setText("lblDescription", currentItemParameters.description)
	else
		widget.setText("lblDescription", "Find this organ's recipe to unlock it's name and description.")
	end
end

function setSelectedSlot(slot)
	widget.setText("lblDescription", config.getParameter("selectOrganDescription"))
	widget.setText("lblSlot", config.getParameter("slotLabelText")[slot])
	
	getOrgansFromSlot(slot)

	-- Sets visible if the condition is true.
	widget.setVisible("imgSelectedHead", slot == "Head")
	widget.setVisible("imgSelectedBack", slot == "Back")
	widget.setVisible("imgSelectedChest", slot == "Chest")
	widget.setVisible("imgSelectedGut", slot == "Gut")
end

function getOrgansFromSlot(slot)
	widget.clearListItems(organList)
	organListArray = {}
	
	local organsToPopulate = organs[slot]

	for _,organInstanceParameters in pairs(organsToPopulate) do
		local listItem = widget.addListItem(organList)
		local name = string.sub(organInstanceParameters.shortdescription, 23, -1)
		widget.setData(string.format("%s.%s", organList, listItem), organInstanceParameters.itemName)
		organListArray[organInstanceParameters.itemName] = listItem
		if isOrganUnlocked(organInstanceParameters.itemName) then
			widget.setImage(string.format("%s.%s.organIcon", organList, listItem), "/items/generic/specialorgans/" .. organInstanceParameters.inventoryIcon .. "?scalebilinear=0.5")
			widget.setText(string.format("%s.%s.organName", organList, listItem), name)
		elseif player.blueprintKnown(organInstanceParameters.itemName) then
			widget.setImage(string.format("%s.%s.organIcon", organList, listItem), organLockedIcon)
			widget.setText(string.format("%s.%s.organName", organList, listItem), name)
		else
			widget.setImage(string.format("%s.%s.organIcon", organList, listItem), organLockedIcon)
			widget.setText(string.format("%s.%s.organName", organList, listItem), "???")
		end
		if player.getProperty("organEquipped_" .. slot, "") == organInstanceParameters.itemName then
			widget.setListSelected(organList, listItem)
		end
	end
end

function isOrganUnlocked(organName)
	local isUnlocked = false
	local unlockedArray = player.getProperty("organsUnlocked", {})
	if (not (unlockedArray[organName] == nil)) then
		if (unlockedArray[organName] == "true") then
			isUnlocked = true
		end
	end
	return isUnlocked
end

function isRelevantItem(itemName)
	local isRelevant = false
	for i=1,#organConfig do
		if (itemName == organConfig[i].name) then
			isRelevant = true
		end
	end
	return isRelevant
end

function unlockOrgan(subsumedOrgan)
	--sb.logInfo(sb.printJson(subsumedOrgan))
	local unlockedArray = player.getProperty("organsUnlocked", {})
	unlockedArray[subsumedOrgan] = "true"
	player.setProperty("organsUnlocked", unlockedArray)
end

function getIndex(slot)
	local index = -1
	if slot=="Head" then index=-1 end
	if slot=="Back" then index=0 end
	if slot=="Chest" then index=1 end
	if slot=="Gut" then index=2 end
	return index
end