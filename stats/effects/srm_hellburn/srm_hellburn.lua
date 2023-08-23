function init()
	animator.setParticleEmitterOffsetRegion("hellflames", mcontroller.boundBox())
	animator.setParticleEmitterActive("hellflames", true)
	effect.setParentDirectives("fade=9bba3d=0.25")
	animator.playSound("burn", -1)
	
	script.setUpdateDelta(5)

	self.tickDamagePercentage = 0.01
	self.tickTime = 0.4
	self.tickTimer = self.tickTime
end

function update(dt)
	self.tickTimer = self.tickTimer - dt
	if self.tickTimer <= 0 then
		self.tickTimer = self.tickTime
		status.applySelfDamageRequest({
			damageType = "IgnoresDef",
			damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
			damageSourceKind = "fire",
			sourceEntityId = entity.id()
		})
	end
end

function uninit()
	
end
