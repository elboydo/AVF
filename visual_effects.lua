
function fire(gun,barrelCoords)
    if(gun.mouseDownSound and getPlayerMouseDown())then
    	if(not gun.loopSoundFile)then 
			PlaySound(gun.mouseDownSound, barrelCoords.pos, 50, false)
		end
    elseif(not gun.tailOffSound or not getPlayerMouseDown())then
    	PlaySound(gun.sound, barrelCoords.pos, 50, false)
    	-- PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],barrelCoords.pos, 400, false)
		
    end


	if(not oldShoot)then
		if(gun.weaponType =="special") then 
			pushSpecial(barrelCoords,gun)
		--	DebugWatch("USING",gun.name)
		else
			pushProjectile(barrelCoords,gun)
		end
	else 
		local cannonLoc=  barrelCoords--rectifyBarrelCoords(gun)
			QueryRejectBody(vehicle.body)
			QueryRejectShape(gun.id)
			local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1),1)
		    local direction = VecSub(fwdPos, cannonLoc.pos)
		    direction = VecNormalize(direction)
		    QueryRequire("physical")
		    hit, dist = QueryRaycast(cannonLoc.pos, direction, maxDist)
		    -- utils.printStr(dist)

		    if hit then
				hitPos = TransformToParentPoint(cannonLoc, Vec(0, dist * -1,0))
			else
				hitPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1,0))
			end
		      	p = cannonLoc.pos

				d = VecNormalize(VecSub(hitPos, p))
				spread = 0.03
				d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d = VecNormalize(d)
				p = VecAdd(p, VecScale(d, 0.5))
				

				-- if(gun.highVelocityShells)then
						-- utils.printStr(gun.loadedMagazine)--type(munitions[gun.magazines[gun.loadedMagazine].name]))
					-- if (gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth and hit) then
							
					-- 	cannonLoc.pos = hitPos
					-- 	pushShell(gun,hitPos,dist,(maxDist-dist),cannonLoc)

					-- else

					-- 	pushShell(gun,hitPos,dist)
					-- end
				-- else
					Shoot(p, d,0)
				-- end		
	end

	

end


---



----

---- specials

-----

function pushSpecial(barrelCoords,gun)
	fireFoam(barrelCoords,gun)
end



function fireFoam(cannonLoc,gun)

	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,-1,0))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	local p = cannonLoc.pos

	local shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
	local predictedBulletVelocity = VecScale(direction,shellType.velocity)

	local q = 1.0 
	for i=1, 64 do
		
		local v = VecAdd(VecScale(predictedBulletVelocity,rnd(7,14)/10),rndVec(shellType.velocity/5))---VecNormalize(direction)--rndVec(projectile.weaponClass.ammo.caliber*0.3)
		local radius = 1
		radius = rnd(radius/2,radius*2) *0.01
		local stretch = rnd(-1,1)
		local endStretch = rnd(-1,1)
		local life = rnd(0.2, 0.7)*30
		life = 0.5 + life*life*life * 0.7

		local w = 0.8-q*0.6
		local w2 = 1.0
		local r = 0.5 *(0.5 + 0.5*q)
		ParticleReset()
		ParticleTile(2)
		ParticleType("smoke")
		ParticleCollide(0.1, 1)
		ParticleFlags(256)
		ParticleColor(w*(rnd(3,6)/10), w*(rnd(3,6)/10), w, w2*(rnd(4,6)/10), w2*(rnd(4,6)/10), w2)
		ParticleRadius(0.5*r, r)
		ParticleGravity(rnd(-2,-20))
		ParticleDrag(0.01)
		ParticleSticky(0.02)
		ParticleAlpha(q, q, "constant", 0, 0.5)
		SpawnParticle(p, v, rnd(3,5))

	end
end


