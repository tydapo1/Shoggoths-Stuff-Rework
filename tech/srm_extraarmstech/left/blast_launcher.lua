function left_blast_launcher_init()
	left_blast_launcher_ammoMax = math.ceil(5 * (status.stat("maxEnergy") / 100))
	left_blast_launcher_ammo = left_blast_launcher_ammoMax
	left_blast_launcher_recoil = {-200.0,0}
	left_blast_launcher_preventAutofire = false
	left_blast_launcher_damage = 10
	left_blast_launcher_projectileParameters = {
		knockback=left_blast_launcher_damage*5,
		power=left_blast_launcher_damage*status.stat("powerMultiplier"),
		piercing=true,
		timeToLive=0.0,
		damageKind="hidden",
		damageTeam={type="friendly"},
		actionOnReap={{action="config",file="/projectiles/explosions/regularexplosion2/regularexplosionknockback.config"}}
	}
end

function left_blast_launcher_update(args, dt)
	if (mcontroller.onGround() or mcontroller.zeroG()) then left_blast_launcher_ammo = left_blast_launcher_ammoMax end
	if ((args.moves["primaryFire"]) and (not left_blast_launcher_preventAutofire)) then
		if (left_blast_launcher_ammo > 0) then
			animator.playSound("leftblast_launchershoot", 0)
			left_blast_launcher_ammo = left_blast_launcher_ammo - 1
			-- recoil
			local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
			local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
			world.spawnProjectile("invisibleprojectile", pos, entity.id(), direction, false, left_blast_launcher_projectileParameters)
			local finalVector = vec2.div((vec2.rotate(left_blast_launcher_recoil, extraarmstech_leftAngle)), 2)
			--mcontroller.setVelocity(finalVector)
			mcontroller.controlApproachVelocity(finalVector, 5000)
		else
			animator.playSound("leftblast_launcherempty", 0)
		end
		left_blast_launcher_preventAutofire = true
		left_blast_launcher_idleTimer = 0
		left_blast_launcher_firstReload = true
		left_blast_launcher_firstBullet = true
	end
	if ((not args.moves["primaryFire"]) and (left_blast_launcher_preventAutofire)) then
		left_blast_launcher_preventAutofire = false
	end
end

function left_blast_launcher_uninit()
	left_blast_launcher_ammo = 0
end