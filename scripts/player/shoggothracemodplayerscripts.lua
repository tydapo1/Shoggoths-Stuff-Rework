require "/scripts/util.lua"
require "/scripts/rect.lua"

function init()
	organsConfig = root.assetJson("/config/srm_organs.config")
	message.setHandler("srm_warp", function(_, isItMine, location) 
		player.warp(location)
	end)
	organsWithTechConfig = {}
	for i=1,#organsConfig do
		if (organsConfig[i].hasTech == true) then
			--sb.logInfo(sb.printJson(organsConfig[i]))
			organsWithTechConfig[#organsWithTechConfig+1] = organsConfig[i] 
		end
	end
	
	script.setUpdateDelta(1)
	
	magsBeGone()
end

function update(dt)
	localAnimator = math.srm_localAnimator
	
	eldritchColoring()
	
	organEffects()
	organTech()
end



--ORGAN FUNCTIONS UNDER HERE
--ORGAN FUNCTIONS UNDER HERE
--ORGAN FUNCTIONS UNDER HERE



-- This gives the effects of the organs
function organEffects()
	if (player.getProperty("organEquipped_Head", "") ~= nil) and (player.getProperty("organEquipped_Head", "") ~= "") then 
		status.addEphemeralEffect(player.getProperty("organEquipped_Head", ""), 0.2)
	end
	if (player.getProperty("organEquipped_Back", "") ~= nil) and (player.getProperty("organEquipped_Back", "") ~= "") then 
		status.addEphemeralEffect(player.getProperty("organEquipped_Back", ""), 0.2)
	end
	if (player.getProperty("organEquipped_Chest", "") ~= nil) and (player.getProperty("organEquipped_Chest", "") ~= "") then 
		status.addEphemeralEffect(player.getProperty("organEquipped_Chest", ""), 0.2)
	end
	if (player.getProperty("organEquipped_Gut", "") ~= nil) and (player.getProperty("organEquipped_Gut", "") ~= "") then 
		status.addEphemeralEffect(player.getProperty("organEquipped_Gut", ""), 0.2)
	end
end

-- If any of the specified statuses exist then equip the tech
function organTech()
	hasRelatedStatus = false
	for i=1,#organsWithTechConfig do
		if hasStatus(organsWithTechConfig[i].name) then hasRelatedStatus = true end
	end
	if hasRelatedStatus then 
		switchEquippedTech("srm_organtech")
	else
		removeTech("srm_organtech")
	end
end

-- Gives the player a tech disk containing their old tech and equip the new one
function switchEquippedTech(tech)
	oldTech = player.equippedTech("body") or "nothing"
	if ((tech ~= oldTech) and (oldTech ~= "nothing")) then
		techdisk = Deathstate{
			parameters= {
				description = "Using this disk will give back the '" .. oldTech .. "' tech.",
				tech_to_unlock = oldTech
			},
			name = "srm_generictech",
			count = 1
		}
		player.giveItem(techdisk)
	end
	player.makeTechAvailable(tech)
	player.enableTech(tech)
	player.equipTech(tech) 
end

-- Removes the specified tech
function removeTech(tech)
	player.unequipTech(tech) 
	player.makeTechUnavailable(tech)
end

--This entire function handles coloring objects and/or items when being a valid eldritch entity.
function eldritchColoring()
	if (hasStatus("srm_eldritchracial")) then		
		--This section of the function fetches the directives from the player's portrait.
		----------------------------------------------------------------------------------------------------------------------------------------
		bodyDirectives = ""
		local portrait = world.entityPortrait(player.id(), "fullneutral")
		--sb.logInfo(sb.printJson(portrait))
		for key, value in pairs(portrait) do
			if (string.find(portrait[key].image, "body.png")) then
				local body_image =	portrait[key].image
				local directive_location = string.find(body_image, "replace")
				bodyDirectives = string.sub(body_image,directive_location)
			end
		end
		bodyDirectives = "?" .. bodyDirectives
		
		--This section handles checking if the object is a valid colorable object.
		----------------------------------------------------------------------------------------------------------------------------------------
		--sb.logInfo(sb.printJson(root.itemConfig(player.swapSlotItem()).config.shoggothColorable, 1))
		local isValid = false
		if (not (player.swapSlotItem() == nil)) then
			if (sb.printJson(root.itemConfig(player.swapSlotItem()).config.shoggothColorable, 1) == "true") then
				isValid = true
				if (player.swapSlotItem().parameters.shoggothColorable == "false") then
					isValid = false
				end
			end
		--This section handles coloring the object, and checks for various parameters to color them as well.
		----------------------------------------------------------------------------------------------------------------------------------------
			if (isValid and not mcontroller.crouching()) then
				local newItem = player.swapSlotItem()
				-- Preventing Recoloring
				newItem.parameters.shoggothColorable = "false"			
				-- Color
				newItem.parameters.color = root.itemConfig(player.swapSlotItem()).config.color .. bodyDirectives				
				-- Inventory Icon
				if (type(root.itemConfig(player.swapSlotItem()).config.inventoryIcon) == "string") then
					newItem.parameters.inventoryIcon = root.itemConfig(player.swapSlotItem()).config.inventoryIcon .. bodyDirectives	
				else
					local iconArray = root.itemConfig(player.swapSlotItem()).config.inventoryIcon
					for i=1,#iconArray do
						iconArray[i].image = iconArray[i].image .. bodyDirectives
					end
					newItem.parameters.inventoryIcon = iconArray
				end
				-- Placement Image
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.placementImage) == "null")) then
					newItem.parameters.placementImage = root.itemConfig(player.swapSlotItem()).config.placementImage .. bodyDirectives				
				end			
				-- Sit Cover Image (When Applicable)
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.sitCoverImage) == "null")) then
					newItem.parameters.sitCoverImage = root.itemConfig(player.swapSlotItem()).config.sitCoverImage .. bodyDirectives			
				end			
				-- Large Image (When Applicable)
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.largeImage) == "null")) then
					newItem.parameters.largeImage = root.itemConfig(player.swapSlotItem()).config.largeImage .. bodyDirectives			
				end			
				player.setSwapSlotItem(newItem)
			elseif (isValid and mcontroller.crouching()) then
				local newItem = player.swapSlotItem()
				-- Preventing Recoloring
				newItem.parameters.shoggothColorable = "false"			
				-- Inventory Icon
				newItem.parameters.inventoryIcon = root.itemConfig(player.swapSlotItem()).config.inventoryIcon			
				-- Color
				newItem.parameters.color = root.itemConfig(player.swapSlotItem()).config.color			
				-- Placement Image
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.placementImage) == "null")) then
					newItem.parameters.placementImage = root.itemConfig(player.swapSlotItem()).config.placementImage					
				end
				-- Sit Cover Image (When Applicable)
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.sitCoverImage) == "null")) then
					newItem.parameters.sitCoverImage = root.itemConfig(player.swapSlotItem()).config.sitCoverImage			
				end			
				-- Large Image (When Applicable)
				if (not (sb.printJson(root.itemConfig(player.swapSlotItem()).config.largeImage) == "null")) then
					newItem.parameters.largeImage = root.itemConfig(player.swapSlotItem()).config.largeImage			
				end
				player.setSwapSlotItem(newItem)
			end	
		end
	end
end

function magsBeGone()
	status.clearPersistentEffects("persistentMag")
end

--UTILITY FUNCTIONS UNDER HERE
--UTILITY FUNCTIONS UNDER HERE
--UTILITY FUNCTIONS UNDER HERE



--finds status, returns true if it is found
function hasStatus(theStatusInQuestion)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == theStatusInQuestion) then
				return true
			end
		end		 
	end
	return false
end