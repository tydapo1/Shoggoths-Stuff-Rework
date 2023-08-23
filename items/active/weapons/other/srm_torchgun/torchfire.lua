require "/scripts/util.lua"
require "/scripts/interp.lua"

-- Base gun fire ability
GunFire = WeaponAbility:new()

function GunFire:init()
	self.weapon:setStance(self.stances.idle)

	self.cooldownTimer = self.fireTime

	self.weapon.onLeaveAbility = function()
		self.weapon:setStance(self.stances.idle)
	end
	
	self.delayTimerReset = self.delayBetweenProjectiles
	self.delayTimer = self.delayTimerReset
	self.projectilesLeftToFire = 0
end

function GunFire:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)

	self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

	if animator.animationState("firing") ~= "fire" then
		animator.setLightActive("muzzleFlash", false)
	end

	if self.fireMode == (self.activatingFireMode or self.abilitySlot)
		and not self.weapon.currentAbility
		and self.cooldownTimer == 0
		and (player.hasCountOfItem("torch") > (projectileCount or self.projectileCount)-1)
		and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

		if self.fireType == "auto" and player.consumeItem({name="torch",count=(projectileCount or self.projectileCount)}) then
			self:setState(self.auto)
		elseif self.fireType == "burst" then
			self:setState(self.burst)
		end
	end
	
	if self.projectilesLeftToFire > 0 then
		if self.delayTimer <= 0 then
			self:muzzleFlash()
			self.delayTimer = self.delayTimerReset
			self.projectilesLeftToFire = self.projectilesLeftToFire - 1
			local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
			params.power = self:damagePerShot()
			params.powerMultiplier = activeItem.ownerPowerMultiplier()
			params.speed = util.randomInRange(params.speed)

			if not projectileType then
				projectileType = self.projectileType
			end
			if type(projectileType) == "table" then
				projectileType = projectileType[math.random(#projectileType)]
			end
		
			if params.timeToLive then
				params.timeToLive = util.randomInRange(params.timeToLive)
			end
		
			params.targetPosition = self:aimTarget(inaccuracy or self.inaccuracy)
			if ((projectileCount or self.projectileCount)>1) then
				params.targetPosition = {0,0}
			end

			animator.playSound("bigfire")
			projectileId = world.spawnProjectile(
				projectileType,
				firePosition or self:firePosition(),
				activeItem.ownerEntityId(),
				self:aimVector(inaccuracy or self.inaccuracy),
				false,
				params
			)
		else
			self.delayTimer = self.delayTimer - dt
		end
	end
end

function GunFire:auto()
	self.weapon:setStance(self.stances.fire)

	self:fireProjectile()
	self:muzzleFlash()

	if self.stances.fire.duration then
		util.wait(self.stances.fire.duration)
	end

	self.cooldownTimer = self.fireTime
	self:setState(self.cooldown)
end

function GunFire:burst()
	self.weapon:setStance(self.stances.fire)

	local shots = self.burstCount
	while shots > 0 and player.consumeItem({name="torch",count=(projectileCount or self.projectileCount)}) do
		self:fireProjectile()
		self:muzzleFlash()
		shots = shots - 1

		self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
		self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

		util.wait(self.burstTime)
	end

	self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

function GunFire:cooldown()
	self.weapon:setStance(self.stances.cooldown)
	self.weapon:updateAim()

	local progress = 0
	util.wait(self.stances.cooldown.duration, function()
		local from = self.stances.cooldown.weaponOffset or {0,0}
		local to = self.stances.idle.weaponOffset or {0,0}
		self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

		self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
		self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

		progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
	end)
end

function GunFire:muzzleFlash()
	animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
	animator.setAnimationState("firing", "fire")
	animator.burstParticleEmitter("muzzleFlash")
	if (not ((projectileCount or self.projectileCount) > 1)) then
		animator.playSound("fire")
	end

	animator.setLightActive("muzzleFlash", true)
end

function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
	local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
	params.power = self:damagePerShot()
	params.powerMultiplier = activeItem.ownerPowerMultiplier()
	params.speed = util.randomInRange(params.speed)

	if not projectileType then
		projectileType = self.projectileType
	end
	if type(projectileType) == "table" then
		projectileType = projectileType[math.random(#projectileType)]
	end

	local projectileId = 0
	if (projectileCount or self.projectileCount)>1 then
		self.projectilesLeftToFire = (projectileCount or self.projectileCount)
	else
		for i = 1, (projectileCount or self.projectileCount) do
			if params.timeToLive then
				params.timeToLive = util.randomInRange(params.timeToLive)
			end
		
			params.targetPosition = self:aimTarget(inaccuracy or self.inaccuracy)
			if ((projectileCount or self.projectileCount)>1) then
				params.targetPosition = {0,0}
			end

			projectileId = world.spawnProjectile(
				projectileType,
				firePosition or self:firePosition(),
				activeItem.ownerEntityId(),
				self:aimVector(inaccuracy or self.inaccuracy),
				false,
				params
			)
		end
	end
	return projectileId
end

function GunFire:firePosition()
	return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function GunFire:aimVector(inaccuracy)
	local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
	aimVector[1] = aimVector[1] * mcontroller.facingDirection()
	return aimVector
end

function GunFire:aimTarget(inaccuracy)
	local aimTarget = vec2.rotate(world.distance(activeItem.ownerAimPosition(), mcontroller.position()), sb.nrand(inaccuracy, 0))
	aimTarget[1] = aimTarget[1] + mcontroller.position()[1]
	aimTarget[2] = aimTarget[2] + mcontroller.position()[2]
	return aimTarget
end

function GunFire:energyPerShot()
	return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function GunFire:damagePerShot()
	return (self.baseDamageMultiplier or 1.0)
end

function GunFire:uninit()
end
