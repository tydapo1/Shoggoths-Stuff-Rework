function init()
	position = config.getParameter("position")
	layer = config.getParameter("layer")
	tile = config.getParameter("tile")
	color = config.getParameter("color")
	canmod = config.getParameter("canmod")
	matmod = config.getParameter("matmod")
	playerid = config.getParameter("playerid")
end

function update()
	local ok = world.placeMaterial(position, layer, tile)
	if ok then
		world.setMaterialColor(position, layer, color)
		if canmod then world.placeMod(position, layer, matmod) end
		world.sendEntityMessage(playerid, "worldbrush_ConsumeRessource")
	end
	stagehand.die()
end