require "/scripts/status.lua"

function init()
	script.setUpdateDelta(15)
	magTables = root.assetJson("/config/srm_mag.config")
	
	beamedIn = true
	onlyPBOnce = true
	status.setResourcePercentage("srm_magPB", 0)
	magId_mag = nil
	magId_magFullbright = nil
	magId_magFlip = nil
	magId_magFullbrightFlip = nil
	lastEvo = nil
	directives = ""
	switchDirection = true
	turnOffset = 0
	sinValue = 0
	maxDelay = 10
	queryDamageSince = 0
	inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)
	posHistory = {}
	for i=1,maxDelay do
		posHistory[i] = entity.position()
	end
	magStatGroup = effect.addStatModifierGroup({
		{ stat = "maxHealth", amount = 0 },
		{ stat = "powerMultiplier", amount = 0 },
		{ stat = "fallDamageMultiplier", effectiveMultiplier = 0 },
		{ stat = "maxEnergy", amount = 0 }
	})
end

function update(dt)
	player = math.srm_player
	mechDirectives()
	inflictedDamage:update()
	
	--sb.logInfo(sb.printJson(player.getProperty("magEquipped", nil)))
	local mag = player.getProperty("magEquipped", nil)
	if ((not mag.parameters.magForm) or 
		(not mag.parameters.synchro) or 
		(not mag.parameters.iq) or 
		(not mag.parameters.def) or 
		(not mag.parameters.pow) or 
		(not mag.parameters.dex) or 
		(not mag.parameters.mind) or 
		(not mag.parameters.defMeter) or 
		(not mag.parameters.powMeter) or 
		(not mag.parameters.dexMeter) or 
		(not mag.parameters.mindMeter) or 
		(not mag.parameters.pbAttack1) or 
		(not mag.parameters.pbAttack2) or 
		(not mag.parameters.pbAttack3)) then
		mag.parameters.magForm = root.itemConfig({name="srm_mag",count=1}).config.magForm
		mag.parameters.synchro = root.itemConfig({name="srm_mag",count=1}).config.synchro
		mag.parameters.iq = root.itemConfig({name="srm_mag",count=1}).config.iq
		mag.parameters.def = root.itemConfig({name="srm_mag",count=1}).config.def
		mag.parameters.pow = root.itemConfig({name="srm_mag",count=1}).config.pow
		mag.parameters.dex = root.itemConfig({name="srm_mag",count=1}).config.dex
		mag.parameters.mind = root.itemConfig({name="srm_mag",count=1}).config.mind
		mag.parameters.defMeter = root.itemConfig({name="srm_mag",count=1}).config.defMeter
		mag.parameters.powMeter = root.itemConfig({name="srm_mag",count=1}).config.powMeter
		mag.parameters.dexMeter = root.itemConfig({name="srm_mag",count=1}).config.dexMeter
		mag.parameters.mindMeter = root.itemConfig({name="srm_mag",count=1}).config.mindMeter
		mag.parameters.pbAttack1 = root.itemConfig({name="srm_mag",count=1}).config.pbAttack1
		mag.parameters.pbAttack2 = root.itemConfig({name="srm_mag",count=1}).config.pbAttack2
		mag.parameters.pbAttack3 = root.itemConfig({name="srm_mag",count=1}).config.pbAttack3
		player.setProperty("magEquipped", mag)
	end
	effect.setStatModifierGroup(magStatGroup, {
		{ stat = "maxHealth", amount = mag.parameters.def },
		{ stat = "powerMultiplier", amount = mag.parameters.pow/100 },
		{ stat = "fallDamageMultiplier", effectiveMultiplier = (200-mag.parameters.dex)/200 },
		{ stat = "maxEnergy", amount = mag.parameters.mind }
	})
	mcontroller.controlModifiers({ speedModifier = (mag.parameters.dex/100+1) })
	mcontroller.controlModifiers({ airJumpModifier = (mag.parameters.dex/100+1) })
	
	if magId_mag then 
		if not world.entityExists(magId_mag) then 
			magId_mag = nil 
		else
			world.sendEntityMessage(magId_mag,"ownerFacing", mcontroller.facingDirection())
		end 
	end
	if magId_magFullbright then 
		if not world.entityExists(magId_magFullbright) then 
			magId_magFullbright = nil 
		else
			world.sendEntityMessage(magId_magFullbright,"ownerFacing", mcontroller.facingDirection())
		end 
	end
	if magId_magFlip then 
		if not world.entityExists(magId_magFlip) then 
			magId_magFlip = nil 
		else 
			world.sendEntityMessage(magId_magFlip,"ownerFacing", mcontroller.facingDirection())
		end 
	end
	if magId_magFullbrightFlip then 
		if not world.entityExists(magId_magFullbrightFlip) then 
			magId_magFullbrightFlip = nil 
		else
			world.sendEntityMessage(magId_magFullbrightFlip,"ownerFacing", mcontroller.facingDirection())
		end
	end
	
	if (status.resourcePercentage("srm_magPB") >= 1.0) and onlyPBOnce then
		onlyPBOnce = false
		trigger(mag, "fullPBTrigger")
	elseif (status.resourcePercentage("srm_magPB") < 1.0) then
		onlyPBOnce = true
	end
	local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
	queryDamageSince = nextStep
	for _, notification in ipairs(damageNotifications) do
		if notification.healthLost >= (status.resourceMax("health")/5) and notification.sourceEntityId ~= notification.targetEntityId then
			trigger(mag, "heavyDamageTrigger")
			break
		end
		if notification.healthLost > 0 then
			local valueToGive = defensePB(notification.healthLost)
			status.modifyResourcePercentage("srm_magPB", valueToGive)
		end
	end
	if beamedIn then
		beamedIn = false
		trigger(mag, "beamingTrigger")
	end
	
	local evo = mag.parameters.magForm
	if not lastEvo then lastEvo = evo end
	if lastEvo ~= evo then 
		if magId_mag then if world.entityExists(magId_mag) then world.sendEntityMessage(magId_mag,"die") magId_mag = nil end end
		if magId_magFullbright then if world.entityExists(magId_magFullbright) then world.sendEntityMessage(magId_magFullbright,"die") magId_magFullbright = nil end end
		if magId_magFlip then if world.entityExists(magId_magFlip) then world.sendEntityMessage(magId_magFlip,"die") magId_magFlip = nil end end
		if magId_magFullbrightFlip then if world.entityExists(magId_magFullbrightFlip) then world.sendEntityMessage(magId_magFullbrightFlip,"die") magId_magFullbrightFlip = nil end end
	end
		
	if (not magId_mag) then
		local image1 = "/items/generic/mags/" .. evo .. "/mag.png"
		local image2 = "/items/generic/mags/" .. evo .. "/magfullbright.png"
		local size1 = root.imageSize(image1)
		local size2 = root.imageSize(image2)
		local p1 = "?crop=0;0;1;1?multiply=0000?replace;0000=FFFF?scalenearest="..size1[1]..";"..size1[2].."?blendmult="..image1
		local p2 = "?crop=0;0;1;1?multiply=0000?replace;0000=FFFF?scalenearest="..size2[1]..";"..size2[2].."?blendmult="..image2
		p1 = p1 .. directives
		p2 = p2 .. directives
		magId_mag = world.spawnProjectile("srm_mag", entity.position(), entity.id(), {1,0}, false, {processing = p1, magForm = evo, flippedImage = false})
		magId_magFullbright = world.spawnProjectile("srm_magfullbright", entity.position(), entity.id(), {1,0}, false, {processing = p2, magForm = evo, flippedImage = false})
		--sb.logInfo("spawned 2")
	elseif ((not evo) and (magId_mag)) then
		world.sendEntityMessage(magId_mag,"die")
		world.sendEntityMessage(magId_magFullbright,"die")
		magId_mag = nil
		magId_magFullbright = nil
	end
	if ((not magId_magFlip) and (magTables[evo].doubleMag)) then
		local image1 = "/items/generic/mags/" .. evo .. "/magflip.png"
		local image2 = "/items/generic/mags/" .. evo .. "/magfullbrightflip.png"
		local size1 = root.imageSize(image1)
		local size2 = root.imageSize(image2)
		local p1 = "?crop=0;0;1;1?multiply=0000?replace;0000=FFFF?scalenearest="..size1[1]..";"..size1[2].."?blendmult="..image1
		local p2 = "?crop=0;0;1;1?multiply=0000?replace;0000=FFFF?scalenearest="..size2[1]..";"..size2[2].."?blendmult="..image2
		p1 = p1 .. directives
		p2 = p2 .. directives
		magId_magFlip = world.spawnProjectile("srm_magflip", entity.position(), entity.id(), {1,0}, false, {processing = p1, magForm = evo, flippedImage = true})
		magId_magFullbrightFlip = world.spawnProjectile("srm_magfullbrightflip", entity.position(), entity.id(), {1,0}, false, {processing = p2, magForm = evo, flippedImage = true})
		--sb.logInfo("spawned 2")
	elseif ((not evo) and (magId_magFlip)) then
		world.sendEntityMessage(magId_magFlip,"die")
		world.sendEntityMessage(magId_magFullbrightFlip,"die")
		magId_magFlip = nil
		magId_magFullbrightFlip = nil
	end
	lastEvo = evo
