function init()
	position = config.getParameter("position")
	positionList = {position}
	layer = config.getParameter("layer")
end

function update()
	world.damageTiles(positionList, layer, position, "blockish", 999999, 99)
	stagehand.die()
end