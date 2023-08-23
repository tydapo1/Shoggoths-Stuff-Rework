require "/scripts/vec2.lua"
require "/items/active/weapons/melee/meleeslash.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
WorldBrushStab = MeleeSlash:new()

function WorldBrushStab:init()
	MeleeSlash.init(self)
	energyConsume = 40
	specialTotalDamage = 50
	specialMaxSpread = 1.0
	specialProjectileAmnt = 7

	self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
	self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
end

function WorldBrushStab:fire()
	animator.setAnimationState("drill", "active")
	
	MeleeSlash.fire(self)
	if (not status.resourceLocked("energy") and (animator.animationState("interfacing") == "idle")) then
		status.overConsumeResource("energy", energyConsume)
		local tipPosition = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("spearpaint", "dotLocation")))
		local handPosition = vec2.add(mcontroller.position(), activeItem.handPosition())
		local aimAngle = world.distance(tipPosition, handPosition)
		for i=0,(specialProjectileAmnt-1) do
			local angle = (specialMaxSpread/2) - (specialMaxSpread/(specialProjectileAmnt-1)) * i
			world.spawnProjectile("srm_inkbucket", tipPosition, activeItem.ownerEntityId(), vec2.rotate(aimAngle, angle), false, { power = (specialTotalDamage/specialProjectileAmnt) * status.stat("powerMultiplier") })
		end
	end

	animator.setAnimationState("drill", "idle")

	if ((self.fireMode == "primary" or self.fireMode == "alt") and self.allowHold ~= false) then
		self:setState(self.hold)
	end
end

function WorldBrushStab:hold()
	self.weapon:setStance(self.stances.hold)
	self.weapon:updateAim()

	animator.setAnimationState("drill", "active")

	while (self.fireMode == "primary" or self.fireMode == "alt") do
		local damageArea = partDamageArea("spear")
		self.weapon:setDamage(self.holdDamageConfig, damageArea)
		coroutine.yield()
	end

	animator.setAnimationState("drill", "idle")
	
	self.cooldownTimer = self:cooldownTime()
end

--local tipPosition = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("spearpaint", "dotLocation")))
	--local coords = activeItem.aimAngleAndDirection(0, entity.position())
	--sb.logInfo(sb.print(tipPosition))