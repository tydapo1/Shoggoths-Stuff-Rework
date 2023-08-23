require "/scripts/util.lua"

function init()
  animaframe = 0
  extraWait = 0
  angular = 0
    
  --detector init
  detectEntityTypes = config.getParameter("detectEntityTypes")
  detectBoundMode = config.getParameter("detectBoundMode", "CollisionArea")
  detectDamageTeam = config.getParameter("detectDamageTeam")
  detectArea = config.getParameter("detectArea")
  pos = object.position()
  if type(detectArea[2]) == "number" then
    --center and radius
    detectArea = {
      {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
      detectArea[2]
    }
  elseif type(detectArea[2]) == "table" and #detectArea[2] == 2 then
    --rect corner1 and corner2
    detectArea = {
      {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
      {pos[1] + detectArea[2][1], pos[2] + detectArea[2][2]}
    }
  end
  
  --debug message positions
  drawPos1 = {pos[1] -2, pos[2] +1}
  drawPos2 = {pos[1] -2, pos[2] +2}
  drawPos3 = {pos[1] -2, pos[2] +3}
  drawPos4 = {pos[1] -1, pos[2] -1}
  
  --Does literally nothing RN.
  triggerTimer = 0
end

function update(dt)

	--Same as above.
	if triggerTimer > 0 then
		triggerTimer = triggerTimer - dt
	elseif triggerTimer <= 0 then
	
    local entityIds = world.entityQuery(detectArea[1], detectArea[2], {
        withoutEntityId = entity.id(),
        includedTypes = detectEntityTypes,
        boundMode = detectBoundMode,
		order = "nearest"
      })

    if detectDamageTeam then
      entityIds = util.filter(entityIds, function (entityId)
          local entityDamageTeam = world.entityDamageTeam(entityId)
          if detectDamageTeam.type and detectDamageTeam.type ~= entityDamageTeam.type then
            return false
          end
          if detectDamageTeam.team and detectDamageTeam.team ~= entityDamageTeam.team then
            return false
          end
          return true
        end)
    end
	
    if (#entityIds > 0) then
		local targetPos = world.entityPosition(entityIds[1])
		world.debugLine({pos[1] + 0.5, pos[2] +0.5}, world.entityPosition(entityIds[1]), "Red")
		angular = math.atan((targetPos[1]-pos[1])/(targetPos[2]-pos[2]))
		
		---- This converts negative angles into positives for reasons...?
		--if angular < 0 then angular = angular + 2 * math.pi end
		
		-- This converts Radians to Degrees.
		angular = angular * (180/math.pi)
		
		-- This divides the angle based on the position of the target
		-- (If target X is bigger, it's right, etc)
		-- This ensures the object outputs a proper 0-360 angle, starting from directly UP (The 360/0 degree)
		-- There is a microscopic chance it'll divide by 0 when in between 0/360...
		-- ... or it'll just look the opposite way (180).
		if (targetPos[1] > pos[1]) then
			if angular < 0 then angular = angular + 180 end
		else
			if angular < 0 then angular = angular + 360
			else angular = angular + 180 end
		end
		
		-- This is just some fancy debug shit. Only visible in debug mode.
		world.debugText(tostring(targetPos[1]), nil, drawPos3, "Red")
		world.debugText(tostring(targetPos[2]), nil, drawPos2, "Red")
		world.debugText(tostring(angular), nil, drawPos1, "Red")
		
		trigger(angular)
		animator.setGlobalTag("animaFrame", tostring(animaframe))
		
		-- More debug.
		world.debugText(tostring(animaframe), nil, drawPos4, "Cyan")
    else
      if extraWait > 0 then
			extraWait = extraWait - dt
			do return end
		else 
			animaframe = math.random(18)
			animator.setGlobalTag("animaFrame", tostring(animaframe))
			extraWait = 9
		end
	  
	  --object.setSoundEffectEnabled(false)
    end
  end
end

function trigger(angulist)
	animaframe = math.floor(((angulist + 22.5) / 45) + 2)
	if (animaframe == 10 or animaframe == 1) then animaframe = 2 end
	extraWait = 3
end

function onInteraction(args)
  --trigger()
end