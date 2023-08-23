function init()
	itemConfig = {}
	craftTime = world.getObjectParameter(pane.containerEntityId(), "craftTime") or 2
	edgeOfInOut = world.getObjectParameter(pane.containerEntityId(), "edgeOfInOut") or 2
end


function update(dt)
	currentTime = world.getObjectParameter(pane.containerEntityId(), "currentTime") or 0
	widget.setProgress("prgTime", currentTime / craftTime)

	denyInvalidItems()
end


function denyInvalidItems()
	-- check for items in input slots
	local containerSize = world.getObjectParameter(pane.containerEntityId(), "slotCount")
	for i = 0, containerSize - (edgeOfInOut+1) do
		validItem = false
		local itemAtSlot = world.containerItemAt(pane.containerEntityId(), i)
		if itemAtSlot then

			-- set proper item to valid item 
			--local slotCount = getItemConfig(itemAtSlot).slotCount
			--if slotCount and not itemAtSlot.parameters.content then
				validItem = true
				--break
			--end

			-- give back invalid items
			if not validItem then
				world.containerConsume(pane.containerEntityId(), itemAtSlot)
				player.giveItem(itemAtSlot)
			end
		end
	end
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
