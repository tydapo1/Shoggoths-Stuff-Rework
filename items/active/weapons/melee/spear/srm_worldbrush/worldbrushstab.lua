require "/items/active/weapons/melee/meleeslash.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
WorldBrushStab = MeleeSlash:new()

function WorldBrushStab:init()
	MeleeSlash.init(self)

	self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
	self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
end

function WorldBrushStab:fire()
	animator.setAnimationState("drill", "active")

	MeleeSlash.fire(self)

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