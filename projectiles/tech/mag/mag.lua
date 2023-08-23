require "/scripts/util.lua"
require "/scripts/companions/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/vec2.lua"

function init()
	script.setUpdateDelta(1)
	magTables = root.assetJson("/config/srm_mag.config")
	
	despawnable = false
	facingDirection = 1
	message.setHandler("die", function(_, isItMine) 
		despawnable = true
	end)
	message.setHandler("ownerFacing", function(_, isItMine, value) 
		facingDirection = value
	end)
	
	form = config.getParameter("magForm", "mag")
	isFlipped = config.getParameter("flippedImage", false)
	switchDirection = true
	turnOffset = 0
	sinValue = 0
	maxDelay = 10
	posHistory = {}
	playerPosition = world.entityPosition(projectile.sourceEntity())
	for i=1,maxDelay do
		posHistory[i] = playerPosition
	end
end

function update(dt)
	playerPosition = world.entityPosition(projectile.sourceEntity())
	if playerPosition then
		local playerPositionOffset = playerPosition
		
		sinValue = sinValue + 1
		if sinValue >= 30000 then sinValue = 0 end
		--sb.logInfo("X : " .. sinValue .. " | Y : " .. ((math.sin(sinValue*0.03))/150))
		
		--sb.logInfo(facingDirection)
		if facingDirection == -1 then
			if switchDirection then
				if turnOffset >= 0 then turnOffset = -1 else turnOffset = -1 - turnOffset end
				switchDirection = false 
			end
			mcontroller.setRotation(math.pi)
		else
			if not switchDirection then
				if turnOffset >= 0 then turnOffset = -1 else turnOffset = -1 - turnOffset end
				switchDirection = true 
			end
			mcontroller.setRotation(0)
		end
		
		local oldPosVec = {}
		if playerPosition then
			oldPosVec = world.distance(posHistory[maxDelay], playerPosition)
		else
			oldPosVec = {0,0}
		end
		playerPositionOffset = vec2.add(playerPositionOffset, oldPosVec)
		local sinWaveValue = ((math.sin(sinValue*0.03))/4)
		if not isFlipped then
			local x = magTables[form].offset[1]
			local y = magTables[form].offset[2]
			x = x * facingDirection
			y = y + sinWaveValue
			playerPositionOffset = vec2.add(playerPositionOffset, {x, y})
			local turnVec = {(turnOffset * 2 * magTables[form].offset[1] * facingDirection), 0}
			playerPositionOffset = vec2.add(playerPositionOffset, turnVec)
		else
			local x = magTables[form].offsetFlip[1]
			local y = magTables[form].offsetFlip[2]
			x = x * facingDirection
			y = y + sinWaveValue
			playerPositionOffset = vec2.add(playerPositionOffset, {x, y})
			local turnVecFlip = {(turnOffset * 2 * magTables[form].offsetFlip[1] * facingDirection), 0}
			playerPositionOffset = vec2.add(playerPositionOffset, turnVecFlip)
		end
		
		mcontroller.setPosition(playerPositionOffset)
		for i=(maxDelay-1),1,-1 do
			posHistory[i+1] = posHistory[i]
		end
		posHistory[1] = playerPosition
		if turnOffset < 0 then turnOffset = turnOffset + (1/maxDelay) end
		if turnOffset > 0 then turnOffset = turnOffset - (1/maxDelay) end
	else
		despawnable = true
	end
end

function shouldDestroy()
	return (despawnable)
end