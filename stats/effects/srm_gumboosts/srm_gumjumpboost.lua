function init()
	local bounds = mcontroller.boundBox()
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = 1.0}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		airJumpModifier = 2.00
	})
end

function uninit()
	
end
