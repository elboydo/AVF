

--[[ debug stuff ]]


function debug_draw_x_y_z(t)
				--red = x axis
			draw_line_from_transform(t,-.1,0,0,	1,0,0)
			
			-- green = z axis
			draw_line_from_transform(t,0,0,-0.1,	0,1,0)

			-- blue = y axis 
			draw_line_from_transform(t,0,-.1,0,	0,0,1)
end


function draw_line_from_transform(t,x,y,z,r,g,b)
	r = (r ~= nil and r) or 0
	g = (g ~= nil and g) or 0
	b = (b ~= nil and b) or 0

	for i =1,10 do 
		local newpos = TransformToParentPoint(t,Vec(x*i,y*i,z*i))

		DebugCross(newpos,r,g,b)
	end


end


--- taken from evertide mall tank script 
function drawReticleSprite(t)
	t.rot = QuatLookAt(t.pos, GetCameraTransform().pos)
	-- t.rot = QuatLookAt(t.pos, GetBodyTransform(body).pos)
	local tr = QuatEuler(0,0,GetTime()*60)
	t.rot = QuatRotateQuat(t.rot,tr)

	local size = 1.2

	if(vehicle.artillery_weapon) then 
		size = size * 3
	end

	DrawSprite(reticle1, t, size, size, .5, 0, 0, 1, false, false)
	DrawSprite(reticle1, t, size, size, .5, 0, 0, 1, true, false)

	local tr = QuatEuler(0,0,GetTime()*-80)
	t.rot = QuatRotateQuat(t.rot,tr)
	
	DrawSprite(reticle2, t, size, size, .5, 0, 0, 1, false, false)
	DrawSprite(reticle2, t, size, size, .5, 0, 0, 1, true, false)
	
	local tr = QuatEuler(0,0,GetTime()*100)
	t.rot = QuatRotateQuat(t.rot,tr)

	DrawSprite(reticle3, t, size, size, .5, 0, 0, 1, false, false)
	DrawSprite(reticle3, t, size, size, .5, 0, 0, 1, true, false)
end



