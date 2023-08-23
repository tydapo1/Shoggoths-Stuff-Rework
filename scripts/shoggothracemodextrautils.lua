local oldInit = init
init = function()
	if oldInit then oldInit() end

	math.srm_player = _ENV.player
	math.srm_localAnimator = _ENV.localAnimator
	message.setHandler("extraarms_setProperty", function(_, isItMine, property, trueOrFalse)
		if (isItMine) then
			player.setProperty(property, trueOrFalse)
		end
	end)
	message.setHandler("extraarms_playSound", function(_, isItMine, sound, loops, volume)
		localAnimator.playAudio(sound, loops, volume)
	end)
	message.setHandler("extraarms_followHook", function(_, isItMine, vector)
		status.addEphemeralEffect("srm_extraarms_hooking", 5)
	end)
	
	--message.setHandler("extraarms_localAnimator", function(_, isItMine, functionType, data) 
	--	if (isItMine) then
	--		if (functionType == "clearDrawables") then
	--			localAnimator.clearDrawables()
	--		elseif (functionType == "clearLightSources") then
	--			localAnimator.clearLightSources()
	--		elseif (functionType == "addDrawable") then
	--			localAnimator.addDrawable(data.drawable, data.renderLayer)
	--			--sb.logInfo(sb.print(data.drawable))
	--			--sb.logInfo("Succesfully drawn!")
	--		elseif (functionType == "addLightSource") then
	--			localAnimator.addLightSource(data.light)
	--		end
	--	end
	--end)
end