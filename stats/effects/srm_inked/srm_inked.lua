function init()
	effect.setParentDirectives("fade=000000=1.0")
	effect.addStatModifierGroup({
		{stat = "powerMultiplier", effectiveMultiplier = 0}
	})

	if status.isResource("stunned") then
		status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
	end
end

function update(dt)
	mcontroller.controlModifiers({
		facingSuppressed = true,
		movementSuppressed = true
	})
end