function init()
	local bounds = mcontroller.boundBox()
end

function update(dt)
	mcontroller.controlModifiers({
		speedModifier = 3.00
	})
end

function uninit()
	
end
