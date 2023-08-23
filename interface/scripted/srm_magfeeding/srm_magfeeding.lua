function init()
	magTables = root.assetJson("/config/srm_mag.config")
	raceTables = root.assetJson("/config/srm_racial.config")
	for k,v in pairs(magTables) do
		if v.conditions then
			require(v.conditions)
		end
	end
	widget.setImage("sectionImage", "/interface/scripted/srm_magfeeding/" .. player.getProperty("magSectionId", nil) .. ".png?multiply=FFFFFF60")
	expireTimer = config.getParameter("windowExpireTimer", 3600)
	consumeableItems = {
		salve = "monofluid",
		medkit = "difluid",
		srm_trifluid = "trifluid",
		bandage = "monomate",
		nanowrap = "dimate",
		srm_trimate = "trimate",
		antidote = "antidote",
		burnspray = "antiparalysis",
		techcard = "solatomizer",
		manipulatormodule = "moonatomizer",
		upgrademodule = "staratomizer"
	}
	meters = {
		def = { meter = widget.bindCanvas("DEFMeter"), meterImage = "/interface/scripted/srm_magfeeding/defmeter.png" },
		pow = { meter = widget.bindCanvas("POWMeter"), meterImage = "/interface/scripted/srm_magfeeding/powmeter.png" },
		dex = { meter = widget.bindCanvas("DEXMeter"), meterImage = "/interface/scripted/srm_magfeeding/dexmeter.png" },
		mind = { meter = widget.bindCanvas("MINDMeter"), meterImage = "/interface/scripted/srm_magfeeding/mindmeter.png" },
		generic = { meter = nil, meterImage = "/interface/scripted/srm_magfeeding/genericmeter.png" }
	}
	userInputLocked = false
	
	levelCap = config.getParameter("levelCap", 200)
	statsCap = config.getParameter("statsCap", 200)
	synchroCap = config.getParameter("synchroCap", 120)
	waitTimerReset = 1.5
	waitTimer = 0
	statsGained = nil
	statsGainedDecreasing = nil
	eatOnce = true
	feedCooldown = 0
	
	local mag = player.getProperty("magEquipped", nil)
	if mag then
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
		mag.parameters.shortdescription = firstToUpper(mag.parameters.magForm)
		mag.parameters.inventoryIcon = "/items/generic/mags/" .. mag.parameters.magForm .. "/mag.png" .. mechDirectives()
		widget.setItemSlotItem("magSlot", mag)
	end
end

