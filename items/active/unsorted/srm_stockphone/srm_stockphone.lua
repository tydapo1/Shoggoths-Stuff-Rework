function activate(fireMode, shiftHeld)
	local cfg = root.assetJson("/interface/scripted/srm_stockmarket/srm_stockmarket.config")
	activeItem.interact("ScriptPane", cfg)
end