function draw()
	local visible	 = 1

	inVehicle, vehicleid = playerInVehicle()
	if(inVehicle)then
		vehicle = vehicles[vehicleid].vehicle
		vehicleFeatures = vehicles[vehicleid].vehicleFeatures
	end

	--Only draw speedometer if visible
	if(inVehicle and not viewingMap) then
		local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
		UiPush()
			if(vehicle.sniperMode and not vehicle.artillery_weapon)then
				for key,gun in pairs(gunGroup)	do 
					drawWeaponReticles(gun)	
				end
		end
		UiPop()
		
		UiPush()

		local status,retVal = pcall(draw_health_bars)
		if status then 
				-- utils.printStr("no errors")
		else
			DebugWatch("[GAMEPLAY TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end

		
		UiPop()

		UiPush()
		
		--Place it in upper right corner
		UiTranslate(UiWidth()+200 - 400*visible, 50)
		-- UiAlign("center middle")
		-- UiTranslate(0, 30)
		-- UiColor(0,0,0,.3)
		-- UiRect(300, 20+90)
		-- UiTranslate(0, -30)
		-- UiColor(1,1,1)
		UiFont("bold.ttf", 24)

		-- local weaponText =  string.format("%s%s\n%s", tag, title, tag)
		if(gunGroup~=nil and #gunGroup>0) then 
			for key,gun in pairs(gunGroup)	do 
					-- UiPush()
						UiAlign("center middle")
						UiTranslate(0, 40)
						UiColor(0,0,0,.3)
						UiRect(350, 10+90)
						UiTranslate(0, -30)
						UiColor(1,1,1)
						UiText(gun.name)
						-- if(not IsShapeBroken(gun.id))then	

						-- 	UiText(gun.name)
						-- else
						-- 	UiText(gun.name.." BROKEN")
						-- end
						
						UiTranslate(0, 40)
						
						
						getWeaponAmmoText(gun)--getWeaponAmmoText(gun))
						UiTranslate(0, 30)
					-- UiPop()
			end
		end
			UiPop()

		if(not GetBool("savegame.mod.hideControls")) then
			drawControls()
		end

			-- if GetBool("savegame.mod.mph") then
			-- 	UiImage("mph.png")
			-- 	--Convert to rotation for mph
			-- 	UiRotate(-displayKmh*2/1.609)
			-- else
			-- 	UiImage("kmh.png")
			-- 	--Convert to rotation for kmh
			-- 	UiRotate(-displayKmh)
			-- end
			-- UiImage("needle.png")

		if(not vehicle.sniperMode and not vehicle.artillery_weapon) then 

			drawDynamicReticle()
		end


	end
end

function progressBar(w, h, t)
	UiPush()
		UiAlign("left top")
		UiColor(0, 0, 0, 0.5)
		UiImageBox("ui/common/box-solid-10.png", w, h, 6, 6)
		if t > 0 then
			UiTranslate(2, 2)
			w = (w-4)*t
			if w < 12 then w = 12 end
			h = h-4
			UiColor(1,1,1,1)
			UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
		end
	UiPop()
end


function draw_health_bars()
	if unexpected_condition then error() end

	local min_vehicle_health = globalConfig.min_vehicle_health 
	drawHealth()
	UiPush()
		UiFont("bold.ttf", 20)
		UiTranslate(UiCenter(), UiHeight()-40)
		local health = GetFloat("game.vehicle.health")
		health = (health - min_vehicle_health) / (1-min_vehicle_health)
		UiTranslate(-100, 0)
		progressBar(200, 20, health)
		UiColor(1,1,1)
		UiTranslate(100, -12)
		UiAlign("center middle")
		UiText("VEHICLE CONDITION")
	UiPop()


end


function drawHealth()
	local health = GetFloat("game.player.health")
	local show = health <= 1

	local healthFade = 1
	if healthFade == 0 then
		return
	end

	UiPush()
		UiTranslate(UiWidth() - 144, UiHeight() - 44*healthFade)

		UiColor(0,0,0, 0.5)
		UiPush()
			UiColor(1,1,1)
			UiFont("bold.ttf", 24)
			UiTranslate(0, 22)
			if health < 0.1 then
				if math.mod(GetTime(), 1.0) < 0.5 then
					UiColor(1, 0, 0,  1.0)
				else
					UiColor(1, 0, 0,  0.1)
				end
			elseif health < 0.5 then
				UiColor(1, 0, 0)
			end
			UiAlign("right")
			UiText("HEALTH")
		UiPop()

		UiTranslate(10, 4)
		local w = 110
		local h = 20
		UiPush()
			UiAlign("left top")
			UiColor(0, 0, 0, 0.5)
			UiImageBox("ui/common/box-solid-10.png", w, h, 6, 6)
			if health > 0 then
				UiTranslate(2, 2)
				w = (w-4)*health
				if w < 12 then w = 12 end
				h = h-4
				UiColor(1,health*2,health,1)
				UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
			end
		UiPop()

	UiPop()
end


function drawControls()
		info = {}
		local target_controls =armedVehicleControls 
		local target_order = armedVehicleControlsOrder
		if(HasTag(vehicle.id,"artillery")) then 
				target_controls =armedVehicleControls_arty 
				target_order = armedVehicleControlsOrder_arty
		end

		for key,val in ipairs(target_order) do
			local inputKey = target_controls[val] 
			key = val	
			info[#info+1] = {inputKey,key}
		end
		if(vehicle.sniperMode) then 
			info[#info+1] = {"Scroll","Adjust Zoom"}
		end
		UiPush()
		UiAlign("top left")
		local w = 250
		local h = #info*22 + 30
		UiTranslate(UiWidth()-w-20, UiHeight()-h-20 - 200) -- because I don't know how big the official vehicle UI will be
		UiColor(0,0,0,0.5)
		UiImageBox("ui/common/box-solid-6.png", 250, h, 6, 6)
		UiTranslate(125, 32)
		UiColor(1,1,1)
		UiTranslate(-60, 0)
		for i=1, #info do
			
			local key = info[i][1]
			local func = info[i][2]
			UiFont("bold.ttf", 22)
			UiAlign("right")
			UiText(key)
			UiTranslate(10, 0)
			UiFont("regular.ttf", 22)
			UiAlign("left")
			UiText(func)
			UiTranslate(-10, 22)
		end
		UiPop()
end

function buildWeaponDisplayText(gun)
	
	-- return weaponText	
end

function getWeaponAmmoText(gun)
	if unexpected_condition then error() end
	local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	local ammoState = ""

	if(gun.magazines[gun.loadedMagazine].outOfAmmo or IsJointBroken(gun.gunJoint) 
				or (gun.turretJoint and IsJointBroken(gun.turretJoint)))then---or IsShapeBroken(gun.id) ) then
		UiColor(1,0,0)
		ammoState = string.format("%d / %d", 0,0)
	
	elseif(gun.reloading) then
		UiColor(1,1,0)
		ammoState = string.format("%d / %d", 0,0)
	else
		local magazineCapacity	 = currentMagazine.magazineCapacity	
		local ammoCount = currentMagazine.AmmoCount
		ammoState = string.format("%d / %d", ammoCount,magazineCapacity)
	end

	local magazineCount	 = gun.magazines[gun.loadedMagazine].magazineCount - currentMagazine.expendedMagazines
	if(GetBool("savegame.mod.infiniteAmmo")) then
		magazineCount = "9999"
	end


	local weaponText =  string.format("%s  | (%s)", ammoState, magazineCount)
	UiAlign("center right")
	UiText(weaponText)
	UiTranslate(0, 20)
	UiColor(1,1,1)
	UiAlign("center middle")
	UiText(gun.magazines[gun.loadedMagazine].CfgAmmo.name)

end


function drawWeaponReticles(gun)
	-- local cannonLoc = GetShapeWorldTransform(gun.id)
	-- local fwdPos = TransformToParentPoint(cannonLoc.pos, Vec(0,  -10,0))
 --    -- local direction = VecSub(fwdPos, cannonLoc.pos)
 UiPush()
	UiAlign("center middle")
	UiTranslate(UiCenter(), UiMiddle());
	if(gun.canZoom and  vehicle.ZOOMLEVEL>vehicle.ZOOMMIN) then
		if(gun.fireControlComputer) then
			UiImageBox(gun.fireControlComputer,UiWidth()*1.0,UiHeight()*1.0,1,1)
		else
			UiImageBox("MOD/gfx/scopeRegion.png",UiWidth()*1,UiHeight()*1,1,1)
			UiImageBox("MOD/gfx/scopeOutside.png",UiWidth()*1,UiHeight()*1,1,1)
		end
		-- local cannonLoc = GetShapeWorldTransform(gun.id)
		-- local fwdPos = TransformToParentPoint(cannonLoc,Vec(1,0,1) )
		-- -- local cannonLoc = VecSub(cannonLoc.pos,GetCameraTransform().pos)
  --   local direction = VecSub(fwdPos, cannonLoc.pos)

		

		UiTranslate(0,-((originalFov/100)*5)+
											(originalFov-
												(vehicle.sniperFOV *
													(1 - (vehicle.ZOOMVAL * vehicle.ZOOMLEVEL)
														)
												)
											)
											*(originalFov/100))
		
		if(gun.scope_offset) then 
			UiTranslate(UiWidth()*gun.scope_offset[1].x,UiHeight()*gun.scope_offset[1].y)
		end
		if(gun.zoomSight)then 
			UiImageBox(gun.zoomSight,UiWidth()*1,UiHeight()*1,1,1)
		else
			UiImageBox("MOD/gfx/t72ScopeInner.png",UiWidth()*1,UiHeight()*1,1,1)
		end
	else
		UiTranslate((originalFov/100)*(gun.sight[1].x*5),((originalFov/100)*30))
		if(gun.weaponType=="MGun") then
			UiImage("MOD/gfx/simpleCrosshair2.png")		
		elseif(gun.weaponType=="rocket") then
			UiImage("MOD/gfx/crosshair-launcher.png")
		else
			UiImage("MOD/gfx/tankCrossHairSimple.png")
			
		end
	end
	UiPop()


end

function draw_weapon_tracking()	




end







-- cheej
function initCamera()
    cameraX = 0
	cameraY = 0
	zoom = 20
end
function manageCamera()

	SetCameraTransform(vehicle.last_external_cam_pos)
end

function manageCamera_update()
    local mx, my = get_mouse_movement(1.5)
	cameraX = cameraX - mx / 10
	cameraY = cameraY - my / 10
	cameraY = clamp(cameraY, -30, 60)
	local cameraRot = QuatEuler(cameraY, cameraX, 0)
	local cameraT = Transform(VecAdd(Vec(0,0,0), GetVehicleTransform(GetPlayerVehicle()).pos), cameraRot)
	zoom = zoom - InputValue("mousewheel")
	zoom = clamp(zoom, 2, 30)

	local vehicle_body = GetVehicleBody(GetPlayerVehicle())
	local min, max = GetBodyBounds(vehicle_body)
	local boundsSize = VecSub(max, min)

	-- DebugWatch("bounds size", boundsSize)
	local cameraPos = TransformToParentPoint(cameraT, 
								Vec(0,
								 boundsSize[2]+2,
								  zoom))

	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)
	if(vehicle.last_external_cam_pos~= nil) then 
		camera.pos = VecLerp(vehicle.last_external_cam_pos.pos,camera.pos ,0.6)

		camera.rot = QuatSlerp(vehicle.last_external_cam_pos.rot,camera.rot ,0.9)
		vehicle.last_external_cam_pos = TransformCopy(camera)
	end

	vehicle.last_external_cam_pos = TransformCopy(camera)
end

function setReticleScreenPos(projectileHitPos)
	reticleScreenPosX, reticleScreenPosY = UiWorldToPixel(projectileHitPos)
	reticleScreenPos = {reticleScreenPosX, reticleScreenPosY}
end
function removeReticleScreenPos()
	reticleScreenPos = nil	
end

function getOuterReticleWorldPos()

	local crosshairDir = UiPixelToWorld(UiCenter(), UiMiddle()-50)
	local crosshairQuat = QuatDir(crosshairDir)
    local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)
    local vehicle_shapes = FindShapes("avf_vehicle_"..vehicle.id,true)
    local crosshairHit, crosshairHitPos = RaycastFromTransform(crosshairTr, nil, nil, {vehicle.body},vehicle_shapes)
    if crosshairHit then
        -- DrawDot(crosshairHitPos, 1,1, 1,0,0, 1)
		reticleWorldPos = crosshairHitPos
	else
		reticleWorldPos = nil
    end

