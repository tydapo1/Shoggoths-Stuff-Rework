function init()
	closedMaterialSpaces = {}
	openMaterialSpaces = {}
	updateSpaces()
	updatedHitbox = true
	hasSwitched = false
	dtTimer = 0
	lastTime = os.time()
	isReversed = config.getParameter("reversed", false)
	swapRate = config.getParameter("swapRate", 4)
end

function update(dt)
	hasSwitched = false
	if (math.fmod(os.time(),(swapRate*2)) < swapRate) then
		if isReversed then
			if updatedHitbox then updatedHitbox = false readyToSwap(openMaterialSpaces, "open") end
		else
			if updatedHitbox then updatedHitbox = false readyToSwap(closedMaterialSpaces, "closed") end
		end
	else
		if isReversed then
			if not updatedHitbox then updatedHitbox = true readyToSwap(closedMaterialSpaces, "closed") end
		else
			if not updatedHitbox then updatedHitbox = true readyToSwap(openMaterialSpaces, "open") end
		end
	end
	if hasSwitched then
		dtTimer = 0
		lastTime = 0
	end
	if ((quickMath(dtTimer) > (swapRate/2)) and (not hasSwitched) and (quickMath(dtTimer) < swapRate)) then
		if (quickMath(dtTimer) ~= lastTime) then
			animator.playSound("beat", 0)
			lastTime = quickMath(dtTimer)
		end
	end
	--sb.logInfo(quickMath(dtTimer))
	--if not hasSwitched then
	--	if lastTime ~= os.time() then
	--		animator.playSound("beat", 0)
	--	end
	--end
	dtTimer = dtTimer + dt
end

function quickMath(n)
	return ((math.floor(n*2))/2)
end

function readyToSwap(spaces, state)
	object.setMaterialSpaces(spaces)
	animator.setAnimationState("doorState", state, false)
	animator.playSound("swap", 0)
	hasSwitched = true
end

function updateSpaces()
	closedMaterialSpaces = {}
	for i, space in ipairs(object.spaces()) do
		table.insert(closedMaterialSpaces, {space, "metamaterial:door"})
	end
	openMaterialSpaces = {}
end