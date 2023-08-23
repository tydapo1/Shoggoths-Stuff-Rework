function init()
	updateIcon()
end

function update(dt, fireMode, shiftHeld)
	if ( status.resource("food") < ( (status.resourceMax("food") ) -4 ) ) then
		if ( config.getParameter("pasteAmount") > 0004 ) then
			status.giveResource("food", 5)
			local quantity = config.getParameter("pasteAmount") - 5
			activeItem.setInstanceValue("pasteAmount", quantity)
			player.cleanupItems()
		end
	end
	
	if ((fireMode == "primary") and (not shiftHeld)) then
		if ( config.getParameter("pasteAmount") < 1000 ) then
			if player.hasItemWithParameter("tooltipKind", "food") then
				local item = player.getItemWithParameter("tooltipKind", "food")
				local hungerAmount = 5
				for foodTimer = 1,200,1 do
					if player.hasItemWithParameter("foodValue", foodTimer) then
						item = player.getItemWithParameter("foodValue", foodTimer)
						hungerAmount = foodTimer
					end
				end
				item.count = 1
				sb.logInfo(sb.printJson(item, 1))
				player.consumeItem(item, false, true)
				local quantity = config.getParameter("pasteAmount") + hungerAmount
				activeItem.setInstanceValue("pasteAmount", quantity)
				player.cleanupItems()
			end
		end
	end
	
	if ((fireMode == "primary") and (shiftHeld)) then
		if ( config.getParameter("pasteAmount") > 0049 ) then
			player.giveItem("cannedfood")
			local quantity = config.getParameter("pasteAmount") - 50
			activeItem.setInstanceValue("pasteAmount", quantity)
			player.cleanupItems()
		end
	end
	
	updateIcon()
end

function activate(fireMode, shiftHeld)
end

function updateIcon()
	if ( config.getParameter("pasteAmount") < 100 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconEmpty"))
	elseif ( ( config.getParameter("pasteAmount") >= 100 ) and ( config.getParameter("pasteAmount") < 200 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon10"))
	elseif ( ( config.getParameter("pasteAmount") >= 200 ) and ( config.getParameter("pasteAmount") < 300 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon20"))
	elseif ( ( config.getParameter("pasteAmount") >= 300 ) and ( config.getParameter("pasteAmount") < 400 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon30"))
	elseif ( ( config.getParameter("pasteAmount") >= 400 ) and ( config.getParameter("pasteAmount") < 500 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon40"))
	elseif ( ( config.getParameter("pasteAmount") >= 500 ) and ( config.getParameter("pasteAmount") < 600 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon50"))
	elseif ( ( config.getParameter("pasteAmount") >= 600 ) and ( config.getParameter("pasteAmount") < 700 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon60"))
	elseif ( ( config.getParameter("pasteAmount") >= 700 ) and ( config.getParameter("pasteAmount") < 800 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon70"))
	elseif ( ( config.getParameter("pasteAmount") >= 800 ) and ( config.getParameter("pasteAmount") < 900 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon80"))
	elseif ( ( config.getParameter("pasteAmount") >= 900 ) and ( config.getParameter("pasteAmount") < 1000 ) ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIcon90"))
	elseif ( config.getParameter("pasteAmount") >= 1000 ) then
		activeItem.setInventoryIcon(config.getParameter("inventoryIconFull"))
	end
end