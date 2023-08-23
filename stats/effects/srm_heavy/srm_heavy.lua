function init()
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.25}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		groundMovementModifier = 0.75,
		speedModifier = 0.75,
		airJumpModifier = 0.75
	})
end

function uninit()

end