function update(dt)
	if not userInputLocked then
		local mag = widget.itemSlotItem("magSlot")
		if mag then
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
			meters["def"].meter:clear()
			meters["pow"].meter:clear()
			meters["dex"].meter:clear()
			meters["mind"].meter:clear()
			mag.parameters.shortdescription = firstToUpper(mag.parameters.magForm)
			mag.parameters.inventoryIcon = "/items/generic/mags/" .. mag.parameters.magForm .. "/mag.png" .. mechDirectives()
			widget.setText("levelMag", getLevel(mag))
			widget.setText("synchroMag", mag.parameters.synchro)
			widget.setText("IQMag", mag.parameters.iq)
			widget.setText("DEFMag", mag.parameters.def)
			widget.setText("POWMag", mag.parameters.pow)
			widget.setText("DEXMag", mag.parameters.dex)
			widget.setText("MINDMag", mag.parameters.mind)
			local fullPBChance = synchroBonus(mag.parameters.synchro) + (triggerSign(magTables[mag.parameters.magForm].fullPBTrigger.sign) * magTables[mag.parameters.magForm].triggerRate)
			local heavyDamageChance = synchroBonus(mag.parameters.synchro) + (triggerSign(magTables[mag.parameters.magForm].heavyDamageTrigger.sign) * magTables[mag.parameters.magForm].triggerRate)
			local beamingChance = synchroBonus(mag.parameters.synchro) + (triggerSign(magTables[mag.parameters.magForm].beamingTrigger.sign) * magTables[mag.parameters.magForm].triggerRate)
			widget.setText("fullPBTrigger", math.floor(fullPBChance) .. "% " .. magTables[mag.parameters.magForm].fullPBTrigger.name)
			widget.setText("heavyDamageTrigger", math.floor(heavyDamageChance) .. "% " .. magTables[mag.parameters.magForm].heavyDamageTrigger.name)
			widget.setText("beamingTrigger", math.floor(beamingChance) .. "% " .. magTables[mag.parameters.magForm].beamingTrigger.name)
			meters["def"].meter:drawImageRect(meters["def"].meterImage, {0,0,mag.parameters.defMeter,5}, {0,0,mag.parameters.defMeter,5})
			meters["pow"].meter:drawImageRect(meters["pow"].meterImage, {0,0,mag.parameters.powMeter,5}, {0,0,mag.parameters.powMeter,5})
			meters["dex"].meter:drawImageRect(meters["dex"].meterImage, {0,0,mag.parameters.dexMeter,5}, {0,0,mag.parameters.dexMeter,5})
			meters["mind"].meter:drawImageRect(meters["mind"].meterImage, {0,0,mag.parameters.mindMeter,5}, {0,0,mag.parameters.mindMeter,5})
		else
			meters["def"].meter:clear()
			meters["pow"].meter:clear()
			meters["dex"].meter:clear()
			meters["mind"].meter:clear()
			widget.setText("levelMag", "x")
			widget.setText("synchroMag", "x")
			widget.setText("IQMag", "x")
			widget.setText("DEFMag", "x")
			widget.setText("POWMag", "x")
			widget.setText("DEXMag", "x")
			widget.setText("MINDMag", "x")
			widget.setText("fullPBTrigger", "x")
			widget.setText("heavyDamageTrigger", "x")
			widget.setText("beamingTrigger", "x")
		end
		if mag then
			local food = widget.itemSlotItem("feedSlot")
			if food then
				widget.setItemSlotItem("feedSlot", nil)
				--sb.logInfo("Mag : " .. sb.printJson(mag))
				--sb.logInfo("Food : " .. sb.printJson(food))
				statsGained = magTables.feedingTables[magTables[mag.parameters.magForm].feedTable][consumeableItems[food.name]]
				statsGainedDecreasing = {}
				for k,v in pairs(statsGained) do
					statsGainedDecreasing[k] = v
				end
				--sb.logInfo("Feeding Table : " .. sb.printJson(magTables.feedingTables[magTables[mag.parameters.magForm].feedTable][consumeableItems[food.name]]))
				
				-- We're giving all the stats in advance to prevent losing them should the user close the UI
				-- The Synchro gain
				--sb.logInfo("Synchro : " .. sb.printJson(statsGainedDecreasing.synchro))
				mag.parameters.synchro = nonMeteredStats("synchroMag", synchroCap, mag.parameters.synchro, statsGainedDecreasing.synchro)
				statsGainedDecreasing.synchro = nil
				-- The IQ gain
				--sb.logInfo("IQ : " .. sb.printJson(statsGainedDecreasing.iq))
				mag.parameters.iq = nonMeteredStats("IQMag", statsCap, mag.parameters.iq, statsGainedDecreasing.iq)
				statsGainedDecreasing.iq = nil
				-- This saves the data for both of the above, since they do not require animating.
				mag.parameters.shortdescription = firstToUpper(mag.parameters.magForm)
				mag.parameters.inventoryIcon = "/items/generic/mags/" .. mag.parameters.magForm .. "/mag.png" .. mechDirectives()
				widget.setItemSlotItem("magSlot", mag)
				-- The DEF gain
				--sb.logInfo("Def : " .. sb.printJson(statsGainedDecreasing.def))
				mag.parameters.defMeter = meteredStats("def", mag.parameters.defMeter, statsGainedDecreasing.def)
				if getLevel(mag)>= levelCap then
					mag.parameters.defMeter = 100
				elseif mag.parameters.defMeter >= 100 then
					mag.parameters.defMeter = mag.parameters.defMeter - 100
					mag.parameters.def = mag.parameters.def + 1
					mag = onLevelUp(mag)
				end
				-- The POW gain
				--sb.logInfo("Pow : " .. sb.printJson(statsGainedDecreasing.pow))
				mag.parameters.powMeter = meteredStats("pow", mag.parameters.powMeter, statsGainedDecreasing.pow)
				if getLevel(mag)>= levelCap then
					mag.parameters.powMeter = 100
				elseif mag.parameters.powMeter >= 100 then
					mag.parameters.powMeter = mag.parameters.powMeter - 100
					mag.parameters.pow = mag.parameters.pow + 1
					mag = onLevelUp(mag)
				end
				-- The DEX gain
				--sb.logInfo("Dex : " .. sb.printJson(statsGainedDecreasing.dex))
				--sb.logInfo(sb.printJson(mag))
				mag.parameters.dexMeter = meteredStats("dex", mag.parameters.dexMeter, statsGainedDecreasing.dex)
				if getLevel(mag)>= levelCap then
					mag.parameters.dexMeter = 100
				elseif mag.parameters.dexMeter >= 100 then
					mag.parameters.dexMeter = mag.parameters.dexMeter - 100
					mag.parameters.dex = mag.parameters.dex + 1
					mag = onLevelUp(mag)
				end
				-- The MIND gain
				--sb.logInfo("Mind : " .. sb.printJson(statsGainedDecreasing.mind))
				mag.parameters.mindMeter = meteredStats("mind", mag.parameters.mindMeter, statsGainedDecreasing.mind)
				if getLevel(mag)>= levelCap then
					mag.parameters.mindMeter = 100
				elseif mag.parameters.mindMeter >= 100 then
					mag.parameters.mindMeter = mag.parameters.mindMeter - 100
					mag.parameters.mind = mag.parameters.mind + 1
					mag = onLevelUp(mag)
				end
				
				player.setProperty("magEquipped", mag)
				waitTimer = waitTimerReset
				userInputLocked = true
			end
		end
	else
		local mag = widget.itemSlotItem("magSlot")
		if waitTimer <= 0 then
			widget.setText("level", "Level")
			if eatOnce then eatOnce = false widget.playSound("/sfx/interface/mag_eating.ogg") end
			----sb.logInfo(sb.printJson(statsGainedDecreasing))
			for k,v in pairs(statsGainedDecreasing) do
				if v ~= 0 then
					local results = meteredStatsProgressive(k, mag.parameters[k .. "Meter"], statsGained[k], statsGainedDecreasing[k])
					statsGainedDecreasing[k] = results.gain
					mag.parameters[k .. "Meter"] = results.amnt
					if getLevel(mag)>= levelCap then
						mag.parameters[k .. "Meter"] = 100
					elseif mag.parameters[k .. "Meter"] >= 100 then
						mag.parameters[k .. "Meter"] = mag.parameters[k .. "Meter"] - 100
						mag.parameters[k] = mag.parameters[k] + 1
						mag = cosmeticLevelUp(mag)
					end
					mag.parameters.shortdescription = firstToUpper(mag.parameters.magForm)
					mag.parameters.inventoryIcon = "/items/generic/mags/" .. mag.parameters.magForm .. "/mag.png" .. mechDirectives()
					widget.setItemSlotItem("magSlot", mag)
				else
					statsGainedDecreasing[k] = nil
				end
			end
			local elem = 0
			for k,v in pairs(statsGainedDecreasing) do elem = elem + 1 end
			if (elem <= 0) then
				mag.parameters.shortdescription = firstToUpper(mag.parameters.magForm)
				mag.parameters.inventoryIcon = "/items/generic/mags/" .. mag.parameters.magForm .. "/mag.png" .. mechDirectives()
				widget.setItemSlotItem("magSlot", mag)
				userInputLocked = false
				statsGainedDecreasing = nil
				statsGained = nil
			end
		else
			eatOnce = true
			waitTimer = waitTimer - dt
		end
	end
	if expireTimer > 0 then
		expireTimer = expireTimer - dt
	else
		pane.dismiss()
	end
