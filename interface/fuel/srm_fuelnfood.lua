require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
	meterCanvas = widget.bindCanvas("foodCanvas")
	meter = "/interface/fuel/foodgauge.png"
	greenMeter = "/interface/fuel/foodgaugegreen.png"
	milestoneList = config.getParameter("upgradeMilestones")
	--sb.logInfo(sb.printJson(milestoneList))
	maxFuel = player.shipUpgrades().maxFuel
	maxFood = 0
	for _, milestone in pairs(milestoneList) do
		--sb.logInfo(sb.printJson(milestone))
		if milestone.foodCost > maxFood then maxFood = milestone.foodCost end
	end
end

function update(dt)
	widget.setText("foodMeter", "Food " .. calculateFoodPreview() .. "/" .. maxFood)
	local milestones = world.getProperty("ship.srm_milestones", {})
	local lowestMilestoneKey = nil
	local lowestMilestoneAmount = maxFood
	
	local fuel = world.getProperty("ship.fuel", 0)
	local food = world.getProperty("ship.srm_food", 0)
	
	--sb.logInfo("Determining if available for upgrade: ")
	for k, milestone in pairs(milestoneList) do
		if ((food >= milestone.foodCost) and (milestones[k] == nil)) then 
			milestones[k] = true
			player.giveItem(milestone.item)
		end
	end
	--sb.logInfo("Determining the lowest: ")
	for k, milestone in pairs(milestoneList) do
		if ((milestone.foodCost <= lowestMilestoneAmount) and (milestones[k] == nil)) then 
			--sb.logInfo(sb.printJson(milestone))
			lowestMilestoneAmount = milestone.foodCost 
			lowestMilestoneKey = k 
		end
	end
	if lowestMilestoneKey then
		widget.setText("milestoneLabel", "The next feeding milestone is at " .. milestoneList[lowestMilestoneKey].foodCost .. " food and will award: ")
		widget.setItemSlotItem("tileSlot",{name=milestoneList[lowestMilestoneKey].item,count=1})
	else
		widget.setText("milestoneLabel", "All milestones cleared!")
		widget.setItemSlotItem("tileSlot",nil)
	end
	world.setProperty("ship.srm_milestones", milestones)
	
	meterCanvas:clear()
	local proportion = math.floor((food/maxFood)*115)
	local proportionGreen = math.floor((calculateFoodPreview()/maxFood)*115)
	meterCanvas:drawImageRect(greenMeter, {0,0,proportionGreen,5}, {0,0,proportionGreen,5})
	meterCanvas:drawImageRect(meter, {0,0,proportion,5}, {0,0,proportion,5})
end

function uninit()
end

function feed()
	--sb.logInfo("Button OK!")
	local milestones = world.getProperty("ship.srm_milestones", {})
	
	local fuel = world.getProperty("ship.fuel", 0)
	local food = world.getProperty("ship.srm_food", 0)
	
	for i=0,5 do
		-- This is where we check for if it's food or fuel.
		local item = world.containerItemAt(pane.containerEntityId(), i)
		if item then
			local itemConfiguration = root.itemConfig(item).config
		
			if (itemConfiguration.fuelAmount) then
				-- We could consume this item for fuel.
				--sb.logInfo("Fuel found!")
				if fuel <= maxFuel then
					-- We should consume this item for fuel.
					--sb.logInfo("Ready to consume fuel!")
				
					if (fuel + (item.count * itemConfiguration.fuelAmount)) <= maxFuel then
						--sb.logInfo("Consuming full fuel stack...")
						local newFuel = (fuel + (item.count * itemConfiguration.fuelAmount))
						world.containerConsumeAt(pane.containerEntityId(), i, item.count)
						world.setProperty("ship.fuel", newFuel)
						fuel = newFuel
					else
						--sb.logInfo("Consuming partial fuel stack...")
						local itemCount = 0
						local newFuel = 0
						for j=item.count,0,-1 do
							if (j * itemConfiguration.fuelAmount) < (maxFuel-fuel) then
								itemCount = j + 1
								newFuel = (fuel + (itemCount * itemConfiguration.fuelAmount))
								break
							end
						end
						if newFuel > maxFuel then newFuel = maxFuel end
						world.containerConsumeAt(pane.containerEntityId(), i, itemCount)
						world.setProperty("ship.fuel", newFuel)
						fuel = newFuel
					end
				end
			elseif (itemConfiguration.foodValue) then
				-- We could consume this item for food.
				--sb.logInfo("Food found!")
				if food <= maxFood then
					-- We should consume this item for food.
					--sb.logInfo("Ready to consume food!")
				
					if (food + (item.count * itemConfiguration.foodValue)) <= maxFood then
						--sb.logInfo("Consuming full food stack...")
						local newFood = (food + (item.count * itemConfiguration.foodValue))
						world.containerConsumeAt(pane.containerEntityId(), i, item.count)
						world.setProperty("ship.srm_food", newFood)
						food = newFood
					else
						--sb.logInfo("Consuming partial food stack...")
						local itemCount = 0
						local newFood = 0
						for j=item.count,0,-1 do
							if (j * itemConfiguration.foodValue) < (maxFood-food) then
								itemCount = j + 1
								newFood = (food + (itemCount * itemConfiguration.foodValue))
								break
							end
						end
						if newFood > maxFood then newFood = maxFood end
						world.containerConsumeAt(pane.containerEntityId(), i, itemCount)
						world.setProperty("ship.srm_food", newFood)
						food = newFood
					end
				end
			else
				--sb.logInfo("Non-relevant item found.")
			end
		end
	end
end

function calculateFoodPreview()
	local number = world.getProperty("ship.srm_food", 0)
	for i=0,5 do
		local item = world.containerItemAt(pane.containerEntityId(), i)
		if item then
			local itemConfiguration = root.itemConfig(item).config
			if (itemConfiguration.foodValue) then
				if number <= maxFood then
					if (number + (item.count * itemConfiguration.foodValue)) <= maxFood then
						local newFood = (item.count * itemConfiguration.foodValue)
						number = number + newFood
					else
						local itemCount = 0
						local newFood = 0
						for j=item.count,0,-1 do
							if (j * itemConfiguration.foodValue) < (maxFood-number) then
								itemCount = j + 1
								newFood = (itemCount * itemConfiguration.foodValue)
								break
							end
						end
						number = number + newFood
					end
				end
			end
		end
	end
	if number > maxFood then number = maxFood end
	return number
end

function tileSlot(slot)
end