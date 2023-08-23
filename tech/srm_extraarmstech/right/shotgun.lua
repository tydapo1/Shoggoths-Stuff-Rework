function right_shotgun_init()
	right_shotgun_ammoMax = math.ceil(6 * (status.stat("maxEnergy") / 100))
	right_shotgun_ammo = right_shotgun_ammoMax
	right_shotgun_recoil = {-66.0,0}
	right_shotgun_preventAutofire = false
	right_shotgun_idleTimerMax = 1.5
	right_shotgun_idleTimer = 0
	right_shotgun_firstReload = true
	right_shotgun_firstBullet = true
	right_shotgun_frameArray = {"idle", 1, 2, 3, 4, 5}
	right_shotgun_currentFrame = 1
	right_shotgun_animationTimerDelay = 3
	right_shotgun_animationTimer = 0
	right_shotgun_totaldamage = 25 * status.stat("powerMultiplier")
	right_shotgun_bulletsperclick = 25
	right_shotgun_damageperbullet = right_shotgun_totaldamage / right_shotgun_bulletsperclick
end

function right_shotgun_update(args, dt)
	if ((args.moves["altFire"]) and (not right_shotgun_preventAutofire)) then
		if (right_shotgun_ammo > 0) then
			animator.playSound("rightshotgunshoot", 0)
			right_shotgun_ammo = right_shotgun_ammo - 1
			right_shotgun_spawnBullets()
			-- recoil
			local finalVector = vec2.div((vec2.rotate(right_shotgun_recoil, extraarmstech_rightAngle)), 2)
			mcontroller.addMomentum(finalVector)
		else
			animator.playSound("rightshotgunempty", 0)
		end
		animator.setGlobalTag("rightFrame", "idle")
		right_shotgun_preventAutofire = true
		right_shotgun_idleTimer = 0
		right_shotgun_animationTimer = right_shotgun_animationTimerDelay
		right_shotgun_firstReload = true
		right_shotgun_firstBullet = true
	end
	if ((not args.moves["altFire"]) and (right_shotgun_preventAutofire)) then
		right_shotgun_preventAutofire = false
	end
	if ((not args.moves["altFire"]) and (not right_shotgun_preventAutofire)) then
		if (not (right_shotgun_ammo >= right_shotgun_ammoMax)) then
			if (right_shotgun_idleTimer < right_shotgun_idleTimerMax) then
				right_shotgun_idleTimer = right_shotgun_idleTimer + dt
			else
				if (right_shotgun_animationTimer <= 0) then
					right_shotgun_animationTimer = right_shotgun_animationTimerDelay
					if (right_shotgun_currentFrame == 1) then
						if (right_shotgun_firstReload) then
							animator.playSound("rightshotgunreloadfirst", 0)
							right_shotgun_firstReload = false
							right_shotgun_animationTimer = right_shotgun_animationTimer + 10
						--else
							--animator.playSound("rightshotgunreload", 0)
						end
					end
					if ((right_shotgun_currentFrame == 6) and (not right_shotgun_firstBullet)) then
						right_shotgun_ammo = right_shotgun_ammo + 1
						animator.playSound("rightshotgunreload", 0)
					end
					if ((right_shotgun_currentFrame == 6) and (right_shotgun_firstBullet)) then
						right_shotgun_firstBullet = false
					end
					local nextFrame = right_shotgun_currentFrame + 1
					if (nextFrame > #right_shotgun_frameArray) then
						nextFrame = 1
					end
						animator.setGlobalTag("rightFrame", "active." .. right_shotgun_frameArray[nextFrame])
						right_shotgun_currentFrame = nextFrame
				else
					right_shotgun_animationTimer = right_shotgun_animationTimer - 1
				end
			end
		end
	end
end

function right_shotgun_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	right_shotgun_ammo = 0
end

function right_shotgun_spawnBullets()
	for i=1,right_shotgun_bulletsperclick do
		right_shotgun_spawnBullet()
	end
	local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
	local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
	world.spawnProjectile("srm_extraarms_muzzleflash", pos, entity.id(), direction, true)
end

function right_shotgun_spawnBullet()
	local pos = vec2.add(animator.partPoint("rightFist", "bulletSpawn"),entity.position())
	local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
	local spread = (math.random() - 0.5) * 0.1 * math.pi
	direction = vec2.rotate(direction, spread)
	world.spawnProjectile("bullet-1", pos, entity.id(), direction, false, {knockback=50,piercing=false,power=right_shotgun_damageperbullet})
end