end

function uninit()
	if not userInputLocked then
		player.setProperty("magEquipped", widget.itemSlotItem("magSlot"))
	end
end

function feedSlot(slot)
	if not userInputLocked then
		local feedingManager = player.getProperty("magFeedingUses", 0)
		if feedingManager > 0 then
			local toWidgetSlot = player.swapSlotItem()
			if (toWidgetSlot.name) then
				local nameMatch = false
				for k,v in pairs(consumeableItems) do
					if (toWidgetSlot.name == k) then nameMatch = true end
				end
				if nameMatch then
					if toWidgetSlot.count <= 1 then
						widget.playSound("/sfx/interface/clickon_success.ogg")
						widget.setItemSlotItem("feedSlot",toWidgetSlot)
						player.setSwapSlotItem(nil)
					else
						local leftOver = {}
						local inserted = {}
						for k,v in pairs(toWidgetSlot) do
							leftOver[k] = v
							inserted[k] = v
							if k=="count" then
								leftOver[k] = v - 1
								inserted[k] = 1
							end
						end
						widget.playSound("/sfx/interface/clickon_success.ogg")
						widget.setItemSlotItem("feedSlot",inserted)
						player.setSwapSlotItem(leftOver)
						player.setProperty("magFeedingUses", (feedingManager-1))
					end
				end
			end
		end
	end