end

function uninit()
	if magId_mag then if world.entityExists(magId_mag) then world.sendEntityMessage(magId_mag,"die") magId_mag = nil end end
	if magId_magFullbright then if world.entityExists(magId_magFullbright) then world.sendEntityMessage(magId_magFullbright,"die") magId_magFullbright = nil end end
	if magId_magFlip then if world.entityExists(magId_magFlip) then world.sendEntityMessage(magId_magFlip,"die") magId_magFlip = nil end end
	if magId_magFullbrightFlip then if world.entityExists(magId_magFullbrightFlip) then world.sendEntityMessage(magId_magFullbrightFlip,"die") magId_magFullbrightFlip = nil end end
end

function trigger(mag, triggerType)
	local t = magTables[mag.parameters.magForm]
	local chance = synchroBonus(mag.parameters.synchro) + (triggerSign(t[triggerType].sign) * t.triggerRate)
	if t[triggerType].effect ~= "none" then
		local result = math.random(1, 100)
		--sb.logInfo(result .. " <= " .. chance)
		if result <= chance then
			--sb.logInfo("Trigger : " .. triggerType .. " succesful")
			local iqBonus = 1 + math.floor(mag.parameters.iq/40)
			status.addEphemeralEffect(t[triggerType].effect, magTables.triggerMaxDurations[t[triggerType].effect] * (iqBonus/6))
		else
			--sb.logInfo("Trigger : " .. triggerType .. " failed")
		end
	end
