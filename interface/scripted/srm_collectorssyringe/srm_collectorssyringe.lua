function init()
	--refreshBrushData(isPlatform, currentTileIndex, currentColor, canPlaceMod, currentMod)
	--updateData()
	--updateDisplay()
end

function update()
	widget.setText("lblCurrency", "^cyan;" .. player.currency("srm_deadcells") .. "^reset;")
	widget.setText("lblCurrencyShadow", "^black;" .. player.currency("srm_deadcells") .. "^reset;")
	if (widget.itemSlotItem("tileSlot")) then
		local totalSpent = 0
		totalSpent = (widget.itemSlotItem("tileSlot")).parameters.cellsConsumed or 0
		local upgradeCost = calculateUpgradeCost(totalSpent)
		local damageBonus = calculateDamageBonus(totalSpent)
		widget.setText("statsTotalSpent", "^cyan;" .. totalSpent .. "^reset;")
		widget.setText("statsTotalSpentShadow", "^black;" .. totalSpent .. "^reset;")
		widget.setText("statsUpgradeCost", "^yellow;" .. upgradeCost .. "^reset;")
		widget.setText("statsUpgradeCostShadow", "^black;" .. upgradeCost .. "^reset;")
		widget.setText("statsDamageBonus", "^red;" .. damageBonus .. "%^reset;")
		widget.setText("statsDamageBonusShadow", "^black;" .. damageBonus .. "%^reset;")
	else
		widget.setText("statsTotalSpent", "^cyan;" .. "x" .. "^reset;")
		widget.setText("statsTotalSpentShadow", "^black;" .. "x" .. "^reset;")
		widget.setText("statsUpgradeCost", "^yellow;" .. "x" .. "^reset;")
		widget.setText("statsUpgradeCostShadow", "^black;" .. "x" .. "^reset;")
		widget.setText("statsDamageBonus", "^red;" .. "x" .. "%^reset;")
		widget.setText("statsDamageBonusShadow", "^black;" .. "x" .. "%^reset;")
	end
end

function uninit()
	if widget.itemSlotItem("tileSlot") ~= nil then
		player.giveItem(widget.itemSlotItem("tileSlot"))
	end
end

function tileSlot(slot)
	if (not player.swapSlotItem() and not widget.itemSlotItem(slot)) then 
		--do nothing because both the slot and the held is empty
	elseif (player.swapSlotItem() or widget.itemSlotItem(slot)) then
		local toSwapSlot = widget.itemSlotItem(slot)
		local toWidgetSlot = player.swapSlotItem()
		widget.setItemSlotItem(slot,toWidgetSlot)
		player.setSwapSlotItem(toSwapSlot)
	end
end

function textfield()
	local amnt = tonumber(widget.getText("textfield")) or 0
	if (amnt > player.currency("srm_deadcells")) then
		widget.setText("textfield", player.currency("srm_deadcells"))
	end
end

function btnJuiceup()
	local newItem = widget.itemSlotItem("tileSlot")
	local amnt = tonumber(widget.getText("textfield")) or 0
	if (amnt ~= 0) then
		if (not newItem.parameters.cellsConsumed) then
			newItem.parameters.cellsConsumed = 0
		end
		newItem.parameters.cellsConsumed = newItem.parameters.cellsConsumed + amnt
		if (not newItem.parameters.oldDescription) then
			newItem.parameters.oldDescription = root.itemConfig(newItem).config.description
		end
		newItem.parameters.description = newItem.parameters.oldDescription .. " ^cyan;" .. newItem.parameters.cellsConsumed .. " Cells Consumed.^reset;"
		widget.setItemSlotItem("tileSlot",newItem)
		player.consumeCurrency("srm_deadcells", amnt)
		textfield()
		widget.playSound("/sfx/objects/pick_power.ogg")
	end
end

function calculateUpgradeCost(currentAmount)
	-- \left(y+10\right)^2-100=x
	return (math.floor((((calculateDamageBonus(currentAmount)+1)+10)^2-100)+0.5) - math.floor((((calculateDamageBonus(currentAmount))+10)^2-100)+0.5))
end

function calculateDamageBonus(currentAmount)
	-- y=\sqrt{x+100\:}-10
	return round((math.sqrt(currentAmount+100)-10),3)
end



-- UTILITY FUNCTIONS



--- Returns if the player has a specific status.
function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end