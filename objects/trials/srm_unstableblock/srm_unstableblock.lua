function init()
	fullMaterialSpaces = {}
	emptyMaterialSpaces = {}
	updateSpaces()
	resetTimerMax = 10
	resetTimer = 9
	sand = true
	sensorConfig = {}
	sensorConfig.detectEntityTypes = {"Player"}
	sensorConfig.detectBoundMode = "CollisionArea"
	sensorConfig.detectDuration = 0.1
	local bb = object.boundBox()
	bb[1] = bb[1] + 1
	bb[2] = bb[2] + 1
	bb[3] = bb[3] - 1
	bb[4] = bb[4] - 1
	local pbb = object.boundBox()
	pbb[3] = (pbb[3] - pbb[1]) - 1.75
	pbb[4] = (pbb[4] - pbb[2]) - 1.75
	pbb[1] = 0.25
	pbb[2] = 0.25
	animator.setParticleEmitterOffsetRegion("sand", pbb)
	sensorConfig.detectArea = {
		{bb[1]+0.35, bb[4]},
		{bb[3]-0.35, bb[4]+1}
	}
end

function update(dt)
	if (animator.animationState("doorState") == "full") then
		resetTimer = 0
		object.setMaterialSpaces(fullMaterialSpaces)
		local entityIds = world.entityQuery(sensorConfig.detectArea[1], sensorConfig.detectArea[2], {
			withoutEntityId = entity.id(),
			includedTypes = sensorConfig.detectEntityTypes,
			boundMode = sensorConfig.detectBoundMode
		})
		if #entityIds > 0 then
			animator.setAnimationState("doorState", "emptying", true)
		end
		animator.setParticleEmitterActive("sand", false)
	elseif (animator.animationState("doorState") == "emptying") then
		resetTimer = 0
		object.setMaterialSpaces(fullMaterialSpaces)
		animator.setParticleEmitterActive("sand", true)
		if sand then sand = false animator.playSound("sandobjectfall", 0) end
	else
		resetTimer = resetTimer + dt
		object.setMaterialSpaces(emptyMaterialSpaces)
		animator.setParticleEmitterActive("sand", false)
		animator.setSoundVolume("sandobjectfall", 0.0, 1.0)
	end
	if resetTimer >= resetTimerMax then
		sand = true
		animator.setSoundVolume("sandobjectfall", 1.0, 0.0)
		animator.stopAllSounds("sandobjectfall")
		animator.setAnimationState("doorState", "full", true)
		resetTimer = 0
	end
end

function updateSpaces()
	fullMaterialSpaces = {}
	for i, space in ipairs(object.spaces()) do
		table.insert(fullMaterialSpaces, {space, "metamaterial:door"})
	end
	emptyMaterialSpaces = {}
end