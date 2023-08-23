function init()
	effect.setParentDirectives("fade=00ff00=0.5")
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.20}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		groundMovementModifier = 0.9,
		speedModifier = 0.9,
		airJumpModifier = 0.9
	})
end

function uninit()

end