end

function magSlot(slot)
	if not userInputLocked then
		local toSwapSlot = widget.itemSlotItem("magSlot")
		local toWidgetSlot = player.swapSlotItem()
		if (not toWidgetSlot) then
			widget.playSound("/sfx/interface/clickon_success.ogg")
			widget.setItemSlotItem("magSlot",toWidgetSlot)
			player.setProperty("magEquipped", toWidgetSlot)
			player.setSwapSlotItem(toSwapSlot)
		elseif (toWidgetSlot.name == "srm_mag") then
			widget.playSound("/sfx/interface/clickon_success.ogg")
			widget.setItemSlotItem("magSlot",toWidgetSlot)
			player.setProperty("magEquipped", toWidgetSlot)
			player.setSwapSlotItem(toSwapSlot)
		end
	end
end

function cosmeticLevelUp(mag)
	local newMag = onLevelUp(mag)
	widget.playSound("/sfx/interface/mag_levelup.ogg")
	widget.setText("level", "^orange;Level up!^reset;")
	widget.setText("levelMag", getLevel(newMag))
	widget.setText("synchroMag", newMag.parameters.synchro)
	widget.setText("IQMag", newMag.parameters.iq)
	widget.setText("DEFMag", newMag.parameters.def)
	widget.setText("POWMag", newMag.parameters.pow)
	widget.setText("DEXMag", newMag.parameters.dex)
	widget.setText("MINDMag", newMag.parameters.mind)
	local fullPBChance = synchroBonus(newMag.parameters.synchro) + (triggerSign(magTables[newMag.parameters.magForm].fullPBTrigger.sign) * magTables[newMag.parameters.magForm].triggerRate)
	local heavyDamageChance = synchroBonus(newMag.parameters.synchro) + (triggerSign(magTables[newMag.parameters.magForm].heavyDamageTrigger.sign) * magTables[newMag.parameters.magForm].triggerRate)
	local beamingChance = synchroBonus(newMag.parameters.synchro) + (triggerSign(magTables[newMag.parameters.magForm].beamingTrigger.sign) * magTables[newMag.parameters.magForm].triggerRate)
	widget.setText("fullPBTrigger", math.floor(fullPBChance) .. "% " .. magTables[newMag.parameters.magForm].fullPBTrigger.name)
	widget.setText("heavyDamageTrigger", math.floor(heavyDamageChance) .. "% " .. magTables[newMag.parameters.magForm].heavyDamageTrigger.name)
	widget.setText("beamingTrigger", math.floor(beamingChance) .. "% " .. magTables[newMag.parameters.magForm].beamingTrigger.name)
	waitTimer = waitTimerReset
	return newMag
end

function onLevelUp(mag)
	return mag
end