end

function offensePB(damageDealt)
	return ((damageDealt/status.stat("powerMultiplier"))/10000)
end

function defensePB(damageTaken)
	return ((damageTaken/status.resourceMax("health"))/5)
end

function synchroBonus(synchro)
	local rateBoost = 0
	if synchro <= 30 then
		rateBoost = 0
	elseif synchro <= 60 then
		rateBoost = 15
	elseif synchro <= 80 then
		rateBoost = 25
	elseif synchro <= 100 then
		rateBoost = 30
	else
		rateBoost = 35
	end
	return rateBoost
end

function triggerSign(sign)
	local rateBoost = 1
	if sign == "positive" then
		rateBoost = 1
	elseif sign == "neutral" then
		rateBoost = 0.5
	else
		rateBoost = 0
	end
	return rateBoost
end

function inflictedDamageCallback(notifications)
	for _,notification in ipairs(notifications) do
		if world.entityExists(notification.targetEntityId) then
			local entityType = world.entityType(notification.targetEntityId)
			if entityType == "npc" or entityType == "monster" or entityType == "player" then
				local valueToGive = offensePB(notification.damageDealt)
				status.modifyResourcePercentage("srm_magPB", valueToGive)
			end
		else
			--sb.logInfo("Skipped event recording for nonexistent entity %s", notification.targetEntityId)
		end
	end
end

function mechDirectives()
	local getColorIndexesMessage = world.sendEntityMessage(entity.id(), "getMechColorIndexes")
	if getColorIndexesMessage:finished() and getColorIndexesMessage:succeeded() then
		local res = getColorIndexesMessage:result()
		self.primaryColorIndex = res.primary
		self.secondaryColorIndex = res.secondary
	--else
		--sb.logError("Mech assembly interface unable to fetch player mech paint colors!")
	end
	if (self.primaryColorIndex) then
		local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
		local toColors = paletteConfig.swapSets[self.primaryColorIndex]
		for i, fromColor in ipairs(paletteConfig.primaryMagicColors) do
			if (toColors == nil) then 
				directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
			else
				directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
			end
		end
		--`directives` would be ?replace=111=222?replace=333=444...
	end
	if (self.secondaryColorIndex) then
		local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
		local toColors = paletteConfig.swapSets[self.secondaryColorIndex]
		for i, fromColor in ipairs(paletteConfig.secondaryMagicColors) do
			if (toColors == nil) then 
				directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
			else
				directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
			end
		end
		--`directivesFullbright` would be ?replace=111=222?replace=333=444...
	end
end