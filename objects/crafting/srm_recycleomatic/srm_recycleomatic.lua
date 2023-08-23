function init()
	itemConfig = {}
	currentTime = 0
	timerActive = false
	craftTime = config.getParameter("craftTime")
	containerSize = config.getParameter("slotCount")
	edgeOfInOut = config.getParameter("edgeOfInOut")
end


function update(dt)
	if not timerActive and next(world.containerItems(entity.id())) ~= nil then
		
		-- continue if any of the 9 slots are empty or has srm_rawpixel that can be further stacked
		local canRecycle = false
		local slotToGiveIn
		for slot=1,edgeOfInOut do 
			local outputSlot = world.containerItemAt(entity.id(), containerSize - slot)
			local maxStack = getItemConfig("srm_rawpixel").maxStack
			if not outputSlot or (outputSlot.name == "srm_rawpixel" and outputSlot.count < maxStack) then
				canRecycle = true
			end
		end
		
		if canRecycle then
			-- look for items in input slots
			for i = 0, containerSize - (edgeOfInOut+1) do
				local itemAtSlot = world.containerItemAt(entity.id(), i)
				if itemAtSlot then
					if checkItem(itemAtSlot) then
						timerActive = true
						startTime = world.time()
						animator.setAnimationState("recyclerState", "active")
						consumeItemAt = i
						break
					end
				end
			end
		end
	end

	if timerActive then
		timer()
	end
end


function timer()
	if currentTime < craftTime then
		currentTime = world.time() - startTime

		-- cancel if input item is no longer present
		if not world.containerItemAt(entity.id(), consumeItemAt) then
			stopTimer()
		end

	-- start crafting
	else
		stopTimer()
		crafting()
	end
	object.setConfigParameter("currentTime", currentTime)
end


function checkItem(item)
	--local slotCount = getItemConfig(item).slotCount
	--if slotCount and not item.parameters.content then
		return true
	--end
end


function crafting()
	local canRecycle = false
	local slotToGiveIn = 1
	for slot=1,edgeOfInOut do
		local inputSlot = world.containerItemAt(entity.id(), consumeItemAt)
		local outputSlot = world.containerItemAt(entity.id(), containerSize - slot)
		local maxStack = getItemConfig("srm_rawpixel").maxStack
		if inputSlot and (not outputSlot or (outputSlot.name == "srm_rawpixel" and outputSlot.count < maxStack)) then
			canRecycle = true
			slotToGiveIn = slot
		end
	end
	
	if canRecycle then

		-- randomize output count
		local outputCount = 1
		local randomNumber = math.random()
		if randomNumber <= 0.1 then
				outputCount = 3
		elseif randomNumber <= 0.5 then
				outputCount = 2
		end

		-- consume item and generate output
		world.containerConsumeAt(entity.id(), consumeItemAt, 1)
		world.containerPutItemsAt(entity.id(), { name = "srm_rawpixel", count = outputCount, parameters = {} }, containerSize - slotToGiveIn)
		consumeItemAt = nil
	end
end


function stopTimer()
	currentTime = 0
	timerActive = false
	animator.setAnimationState("recyclerState", "idle")
end

function getItemConfig(itemDesc)
	if not itemDesc then
		return
	elseif type(itemDesc) ~= "table" then
		itemDesc = {name = itemDesc, count = 1, parameters = {}}
	end
	if not itemConfig[itemDesc.name] then
		local default = root.itemConfig(itemDesc)
		-- sb.logInfo("itemConfig: %s", default)
		if default then
			itemConfig[itemDesc.name] = {
				category = default.config.category,
				craftTime = default.config.craftTime,
				inventoryIcon = default.config.inventoryIcon,
				maxStack = default.config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack"),
				price = default.config.price or 0,
				rarity = default.config.rarity,
				shortdescription = default.config.shortdescription,
				slotCount = default.config.slotCount,
				colonyTags = default.config.colonyTags
			}
		else
			itemConfig[itemDesc.name] = {}
		end
	end

	return itemConfig[itemDesc.name]
end


function tableToString(tbl)
	if type(tbl) == "table" then
		local contents = {}
		for k,v in pairs(tbl) do
			local kstr = tostring(k)
			local vstr = tostring(v)
			if type(v) == "table" and (not getmetatable(v) or not getmetatable(v).__tostring) then
				vstr = tableToString(v)
			end
			contents[#contents+1] = kstr.." = "..vstr
		end
		return "{ " .. table.concat(contents, ", ") .. " }"
	else
		return "{}"
	end
end