function evolve(mag, newForm)
	local newMag = mag
	newMag.parameters.magForm = newForm
	if newMag.parameters.pbAttack1 == "" then
		newMag.parameters.pbAttack1 = magTables[newForm].PBLearned
	elseif newMag.parameters.pbAttack2 == "" then
		newMag.parameters.pbAttack2 = magTables[newForm].PBLearned
	elseif newMag.parameters.pbAttack3 == "" then
		newMag.parameters.pbAttack3 = magTables[newForm].PBLearned
	end
	return newMag
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

function getLevel(mag)
	return mag.parameters.def + mag.parameters.pow + mag.parameters.dex + mag.parameters.mind
end

function meteredStats(stat, currentAmount, gain)
	if (gain>0) then
		local oldAmount = currentAmount
		currentAmount = currentAmount + gain
		--sb.logInfo(oldAmount)
		--sb.logInfo(currentAmount)
		meters[stat].meter:drawImageRect(meters[stat].meterImage, {0,0,oldAmount,5}, {0,0,oldAmount,5})
		meters[stat].meter:drawImageRect(meters["generic"].meterImage, {oldAmount,0,currentAmount,5}, {oldAmount,0,currentAmount,5})
	elseif (gain<0) then
		local oldAmount = currentAmount
		if (currentAmount <= 0) then
		elseif ((currentAmount + gain) <= 0) then
			currentAmount = 0
		else
			currentAmount = currentAmount + gain
		end
		meters[stat].meter:drawImageRect(meters[stat].meterImage, {0,0,oldAmount,5}, {0,0,oldAmount,5})
		meters[stat].meter:drawImageRect(meters["generic"].meterImage, {currentAmount,0,oldAmount,5}, {currentAmount,0,oldAmount,5})
	end
	return currentAmount
end

function meteredStatsProgressive(stat, currentAmount, amountGainTotal, amountGainLeft)
	meters[stat].meter:clear()
	if (amountGainLeft>0) then
		amountGainLeft = amountGainLeft - 1
		currentAmount = currentAmount + 1
		meters[stat].meter:drawImageRect(meters[stat].meterImage, 		{0,0,currentAmount,5}, {0,0,currentAmount,5})
		meters[stat].meter:drawImageRect(meters["generic"].meterImage, 	{currentAmount,0,(currentAmount+amountGainLeft),5}, {currentAmount,0,(currentAmount+amountGainLeft),5})
	elseif (amountGainLeft<0) then
		amountGainLeft = amountGainLeft + 1
		if currentAmount>0 then currentAmount = currentAmount - 1 end
		meters[stat].meter:drawImageRect(meters[stat].meterImage, 		{0,0,currentAmount,5}, {0,0,currentAmount,5})
		meters[stat].meter:drawImageRect(meters["generic"].meterImage, 	{(currentAmount-amountGainTotal),0,currentAmount,5}, {(currentAmount-amountGainTotal),0,currentAmount,5})
	end
	return {gain=amountGainLeft,amnt=currentAmount}
end

function nonMeteredStats(textRegion, statCap, currentAmount, gain)
	if (gain>0) then
		if (currentAmount >= statCap) then
		elseif ((currentAmount + gain) >= statCap) then
			currentAmount = statCap
		else
			currentAmount = currentAmount + gain
		end
		widget.setText(textRegion, "^orange;" .. currentAmount .. "^reset;")
	elseif (gain<0) then
		if (currentAmount <= 0) then
		elseif ((currentAmount + gain) <= 0) then
			currentAmount = 0
		else
			currentAmount = currentAmount + gain
		end
		widget.setText(textRegion, "^cyan;" .. currentAmount .. "^reset;")
	end
	return currentAmount
end

function mechDirectives()
	local getColorIndexesMessage = world.sendEntityMessage(player.id(), "getMechColorIndexes")
	if getColorIndexesMessage:finished() and getColorIndexesMessage:succeeded() then
		local res = getColorIndexesMessage:result()
		self.primaryColorIndex = res.primary
		self.secondaryColorIndex = res.secondary
	--else
		--sb.logError("Mech assembly interface unable to fetch player mech paint colors!")
	end
	local directives = ""
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
	return directives
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function isHigher(n1, n2)
	return n1 >= n2
end