end
function drawDynamicReticle()
	if reticleScreenPos ~= nil then
		UiPush()
			UiTranslate(reticleScreenPos[1], reticleScreenPos[2])
			UiAlign('center middle')
			UiColor(1,1,1,0.5)
			UiImageBox('ui/hud/dot-small.png', 15,15, 1,1)
		UiPop()
	end
	UiPush()
		UiTranslate(UiCenter(), UiMiddle()-50)
		UiAlign('center middle')
		UiColor(1,1,1,0.5)
		UiImageBox('ui/hud/target.png', 30,30, 1,1)
	UiPop()

	getOuterReticleWorldPos()
end


function QuatDir(dir) return QuatLookAt(Vec(0, 0, 0), dir) end -- Quat to 3d worldspace dir.
function GetQuatEulerVec(quat) local x,y,z = GetQuatEuler(quat) return Vec(x,y,z) end
---@param tr table
---@param distance number
---@param rad number
---@param rejectBodies table
---@param rejectShapes table
function RaycastFromTransform(tr, distance, rad, rejectBodies, rejectShapes)

	if distance ~= nil then distance = -distance else distance = -300 end

	if rejectBodies ~= nil then for i = 1, #rejectBodies do QueryRejectBody(rejectBodies[i]) end end
	if rejectShapes ~= nil then for i = 1, #rejectShapes do QueryRejectShape(rejectShapes[i]) end end

	local plyTransform = tr
	local fwdPos = TransformToParentPoint(plyTransform, Vec(0, 0, distance))
	local direction = VecSub(fwdPos, plyTransform.pos)
	local dist = VecLength(direction)
	direction = VecNormalize(direction)
	QueryRejectBody(rejectBody)
	local h, d, n, s = QueryRaycast(tr.pos, direction, dist, rad)
	if h then
		local p = TransformToParentPoint(plyTransform, Vec(0, 0, d * -1))
		local b = GetShapeBody(s)
		return h, p, s, b, d
	else
		return nil
	end
