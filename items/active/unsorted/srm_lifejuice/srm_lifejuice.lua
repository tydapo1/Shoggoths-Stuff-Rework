function init()
	maxCapacity = 10000
	rainbowValue = 0
	updateIcon()
end

function update(dt, fireMode, shiftHeld)
	-- This regenerates energy
	if ( status.resource("energy") < status.resourceMax("energy") ) then
		if ( config.getParameter("energyAmount") > 00000 ) then
			local total = ( status.resourceMax("energy") - status.resource("energy") )
			status.giveResource("energy", total)
			local quantity = config.getParameter("energyAmount") - total
			activeItem.setInstanceValue("energyAmount", quantity)
			player.cleanupItems()
		end
	end
	-- This regenerates health
	if ( status.resource("health") < status.resourceMax("health") ) then
		if ( config.getParameter("bloodAmount") > 00000 ) then
			status.giveResource("health", 1)
			local quantity = config.getParameter("bloodAmount") - 1
			activeItem.setInstanceValue("bloodAmount", quantity)
			player.cleanupItems()
		end
	end
	-- This regenerates food
	if ( status.resource("food") < ( (status.resourceMax("food") ) ) ) then
		if ( config.getParameter("pasteAmount") > 00000 ) then
			local total = ( status.resourceMax("food") - status.resource("food") )
			status.giveResource("food", total)
			local quantity = config.getParameter("energyAmount") - total
			activeItem.setInstanceValue("energyAmount", quantity)
			player.cleanupItems()
		end
	end
	
	if ((fireMode == "primary") and (not shiftHeld)) then
		-- Energy intake
		if ( config.getParameter("energyAmount") < maxCapacity ) then
			if player.hasItemWithParameter("itemName", "liquidpoison") then
				player.consumeItemWithParameter("itemName", "liquidpoison", 1)
				local quantity = config.getParameter("energyAmount") + 1
				if quantity > maxCapacity then quantity = maxCapacity end
				activeItem.setInstanceValue("energyAmount", quantity)
				player.cleanupItems()
			end
		end
		-- Health intake
		if ( config.getParameter("bloodAmount") < maxCapacity ) then
			if player.hasItemWithParameter("liquid", "srm_liquidblood") then
				player.consumeItemWithParameter("liquid", "srm_liquidblood", 1)
				local quantity = config.getParameter("bloodAmount") + 1
				if quantity > maxCapacity then quantity = maxCapacity end
				activeItem.setInstanceValue("bloodAmount", quantity)
				player.cleanupItems()
			end
		end
		-- Food intake
		if ( config.getParameter("pasteAmount") < maxCapacity ) then
			if player.hasItemWithParameter("tooltipKind", "food") then
				local item = nil
				local hungerAmount = 0
				for foodTimer = 1,200,1 do
					if player.hasItemWithParameter("foodValue", foodTimer) then
						item = player.getItemWithParameter("foodValue", foodTimer)
						hungerAmount = foodTimer
						break
					end
				end
				item.count = 1
				player.consumeItem(item, false, true)
				local quantity = config.getParameter("pasteAmount") + hungerAmount
				if quantity > maxCapacity then quantity = maxCapacity end
				activeItem.setInstanceValue("pasteAmount", quantity)
				player.cleanupItems()
			end
		end
	elseif ((fireMode == "primary") and (shiftHeld)) then
		-- Energy outtake
		if ( config.getParameter("energyAmount") > 00000 ) then
			player.giveItem("liquidpoison")
			local quantity = config.getParameter("energyAmount") - 1
			activeItem.setInstanceValue("energyAmount", quantity)
			player.cleanupItems()
		end
		-- Health outtake
		if ( config.getParameter("bloodAmount") > 00000 ) then
			player.giveItem("srm_liquidblood")
			local quantity = config.getParameter("bloodAmount") - 1
			activeItem.setInstanceValue("bloodAmount", quantity)
			player.cleanupItems()
		end
		-- Food outtake
		if ( config.getParameter("pasteAmount") > 00049 ) then
			player.giveItem("cannedfood")
			local quantity = config.getParameter("pasteAmount") - 50
			activeItem.setInstanceValue("pasteAmount", quantity)
			player.cleanupItems()
		end
	end
	
	-- This takes care of animation
	local portion_food = math.ceil(config.getParameter("pasteAmount") / (maxCapacity/10))
	local portion_health = math.ceil(config.getParameter("bloodAmount") / (maxCapacity/10))
	local portion_energy = math.ceil(config.getParameter("energyAmount") / (maxCapacity/10))
	animator.setGlobalTag("frame_energy", portion_food)
	animator.setGlobalTag("frame_health", portion_health)
	animator.setGlobalTag("frame_food", portion_energy)
	updateIcon()
end

function activate(fireMode, shiftHeld)
end

function updateIcon()
	local frame = math.ceil((config.getParameter("energyAmount") + config.getParameter("bloodAmount") + config.getParameter("pasteAmount")) / ((maxCapacity/10)*3))
	
	rainbowValue = rainbowValue + 10
	if rainbowValue >= 360 then rainbowValue = 0 end
	
	activeItem.setInventoryIcon(
		config.getParameter("updatingIcon") .. ":" .. frame .. "?hueshift=" .. rainbowValue
	)
end