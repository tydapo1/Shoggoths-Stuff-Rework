function init()
	lockedPower = false
end

function activate(fireMode, shiftHeld)
	if not lockedPower then
		if shiftHeld then
			local cfg = root.assetJson("/interface/scripted/srm_stockmarket/srm_stockmarket.config")
			activeItem.interact("ScriptPane", cfg)
		else
			if fireMode == "primary" then
				-- use power here
			elseif fireMode == "alt" then
				-- switch power here
			end
		end
	end
end