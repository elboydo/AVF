
function addGun(gunJoint,attatchedShape,turretJoint)
	if unexpected_condition then error() end
	
	local gun = GetJointOtherShape(gunJoint, attatchedShape)
	local gun_trigger = nil
	local gun_shapes = GetBodyShapes( GetShapeBody(gun))
	local debugging_multi_shape = HasTag(gun,"test_avf_shape")
	if(debugging_multi_shape ) then
		DebugPrint("gun has "..#gun_shapes.." shapes")

	end
	-- DebugPrint("gun has "..#gun_shapes.." shapes")
	for s =1,#gun_shapes do
		if(debugging_multi_shape ) then
			DebugPrint(s)
			DebugWatch("shape "..s.." has component? ",HasTag(gun_shapes[s], "component"))
			DebugWatch("shape "..s.." is gun ? ", GetTagValue(gun_shapes[s], "component") == "gun" )
			DebugWatch("shape "..s.." group ? ", GetTagValue(gun_shapes[s], "group") )
		end
		if(HasTag(gun_shapes[s], "component") and GetTagValue(gun_shapes[s], "component") == "gun" ) then
			
			gun = gun_shapes[s]
		elseif(HasTag(gun_shapes[s], "gun_trigger")) then
			gun_trigger = gun_shapes[s]
			SetTag(gun_trigger , "AVF_Parent", vehicle.groupIndex )
		end
	end
	local val3 = GetTagValue(gun, "component")
	if(val3=="" or val3 == nil) then 
		DebugPrint("ERROR, MISSING GUN COMPONENT ")
	end
	local weaponType = GetTagValue(gun, "weaponType")
	local min, max = GetJointLimits(gunJoint)
	local group = GetTagValue(gun, "group")

	local gun_body_shapes = GetBodyShapes(GetShapeBody(gun))
	for i = 1,#gun_body_shapes do 
		SetTag(gun_body_shapes[i],"avf_id",vehicle.id)

		SetTag(gun_body_shapes[i],"avf_vehicle_"..vehicle.id)
	end
	SetTag(gun,"avf_id",vehicle.id)

	SetTag(gun,"avf_vehicle_"..vehicle.id)
	if(debugging_traversal) then
		DebugPrint(weaponType.." | "..gunJoint.." | "..group.." | vehicle: "..vehicle.id)
	end
	if(group=="" or weaponType=="" or not IsHandleValid(gun)) then
		
		DebugPrint("error in config_ avf")
		if(group=="" or weaponType=="") then 
		 	DebugPrint("missing group")
		else
		 	DebugPrint("gun handle invalid")
		end
		return "false"

	end



	SetTag(gun, "AVF_Parent", vehicle.groupIndex )

	-- if(group=="" or weaponType=="") then
	-- 	return "false"
	-- end
	local index = (#vehicleFeatures.weapons[group])+1
	-- printStr(index)
	if(debugging_traversal) then
		DebugPrint("group: "..group.." | gun: "..gun.." | index: "..index)
	end

	if(weapons[weaponType]~=nil) then 
		vehicleFeatures.weapons[group][index] = deepcopy(weapons[weaponType])
	

	end

	-- vehicleFeatures.weapons[group][index].test = deepcopy(weapons[weaponType])
	vehicleFeatures.weapons[group][index].id = gun

	local status,retVal = pcall(gunCustomization,(vehicleFeatures.weapons[group][index]));
	if status then 
		-- DebugPrint("no errors")
	else
		DebugPrint(retVal)
	end
	-- gunCustomization(vehicleFeatures.weapons[group][index])

	status,retVal = pcall(loadShells,(vehicleFeatures.weapons[group][index]));
	if status then 
		-- utils.printStr("no errors")
	else
		DebugPrint(retVal)
		errorMessages = errorMessages..retVal.."\n"
	end

	-- loadShells(vehicleFeatures.weapons[group][index])

	if(turretJoint) then
		vehicleFeatures.weapons[group][index].turretJoint = turretJoint
		vehicleFeatures.weapons[group][index].base_turret = {} 
		vehicleFeatures.weapons[group][index].base_turret.id = attatchedShape
	end

	vehicleFeatures.weapons[group][index].gunJoint = gunJoint
	vehicleFeatures.weapons[group][index].elevationMin = -min
	vehicleFeatures.weapons[group][index].elevationMax = -max
	vehicleFeatures.weapons[group][index].rangeCalc = (-max-min) / vehicleFeatures.weapons[group][index].gunRange
	
	-- removed tags for weapons for the time being

	if(gun_trigger==nil) then 
		SetTag(gun,"interact",vehicleFeatures.weapons[group][index].name)
	else 
		SetTag(gun_trigger,"interact",vehicleFeatures.weapons[group][index].name)
		SetTag(gun_trigger,"weapon_host",gun)
	end
		
	
	-- RemoveTag(gun,"interact")
	vehicleFeatures.weapons[group][index].reloading = false
	vehicleFeatures.weapons[group][index].ammo = 0			
	vehicleFeatures.weapons[group][index].currentReload = 0
	vehicleFeatures.weapons[group][index].timeToFire = 0
	vehicleFeatures.weapons[group][index].cycleTime = 60 / vehicleFeatures.weapons[group][index].RPM 


	if(not vehicleFeatures.weapons[group][index].elevationSpeed) then
		vehicleFeatures.weapons[group][index].elevationSpeed = 1
	end

	if (not vehicleFeatures.weapons[group][index].sight[1].bias)then
		vehicleFeatures.weapons[group][index].sight[1].bias = 1
	end

	if(vehicleFeatures.weapons[group][index].soundFile)then
		vehicleFeatures.weapons[group][index].sound = LoadSound(vehicleFeatures.weapons[group][index].soundFile)
	end
	if(vehicleFeatures.weapons[group][index].mouseDownSoundFile)then
		vehicleFeatures.weapons[group][index].mouseDownSound = LoadSound(vehicleFeatures.weapons[group][index].mouseDownSoundFile)
	end
	if(vehicleFeatures.weapons[group][index].loopSoundFile)then
		vehicleFeatures.weapons[group][index].loopSoundFile = LoadLoop(vehicleFeatures.weapons[group][index].loopSoundFile)
	end
	if(vehicleFeatures.weapons[group][index].tailOffSound)then
		vehicleFeatures.weapons[group][index].tailOffSound = LoadSound(vehicleFeatures.weapons[group][index].tailOffSound)
		vehicleFeatures.weapons[group][index].rapidFire = false
	end
	if(vehicleFeatures.weapons[group][index].reloadSound and vehicleFeatures.weapons[group][index].reloadPlayOnce)then
		vehicleFeatures.weapons[group][index].reloadSound = LoadSound(vehicleFeatures.weapons[group][index].reloadSound)
	elseif(vehicleFeatures.weapons[group][index].reloadSound) then
		vehicleFeatures.weapons[group][index].reloadSound = LoadLoop(vehicleFeatures.weapons[group][index].reloadSound)
	else
		vehicleFeatures.weapons[group][index].reloadSound = LoadLoop(weaponDefaults.reloadSound)
	end
	vehicleFeatures.weapons[group][index].dryFire =  LoadSound("MOD/sounds/dryFire0.ogg")

	vehicleFeatures.weapons[group][index].shell_ejected = false
	-- if(weaponType~="2A46M")then
	-- 	utils.printStr(weaponType.." | "..vehicleFeatures.weapons[group][index].name.." | "..group)
	
	-- end


	if(HasTag(gun,"commander")) then
		 vehicleFeatures.commanderPos = gun
	end

	if HasTag(gun,"coax")then
		addCoax(gunJoint,attatchedShape,turretJoint,vehicleFeatures.weapons[group][index].base_turret)

	end

	addSearchlights(gun)

	if(vehicleFeatures.weapons[group][index].shell_ejector~=nil) then 
		vehicleFeatures.weapons[group][index].ejector_port = 1
		local gun_caliber = vehicleFeatures.weapons[group][index].magazines[1].CfgAmmo.caliber
		-- DebugPrint("gun caliber: "..gun_caliber)
		if(gun_caliber<10) then 
			vehicleFeatures.weapons[group][index].shell_casing_type = "object='shell_1x1"
		elseif(gun_caliber<50) then 
			vehicleFeatures.weapons[group][index].shell_casing_type = "object='shell_2x1"

		elseif(gun_caliber<150) then 
			vehicleFeatures.weapons[group][index].shell_casing_type = "object='shell_3x1"

		elseif(gun_caliber<250) then 
			vehicleFeatures.weapons[group][index].shell_casing_type = "object='shell_4x1"
			
		else
			vehicleFeatures.weapons[group][index].shell_casing_type = "object='shell_6x1"

		end

		local ejection_joint = FindJoint(gun.."_".."ejector_hatch",true)
		if(ejection_joint~=0) then 
			vehicleFeatures.weapons[group][index].ejection_joint = ejection_joint
			-- DebugPrint("found ejector_hatch from AVF")
		-- else	
			-- DebugPrint("AVF couldn't find ejector hatch")
		
		end
	end

	vehicle.shapes[#vehicle.shapes+1] = gun

	return "gun: "..index.." "..#vehicleFeatures.weapons[group].."\n"..min.." | "..max.." "..vehicleFeatures.weapons[group][index].name.." "..gun.." "..vehicleFeatures.weapons[group][index].id.."\n"
end

function addCoax(gunJoint,attatchedShape,turretJoint,base_turret)


	-- DebugPrint("ADDING COAX")

	local gun = GetJointOtherShape(gunJoint, attatchedShape)
	local gun_shapes = GetBodyShapes( GetShapeBody(gun))
	-- DebugPrint("gun has "..#gun_shapes.." shapes")
	for s =1,#gun_shapes do
		if(HasTag(gun_shapes[s], "component")) then
			gun = gun_shapes[s]
		elseif(HasTag(gun_shapes[s], "gun_trigger")) then
			gun_trigger = gun_shapes[s]
			SetTag(gun_trigger , "AVF_Parent", vehicle.groupIndex )
		end
	end


	local val3 = GetTagValue(gun, "component")
	local weaponType = GetTagValue(gun, "coax")
	local min, max = GetJointLimits(gunJoint)
	local group = "coax"


	-- if(debugMode) then
	-- 	DebugPrint(weaponType.." | "..gunJoint.." | "..group.." | vehicle: "..vehicle.id)
	-- end
	if(group=="" or weaponType=="" or not IsHandleValid(gun)) then
		DebugPrint("error in config")
		return "false"

	end

	local index = (#vehicleFeatures.weapons[group])+1
	vehicleFeatures.weapons[group][index] = deepcopy(weapons[weaponType])
	vehicleFeatures.weapons[group][index].id = gun

	gunCustomization(vehicleFeatures.weapons[group][index],true)

	loadShells(vehicleFeatures.weapons[group][index],true)

	if(turretJoint) then
		vehicleFeatures.weapons[group][index].turretJoint = turretJoint
		vehicleFeatures.weapons[group][index].base_turret = base_turret
	end

	vehicleFeatures.weapons[group][index].gunJoint = gunJoint
	vehicleFeatures.weapons[group][index].elevationMin = -min
	vehicleFeatures.weapons[group][index].elevationMax = -max
	vehicleFeatures.weapons[group][index].rangeCalc = (-max-min) / vehicleFeatures.weapons[group][index].gunRange
	vehicleFeatures.weapons[group][index].reloading = false
	vehicleFeatures.weapons[group][index].ammo = 0			
	vehicleFeatures.weapons[group][index].currentReload = 0
	vehicleFeatures.weapons[group][index].timeToFire = 0
	vehicleFeatures.weapons[group][index].cycleTime = 60 / vehicleFeatures.weapons[group][index].RPM 
	if(not vehicleFeatures.weapons[group][index].elevationSpeed) then
		vehicleFeatures.weapons[group][index].elevationSpeed = 1
	end
	if (not vehicleFeatures.weapons[group][index].sight[1].bias)then
		vehicleFeatures.weapons[group][index].sight[1].bias = 1
	end
	if(vehicleFeatures.weapons[group][index].soundFile)then
		vehicleFeatures.weapons[group][index].sound = LoadSound(vehicleFeatures.weapons[group][index].soundFile)
	end
	if(vehicleFeatures.weapons[group][index].mouseDownSoundFile)then
		vehicleFeatures.weapons[group][index].mouseDownSound = LoadSound(vehicleFeatures.weapons[group][index].mouseDownSoundFile)
	end
	if(vehicleFeatures.weapons[group][index].loopSoundFile)then
		vehicleFeatures.weapons[group][index].loopSoundFile = LoadLoop(vehicleFeatures.weapons[group][index].loopSoundFile)
	end
	if(vehicleFeatures.weapons[group][index].tailOffSound)then
		vehicleFeatures.weapons[group][index].tailOffSound = LoadSound(vehicleFeatures.weapons[group][index].tailOffSound)
		vehicleFeatures.weapons[group][index].rapidFire = false
	end
	if(vehicleFeatures.weapons[group][index].reloadSound and vehicleFeatures.weapons[group][index].reloadPlayOnce)then
		vehicleFeatures.weapons[group][index].reloadSound = LoadSound(vehicleFeatures.weapons[group][index].reloadSound)
	elseif(vehicleFeatures.weapons[group][index].reloadSound) then
		vehicleFeatures.weapons[group][index].reloadSound = LoadLoop(vehicleFeatures.weapons[group][index].reloadSound)
	else
		vehicleFeatures.weapons[group][index].reloadSound = LoadLoop(weaponDefaults.reloadSound)
	end
	vehicleFeatures.weapons[group][index].dryFire =  LoadSound("MOD/sounds/dryFire0.ogg")



	-- DebugPrint("added gun")
end

function gunCustomization(gun,coax)
	if unexpected_condition then error() end
	
	for key,val in pairs(weaponOverrides) do 
		if(coax)then
			tagkey = key.."coax"
		else
			tagkey = key
		end
		if(key =="namecoax") then
			local teststr = "false"
			if(HasTag(gun.id,"@"..tagkey)) then
				teststr = "true - "..GetTagValue(gun.id,"@"..tagkey)
			end
			--DebugPrint("tagkey: "..tagKey.." | Key: "..key.." "..teststr)
		-- DebugPrint(key)
		end

		if(HasTag(gun.id,"@"..tagkey) ) then
			-- if(key == "shell_ejector") then 
			-- 	DebugPrint(tagkey)
			-- end
			--DebugPrint(tagkey)
			if(type(val)== 'table') then
				local subKeyItems = 50
				if(key == "backBlast") then
					subKeyItems = #gun.barrels
				end

				for i =1,subKeyItems do---#gun[key] do

					
					for subKey,subVal in pairs(val) do

						if(HasTag(gun.id,"@"..tagkey..i..subVal)  ) then
							-- DebugPrint("tagkey: "..key.." | "..tagkey.." | "..i.." | "..subVal)
							if(gun[key]==nil) then 
								gun[key] = {}
								gun[key][i] = deepcopy(override_samples[key][1])
								
							elseif(i>#gun[key]) then 
								i = #gun[key]+1
								gun[key][i] = deepcopy(gun[key][1])
								
							end
							local gunPart = gun[key][i] 
							-- DebugPrint( " | "..key..i..subVal.." syubkey:"..subKey)
							local teststr = tagkey..i..subKey.." : "..gunPart[subKey]
							local tagValue = GetTagValue(gun.id,"@"..tagkey..i..subVal)
							if tonumber(tagValue) ~= nil then
								tagValue = tonumber(tagValue)
							end
							gunPart[subKey] = tagValue 
							-- DebugPrint( GetTagValue(gun.id,"@"..key..i..subVal).." | "..key..i..subVal)
							if(debugging_traversal) then 
								DebugPrint("Before: "..teststr.." | ".."after: "..gunPart[subKey].."")
							end
						elseif(key == "backBlast" and #gun.backBlast>0) then
							gun.backBlast[#gun.backBlast+1] = deepcopy(gun.backBlast[1])
						end
					end
				end
			else
				local tagValue = GetTagValue(gun.id,"@"..tagkey)
				if tonumber(tagValue) ~= nil then
					tagValue = tonumber(tagValue)
				elseif(tagValue=="true") then
						tagValue = true
				elseif(tagValue=="false") then
					tagValue = false
				end;
				gun[key] = tagValue--GetTagValue(gun.id,"@"..val)
			end
		end
	end
	-- body
end

function loadShells(gun,coax)
	local gunMagazines = #gun.magazines
	-- DebugPrint(gunMagazines)
	local coaxVal = ""
	if(coax)then
		coaxVal = "coax"
	end
	for i=1,50 do
		if(i>#gun.magazines and HasTag(gun.id,"@magazine"..i.."_name"..coaxVal)) then 
			local index = #gun.magazines+1
			gun.magazines[index] = deepcopy(gun.magazines[1])
			
		end
	end
--	DebugPrint(#gun.magazines)
	gunMagazines = #gun.magazines
--	DebugPrint("munitions name: "..gun.magazines[1].name)
-- deepcopy(weapons[weaponType])
	for i =1,gunMagazines do
		gun.magazines[i].CfgAmmo = deepcopy(munitions[gun.magazines[i].name])

-- AmmoOverrides = {
-- 	name				= "name",	
-- 	magazineCapacity   	= "magazineCapacity",
-- 	magazineCount    	= "magazineCount",
-- 	explosionSize		= "explosionSize",
-- 	maxPenDepth			= "maxPenDepth",

		for key,val in pairs(AmmoOverrides) do 
			
			if(coax)then
				tagkey = key.."coax"
			else
				tagkey = key
			end
			if(HasTag(gun.id,"@magazine"..i.."_"..tagkey) ) then
				if(utils.contains(gun.magazines[i],key)) then
					if(key =="name") then 
						gun.magazines[i].CfgAmmo.name = GetTagValue(gun.id,"@magazine"..i.."_name"..coaxVal)  
						gun.magazines[i].name = gun.magazines[i].CfgAmmo.name	
					else
						local tagValue = GetTagValue(gun.id,"@magazine"..i.."_"..val..coaxVal)
						if tonumber(tagValue) ~= nil then
   								tagValue = tonumber(tagValue)
   						elseif(tagValue=="true") then
   							tagValue = true
						elseif(tagValue=="false") then
							tagValue = false
						end;
						gun.magazines[i][key] = tagValue	
					end
				else

					local tagValue = GetTagValue(gun.id,"@magazine"..i.."_"..val..coaxVal)
						if tonumber(tagValue) ~= nil then
   								tagValue = tonumber(tagValue)
   						elseif(tagValue=="true") then
   							tagValue = true
						elseif(tagValue=="false") then
							tagValue = false
						end;
						gun.magazines[i].CfgAmmo[key] = tagValue
				end
			end
		end



		if (gun.magazines[i].CfgAmmo.shellSpriteRearName )then 
			gun.magazines[i].CfgAmmo.spriteRear = LoadSprite(gun.magazines[i].CfgAmmo.shellSpriteRearName)
		else
			gun.magazines[i].CfgAmmo.spriteRear = LoadSprite("MOD/gfx/shellRear2.png")
		end

		if(gun.magazines[i].CfgAmmo.shellSpriteName ) then 
			gun.magazines[i].CfgAmmo.sprite = LoadSprite(gun.magazines[i].CfgAmmo.shellSpriteName)
		else
			gun.magazines[i].CfgAmmo.sprite = LoadSprite("MOD/gfx/shellModel2.png")
		end

		if(gun.magazines[i].CfgAmmo.spallingSpriteName) then
			gun.magazines[i].CfgAmmo.Spallingsprite = LoadSprite(gun.magazines[i].CfgAmmo.spallingSpriteName)
		else
			gun.magazines[i].CfgAmmo.Spallingsprite = LoadSprite("MOD/gfx/spalling.png")
		end	

		if((gun.magazines[i].CfgAmmo.flightLoop)) then
			gun.magazines[i].CfgAmmo.flightLoopSound = LoadLoop(gun.magazines[i].CfgAmmo.flightLoop)
		end


		local modifier = math.log(gun.magazines[i].CfgAmmo.caliber)/10--/10
		modifier = modifier*.75
		if(gun.magazines[i].CfgAmmo.payload =="kinetic") then
			modifier = modifier * .75
		end
		-- DebugPrint(modifier)
		gun.magazines[i].CfgAmmo.bulletdamage = {
							[1] = modifier*1.3,
							[2] = modifier*1,
							[3] = modifier*0.5
						}


		--- add penetration modifiers
		local penModifier = 1
		if( penetrationModifiers[gun.magazines[i].CfgAmmo.payload]) then 
			penModifier = penetrationModifiers[gun.magazines[i].CfgAmmo.payload]
		end
		gun.magazines[i].CfgAmmo.penModifier = penModifier

		--- add True pen RHA value (RHAe)
		
		if (gun.magazines[i].CfgAmmo.RHAe) then 
			-- DebugPrint("gun.magazines[i].CfgAmmo.RHAe "..gun.magazines[i].CfgAmmo.RHAe)
			-- DebugPrint("existing pen: "..gun.magazines[i].CfgAmmo.maxPenDepth)
			local rhae_value = get_penetration_table_by_payload(gun.magazines[i].CfgAmmo.payload)['hardmetal']
			-- DebugPrint("rhae_value "..rhae_value)
			-- DebugPrint("target pen: ".. rhae_value * (gun.magazines[i].CfgAmmo.RHAe * globalConfig.RHAe_2_vox) )
			gun.magazines[i].CfgAmmo.maxPenDepth = rhae_value * (gun.magazines[i].CfgAmmo.RHAe *  globalConfig.RHAe_2_vox) 
			-- DebugPrint("RHAe value entered: "..gun.magazines[i].CfgAmmo.RHAe)
			-- DebugPrint("RHAe value output: "..gun.magazines[i].CfgAmmo.maxPenDepth)
		end
		
		if(gun.magazines[i].CfgAmmo.hit and gun.magazines[i].CfgAmmo.hit ==3) then
			gun.magazines[i].CfgAmmo.bulletdamage[3] = gun.magazines[i].CfgAmmo.bulletdamage[3] *.5 
		end

		-- if(i==1) then
			-- utils.printStr("@shell"..i.."_name")


			-- if(HasTag(gun.id,"@magazine"..i.."_name")) then 
			-- 	gun.magazines[i].CfgAmmo.name = GetTagValue(gun.id,"@magazine"..i.."_name")  
			-- 	gun.magazines[i].name = gun.magazines[i].CfgAmmo.name
			-- end
			-- if(HasTag(gun.id,"@magazine"..i.."_explosionSize")) then 
			-- 	gun.magazines[i].CfgAmmo.explosionSize = GetTagValue(gun.id,"@magazine"..i.."_explosionSize")  
			-- end
			-- if(HasTag(gun.id,"@magazine"..i.."_maxPenDepth")) then 
			-- 	gun.magazines[i].CfgAmmo.maxPenDepth = tonumber(GetTagValue(gun.id,"@magazine"..i.."_maxPenDepth"))  
			-- end
			-- if(HasTag(gun.id,"@magazine"..i.."_".."magazineCapacity")) then 
			-- 	gun.magazines[i].magazineCapacity = GetTagValue(gun.id,"@magazine"..i.."_magazineCapacity")  
			-- end
			-- if(HasTag(gun.id,"@magazine"..i.."_".."magazineCount")) then 
			-- 	gun.magazines[i].magazineCount = GetTagValue(gun.id,"@magazine"..i.."_magazineCount")  
			-- end
			gun.magazines[i].currentMagazine = 1
			gun.magazines[i].outOfAmmo = false
			gun.magazines[i].magazinesAmmo = {}
			for j = 1,gun.magazines[i].magazineCount do 

				gun.magazines[i].magazinesAmmo[j] = deepcopy(ammoDefaults.defaultMagazine)
				gun.magazines[i].magazinesAmmo[j].ammoName = gun.magazines[i].name
				gun.magazines[i].magazinesAmmo[j].magazineCapacity = gun.magazines[i].magazineCapacity
				gun.magazines[i].magazinesAmmo[j].AmmoCount 	= gun.magazines[i].magazineCapacity
				gun.magazines[i].magazinesAmmo[j].expendedMagazines 	= 0
				if(gun.magazines[i].magazinesAmmo[j].AmmoCount ==0) then 
					gun.magazines[i].magazinesAmmo[j].isEmpty = true
				else
					gun.magazines[i].magazinesAmmo[j].isEmpty = false
				end
				
			end


	-- 			ammoDefaults = {
	-- 	defaultMagazine = {
	-- 		ammoName = "",
	-- 		magazineCapacity = 0,
	-- 		AmmoCount = 0,
	-- 		isEmpty = true

	-- },

		-- end
	end
-- munitions[gun.magazines[gun.loadedMagazine].name]


end


--[[
	
	helper functions to detect warhead traits - such as rockets or chemical effect based warheads like HEAT. 

	Initial use case is for shells that don't suffer penetration loss over distance

]]
function is_rocket(projectile)
	if(shell_launcher_types[projectile.shellType.launcher] and 
			shell_launcher_types[projectile.shellType.launcher] == "rocket") then 
		return true
	else
		return false
	end

end

function is_chemical_warhead(projectile)
	if(shell_warhead_penetration_effect[projectile.shellType.payload] and 
			shell_warhead_penetration_effect[projectile.shellType.payload] == "chemical") then 
		return true
	else
		return false
	end


end


function addSearchlights(object)
	local objectLights= GetShapeLights(object)
	if(objectLights) then 
		for i=1,#objectLights do
			vehicle.lights[#vehicle.lights+1] = objectLights[i]
		end
	end
end

function addSmokeLauncher(object)
		local launcherName = GetTagValue(object, "smokeLauncher")

		local launcherConfig = deepcopy(weapons[launcherName])

		local group = GetTagValue(object, "group")
	-- utils.printStr(group)

		local index = (#vehicleFeatures.utility[group])+1
		
		vehicleFeatures.utility[group][index] = launcherConfig

		vehicleFeatures.utility[group][index].id = object
		vehicleFeatures.utility[group][index].reloading = false
		vehicleFeatures.utility[group][index].currentReload = 0
		
end

function traverseTurret(turretJoint,attatchedShape)
	local outString = ""
	local turret = GetJointOtherShape(turretJoint, attatchedShape)

	local group  = GetTagValue(turret, "turretGroup")
	if (not group or group=="") then 
		group = "mainTurret"
	end
	local idNo   = (#vehicleFeatures.turrets[group])+1
	vehicleFeatures.turrets[group][idNo] = {}
	vehicleFeatures.turrets[group][idNo].id 	= turret
	vehicleFeatures.turrets[group][idNo].turretJoint  = turretJoint	

	local shapes = GetBodyShapes(GetShapeBody(turret))
	for i=1,#shapes do 

		SetTag(shapes[i],"avf_id",vehicle.id)

		SetTag(shapes[i],"avf_vehicle_"..vehicle.id)
		local joints = GetShapeJoints(shapes[i])
		if(debugging_traversal) then 
			DebugPrint("found "..#joints.." Turret linked Joints")
		end
		for j=1,#joints do 
			if(joints[j]~=turretJoint)then
				local val2 = GetTagValue(joints[j], "component")
				if(debugging_traversal) then 
					DebugPrint("found component: "..val2)
				end
				if val2=="gunJoint" then
						status,retVal = pcall(addGun, joints[j], turret,turretJoint);
						if status then 
							-- utils.printStr("no errors")
						else
							DebugPrint("[ERROR] "..retVal)
							--errorMessages = errorMessages..retVal.."\n"
						end


	--				outString = outString..addGun(joints[j], turret,turretJoint)
				else
					tag_jointed_object(joints[j],shapes[i])
				end
			end
		end
		if(HasTag(turret,"smokeLauncher")) then

			addSmokeLauncher(turret)

		end
		if(HasTag(turret,"commander")) then
			 vehicleFeatures.commanderPos = turret
		end
	end
	addSearchlights(turret)

	vehicle.shapes[#vehicle.shapes+1] = turret

	return outString

end


function tag_jointed_object(joint,source_shape)
		
		
	local shape= GetJointOtherShape(joint, source_shape)
	local shapes = GetBodyShapes(GetShapeBody(shape))
	for i=1,#shapes do 
		SetTag(shapes[i],"avf_id",vehicle.id)

		SetTag(shapes[i],"avf_vehicle_"..vehicle.id)
	end
end

function pollNewVehicle(dt)
	-- if GetBool("savegame.mod.newVehicle") then
		addVehicle()

	-- 	SetBool("savegame.mod.newVehicle",false)
	-- end

end

function addVehicle()
	local sceneVehicles = FindVehicles("AVF_Custom",true)
	--utils.printStr(#sceneVehicles)

	for i = 1,#sceneVehicles do 
		if(GetTagValue(sceneVehicles[i], "AVF_Custom")=="unset" and
			GetTagValue(sceneVehicles[i], "cfg") == "vehicle" ) then

			local index = #vehicles +1
			vehicles[index] = {
							vehicle ={
									id = sceneVehicles[i],
									groupIndex = index,
									},
							vehicleFeatures = deepcopy(defaultVehicleFeatures),
							}
			vehicle = vehicles[index].vehicle
			vehicleFeatures = vehicles[index].vehicleFeatures
			initVehicle(vehicles[index])

			SetTag(sceneVehicles[i],"AVF_Custom","set")
			
			-- RemoveTag(sceneVehicles[i],"AVF_Custom")
		end
	end

end
