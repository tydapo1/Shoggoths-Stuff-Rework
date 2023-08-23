function init()
	updateIcon()
end

function update(dt, fireMode, shiftHeld)
	if ( status.resource("energy") < status.resourceMax("energy") ) then
		if ( config.getParameter("energyAmount") > 0000 ) then
			local total = ( status.resourceMax("energy") - status.resource("energy") )
			status.giveResource("energy", total)
			local quantity = config.getParameter("energyAmount") - total
			activeItem.setInstanceValue("energyAmount", quantity)
			player.cleanupItems()
		end
	end
	
	if ((fireMode == "primary") and (not shiftHeld)) then
		if ( config.getParameter("energyAmount") < 1000 ) then
			if player.hasItemWithParameter("itemName", "liquidpoison") then
				player.consumeItemWithParameter("itemName", "liquidpoison", 1)
				local quantity = config.getParameter("energyAmount") + 1
				activeItem.setInstanceValue("energyAmount", quantity)
				player.cleanupItems()
			end
		end
	end
	
	if ((fireMode == "primary") and (shiftHeld)) then
		if ( config.getParameter("energyAmount") > 0000 ) then
			player.giveItem("liquidpoison")
			local quantity = config.getParameter("energyAmount") - 1
			activeItem.setInstanceValue("energyAmount", quantity)
			player.cleanupItems()
		end
	end
	
	updateIcon()
end

function activate(fireMode, shiftHeld)
end

function updateIcon()
	if ( config.getParameter("energyAmount") < 100 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconEmpty"))
	elseif ( ( config.getParameter("energyAmount") >= 100 ) and ( config.getParameter("energyAmount") < 200 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon10"))
	elseif ( ( config.getParameter("energyAmount") >= 200 ) and ( config.getParameter("energyAmount") < 300 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon20"))
	elseif ( ( config.getParameter("energyAmount") >= 300 ) and ( config.getParameter("energyAmount") < 400 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon30"))
	elseif ( ( config.getParameter("energyAmount") >= 400 ) and ( config.getParameter("energyAmount") < 500 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon40"))
	elseif ( ( config.getParameter("energyAmount") >= 500 ) and ( config.getParameter("energyAmount") < 600 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon50"))
	elseif ( ( config.getParameter("energyAmount") >= 600 ) and ( config.getParameter("energyAmount") < 700 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon60"))
	elseif ( ( config.getParameter("energyAmount") >= 700 ) and ( config.getParameter("energyAmount") < 800 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon70"))
	elseif ( ( config.getParameter("energyAmount") >= 800 ) and ( config.getParameter("energyAmount") < 900 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon80"))
	elseif ( ( config.getParameter("energyAmount") >= 900 ) and ( config.getParameter("energyAmount") < 1000 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon90"))
	elseif ( config.getParameter("energyAmount") >= 1000 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconFull"))
	end
end