function init()
	script.setUpdateDelta(10)
	immortalStatGroup = effect.addStatModifierGroup({
		{stat = "invulnerable", amount = 0},
		{stat = "fireStatusImmunity", amount = 0},
		{stat = "iceStatusImmunity", amount = 0},
		{stat = "electricStatusImmunity", amount = 0},
		{stat = "poisonStatusImmunity", amount = 0},
		{stat = "powerMultiplier", effectiveMultiplier = 1}
	})
	animator.setAnimationRate(1)
	effect.setParentDirectives("saturation=" .. -000)
	timerValue = 0
end

function update(dt)
	if mcontroller.crouching() then
		if timerValue < 5 then
			timerValue = timerValue + dt
		end
	else
		if timerValue > 0 then
			timerValue = timerValue - dt
		end
	end
	 
	if timerValue < 0.5 then
		stages(0, 1, -000)
		mcontroller.controlModifiers({ facingSuppressed = false })
	elseif ( timerValue >= 0.5 and timerValue < 1 ) then
		stages(0, 1, -025)
		mcontroller.controlModifiers({ facingSuppressed = false })
	elseif ( timerValue >= 1 and timerValue < 1.5 ) then
		stages(0, 1, -050)
		mcontroller.controlModifiers({ facingSuppressed = false })
	elseif ( timerValue >= 1.5 and timerValue < 2 ) then
		stages(0, 1, -075)
		mcontroller.controlModifiers({ facingSuppressed = false })
	elseif timerValue >= 2 then
		stages(1, 0, -100)
		mcontroller.controlModifiers({ facingSuppressed = true })
	end
	
	if timerValue == 1 then animator.playSound("stage0") end
	if timerValue == 2 then animator.playSound("stage1") end
	if timerValue == 3 then animator.playSound("stage2") end
	if timerValue == 4 then animator.playSound("stage3") end
end

function stages(value0, value1, saturation)
	effect.setStatModifierGroup(immortalStatGroup, {
		{stat = "invulnerable", amount = value0},
		{stat = "fireStatusImmunity", amount = value0},
		{stat = "iceStatusImmunity", amount = value0},
		{stat = "electricStatusImmunity", amount = value0},
		{stat = "poisonStatusImmunity", amount = value0},
		{stat = "powerMultiplier", effectiveMultiplier = value1}
	})
	animator.setAnimationRate(value1)
	effect.setParentDirectives("saturation=" .. saturation)
end

function uninit()
	
end
