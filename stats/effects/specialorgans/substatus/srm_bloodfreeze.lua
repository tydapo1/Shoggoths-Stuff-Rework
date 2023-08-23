function init()
	effect.setParentDirectives("saturation=-100?fade=00ffff=0.5")
	animator.playSound("freeze_start")
	
	animator.setAnimationRate(0)
	effect.addStatModifierGroup({
		{stat = "powerMultiplier", effectiveMultiplier = 0}
	})

	if status.isResource("stunned") then
		status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
	end

	mcontroller.setVelocity({0, 0})
end

function update(dt)
	mcontroller.setVelocity({0, 0})
	mcontroller.controlModifiers({
		facingSuppressed = true,
		movementSuppressed = true
	})
end

function uninit()
	animator.setAnimationRate(1)
end
