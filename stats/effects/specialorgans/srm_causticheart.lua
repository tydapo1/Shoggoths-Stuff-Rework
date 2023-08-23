function init()
	self.minRange = config.getParameter("minRange") or 0.5

	self.visualProjectileType = "money"
	self.visualProjectileCount = 25
	self.visualProjectileSpeed = 10
	self.visualProjectileTime = 0
	self.visualDuration = 0
	self.damageStored = 0
	self.damageCap = 0.9*status.resourceMax("health")

	self.damageProjectileType = "money"
	self.damageMultiplier = 0.00
	self.border = config.getParameter("border")

	self.cooldown = 0

	self.minTriggerDamage = config.getParameter("minTriggerDamage") or 0

	resetThorns()
	self.cooldownTimer = 0

	if self.border then
		effect.setParentDirectives("border="..self.border)
	end

	self.queryDamageSince = 0
end

function resetThorns()
	self.cooldownTimer = self.cooldown
	self.triggerThorns = false
	self.thornsTimer = 0
	self.spawnedThorns = 0
	self.thornDamage = 0
end

function update(dt)
	if self.cooldownTimer <= 0 then
		local damageNotifications, nextStep = status.damageTakenSince(self.queryDamageSince)
		self.queryDamageSince = nextStep
		for _, notification in ipairs(damageNotifications) do
			if notification.healthLost > self.minTriggerDamage and notification.sourceEntityId ~= notification.targetEntityId then
				self.damageStored = self.damageStored + notification.healthLost
				self.cooldownTimer = self.cooldown
				break
			end
		end
	end

	if self.cooldownTimer > 0 then
		self.cooldownTimer = self.cooldownTimer - dt
	end
	
	if self.damageStored >= self.damageCap then
		world.spawnProjectile("srm_selfdestruct", mcontroller.position(), entity.id(), {0,0}, false, {power = (50*status.stat("powerMultiplier"))})
		self.damageStored = 0
	end
end