function activate(fireMode, shiftHeld)
	local cfg = root.assetJson("/interface/scripted/srm_loadoutotron/srm_loadoutotron.config")
	activeItem.interact("ScriptPane", cfg)
end