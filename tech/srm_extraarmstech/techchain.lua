require "/scripts/vec2.lua"
require "/scripts/util.lua"

function update_chainList(dt)
  --world.sendEntityMessage(entity.id(), "extraarms_localAnimator", "clearDrawables")
  --world.sendEntityMessage(entity.id(), "extraarms_localAnimator", "clearLightSources")
  localAnimator.clearDrawables()
  localAnimator.clearLightSources()
  
  chainList = chains or {}
  --sb.logInfo(sb.print(chainList))
  for _, chainList in pairs(chainList) do
    local continue = false
    if chainList.targetEntityId then
      if world.entityExists(chainList.targetEntityId) then
        chainList.endPosition = world.entityPosition(chainList.targetEntityId)
      end
    end
    if chainList.sourcePart then
      local beamSource = animationConfig.partPoint(chainList.sourcePart, "beamSource")
      if beamSource then
        chainList.startPosition = vec2.add(entity.position(), beamSource)
      else
        continue = true
      end
    end
    if chainList.endPart then
      local beamEnd = animationConfig.partPoint(chainList.endPart, "beamEnd")
      if beamEnd then
        chainList.endPosition = vec2.add(entity.position(), beamEnd)
      else
        continue = true
      end
    end
	
    --sb.logInfo(sb.print(continue))

    if not continue and (not chainList.targetEntityId or world.entityExists(chainList.targetEntityId)) then
      -- sb.logInfo("Building drawables for chainList %s", chainList)
      local startPosition = chainList.startPosition or vec2.add(entity.position(), chainList.startOffset)
      local endPosition = chainList.endPosition or tech.aimPosition()

      if chainList.maxLength then
        endPosition = vec2.add(startPosition, vec2.mul(vec2.norm(world.distance(endPosition, startPosition)), chainList.maxLength))
      end

      if chainList.testCollision then
        local angle = vec2.angle(world.distance(endPosition, startPosition))
         -- lines starting on tile boundaries will collide with the tile
         -- work around this by starting the collision check a small distance along the line from the actual start position
        local collisionStart = vec2.add(startPosition, vec2.withAngle(angle, 0.01))
        local collision = world.lineTileCollisionPoint(startPosition, endPosition)
        if collision then
          local collidePosition, normal = collision[1], collision[2]
          if chainList.bounces and chainList.bounces > 0 then
            local length = world.magnitude(endPosition, startPosition) - world.magnitude(collidePosition, startPosition)
            local newchainList = copy(chainList)
            newchainList.sourcePart, newchainList.endPart, newchainList.targetEntityId = nil, nil, nil
            newchainList.startPosition = collidePosition
            newchainList.endPosition = vec2.add(collidePosition, vec2.mul(vec2.withAngle(angle, length), normal[1] == 0 and {1, -1} or {-1, 1}))
            newchainList.bounces = chainList.bounces - 1
            table.insert(chainList, newchainList)
          end

          endPosition = collidePosition
        end
      end

      local chainListVec = world.distance(endPosition, startPosition)
      local chainListDirection = chainListVec[1] < 0 and -1 or 1
      local chainListLength = vec2.mag(chainListVec)

      local arcAngle = 0
      if chainList.arcRadius then
        arcAngle = chainListDirection * 2 * math.asin(chainListLength / (2 * chainList.arcRadius))
        chainListLength = chainListDirection * arcAngle * chainList.arcRadius
      end

      local segmentCount = math.floor(((chainListLength + (chainList.overdrawLength or 0)) / chainList.segmentSize) + 0.5)
      if segmentCount > 0 then
        local chainListStartAngle = vec2.angle(chainListVec) - arcAngle / 2
        if chainListVec[1] < 0 then chainListStartAngle = math.pi - chainListStartAngle end

        local segmentOffset = vec2.mul(vec2.norm(chainListVec), chainList.segmentSize)
        segmentOffset = vec2.rotate(segmentOffset, -arcAngle / 2)
        local currentBaseOffset = vec2.add(startPosition, vec2.mul(segmentOffset, 0.5))
        local lastDrawnSegment = chainList.drawPercentage and math.ceil(segmentCount * chainList.drawPercentage) or segmentCount
        for i = 1, lastDrawnSegment do
          local image = chainList.segmentImage
          if i == 1 and chainList.startSegmentImage then
            image = chainList.startSegmentImage
          elseif i == lastDrawnSegment and chainList.endSegmentImage then
            image = chainList.endSegmentImage
          end

          -- taper applies evenly from full size at the start to (1.0 - chainList.taper) size at the end
          if chainList.taper then
            local taperFactor = 1 - ((i - 1) / lastDrawnSegment) * chainList.taper
            image = image .. "?scale=1.0=" .. util.round(taperFactor, 1)
          end

          -- per-segment offsets (jitter, waveform, etc)
          local thisOffset = {0, 0}
          if chainList.jitter then
            thisOffset = vec2.add(thisOffset, {0, (math.random() - 0.5) * chainList.jitter})
          end
          if chainList.waveform then
            local angle = ((i * chainList.segmentSize) - (os.clock() * (chainList.waveform.movement or 0))) / (chainList.waveform.frequency / math.pi)
            local sineVal = math.sin(angle) * chainList.waveform.amplitude * 0.5
            thisOffset = vec2.add(thisOffset, {0, sineVal})
          end

          local segmentAngle = chainListStartAngle + (i - 1) * chainListDirection * (arcAngle / segmentCount)

          thisOffset = vec2.rotate(thisOffset, chainListVec[1] >= 0 and segmentAngle or -segmentAngle)
          
          local segmentPos = vec2.add(currentBaseOffset, thisOffset)
          local drawable = {
            image = image,
            centered = true,
            mirrored = chainListVec[1] < 0,
            rotation = segmentAngle,
            position = segmentPos,
            fullbright = chainList.fullbright or false
          }

		  local dataDrawable = {}
		  dataDrawable.renderLayer = chainList.renderLayer
		  dataDrawable.drawable = drawable
		  localAnimator.addDrawable(dataDrawable.drawable, dataDrawable.renderLayer)
		  --world.sendEntityMessage(entity.id(), "extraarms_localAnimator", "addDrawable", dataDrawable)
		  --sb.logInfo("Succesfully messaged the entity!")
          if chainList.light then
		    local dataLight = {}
			dataLight.light = {
              position = segmentPos,
              color = chainList.light,
            }
			localAnimator.addLightSource(dataLight.light)
		    --world.sendEntityMessage(entity.id(), "extraarms_localAnimator", "addLightSource", data)
          end

          segmentOffset = vec2.rotate(segmentOffset, arcAngle / segmentCount)
          currentBaseOffset = vec2.add(currentBaseOffset, segmentOffset)
        end
      end
    end
  end
end