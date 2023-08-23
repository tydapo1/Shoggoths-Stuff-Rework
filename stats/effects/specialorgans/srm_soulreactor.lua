function init()
	self.minRange = config.getParameter("minRange") or 0.5
	self.damageProjectileType = "srm_soulreactorheartexplosion"
	self.border = config.getParameter("border")

	self.cooldown = config.getParameter("cooldown") or 1

	self.minTriggerDamage = 0

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
		self.damageMultiplier = status.stat("powerMultiplier") or 1
		triggerThorns(5 * self.damageMultiplier)
		self.cooldownTimer = self.cooldown
	end

	if self.cooldownTimer > 0 then
		self.cooldownTimer = self.cooldownTimer - dt
	end

	if self.triggerThorns then
		self.thornsTimer = self.thornsTimer - dt
	end
end

function triggerThorns(damage)
	local damageConfig = {
		power = damage,
		speed = 0,
		physics = "default"
	}
	world.spawnProjectile(self.damageProjectileType, mcontroller.position(), entity.id(), {0, 0}, true, damageConfig)
end
