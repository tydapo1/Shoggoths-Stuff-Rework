require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rope.lua"

function init()
	self.fireOffset = config.getParameter("fireOffset")
	self.ropeOffset = config.getParameter("ropeOffset")
	self.ropeVisualOffset = config.getParameter("ropeVisualOffset")
	self.consumeOnUse = config.getParameter("consumeOnUse")
	self.projectileType = config.getParameter("projectileType")
	self.projectileParameters = config.getParameter("projectileParameters")
	self.reelInDistance = config.getParameter("reelInDistance")
	self.reelOutLength = config.getParameter("reelOutLength")
	self.breakLength = config.getParameter("breakLength")
	self.minSwingDistance = config.getParameter("minSwingDistance")
	self.reelSpeed = config.getParameter("reelSpeed")
	self.controlForce = config.getParameter("controlForce")
	self.groundLagTime = config.getParameter("groundLagTime")
	ropeColor = config.getParameter("ropeColor")
	ropeColor2 = config.getParameter("ropeColor2")

	self.rope = {}
	self.ropeLength = 0
	self.aimAngle = 0
	self.onGround = false
	self.onGroundTimer = 0
	self.facingDirection = 0
	self.projectileId = nil
	self.projectilePosition = nil
	self.anchored = false
	self.anchoredSFX = false
	self.previousMoves = {}
	self.previousFireMode = nil
end

function uninit()
	cancel()
end

-- Usage: hex2rgb("#a85636") result: 
function hex2rgb(hex)
	hex = hex:gsub("#","")
	local rgbValue = tonumber("0x"..hex:sub(1,2)) .. "," .. tonumber("0x"..hex:sub(3,4)) .. "," .. tonumber("0x"..hex:sub(5,6))
	return rgbValue
end

-- local myString = "100, 200, 300, 400"
-- local splited = myString:split(",") it can be any delimiter
-- Result: Splited = {100, 200, 300, 400}
function string:split( inSplitPattern, outResults )
	if not outResults then
		outResults = { }
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	while theSplitStart do
		table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	end
	table.insert( outResults, string.sub( self, theStart ) )
	return outResults
end