end
function DrawDot(pos, l, w, r, g, b, a, dt)
	local dot = LoadSprite("ui/hud/dot-small.png")
	local spriteRot = QuatLookAt(pos, GetCameraTransform().pos)
	local spriteTr = Transform(pos, spriteRot)
	DrawSprite(dot, spriteTr, l or 0.2, w or 0.2, r or 1, g or 1, b or 1, a or 1, dt or true)
end
function AabbGetShapeCenterPos(shape)
	local mi, ma = GetShapeBounds(shape)
	return VecLerp(mi,ma,0.5)
end

function math.sign(x) 
	if(x<0) then 
		return -1
	else
		return 1
	end

end



function debug_vehicle_locations()

	for key,vehicle in pairs(vehicles) do
	vehicleFeatures = vehicle.vehicleFeatures

	--- reload all weapons 
		for key,gunGroup in pairs(vehicleFeatures.weapons) do

			for key2,gun in ipairs(gunGroup) do
				debug_track_gun(gun)
			end
		end
	end
end

function debug_track_gun_locations()

end

function debug_track_gun(gun)
	local barrel = nil
	if(gun.multiBarrel)then
		-- gun.multiBarrel, barrel = next(gun.barrels,gun.multiBarrel)
		barrel = gun.barrels[gun.multiBarrel]
		gun.multiBarrel = (gun.multiBarrel%#gun.barrels)+1
	else 
		barrel = gun.barrels[1]
	end
	-- utils.printStr	(gun.multiBarrel)--.." | "..#gun.barrels	)
	local cannonLoc = GetShapeWorldTransform(gun.id)
	DebugCross(cannonLoc.pos,1,0,0)
	local y = barrel.y
	local x = barrel.x 
	local z = barrel.z
	if(debugging_traversal) then 
		DebugWatch("x,y,z",x..","..y..","..z)
	end
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(x, z,y))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	cannonLoc.pos = VecAdd(cannonLoc.pos, direction)

	DebugCross(cannonLoc.pos)
	return cannonLoc
end
