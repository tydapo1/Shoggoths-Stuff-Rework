function init()
	effect.setParentDirectives("fade=FFFFFF=0.4")
	effect.addStatModifierGroup({
		{stat = "powerMultiplier", effectiveMultiplier = 0}
	})

	if status.isResource("stunned") then
		status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
	end

	--mcontroller.setVelocity({0, 0})
	mcontroller.controlApproachVelocity({0, 5}, 100)
end

function update(dt)
	--mcontroller.setVelocity({0, 0})
	mcontroller.controlApproachVelocity({0, 5}, 100)
	mcontroller.controlModifiers({
		facingSuppressed = true,
		movementSuppressed = true
	})
end