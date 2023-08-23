function init()
	updateIcon()
end

function update(dt, fireMode, shiftHeld)
	if ( status.resource("health") < status.resourceMax("health") ) then
		if ( config.getParameter("bloodAmount") > 0001 ) then
			status.giveResource("health", 2)
			local quantity = config.getParameter("bloodAmount") - 2
			activeItem.setInstanceValue("bloodAmount", quantity)
			player.cleanupItems()
		end
	end
	
	if ((fireMode == "primary") and (not shiftHeld)) then
		if ( config.getParameter("bloodAmount") < 1000 ) then
			if player.hasItemWithParameter("liquid", "srm_liquidblood") then
				player.consumeItemWithParameter("liquid", "srm_liquidblood", 1)
				local quantity = config.getParameter("bloodAmount") + 1
				activeItem.setInstanceValue("bloodAmount", quantity)
				player.cleanupItems()
			end
		end
	end
	
	if ((fireMode == "primary") and (shiftHeld)) then
		if ( config.getParameter("bloodAmount") > 0000 ) then
			player.giveItem("srm_liquidblood")
			local quantity = config.getParameter("bloodAmount") - 1
			activeItem.setInstanceValue("bloodAmount", quantity)
			player.cleanupItems()
		end
	end
	
	updateIcon()
end

function activate(fireMode, shiftHeld)
end

function updateIcon()
	if ( config.getParameter("bloodAmount") < 100 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconEmpty"))
	elseif ( ( config.getParameter("bloodAmount") >= 100 ) and ( config.getParameter("bloodAmount") < 200 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon10"))
	elseif ( ( config.getParameter("bloodAmount") >= 200 ) and ( config.getParameter("bloodAmount") < 300 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon20"))
	elseif ( ( config.getParameter("bloodAmount") >= 300 ) and ( config.getParameter("bloodAmount") < 400 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon30"))
	elseif ( ( config.getParameter("bloodAmount") >= 400 ) and ( config.getParameter("bloodAmount") < 500 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon40"))
	elseif ( ( config.getParameter("bloodAmount") >= 500 ) and ( config.getParameter("bloodAmount") < 600 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon50"))
	elseif ( ( config.getParameter("bloodAmount") >= 600 ) and ( config.getParameter("bloodAmount") < 700 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon60"))
	elseif ( ( config.getParameter("bloodAmount") >= 700 ) and ( config.getParameter("bloodAmount") < 800 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon70"))
	elseif ( ( config.getParameter("bloodAmount") >= 800 ) and ( config.getParameter("bloodAmount") < 900 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon80"))
	elseif ( ( config.getParameter("bloodAmount") >= 900 ) and ( config.getParameter("bloodAmount") < 1000 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon90"))
	elseif ( config.getParameter("bloodAmount") >= 1000 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconFull"))
	end
end