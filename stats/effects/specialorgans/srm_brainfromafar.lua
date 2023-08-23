function init()
	script.setUpdateDelta(40)
end

function update(dt)
	local quadrant = math.random(1, 4)
	local directionX = math.random()*5
	local directionY = math.random()*5
	local direction = {0,0}
	
	if quadrant == 1 then 
		directionX = directionX * 1 
		directionY = directionY * 1
	elseif quadrant == 2 then
		directionX = directionX * 1 
		directionY = directionY * -1
	elseif quadrant == 3 then
		directionX = directionX * -1 
		directionY = directionY * 1
	elseif quadrant == 4 then
		directionX = directionX * -1 
		directionY = directionY * -1
	end
	direction = {directionX,directionY}
	
	world.spawnProjectile("srm_lightwisp", mcontroller.position(), entity.id(), direction, false, {power = 0})
end