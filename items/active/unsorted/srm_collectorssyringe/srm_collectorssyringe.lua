function activate(fireMode, shiftHeld)
	local cfg = root.assetJson("/interface/scripted/srm_collectorssyringe/srm_collectorssyringe.config")
	activeItem.interact("ScriptPane", cfg)
end