function init()
	position = config.getParameter("pos")
end

function update()
	if (not world.placeObject("torch", position)) then
		world.spawnItem("torch", position, 1)
	end
	stagehand.die()
end