function update(dt, fireMode, shiftHeld, moves)
	if config.getParameter("brandnew") then
		local portrait = world.entityPortrait(entity.id(), "full")
		--sb.logInfo("%s", sb.printJson(portrait))
		for key, value in pairs(portrait) do
			if (string.find(portrait[key].image, "body.png") and (hasStatus("srm_eldritchracial"))) then
				local body_image =	portrait[key].image
				local directive_location = string.find(body_image, "replace")
				local bodyDirectives = string.sub(body_image,directive_location)
				activeItem.setInstanceValue("inventoryIcon", "srm_shoggotharmicon.png?" .. bodyDirectives)
				self.projectileParameters.processing = "?" .. bodyDirectives
				activeItem.setInstanceValue("projectileParameters", self.projectileParameters) --41446f 323660
				--sb.logInfo("%s", sb.print(bodyDirectives))
				local colorHex1 = "bleh"
				local colorHex2 = "bluh"
				local red1 = 255
				local red2 = 255
				local green1 = 255
				local green2 = 255
				local blue1 = 255
				local blue2 = 255
				local rgb1 = "0"
				local rgb2 = "0"
				colorHex1 = bodyDirectives:match("41446f=(%x+)")
				colorHex2 = bodyDirectives:match("323660=(%x+)")
				--sb.logInfo("%s", sb.print(colorHex1))
				--sb.logInfo("%s", sb.print(colorHex2))
				rgb1 = hex2rgb("#" .. colorHex1)
				rgb2 = hex2rgb("#" .. colorHex2)
			
				local myString = rgb1
				local splited = myString:split(",")
				local myString2 = rgb2
				local splited2 = myString2:split(",")
			
				activeItem.setInstanceValue("ropeColor", splited)
				activeItem.setInstanceValue("ropeColor2", splited2)
				activeItem.setInstanceValue("brandnew", false)
			elseif not hasStatus("srm_eldritchracial") then
				activeItem.setInstanceValue("description", "This eldritch arm can stretch REALLY far!")
				activeItem.setInstanceValue("shortdescription", "Eldritch Arm")
				activeItem.setInstanceValue("brandnew", false)
			end
		end
	end

	if fireMode == "primary" and self.previousFireMode ~= "primary" then
		if self.projectileId then
			cancel()
		elseif status.stat("activeMovementAbilities") < 1 then
			fire()
		end
	end
	self.previousFireMode = fireMode

	self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
	activeItem.setFacingDirection(self.facingDirection)

	trackGround(dt)
	trackProjectile()

	if self.projectileId then
		if world.entityExists(self.projectileId) then
			local position = mcontroller.position()
			local handPosition = vec2.add(position, activeItem.handPosition(self.ropeOffset))

			local newRope
			if #self.rope == 0 then
				newRope = {handPosition, self.projectilePosition}
			else
				newRope = copy(self.rope)
				table.insert(newRope, 1, world.nearestTo(newRope[1], handPosition))
				table.insert(newRope, world.nearestTo(newRope[#newRope], self.projectilePosition))
			end

			windRope(newRope)
			updateRope(newRope)

			if not self.anchored and self.ropeLength > self.reelOutLength then
				cancel()
			end
		else
			cancel()
		end
	end

	if self.ropeLength > self.breakLength then
		cancel()
	end

	if self.anchored then
		if not self.anchoredSFX then animator.playSound("collide") self.anchoredSFX = true end
		swing(moves)
	else
		if self.anchoredSFX then self.anchoredSFX = false end
		activeItem.setArmAngle(self.aimAngle)
	end
end

function trackProjectile()
	if self.projectileId then
		if world.entityExists(self.projectileId) then
			local position = mcontroller.position()
			self.projectilePosition = vec2.add(world.distance(world.entityPosition(self.projectileId), position), position)
			if not self.anchored then
				self.anchored = world.callScriptedEntity(self.projectileId, "anchored")
			end
		else
			cancel()
		end
	end
end

function trackGround(dt)
	if mcontroller.onGround() then
		self.onGround = true
		self.onGroundTimer = self.groundLagTime
	else
		self.onGroundTimer = self.onGroundTimer - dt
		if self.onGroundTimer < 0 then
			self.onGround = false
		end
	end
end

function fire()
	cancel()

	local aimVector = vec2.rotate({1, 0}, self.aimAngle)
	aimVector[1] = aimVector[1] * self.facingDirection

	self.projectileId = world.spawnProjectile(
		self.projectileType,
		firePosition(),
		activeItem.ownerEntityId(),
		aimVector,
		false,
		self.projectileParameters
	)

	if self.projectileId then
		animator.playSound("fire")
		status.setPersistentEffects("grapplingHook"..activeItem.hand(), {{stat = "activeMovementAbilities", amount = 0.5}})
	end
end

function cancel()
	if self.projectileId and world.entityExists(self.projectileId) then
		world.callScriptedEntity(self.projectileId, "kill")
	end
	if self.projectileId and self.anchored and self.consumeOnUse then
		item.consume(1)
	end
	self.projectileId = nil
	self.projectilePosition = nil
	self.anchored = false
	updateRope({})
	status.clearPersistentEffects("grapplingHook"..activeItem.hand())
end

function swing(moves)
	local canReel = self.ropeLength > self.reelInDistance or world.magnitude(self.rope[2], mcontroller.position()) > self.reelInDistance

	local armAngle = activeItem.aimAngle(self.fireOffset[2], self.rope[2])
	local pullDirection = vec2.withAngle(armAngle)
	activeItem.setArmAngle(self.facingDirection == 1 and armAngle or math.pi - armAngle)

	if world.magnitude(self.projectilePosition, mcontroller.position()) < self.minSwingDistance then
		--do nothing
	elseif self.onGround then
		if (moves.up and canReel) or self.ropeLength > self.reelOutLength then
			mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
		end
	else
		if moves.down and self.ropeLength < self.reelOutLength then
			mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), -self.reelSpeed, self.controlForce, true)
		elseif moves.up and canReel then
			mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), self.reelSpeed, self.controlForce, true)
		elseif pullDirection[2] > 0 or self.ropeLength > self.reelOutLength then
			mcontroller.controlApproachVelocityAlongAngle(vec2.angle(pullDirection), 0, self.controlForce, true)
		end

		if moves.jump and not self.previousMoves.jump then
			if not mcontroller.canJump() then
				mcontroller.controlJump(true)
			end
			cancel()
		end
	end

	self.previousMoves = moves
end

function firePosition()
	local entityPos = mcontroller.position()
	local barrelOffset = activeItem.handPosition(self.fireOffset)
	local barrelPosition = vec2.add(entityPos, barrelOffset)
	local collidePoint = world.lineCollision(entityPos, barrelPosition)
	if collidePoint then
		return vec2.add(entityPos, vec2.mul(barrelOffset, vec2.mag(barrelOffset) - 0.5))
	else
		return barrelPosition
	end
end

function updateRope(newRope)
	local position = mcontroller.position()
	local previousRopeCount = #self.rope
	self.rope = newRope
	self.ropeLength = 0

	activeItem.setScriptedAnimationParameter("ropeOffset", self.ropeVisualOffset)
	for i = 2, #self.rope do
		self.ropeLength = self.ropeLength + world.magnitude(self.rope[i], self.rope[i - 1])
		activeItem.setScriptedAnimationParameter("p" .. i, self.rope[i])
	end
	for i = #self.rope + 1, previousRopeCount do
		activeItem.setScriptedAnimationParameter("p" .. i, nil)
	end
end

--finds status, returns true if it is found
function hasStatus(theStatusInQuestion)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == theStatusInQuestion) then
				return true
			end
		end		 
	end
	return false
end