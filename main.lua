
--[[]
#include "umf/umf_core.lua"
#include "AVF_VERSION.lua"

#include "common.lua"
#include "ammo.lua"
#include "weapons.lua"

#include "AIComponent.lua"


#include "explosionController.lua"

#include "controls.lua"
]]
-- #include "../Abu Zayeet Ballistic Range/main/scripts/testing.lua"



--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) 
*
* FILENAME :        main.lua             
*
* DESCRIPTION :
*       File that controls player vehicle turrets within the game teardown (2020)
*
*		File Handles both player physics controlled and in vehicle controlled turrets
*		This is extended to include ammo reloading and weapon group management
*		
*
* SETUP FUNCTIONS :
*		In V3 all initialization is done at level init and based entirely off 
*		Vehicle xml values
*
*
*		In accessor init: 
*
*       setValues(vehicle,weaponFeatures) - Establishes environment variables for vehicle
*       gunInit() 						  - Establishes vehicle gun state
*
*		In accessor Tick(dt):
*
*		gunTick(dt)						  - Manages gun control during gameplay
*
*
*		gunUpdate(d)					  - Manages gun elevation during gameplay
*
*
*
* VEHICLE SETUP 
*
*		add inside tags=""
*
*		vehicle -> cfg=vehicle
*		body -> component=body
*		vox  (for vehicle body) -> component=chassis
*		vox (for turret) -> component=turret turretGroup=mainTurret
*		joint (for turret joint) ->component=turretJoint
*		vox (for gun) -> component=gun weaponType=2A46M group=primary  
*		vox (for gun joint) -> component=gunJoint
*
*
*
* NOTES :
*       Future versions may ammend issue with exact gun location
*		physics based gun control lost after driving player vehicle.
*       
* 		Please ensure to add player click to hud.lua.  (no longer needed)
*
*       Copyright - Of course no copyright but please give credit if this code is 
* 		re-used in part or whole by yourself or others.
*
* AUTHOR :    elboydo        START DATE :    04 Nov 2020
*
*
* ACKNOWLEDGEMENTS:
*
*		Mnay thanks to the many users of the teardown discord for support in coding an establishing this mod,
* 		particularly @rubikow for their invaluable assistance in grasping lua and the functions
*		provided to teardown modders at the inception of this mod, many thanks to Thomasims for guidance on custom projectiles
*		Thanks to spexta for all of the excellent models and assistance involved in developing this mod.  
*
* HUB REPO: https://github.com/elboydo/TearDownTurretControl
*
* CHANGES :
*
*			Release: Public release V_1 - NOV 11 - 11 - 2020
*
*			V2: Added Turret elevation
*					Added crane functionality to control turret 
*					Added high velocity shells
*					+ other quality of life features
*
*			Release: Public release V_1_0_0 - DEC 21 - 12 - 2020
*
*			REMOVED:
*					crane functionality to control turret - replaced with player input
*
*
*			ADDITIONS:
*					Complete rewrite
*					XML driven control
*					Complete XML overrides for weapons
*					Lua controlled weapon / ammo configs
*					Shell penetration
*					Multiple weapon support
*					Multilple gun support
*					Kronenberg 1664 support
*					Dynamic ammo and reloading
*
*					custom projectiles 
*					tracers
*					shrapnal
*					backblast
*					cannon blast
*					sniperMode
*					custom sniper zooms					
*
*			Release: Public release V_1_0_8 - DEC 22 - 12 - 2020
*
*
*			Fixed: FOV bug on exiting game when in sniper mode
*			New issue - this will have issues if you change your fov later, can be fixed
*
*
*			Release: Public release V_1_0_9 - JAN 02 - 01 - 2021
*
*
*			Fixed: FOV related Bugs
* 			
*			ADDITIONS:
*				aerial Weapons and rockets. 
*				Customization scripts
*				gravityCoef and dispersionCoef to shells
*
*
*
*			Release: Public release V_1_1_0 - JAN 06 - 01 - 2021
*
*			ADDITIONS:
*				More aerial Weapons and rockets. 
*				guided Missiles
*
*
*			Release: Public release V_1_1_1 - JAN 20 - 01 - 2021
*
*			ADDITIONS:
*				Custom weapon and ammo slot to enable better custom weapons
*				HEAT shells
* 				HESH shells
* 				Spalling / shrapnal mechanics
* 				Improved zoom
* 				ERA armour support
*				
*
*
*			Release: Public release V_1_1_1_75 - FEB 05 - 02 - 2021
*
*
*				Temp fix for loading custom sprites - disabled custom shell sprites
*
*
*
*			Release: Public release V_1_1_2 - FEB 10 - 02 - 2021
*
*			ADDITIONS:
*				Controls hud
*				Demo map
* 				Small fixes
*
*
*
*			Release: Public release V_1_2_1 - MARCH 22 - 03 - 2021
*
*			ADDITIONS:
*				Interacton based control
*
*
*
*
*			Release: Public release V_1_3_0 - June 20 - 06 - 2021
*
*			ADDITIONS:
*				Reworked explosive system for better realism
*				Improved penetration mechanics
*				Added more realistic penetration model
*
*
*			Release: Public release V_1_9_0 - June 20 - 06 - 2021
**				lots of stuff unlisted here - projectile ops, pen charts, more features

*			Release: Public release V_2_4_0 - Jan 20 - 01 - 2022
*
*			ADDITIONS:


				All avf confirmed vehicles included with mod

				artillery system rework 

				interaction timers -- DONE

				improve Heat effects / damage - DONE
**


*			Release: Public release V_2_4_1 - Feb 07 - 02 - 2022
*
*			ADDITIONS:


				Player damage from bullets




*			Release: Public release V_2_5_0 - xxx xx - xx - xxxx
*
*			ADDITIONS:


				Shell ejection
				Better HEAT impact
				upgraded ERA / special armour behaviors

				general bug  fixes - 
					- fixed aim bug 
					- fixed backblast customization 
					- fixed vehicle mapping when incorrect weapon entered 
					- fixed heat impact breaking 
					- added better error handling 
					- updated reloading to better occur across weapons 
					- improved turret mechanics when leaving vehicle 
					- improved recoil mechanics

			TO DO:


				ai pathing 

				ai combat

			ISSUES: 

				HEAT non pen impact pos wrong
				some lag issues


*			Release: Public release V_2_6_0 - xxx xx - xx - xxxx
*
*			ADDITIONS:
				Improved shell impact effects  [REALISM]
				Improved HEAT mechanics [REALISM]
				Improved penetration values  [REALISM]
				doubled penetration checks pr vox (improves sloped armour)  [REALISM]

			BUG FIXES 
				Scope reticle missing
				HEAT non pen impact pos wrong
				ATGM aimpos wrong
				some lag issues


			TO DO:
				custom sounds from avf_custom
				custom gui from avf_custom

				ai pathing 

				ai combat

			ISSUES: 


*			Release: Public release V_2_6_2 - xxx xx - xx - xxxx
*
*			ADDITIONS:
				Improved shell impact effects  [REALISM]
				Improved HEAT mechanics [REALISM]
				Improved penetration values  [REALISM]
				doubled penetration checks pr vox (improves sloped armour)  [REALISM]

				Added distance modifiers for shell penetration

			BUG FIXES 


			TO DO:
				custom sounds from avf_custom
				custom gui from avf_custom

				ai pathing 

				ai combat

			ISSUES: 

*
]]



debugMode = false

DEBUG_AI = false

DEBUG_CODE = true

debugging_traversal =false

debug_combat_stuff = false

debug_weapon_pos = false


debug_special_armour = false

debug_shell_casings = false


debug_player_damage = false


debug_vehicle_locations_active = true


debugStuff= {

	redCrosses = {}
}

errorMessages = ""
frameErrorMessages = ""

globalConfig = {
	base_pen = 0.1,
	RHAe_2_vox = 0.01,
	min_vehicle_health = 0.6,
	penCheck = 0.01,
	penIteration = 0.1,
	pen_check_iterations = 100,
	HEATRange = 3,
	gravity = Vec(0,-10,0),
	impulse_coef = 0.002,
	fire_chance_thres = 0.975,
	--gravity = Vec(0,-25,0),
	weaponOrders = {
			[1] = "primary",
			[2] = "secondary",
			[3] = "tertiary",
			[4] = "smoke",
			[5] = "utility1",
			[6] = "utility2",
			[7] = "utility3",
			[8] = "1",
			[9] = "2",
			[10] = "3",
			[11] = "4",
			[12] = "5",
			[13] = "6",
			[14] = "coax",
		},
	MaxSpall = 16,
	spallQuantity = 32,
	spallFactor = {
			kinetic = 0.85,
			AP 		= 0.4,
			APHE    = 0.4,
			HESH 	= 1.8,
			HESH 	= 1.5,
			HEI 	= 1,
	},

	materials = {
		rock  = 13,
		dirt  = 0.2,
		plaster = 0.1,
		plastic = 0.05,
		masonry = 0.27,
		glass = 0.05,
		foliage = 0.025,
		wood  = 0.2,
		metal  = 0.42,
		hardmetal = 0.73,
		heavymetal  = 13,
		hardmasonry = 0.6,


	},

	HEAT_pentable = {
		rock  = 13,
		dirt  = 0.5,
		plaster = 0.25,
		plastic = 0.025,
		masonry = 0.5,
		glass = 0.2,
		foliage = 0.0023,
		wood  = 0.1,
		metal  = 0.21,
		hardmetal = 0.33,
		heavymetal  = 4,
		hardmasonry = 0.8,

	},

	kinetic_pentable = {
		rock  = 13,
		dirt  = 0.2,
		plaster = 0.1,
		plastic = 0.05,
		masonry = 0.27,
		glass = 0.05,
		foliage = 0.025,
		wood  = 0.2,
		metal  = 0.23,
		hardmetal = 0.45,
		heavymetal  = 10,
		hardmasonry = 0.6,


	},
	pen_coefs = {
		HEAT = .75,
		kinetic= .55,



	},
	optimum_spall_shell_calibre_size = 100, 

	shrapnel_coefs = {
		HEAT = 0.5,
		kinetic= 2,
		APHE = 25,
		HE = 75,
		shrapnel = 125,
		frag = 125,




	},
	shrapnel_hard_damage_coef = {
		HEAT = 1,
		kinetic= 1,
		HE = 0.8,

	},
	shrapnel_pen_coef = {
		HEAT = 1,
		kinetic= 1,
		HE = 10,
		shrapnel = 4,

	},
	shrapnel_speed_coefs = {
		HEAT = 1,
		kinetic= 1,
		HE = 2,
		shrapnel = 2,



	},

	armour_types = {
		RHA = 0.03

	},
}
penVals = "PENETRATION RESULTS\n-------------------------"
--[[
 Vehicle config
]]



avf_types = {
	"vehicle",
	"turret",
	"artillery"
}

vehicle = {
	vehicleName 				= "",
	armed 						= true,
  	Create 						= "elboydo"
  }


 vehicles = {

 }

 ammoContainers = {
 	refillTimer = 0,
 }


vehicleFeatures = {}

defaultVehicleFeatures = {
	weapons = 
		{
			primary 	= {},
			secondary 	= {},
			tertiary 	= {},
			coax    	= {},
			smoke 		= {},
			utility1 	= {},
			utility2 	= {},
			utility3 	= {},
			["1"] 	= {},
			["2"] 	= {},
			["3"] 	= {},
			["4"] 	= {},
			["5"] 	= {},
			["6"] 	= {},
		},
	utility = {
		smoke 		= {},
	},
	equippedGroup = "primary",
	turrets = 
				{
					mainTurret 			= {},
					secondaryTurret 	= {},
					tertiaryTurret 		= {}
				}

}

artilleryHandler = 
{
	shellNum = 1,

	explosionSize = 0.5,

	shells = {

	},
	defaultShell = {active=false, hitPos=nil,timeToTarget =0},
}
shellSpeed = 0.005--5--0.05 --45

projectileHandler = 
	{
		shellNum = 1,
		shells = {

		},
	defaultShell = {active=false, velocity=nil, direction =nil, currentPos=nil, timeLaunched=nil},
	velocity = 200,
	gravity = Vec(0,-25,0),
	shellWidth = 0.3,
	shellHeight = 1.2,
	}


spallHandler = 
	{
		shellNum = 1,
		shells = {

		},
	defaultShell = {active=false, velocity=nil, direction =nil, currentPos=nil, timeLaunched=nil},
	velocity = 200,
	gravity = Vec(0,-25,0),
	shellWidth = 0.3,
	shellHeight = 0.3,
	}


projectorHandler = 
	{
		shellNum = 1,
		shells = {

		},
	defaultShell = {active=false, speed=0, currentPos=nil, hitPos=nil,timeToTarget =0},
	}


explosion_sounds = {}


maxDist = 500

AVF_Vehicle_Used = false

interaction_timeout_max = 1

interaction_timeout_timer = 0



viewingMap = false

AVF_V3 = {
	interactions = {
		firedLastFrame = false,


	}


}


-- weapon would use xml weaponType= tag then that would relate to the thing

function init()
	-- SetBool("savegame.mod.newVehicle",false)
	-- SetInt("savegame.mod.playerFov",0)
	-- originalFov = SetInt("options.gfx.fov", 90)
	-- if(not GetInt("savegame.mod.playerFov") or GetInt("savegame.mod.playerFov") == 0) then
	-- 	SetInt("savegame.mod.playerFov",GetInt("options.gfx.fov"))
	-- 	-- DebugPrint(GetInt("options.gfx.fov").." | "..GetInt("savegame.mod.playerFov"))
	-- end
	-- DebugPrint(GetInt("options.gfx.fov").." | "..GetInt("savegame.mod.playerFov"))
	-- SetInt("savegame.mod.playerFov",GetInt("options.gfx.fov"))
	originalFov = GetInt("options.gfx.fov")---GetInt("savegame.mod.playerFov")
	-- SetInt("options.gfx.fov",originalFov)
	if(GetBool("savegame.mod.debug")) then	
		debugMode = true
	end


	initCamera()

	reticle1 = LoadSprite("MOD/sprite/reticle1.png")
	reticle2 = LoadSprite("MOD/sprite/reticle2.png")
	reticle3 = LoadSprite("MOD/sprite/reticle3.png")



	globalConfig.gravity = VecScale(globalConfig.gravity,1)

	ammoContainers.crates = FindTriggers("ammoStockpile",true)
	ammoRefillSound = LoadSound(weaponDefaults.refillingAmmo)

	local sceneVehicles = FindVehicles("cfg",true)
	--utils.printStr(#sceneVehicles)

	for i = 1,#sceneVehicles do 
		local value = GetTagValue(sceneVehicles[i], "cfg")

		if(value == "vehicle" and not HasTag(sceneVehicles[i],"AVF_Custom")) then

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

			vehicle.last_cam_pos = nil
			vehicle.last_external_cam_pos = nil


			if(not GetBool("savegame.mod.debug")) then	
				initVehicle(vehicles[index])
			else
				local status,retVal = pcall(initVehicle,vehicles[index])
				if status then 
						-- utils.printStr("no errors")
				else
					errorMessages = errorMessages..retVal.."\n"
				end
			end
		end
	end


	-- ignored_shapes = FindShapes("muzzle_blast_ignore",true)

	-- ignored_bodies = {}
	-- for i=1,#ignored_shapes do 
	-- 	ignored_bodies[i] = GetShapeBody(ignored_shapes[i])
	-- end

	for i =1,1050 do
		artilleryHandler.shells[i] = deepcopy(artilleryHandler.defaultShell)

		projectorHandler.shells[i]= deepcopy(projectorHandler.defaultShell)

		projectileHandler.shells[i]= deepcopy(projectileHandler.defaultShell)


		spallHandler.shells[i]= deepcopy(projectileHandler.defaultShell)
	end


	for i=1, 7 do
		explosion_sounds[i] = LoadSound("MOD/sounds/explosion/ExplosionDistant0"..i..".ogg")
	end

	loadCustomControls()

	if(GetBool("savegame.mod.debug")) then	
		utils.printStr("AVF: "..VERSION.." Started!")
	end
		
		-- utils.printStr(testing.test)

	gunSmokedissipation = 3
	gunSmokeSize =1
	gunSmokeGravity = 2


	----- setting up tandem warhead pen valeus - ideally this will be raw deduction on major, or perhaps something more elegant is needed 

	-- potentially a calc of 20-80 on primary charge to secondary 
	
	---- setup Complete

	SetBool("level.avf.enabled", true)
	
end



function initVehicle(vehicle_in,vehicle_type)

	if unexpected_condition then error() end
	vehicle.body = GetVehicleBody(vehicle.id)
	vehicle.transform =  GetBodyTransform(vehicle.body)
	vehicle.shapes = GetBodyShapes(vehicle.body)
	vehicle.sniperFOV = originalFov
	totalShapes = ""


	if(vehicle_type~=nil) then 
		vehicle.entity_type = vehicle_type
	else
		vehicle.entity_type = "vehicle"
	end

	if(HasTag(vehicle.id,"turret")) then 
		 vehicle.turret_weapon = true
	end
	if(HasTag(vehicle.id,"artillery")) then 
		 vehicle.artillery_weapon = true
		 vehicle.arty_cam_pos = nil

		vehicle.last_mouse_shift = {0,0}
	end

	vehicle.lights = {}

	if(debugging_traversal) then 
		DebugPrint("x shapes : "..#vehicle.shapes)
	end
	for i=1,#vehicle.shapes do
		SetTag(vehicle.shapes[i],"avf_id",vehicle.id)

		SetTag(vehicle.shapes[i],"avf_vehicle_"..vehicle.id)
		if(HasTag(vehicle.shapes[i],"commander")) then
			 vehicleFeatures.commanderPos = vehicle.shapes[i]
		end
			
		local value = GetTagValue(vehicle.shapes[i], "component")
		-- if(value~= "")then

			totalShapes = totalShapes..value.." "

			local test = GetShapeJoints(vehicle.shapes[i])
			if(#test>0 and debugging_traversal)then 

				DebugPrint("body joints: "..#test)
			end
				for j=1,#test do 
					local val2 = GetTagValue(test[j], "component")
					if(val2~= "")then

						totalShapes = totalShapes..val2.." "

						if(val2=="turretJoint")then
							if(debugging_traversal) then 
								DebugPrint("tag val: "..val2)
							end
							totalShapes = totalShapes..traverseTurret(test[j], vehicle.shapes[i])

						elseif val2=="gunJoint" then
							
							local status,retVal = pcall(addGun,test[j], vehicle.shapes[i])
							if status then 
							-- utils.printStr("no errors")
							else
								errorMessages = errorMessages..retVal.."\n"
							end
							-- totalShapes = totalShapes..addGun(test[j], vehicle.shapes[i])
						else
							tag_jointed_object(test[j],vehicle.shapes[i])
						end
					else
						tag_jointed_object(test[j],vehicle.shapes[i])
					end
				end
			
		
			if(HasTag(vehicle.shapes[i],"smokeLauncher")) then

				addSmokeLauncher(vehicle.shapes[i])

			end	


		-- end	

	-- utils.printStr(totalShapes)
	-- DebugPrint(totalShapes)
	end
	local count = 1
	-- local tstStrn = "test" 
	vehicleFeatures.validGroups = {}
	vehicleFeatures.currentGroup =1
	for key,val in ipairs(globalConfig.weaponOrders) do
		
		if(#vehicleFeatures.weapons[val]>0)then
			vehicleFeatures.validGroups[count] = val
			count = count +1
			-- tstStrn = tstStrn.."\n"..key.." "..count
		end
	end


	vehicleFeatures.equippedGroup = vehicleFeatures.validGroups[vehicleFeatures.currentGroup]
	-- for key,val in ipairs(globalConfig.weaponOrders) do
	-- 	if(vehicleFeatures.validGroups[vehicleFeatures.currentGroup] == val) then
	-- 		DebugPrint(val.." | "..vehicleFeatures.validGroups[vehicleFeatures.currentGroup])

	-- 		vehicleFeatures.equippedGroup = vehicleFeatures.validGroups[vehicleFeatures.currentGroup]
	-- 	end
	-- end
	if not vehicleFeatures.commanderPos then
		if(#vehicleFeatures.turrets.mainTurret>0) then
			vehicleFeatures.commanderPos = vehicleFeatures.turrets.mainTurret[1].id
		else

			vehicleFeatures.commanderPos = vehicle.shapes[1]
		end

	end

	vehicle.ZOOMVAL   = 0.1
	vehicle.ZOOMMAX   = 8
	vehicle.ZOOMMIN   = 0 
	vehicle.ZOOMLEVEL = vehicle.ZOOMMIN   

	if(DEBUG_AI) then 
		local status,retVal = pcall(initAI)
		if status then 
				-- utils.printStr("no errors")
			else
				DebugWatch("[ai config ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end
	else
		initAI()
	end



	-- utils.printStr(tstStrn)
end


function initAI()

	if(HasTag(vehicle.id,"avf_ai")) then
		AVF_ai:initAi()
		-- DebugPrint("Vehicle: "..vehicle.id.." is ai ready")
	end
end

function tick(dt)
	frameErrorMessages = ""

	-- local player_pos = GetPlayerCameraTransform().pos
	-- local hit,d,n= QueryRaycast(player_pos, Vec(0,-1,0),10)
	-- DebugWatch("player height ",d)
	-- if(AVF_Vehicle_Used and (InputPressed("esc") or InputDown("esc") or InputReleased("esc"))) then
	-- 	SetInt("options.gfx.fov",originalFov)
	-- end


	-- gameplayTicks(dt)
					local status,retVal = pcall(gameplayTicks,dt)
					if status then 
							-- utils.printStr("no errors")
						else
							DebugWatch("[GAMEPLAY TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
						end
	if(DEBUG_CODE) then 
		local status,retVal = pcall(playerTicks,dt)
		if status then 
				
		else
			DebugWatch("[PLAYER TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end
	else
		playerTicks(dt)
	end

	pollNewVehicle(dt)

	if(GetBool("savegame.mod.debug")) then	
		DebugWatch("Errors: ",errorMessages)
		DebugWatch("Frame errors",frameErrorMessages)
	end

	if(debugMode or debug_player_damage) then 
		if(#debugStuff.redCrosses>0) then
			for i = 1,#debugStuff.redCrosses do

				DebugCross(debugStuff.redCrosses[i],2-i,-1+i,0)

			end
		end
	end

	-- DebugWatch("x: ",InputValue("mousedx"))
	-- DebugWatch("y: ",InputValue("mousedy"))
	-- DebugWatch("fox: ",GetInt("options.gfx.fov", fov))

	-- if(AVF_Vehicle_Used and (InputPressed("esc") or InputDown("esc") or InputReleased("esc"))) then
	-- 	SetInt("options.gfx.fov",originalFov)
	-- end

end

function gameplayTicks( dt )
	if unexpected_condition then error() end

	--- to be implemented


		AVF_ai:aiTick(dt)

	

	reloadTicks(dt)




	ammoRefillTick(dt)

	explosionController:tick(dt)
end

function playerTicks( dt )
	if unexpected_condition then error() end
	-- for key,val in pairs(vehicles) do

	-- 	vehicle = val.vehicle
	-- 	vehicleFeatures = val.vehicleFeatures
	--     if(vehicle.artillery_weapon) then 
	--     	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
 --    		for key2,gun in ipairs(gunGroup) do
	-- 			if( not IsJointBroken(gun.gunJoint) and  not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	---not IsShapeBroken(gun.id) and
	-- 				if(not gun.magazines[gun.loadedMagazine].outOfAmmo and gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]) then
	-- 					local barrelCoords = getBarrelCoords(gun)
	-- 			    	t,hit = simulate_projectile_motion(gun,barrelCoords)
	-- 			    	projectileHitPos = t.pos 
	-- 			    end
	-- 			end
	-- 		end
	--     end
	-- end

	
	if(
		(GetBool("game.player.usevehicle") )) 
	then
			
			inVehicle, vehicleid = playerInVehicle()
				if(inVehicle)then 
					if(interaction_timeout_timer >0) then
						interaction_timeout_timer  = 0
					end 


					if(not AVF_Vehicle_Used) then
						AVF_Vehicle_Used = true
					end
					vehicle = vehicles[vehicleid].vehicle
					vehicleFeatures = vehicles[vehicleid].vehicleFeatures

					handleInputs(dt)
					--DebugWatch("sniperMode", vehicle.sniperMode) 
					if(vehicle.artillery_weapon) then 
						handle_artillery_control(dt)

					elseif(not viewingMap and not vehicle.sniperMode) then 
						manageCamera()
					elseif (vehicle.sniperMode	) then
					--DebugWatch("sniperMode", vehicle.sniperMode) 
						-- DebugWatch("arty ")
						--if(vehicle.artillery_weapon) then 
						--	set_artillery_cam(vehicle.arty.final_pos,vehicle.arty.hit_target)
						--else
						
							set_sniper_cam(dt)
						--end
					end
					
					if(vehicle.sniperMode and vehicle.arty_cam_pos~=nil) then 
						set_artillery_cam()
					end
					handleUtilityReloads(dt)
				end

	elseif(viewingMap) then
		viewingMap = false
	else 
		if(interaction_timeout_timer < interaction_timeout_max) then 
			interaction_timeout_timer = interaction_timeout_timer + dt
		else
			interactionTicks(dt)

		end

	end

end



function interactionTicks(dt)
	if(GetPlayerVehicle()==0) then 

		local interactGun = GetPlayerInteractShape()
	--SetTag(gun, "AVF_Parent", vehicle.groupIndex )
		if(HasTag(interactGun,"weapon_host")) then 
			local gun_shapes = GetBodyShapes(GetShapeBody(interactGun))
			for i = 1,#gun_shapes do
				if(HasTag(gun_shapes[i],"component") and GetTagValue(gun_shapes[i],"component")=="gun") then  
					interactGun =gun_shapes[i]
					break
				end
			end
		end

		--- check for palyer inpyut and if player nput found then allocate the vehicle based on tag val. 
			--- then do cool stuff
		if(HasTag(interactGun,"AVF_Parent") and  getPlayerInteactInput()) then 

			-- DebugPrint("AVF_Parent val: "..GetTagValue(interactGun,"AVF_Parent").." gun index: "..interactGun)
			interactVehicle = vehicles[tonumber(GetTagValue(interactGun,"AVF_Parent"))]
			vehicle = interactVehicle.vehicle
			vehicleid = vehicle.groupIndex
			vehicleFeatures = interactVehicle.vehicleFeatures

			if(vehicle.turret_weapon) then 
				SetPlayerVehicle(vehicle.id)
			else
				handleInteractedGunOperation(dt,interactGun)
			end
		end
		local interactGun  =  GetPlayerGrabShape()
		if(HasTag(interactGun,"AVF_Parent") and  getPlayerGrabInput()) then 

			-- DebugPrint("AVF_Parent val: "..GetTagValue(interactGun,"AVF_Parent").." gun index: "..interactGun)
			interactVehicle = vehicles[tonumber(GetTagValue(interactGun,"AVF_Parent"))]
			vehicle = interactVehicle.vehicle
			vehicleid = vehicle.groupIndex
			vehicleFeatures = interactVehicle.vehicleFeatures

				handleGrabGunReset(interactGun)
			-- end
		end
	end

end

function reloadTicks(dt)
	for key,vehicle in pairs(vehicles) do
		vehicleFeatures = vehicle.vehicleFeatures

		--- reload all weapons 
		for key,gunGroup in pairs(vehicleFeatures.weapons) do

			for key2,gun in ipairs(gunGroup) do
				if(HasTag(gun.id, "interact") and 
					(IsJointBroken(gun.gunJoint) or (gun.turretJoint and IsJointBroken(gun.turretJoint)))) then 
					RemoveTag(gun.id, "interact")
				end
				if(debug_weapon_pos) then 
					DebugCross(GetShapeWorldTransform(gun.id).pos,1,0,0)
					DebugCross(retrieve_first_barrel_coord(gun).pos,0,1,0)
				end
				if(gun.reloading) then
					handleReload(gun,dt)
				end
			end

		end
		---
end

end


function update(dt)
	--physics_update_ticks(dt) 
	local status,retVal =pcall(physics_update_ticks,dt);
	if status then 
		-- utils.printStr("no errors")
	else
		DebugWatch("[ERROR]",retVal)
	end

	if(DEBUG_CODE) then 
		local status,retVal = pcall(update_gameplay_ticks,dt)
		if status then 
				
		else
			DebugWatch("[update_gameplay_ticks ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end
		if(debug_vehicle_locations_active) then 
			debug_vehicle_locations()
		end
	else
		update_gameplay_ticks(dt)
	end


end


function update_gameplay_ticks(dt)
	if unexpected_condition then error() end
	if(
		(GetBool("game.player.usevehicle") )) 
	then
			
			inVehicle, vehicleid = playerInVehicle()
				if(inVehicle)then 
					-- if(InputPressed("esc") or InputDown("esc") or InputReleased("esc")) then
					-- 	SetInt("options.gfx.fov",originalFov)
					-- end
					if(not AVF_Vehicle_Used ) then
						AVF_Vehicle_Used = true
					end
					vehicle = vehicles[vehicleid].vehicle
					vehicleFeatures = vehicles[vehicleid].vehicleFeatures
					if(not vehicle.artillery_weapon) then 
						handlegunAngles()
					

					physics_player_update(dt)
					end

					handleGunOperation(dt)
					
					if(not vehicle.sniperMode and not vehicle.artillery_weapon) then
						manageCamera_update()
						
						local rotated_turrets= {}
						local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
						if(gunGroup~= nil) then 
							for key2,gun in ipairs(gunGroup) do
								if(gun.base_turret and not IsJointBroken(gun.turretJoint)) then 
									if(not check_turret_has_rotated(rotated_turrets,gun.base_turret.id)) then 
										turretRotatation(gun.base_turret,gun.turretJoint,retrieve_first_barrel_coord(gun),gun)
										rotated_turrets[#rotated_turrets+1] =gun.base_turret.id
									end 
								end
							end
							for key,gunGroup in pairs(vehicleFeatures.weapons) do
								for key2,gun in ipairs(gunGroup) do
									if(key ~= vehicleFeatures.equippedGroup) then 
										if(
											gun.base_turret and 
											not IsJointBroken(gun.turretJoint) and 
											not check_turret_has_rotated(rotated_turrets,gun.base_turret.id)) 
										then
											SetJointMotor(gun.turretJoint, 0)
										end
									end
								end
							end
						end
						--[[ OLD TURRET ROTATION SETUP

						for key,turretGroup in pairs(vehicleFeatures.turrets) do
							for key2,turret in ipairs(turretGroup) do
								if(not IsJointBroken(turret.turretJoint) and not vehicle.sniperMode) then
									local status,retVal = pcall(turretRotatation,turret,turret.turretJoint);
									if status then 
										-- utils.printStr("no errors")
									else
										errorMessages = errorMessages..retVal.."\n"
									end
								-- turretRotatation(turret.id,turret.turretJoint)
								end
							end
						end 
						]]	
											

					end
				end
	else
		-- if(AVF_Vehicle_Used) then
		-- 	SetInt("options.gfx.fov",originalFov)
		-- 	AVF_Vehicle_Used = false
		-- end 
		for _, vehicle in pairs(vehicles) do 					
			if(not HasTag(vehicle.vehicle.id,"avf_ai")) then 
				for key,turretGroup in pairs(vehicle.vehicleFeatures.turrets) do

					for key2,turret in ipairs(turretGroup) do
						SetJointMotor(turret.turretJoint, 0)
					end
				end
			end
		end
	end
	if(explosionController.update~=nil) then 
		-- DebugWatch("controlelr func exist",explosionController.update==nil)
		-- DebugWatch("controlller tst",explosionController.test)
		
		-- DebugWatch("controlller",explosionController:testFunc())
		explosionController:update(dt)
	end
	-- if(AVF_Vehicle_Used and(InputPressed("esc") or InputDown("esc") or InputReleased("esc"))) then
	-- 	SetInt("options.gfx.fov",originalFov)
	-- end
end

function check_turret_has_rotated(rotated_turrets,turret) 
	for i = 1,#rotated_turrets do 
		if(rotated_turrets[i] == turret) then
			return true
		end
	end
	return false

end


function physics_update_ticks(dt) 
	if unexpected_condition then error() end

	projectileTick(dt)


	spallingTick(dt)

	projectorTick(dt)
	
	artilleryTick(dt)





end


function physics_player_update(dt)

					if(vehicle.sniperMode) then
						handleSniperMode(dt)
					else
						handleGunMovement(dt)
					end


end

function handleLightOperation()
	if(InputPressed(armedVehicleControls.toggle_Searchlight)) then
		local light = nil
		for i=1, #vehicle.lights do
			light = vehicle.lights[i]
			if(IsLightActive(light)) then
				SetLightEnabled(light,false)
			else

				SetLightEnabled(light,true)
			end

		end

	end
end

function handleGunMovement(dt)
	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	local gunMovement = 0
	if(InputPressed(armedVehicleControls.elevateGun)or InputDown(armedVehicleControls.elevateGun)) then
		gunMovement = 1
	elseif InputPressed(armedVehicleControls.depressGun) or InputDown(armedVehicleControls.depressGun) then
		gunMovement = -1

	end
		
	local bias = 0.25
	-- local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	if(gunGroup~=nil and #gunGroup>0) then

		for key2,gun in ipairs(gunGroup) do
			if(not IsJointBroken(gun.gunJoint) and not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	
				if(gun.locked) then
					gunMovement = lockedGunAngle(gun)

				end
				if(gun.elevationSpeed) then
					bias = gun.elevationSpeed
				end
				-- utils.printStr(gun.magazines[gun.loadedMagazine].name)
				if(gunMovement~= 0)then
					gun.moved = true
				end
				SetJointMotor(gun.gunJoint, gunMovement*bias)
			end
		end
	end
	 
end


function handleSniperMode(dt ) 
	if unexpected_condition then error() end


	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	local testgunobj = gunGroup[1].id

	local focusGun = gunGroup[1]
	local y = tonumber(focusGun.sight[1].y)
	local x = tonumber(focusGun.sight[1].x)
	local z = tonumber(focusGun.sight[1].z)




	local commanderPos = GetShapeWorldTransform(vehicleFeatures.commanderPos) 
	local focusGunPos = GetShapeWorldTransform(focusGun.id) 

	if(HasTag(testgunobj,"commander")) then 
		commanderPos = GetShapeWorldTransform(testgunobj)
		if(testgunobj ~= nil and 
			(HasTag(testgunobj,"flip_angle_x") or 
				HasTag(testgunobj,"flip_angle_y") or 
				HasTag(testgunobj,"flip_angle_z"))) then
			local x_tag = tonumber(GetTagValue(testgunobj,"flip_angle_x"))
			local y_tag = tonumber(GetTagValue(testgunobj,"flip_angle_y"))
			local z_tag = tonumber(GetTagValue(testgunobj,"flip_angle_z"))
			local x_rot = (x_tag~=nil and x_tag) or 0
			local y_rot = (y_tag~=nil and y_tag) or 0
			local z_rot = (z_tag~=nil and z_tag) or 0 
			-- DebugWatch("x_rot",x_rot)
			-- DebugWatch("y_rot",y_rot)
			-- DebugWatch("z_rot",z_rot)
			commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(x_rot,y_rot, z_rot))
		end
	end
	-- 
	-- focusGunPos = rectifyBarrelCoords(focusGun)
	

	--DebugWatch("orgiinal barrel pos",focusGunPos)
	focusGunPos = retrieve_first_barrel_coord(focusGun)

	--DebugWatch("changing barrel pos",focusGunPos)
	
	local zero_range = 200	
	if(focusGun.zero_range) then
		zero_range = focusGun.zero_range
	end	
	--	DebugWatch("ZERO RANGE",zero_range)
	local cmddist = zero_range
	-- if(GetBool("savegame.mod.horizontalGunLaying")) then
	-- 	QueryRejectBody(vehicle.body)
	-- 	QueryRejectShape(focusGun.id)
	-- 	local cmdfwdPos = TransformToParentPoint(focusGunPos, Vec(0,  200 * -1),1)
	--     local cmddirection = VecSub(cmdfwdPos, focusGunPos.pos)
	--     cmddirection = VecNormalize(cmddirection)
	--     QueryRequire("physical")
	--     cmdhit, cmddist = QueryRaycast(focusGunPos.pos, cmddirection, 200)
	--     DebugWatch("dist",cmddist)
	-- end
	-- DebugWatch("x: ",x)
	-- DebugWatch("y: ",y)
	-- DebugWatch("z: ",z)
	local deadzone = 0
	-- local commanderPos = GetShapeWorldTransform(vehicleFeatures.commanderPos) --vehicleFeatures.turrets.mainTurret[1].id)
	-- local commanderPos = GetVehicleTransform(vehicle.id)
	local posLoc  = TransformToParentPoint(commanderPos, Vec(x,  z, y ))
	local fwdLoc  = TransformToParentPoint(commanderPos, Vec(x,  z-2,y ))
	local direction = VecSub(posLoc, commanderPos.pos)

	commanderPos.rot = QuatLookAt(posLoc,fwdLoc)
	-- commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(0, 0, 0))
	commanderPos.pos = VecAdd(commanderPos.pos, direction)

	-- DebugWatch("x type",type(x))
	----
	local bias = utils.sign(x)

	local primary = GetJointMovement(gunGroup[1].gunJoint)
	
	commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(-primary,0, 0))
	-- DebugWatch("zero range",zero_range)

	local testCommander =  TransformToParentPoint(commanderPos,Vec(0,000,-zero_range))
	local testGun =  TransformToParentPoint( GetShapeWorldTransform(testgunobj),Vec(0,-zero_range,0))
	local offSetAngle = (math.atan(VecLength(VecSub(testCommander,testGun))/cmddist)*10)*bias

	if(focusGun.aimForwards) then
		offSetAngle = 0
	end

	-- 	DebugWatch("test veclength: ",VecLength(VecSub(testCommander,testGun)))
	--DebugWatch("test angle: ",offSetAngle)

	commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(0,-offSetAngle, 0))
	

	local mousewheel = InputValue("mousewheel")
	if(mousewheel > 0 and vehicle.ZOOMLEVEL <vehicle.ZOOMMAX) then
		vehicle.ZOOMLEVEL  = vehicle.ZOOMLEVEL + 1
	elseif(mousewheel < 0 and vehicle.ZOOMLEVEL >vehicle.ZOOMMIN)then 
		vehicle.ZOOMLEVEL = vehicle.ZOOMLEVEL - 1
	end
	local ZOOMVALUE = 1 - (vehicle.ZOOMVAL * vehicle.ZOOMLEVEL)
	-- local mousewheel = InputValue("mousewheel")
	-- if(mousewheel > 0 and vehicle.sniperFOV >20) then
	-- 	vehicle.sniperFOV  = vehicle.sniperFOV - 10
	-- elseif(mousewheel < 0 and vehicle.sniperFOV <originalFov)then 
	-- 	vehicle.sniperFOV = vehicle.sniperFOV + 10
	-- end
	-- DebugWatch("mouse wheel",mousewheel)

	-- DebugWatch("VecLength: ",VecLength(VecSub(commanderPos.pos,GetShapeWorldTransform(vehicleFeatures.turrets.mainTurret[1].id).pos)))
	local rotateSpeed = (vehicle.sniperFOV*ZOOMVALUE) / vehicle.sniperFOV
	local mouseX, mouseY = get_mouse_movement(10)
	mouseX = -mouseX
	mouseY = -mouseY


	if(debugMode)then
		DebugWatch("MouseX",mouseX)
		DebugWatch("MouseY",mouseY)
	end

		-- if(#vehicleFeatures.turrets.mainTurret>0)then
		-- 	if(math.abs(mouseX)>deadzone) then
		-- 			local turn_force = 1
		-- 			turret_rotateSpeed = rotateSpeed*.6
		-- 			SetJointMotor(vehicleFeatures.turrets.mainTurret[1].turretJoint, (turn_force*utils.sign(mouseX))*turret_rotateSpeed)
		-- 	else
		-- 		SetJointMotor(vehicleFeatures.turrets.mainTurret[1].turretJoint, 0)
		-- 	end 
		-- end


		for key,gun in pairs(gunGroup) do

			if(gun.turretJoint~=nil) then 
				if(math.abs(mouseX)>deadzone) then
						local turn_force = 1
						turret_rotateSpeed = rotateSpeed*.6
						SetJointMotor(gun.turretJoint, (turn_force*utils.sign(mouseX))*turret_rotateSpeed)
				else
					SetJointMotor(gun.turretJoint, 0)
				end
			end


			if(gun.locked) then
				handleGunMovement(dt)
			
			elseif(math.abs(mouseY)>deadzone) then
				if( gun.elevationSpeed) then
					local pre = GetJointMovement(gun.gunJoint)
					SetJointMotor(gun.gunJoint, (gun.elevationSpeed*utils.sign(mouseY))*rotateSpeed)
					gun.moved = true
				else
					SetJointMotor(gun.gunJoint, (1*utils.sign(mouseY))*rotateSpeed)
					gun.moved = true
				end
			else
				if(gun.currentGunjointAngle) then
					
					local bias = 0.25
					if(gun.elevationSpeed) then
						bias = gun.elevationSpeed/10
					end
					SetJointMotor(gun.gunJoint, retainGunAngle(gun)*bias)
				else
					SetJointMotor(gun.gunJoint, 0)
				end
			end 
		end
	-- SetCameraTransform(commanderPos, vehicle.sniperFOV*ZOOMVALUE)
end


function set_sniper_cam(dt) 
	if unexpected_condition then error() end


	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	local testgunobj = gunGroup[1].id

	local focusGun = gunGroup[1]
	local y = tonumber(focusGun.sight[1].y)
	local x = tonumber(focusGun.sight[1].x)
	local z = tonumber(focusGun.sight[1].z)




	local commanderPos = GetShapeWorldTransform(vehicleFeatures.commanderPos) 
	local focusGunPos = GetShapeWorldTransform(focusGun.id) 
	if(HasTag(testgunobj,"commander")) then 
		commanderPos = GetShapeWorldTransform(testgunobj)
		if(testgunobj ~= nil and 
		(HasTag(testgunobj,"flip_angle_x") or 
			HasTag(testgunobj,"flip_angle_y") or 
			HasTag(testgunobj,"flip_angle_z"))) then
		local x_tag = tonumber(GetTagValue(testgunobj,"flip_angle_x"))
		local y_tag = tonumber(GetTagValue(testgunobj,"flip_angle_y"))
		local z_tag = tonumber(GetTagValue(testgunobj,"flip_angle_z"))
		local x_rot = (x_tag~=nil and x_tag) or 0
		local y_rot = (y_tag~=nil and y_tag) or 0
		local z_rot = (z_tag~=nil and z_tag) or 0 
		-- DebugWatch("x_rot",x_rot)
		-- DebugWatch("y_rot",y_rot)
		-- DebugWatch("z_rot",z_rot)
		commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(x_rot,y_rot, z_rot))
		end
	end
	-- 
	-- focusGunPos = rectifyBarrelCoords(focusGun)
	--DebugWatch("orgiinal barrel pos",focusGunPos)
	focusGunPos = retrieve_first_barrel_coord(focusGun)

	--DebugWatch("changing barrel pos",focusGunPos)
	
	local zero_range = 200	
	if(focusGun.zero_range) then
		zero_range = focusGun.zero_range
	end	
		-- DebugWatch("ZERO RANGE",zero_range)
	local cmddist = zero_range
	local deadzone = 0
	-- local commanderPos = GetShapeWorldTransform(vehicleFeatures.commanderPos) --vehicleFeatures.turrets.mainTurret[1].id)
	
	-- local commanderPos = GetVehicleTransform(vehicle.id)
	local posLoc  = TransformToParentPoint(commanderPos, Vec(x,  z, y ))
	local fwdLoc  = TransformToParentPoint(commanderPos, Vec(x,  z-2,y ))
	local direction = VecSub(posLoc, commanderPos.pos)

	commanderPos.rot = QuatLookAt(posLoc,fwdLoc)
	commanderPos.pos = VecAdd(commanderPos.pos, direction)

	local bias = utils.sign(x)

	local primary = GetJointMovement(gunGroup[1].gunJoint)
	if(vehicleFeatures.commanderPos~=focusGun.id) then 
		commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(-primary,0, 0))
	end
	-- DebugWatch("zero range",zero_range)

	local testCommander =  TransformToParentPoint(commanderPos,Vec(0,000,-zero_range))
	local testGun =  TransformToParentPoint( GetShapeWorldTransform(testgunobj),Vec(0,-zero_range,0))
	local offSetAngle = (math.atan(VecLength(VecSub(testCommander,testGun))/cmddist)*10)*bias

	if(focusGun.aimForwards) then
		offSetAngle = 0
	end

	-- 	DebugWatch("test veclength: ",VecLength(VecSub(testCommander,testGun)))
	--DebugWatch("test angle: ",offSetAngle)

	commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(0,-offSetAngle, 0))
	local ZOOMVALUE = 1 - (vehicle.ZOOMVAL * vehicle.ZOOMLEVEL)

	if(vehicle.last_cam_pos ~= nil) then 
		local t= (0.5 * ZOOMVALUE)+0.01

		local testCommanderPos = TransformCopy(commanderPos)
		--testCommanderPos.pos = VecLerp(vehicle.last_cam_pos.pos,testCommanderPos.pos, t)
		testCommanderPos.rot = QuatSlerp(vehicle.last_cam_pos.rot,testCommanderPos.rot, t)
		commanderPos = TransformCopy(testCommanderPos)
	end
	vehicle.last_cam_pos = TransformCopy(commanderPos)
	
	SetCameraTransform(commanderPos, vehicle.sniperFOV*ZOOMVALUE)
end



function set_artillery_cam()
	local reticle_pos = vehicle.arty_cam_pos[1]
	local hit_target = vehicle.arty_cam_pos[2]
	if(hit_target) then 
		local mousewheel = InputValue("mousewheel")
		if(mousewheel > 0 and vehicle.ZOOMLEVEL <vehicle.ZOOMMAX) then
			vehicle.ZOOMLEVEL  = vehicle.ZOOMLEVEL + 1
		elseif(mousewheel < 0 and vehicle.ZOOMLEVEL >vehicle.ZOOMMIN)then 
			vehicle.ZOOMLEVEL = vehicle.ZOOMLEVEL - 1
		end

		local ZOOMVALUE = 1 - (vehicle.ZOOMVAL * vehicle.ZOOMLEVEL)

		local camHeight = 80
		local commanderPos = Transform(Vec(0, camHeight*ZOOMVALUE,0), QuatLookAt(Vec(0,0,0),Vec(0,-1,0)))
		commanderPos = TransformToParentTransform(reticle_pos,commanderPos)

		if(vehicle.last_cam_pos ~= nil) then 
			local t= (0.01 * ZOOMVALUE)+0.01

			-- local mx,my = get_mouse_movement()
			-- local y = commanderPos.pos[2]
			local testCommanderPos = TransformCopy(commanderPos)

			local last_cam_pos = TransformCopy(vehicle.last_cam_pos)
			-- testCommanderPos.pos =  VecAdd(last_cam_pos.pos,Vec(-mx*1,0,-my*1))
			-- if(hit_target) then 
			-- 	testCommanderPos.pos[2] = commanderPos.pos[2]
			-- else
			-- 	testCommanderPos.pos[2] = GetVehicleTransform(vehicle.id).pos[2]+camHeight
			-- end
			testCommanderPos.pos = VecLerp(last_cam_pos.pos,testCommanderPos.pos, t)
			testCommanderPos.rot = QuatSlerp(last_cam_pos.rot,testCommanderPos.rot, t)
			commanderPos = TransformCopy(testCommanderPos)
		end
		vehicle.last_cam_pos = TransformCopy(commanderPos)
		SetCameraTransform(commanderPos)
	elseif(vehicle.last_cam_pos~=nil) then 	
		SetCameraTransform(vehicle.last_cam_pos)
	end
end

function handle_artillery_control(dt)
	-- if(vehicle.arty_cam_pos~= nil ) then 
		local gun_movement = 0  
		local mouseX, mouseY = get_mouse_movement(0.25)
		-- if(input_active("w")) then
		-- 	gun_movement = -1
		-- elseif input_active("s") then
		-- 	gun_movement = 1
		-- end	
		local turret_movement = 0 
		-- if(input_active("a")) then
		-- 	turret_movement = 1
		-- elseif input_active("d") then
		-- 	turret_movement = -1
		-- end	
		local rotate_vec = Vec(mouseX,0,mouseY)

		gun_movement = mouseY
		turret_movement = mouseX
		local rotateSpeed = 1

		local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
		
		for key,gunGroup in pairs(vehicleFeatures.weapons) do
			
		-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do

				--[[ 	movement stuff ]]
				  gun_movement, turret_movement = get_arty_aim_movement(rotate_vec,vehicle.arty_cam_pos[1],gun)
				  get_arty_aim_movement(rotate_vec,vehicle.arty_cam_pos[1],gun)
				-- gun_movement, turret_movement =  get_arty_aim_movement(rotate_vec,vehicle.arty_cam_pos,gun)
				-- local min, max = GetJointLimits(gun.gunJoint)
				-- local movement = GetJointMovement(gun.gunJoint)
				-- DebugWatch("joint movement",movement)
				-- DebugWatch("min movement",min)
				-- DebugWatch("max movement",max)
				-- DebugWatch("gun movement",gun_movement)
				-- DebugWatch("turet  movement",turret_movement)
				--[[]]
				if(gun_movement~=0 and not IsJointBroken(gun.gunJoint) and not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	
					if( gun.elevationSpeed) then
						SetJointMotor(gun.gunJoint, (gun.elevationSpeed*gun_movement)*rotateSpeed)
					else
						SetJointMotor(gun.gunJoint, gun_movement*rotateSpeed)
					end
					gun.last_gun_joint_pos = GetJointMovement(gun.gunJoint)
			
					--DebugWatch(" gun_movement*rotateSpeed", gun_movement*rotateSpeed)
				else
					if(gun.last_gun_joint_pos and gun.last_gun_joint_pos < GetJointMovement(gun.gunJoint)) then 
						SetJointMotor(gun.gunJoint, 0.2)
					elseif(gun.last_gun_joint_pos and gun.last_gun_joint_pos > GetJointMovement(gun.gunJoint)) then 
						SetJointMotor(gun.gunJoint, -0.2)
					else
						SetJointMotor(gun.gunJoint, 0)
					end
				end 

				if(gun.base_turret) then 
					if(not IsJointBroken(gun.turretJoint)) then
						SetJointMotor(gun.turretJoint, 1*turret_movement)
				
					end
				end
			end
		end
	-- end
	-- -- DebugPrint("turret move: "..turret_movement.." | gun move: "..gun_movement)
	-- for key,turretGroup in pairs(vehicleFeatures.turrets) do
	-- 	for key2,turret in ipairs(turretGroup) do
	-- 		if(not IsJointBroken(turret.turretJoint)) then
	-- 			SetJointMotor(turret.turretJoint, 1*turret_movement)
			
	-- 		end
	-- 	end 	
	-- end
	-- if(#vehicleFeatures.turrets.mainTurret>0)then
	-- 	if(math.abs(mouseX)>deadzone) then
	-- 			local turn_force = 1
	-- 			turret_rotateSpeed = rotateSpeed*.6
	-- 			SetJointMotor(vehicleFeatures.turrets.mainTurret[1].turretJoint, (turn_force*utils.sign(mouseX))*turret_rotateSpeed)
	-- 	else
	-- 		SetJointMotor(vehicleFeatures.turrets.mainTurret[1].turretJoint, 0)
	-- 	end 
	-- end
	-- local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	
	-- for key2,gun in ipairs(gunGroup) do
	-- 	if(gun_movement~=0 and not IsJointBroken(gun.gunJoint) and not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	
	-- 		if( gun.elevationSpeed) then
	-- 			SetJointMotor(gun.gunJoint, (gun.elevationSpeed*gun_movement)*rotateSpeed)
	-- 		else
	-- 			SetJointMotor(gun.gunJoint, gun_movement*rotateSpeed)
	-- 		end
	-- 		gun.last_gun_joint_pos = GetJointMovement(gun.gunJoint)
	
	-- 		--DebugWatch(" gun_movement*rotateSpeed", gun_movement*rotateSpeed)
	-- 	else
	-- 		if(gun.last_gun_joint_pos and gun.last_gun_joint_pos < GetJointMovement(gun.gunJoint)) then 
	-- 			SetJointMotor(gun.gunJoint, 0.2)
	-- 		elseif(gun.last_gun_joint_pos and gun.last_gun_joint_pos > GetJointMovement(gun.gunJoint)) then 
	-- 			SetJointMotor(gun.gunJoint, -0.2)
	-- 		else
	-- 			SetJointMotor(gun.gunJoint, 0)
	-- 		end
	-- 	end 
	-- end



end


function get_arty_aim_movement(rotate_vec,arty_pos,gun)
	-- arty_pos.pos = rotate_vec
	-- DebugWatch("arty_cam",arty_pos)
	-- DebugWatch("rotate_vec",rotate_vec)
	local new_pos = VecAdd(arty_pos.pos,rotate_vec)
	local cannon_pos = retrieve_first_barrel_coord(gun)
	-- local target_pos = TransformToLocalTransform(vehicle.last_cam_pos,arty_pos)
	local target_pos_01 = TransformToLocalPoint(cannon_pos,arty_pos.pos)
	local target_pos_02 = TransformToLocalPoint(cannon_pos,new_pos)
	-- DebugWatch("tagret pos 1",target_pos_01)
	-- DebugWatch("tagret pos 2",target_pos_02)
	local target_pos = VecSub(target_pos_02,target_pos_01)
	-- DebugWatch("tagret pos 3",target_pos)

	local x,y,z = -target_pos[1],-target_pos[2],-target_pos[3]
	-- DebugPrint(x)
	-- DebugPrint(y)
	-- DebugPrint(z)
	-- -- DebugWatch("x",target_pos.pos[1])
	return y,x
	
end

--[[@GUNHANDLING


	GUN_OPERATION_HANDLING_CODE
	CODE KEY @GUNHANDLING


]]

function handleGunOperation(dt)

	local playerShooting,released,held = getPlayerShootInput()
	local firing = false	
	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	if ((
		(GetBool("game.player.usevehicle") and playerInVehicle()
			and  playerShooting
			 )))
	then
		firing = true
	elseif( released and not held)then
		
		
		-- utils.printStr(#gunGroup)
		for key2,gun in ipairs(gunGroup) do
			if(not gun.reloading and gun.tailOffSound and gun.rapidFire)then
				local cannonLoc = GetShapeWorldTransform(gun.id)
				PlaySound(gun.tailOffSound, cannonLoc.pos, 80)
				gun.rapidFire = false
			end
		end
		
	end

	-- for key,gunGroup in pairs(vehicleFeatures.weapons) do
		-- utils.printStr(#vehicleFeatures.weapons[vehicleFeatures.equippedGroup].." | "..vehicleFeatures.equippedGroup)
	

	-- local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	
	-- utils.printStr(#gunGroup)
	if(gunGroup~=nil and #gunGroup>0) then
		for key2,gun in ipairs(gunGroup) do
			if( not IsJointBroken(gun.gunJoint) and  not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	---not IsShapeBroken(gun.id) and
				if(not gun.magazines[gun.loadedMagazine].outOfAmmo and gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]) then
		

					local barrelCoords = getBarrelCoords(gun)
					-- DebugWatch("gun pos",GetShapeWorldTransform(gun.id))
					local maxDist = 400				
					----- gun laying 
					if(not vehicle.sniperMode and not vehicle.artillery_weapon) then 
						autoGunAim(gun,barrelCoords)
					

					end
						--- gun reticle drawing
					if((not vehicle.sniperMode or vehicle.artillery_weapon or vehicle.ZOOMLEVEL<=vehicle.ZOOMMIN)) then

						QueryRejectBody(vehicle.body)
						QueryRejectShape(gun.id)
						local fwdPos = TransformToParentPoint(barrelCoords, Vec(0,  maxDist * -1),1)
					    local direction = VecSub(fwdPos, barrelCoords.pos)
					    direction = VecNormalize(direction)
					    QueryRequire("physical")
					    local hit, dist = QueryRaycast(barrelCoords.pos, direction, maxDist)
					    local projectileHitPos = VecAdd(barrelCoords.pos,VecScale(direction, dist))
					    local t = Quat()

					    if(vehicle.artillery_weapon) then 
					    	t,hit = simulate_projectile_motion(gun,retrieve_first_barrel_coord(gun))
					    	projectileHitPos = t.pos 
					    end
					    if(hit) then 
				    		
							t.pos = projectileHitPos
							drawReticleSprite(t)

							setReticleScreenPos(projectileHitPos)


						else
							removeReticleScreenPos()
						end
					end

					local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
					-- utils.printStr(currentMagazine.AmmoCount)
					if(not gun.reloading and currentMagazine.AmmoCount > 0) then  
						-- utils.printStr(currentMagazine.AmmoCount)
						    -- DebugWatch("cfgammo",gun.magazines[gun.loadedMagazine].CfgAmmo.launcher)

					  
					    if(gun.magazines[gun.loadedMagazine].CfgAmmo.launcher == "homing") then 
					    	initiate_missile_guidance(dt,gun,firing)
					    else

						    if(getPlayerMouseDown() and gun.loopSoundFile)then
						    	if not gun.rapidFire then
						    		
						    		gun.rapidFire = true

						    	end
								local cannonLoc = GetShapeWorldTransform(gun.id)

								PlayLoop(gun.loopSoundFile, cannonLoc.pos, 5)
								
							end
							
							-- handle_weapon_firing(dt,gun)

							if (gun.timeToFire and gun.timeToFire <=0) then
							 	if (firing) then
							 		-- smokeProjection(gun)
							 		
							 		if (gun.cycleTime < dt) then
							 			local firePerFrame =1
							 		
							 			firePerFrame = (math.floor((dt/gun.cycleTime)+0.5))
								 		
								 		-- utils.printStr(firePerFrame)
								 		for i =1, firePerFrame do 
								 			eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
											fireControl(dt,gun)
											currentMagazine.AmmoCount =currentMagazine.AmmoCount -1
											if(currentMagazine.AmmoCount <= 0) then
												break
											end
										end
										
									else
										fireControl(dt,gun)
										currentMagazine.AmmoCount =currentMagazine.AmmoCount -1

									end
									if(currentMagazine.AmmoCount <= 0) then
										local status,retVal = pcall(reloadGun,gun);
										if status then 
											-- utils.printStr("no errors")
										else
											errorMessages = errorMessages..retVal.."\n"
										end
										-- reloadGun(gun)
									end
									
									-- utils.printStr((gun.magazines[gun.loadedMagazine].name))
								end
							elseif (gun.timeToFire) then
								eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
								gun.timeToFire = gun.timeToFire - dt
							end
						end
						-- utils.printStr(dt)
					-- elseif(gun.reloading) then
					-- 	-- utils.printStr("reloading")
					-- 	handleReload(gun,dt)
					end
				elseif(playerShooting) then
					PlaySound(gun.dryFire, GetShapeWorldTransform(gun.id).pos, 5)
					-- utils.printStr("gun out of ammo"..gun.magazines[gun.loadedMagazine].name)
				end
			end
		end
	end

	-- end 
end



function handleGrabGunReset(interactGun)
		for key,gunGroup in pairs(vehicleFeatures.weapons) do
		
		-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do
				if(gun.id == interactGun)then
					SetJointMotor(gun.gunJoint,0,0)
					if(gun.turretJoint) then 
						SetJointMotor(gun.turretJoint,0,0)
					end
				end
			end
		end
end


function handleInteractedGunOperation(dt,interactGun)

	local playerShooting,released = getPlayerInteactInput()
	local firing = false	
	if (
		playerShooting
			 )
	then
		firing = true
	elseif( released)then
		for key,gunGroup in pairs(vehicleFeatures.weapons) do
		
		-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do
				if(gun.id == interactGun and not gun.reloading and gun.tailOffSound and gun.rapidFire)then
					local cannonLoc = GetShapeWorldTransform(gun.id)
					PlaySound(gun.tailOffSound, cannonLoc.pos, 5)
					gun.rapidFire = false
				end
			end
		end
	end

	for key,gunGroup in pairs(vehicleFeatures.weapons) do
		-- utils.printStr(#vehicleFeatures.weapons[vehicleFeatures.equippedGroup].." | "..vehicleFeatures.equippedGroup)
		
		for key2,gun in ipairs(gunGroup) do
			if(gun.id == interactGun and not IsJointBroken(gun.gunJoint))then	---not IsShapeBroken(gun.id) and
				if(not gun.magazines[gun.loadedMagazine].outOfAmmo and gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]) then
					local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
					if(not gun.reloading and currentMagazine.AmmoCount > 0) then  
					    if(getInteractMouseDown() and gun.loopSoundFile)then
					    	if not gun.rapidFire then
					    		
					    		gun.rapidFire = true

					    	end
							local cannonLoc = GetShapeWorldTransform(gun.id)

							PlayLoop(gun.loopSoundFile, cannonLoc.pos, 5)
							
						end
						
						if (gun.timeToFire and gun.timeToFire <=0) then
						 	if (firing) then
						 		
						 		if (gun.cycleTime < dt) then
						 			local firePerFrame =1
						 		
						 			firePerFrame = (math.floor((dt/gun.cycleTime)+0.5))
							 		for i =1, firePerFrame do 
										fireControl(dt,gun)
										eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
										currentMagazine.AmmoCount =currentMagazine.AmmoCount -1
										if(currentMagazine.AmmoCount <= 0) then
											break
										end
									end
									
								else
									fireControl(dt,gun)
									currentMagazine.AmmoCount =currentMagazine.AmmoCount -1

								end
								if(currentMagazine.AmmoCount <= 0) then
									local status,retVal = pcall(reloadGun,gun);
									if status then 
									else
										errorMessages = errorMessages..retVal.."\n"
									end
								end
								
							end
						elseif (gun.timeToFire) then
							eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)

							gun.timeToFire = gun.timeToFire - dt
						end

					end
				elseif(playerShooting) then
					PlaySound(gun.dryFire, GetShapeWorldTransform(gun.id).pos, 5)
				end
			end
		end

	end 
end

function handle_weapon_firing(dt,gun)
	if (gun.timeToFire and gun.timeToFire <=0) then
	 	if (firing) then
	 		if (gun.cycleTime < dt) then
	 			local firePerFrame =1
	 			firePerFrame = (math.floor((dt/gun.cycleTime)+0.5))
		 		for i =1, firePerFrame do 
		 			eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
					fireControl(dt,gun)
					currentMagazine.AmmoCount =currentMagazine.AmmoCount -1
					if(currentMagazine.AmmoCount <= 0) then
						break
					end
				end
				
			else
				fireControl(dt,gun)
				currentMagazine.AmmoCount =currentMagazine.AmmoCount -1

			end
			if(currentMagazine.AmmoCount <= 0) then
				local status,retVal = pcall(reloadGun,gun);
				if not status then 
					DebugWatch("weapon reload error: ",retVal)
				end
			end
		end
	elseif (gun.timeToFire) then
		eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
		gun.timeToFire = gun.timeToFire - dt
	end

end


--[[@MISSILE_GUIDANCE

	MISSILE GUIDANCE CODE


]]
function initiate_missile_guidance(dt,gun,firing)
	local max_dist = 400
	local playerShooting,released,held = getPlayerShootInput()
	if(playerShooting and firing)then
		local cannonLoc = retrieve_first_barrel_coord(gun)
		
		QueryRejectBody(vehicle.body)
		local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  max_dist * -1),0)
	    local direction = VecSub(fwdPos, cannonLoc.pos)
	
	    DebugWatch("test firing 2",firing)
	    direction = VecNormalize(direction)
	    QueryRequire("physical")
	    local hit, dist,n,shape = QueryRaycast(cannonLoc.pos, direction, max_dist)
	    DebugWatch("current track",gun.missile_guidance_current_track )
	    if(hit) then 
	    	
	    	local last_tracked,tracked_object = verify_tracked_target(gun,shape)


	    	if(gun.missile_guidance_tracked_target ~= nil and last_tracked ) then 
	    		gun.missile_guidance_current_track = gun.missile_guidance_current_track + dt
	    		missile_guidance_behaviors(gun)
	    	else
				reset_missile_track(gun)
				gun.missile_guidance_tracking_target = true
	    		gun.missile_guidance_tracked_target = tracked_object
	    	end
    	else
	    	dist = max_dist
	    end

	    local pos = VecAdd(cannonLoc.pos,VecScale(direction,dist))
	    DrawLine(cannonLoc.pos, pos, 1, 0, 0) 

	    DebugWatch("dist",dist)
	

	elseif(released) then 
		if(gun.missile_guidance_current_track>3) then 
	    	local min, max = GetBodyBounds(gun.missile_guidance_tracked_target )
			local boundsSize = VecSub(max, min)
			local center = VecLerp(min, max, 0.5)
			gun.missile_guidance_active_tracking_target = true
			gun.missile_guidance_target_lock = true
			gun.missile_guidance_target_pos = TransformToLocalPoint(GetBodyTransform(gun.missile_guidance_tracked_target),center)
			Explosion(TransformToParentPoint(GetBodyTransform(gun.missile_guidance_tracked_target),gun.missile_guidance_target_pos ),1.5)
		elseif (gun.missile_guidance_current_track)>0.5 then       	
			local min, max = GetBodyBounds(gun.missile_guidance_tracked_target )
			local boundsSize = VecSub(max, min)
			local center = VecLerp(min, max, 0.5)
			gun.missile_guidance_target_pos = center
			Explosion(center,1.2)
		end
		reset_missile_track(gun)
	elseif(gun.missile_guidance_tracking_target) then
		reset_missile_track(gun)
	end						    	
end

function verify_tracked_target(gun,shape) 
	local tracked_body = GetShapeBody(shape)
	tracked_body,mass = get_largest_body(tracked_body)
	DebugWatch("mass",mass)
	if(mass==0) then 
		return false,tracked_body
	end
	local last_tracked = false
	if(gun.missile_guidance_tracked_target ~= nil) then 
		if(tracked_body == gun.missile_guidance_tracked_target) then 
			return true, tracked_body
		end
	end
	return last_tracked,tracked_body
end


function get_largest_body(body)
	local mass = GetBodyMass(body)
	local largest_body =  body
	local all = GetJointedBodies(body)
	for i=1,#all do
		local test_mass = GetBodyMass(all[i])
		if(test_mass>mass) then
			mass = test_mass
			largest_body = all[i]
		end
	end
	return largest_body,mass
end



function missile_guidance_behaviors(gun)
	if(gun.missile_guidance_current_track>3) then 
		DrawBodyOutline(gun.missile_guidance_tracked_target, 0, 1, 0, 1)

	elseif(gun.missile_guidance_current_track)>0.5 then 
		DrawBodyOutline(gun.missile_guidance_tracked_target, 1, 0, 0, 1)
	end

end

function reset_missile_track(gun) 
	gun.missile_guidance_tracking_target = false
	gun.missile_guidance_active_tracking_target = false
	gun.missile_guidance_tracked_target = nil		
	gun.missile_guidance_target_pos = nil		
	gun.missile_guidance_target_lock = false
	gun.missile_guidance_current_track = 0

end

--[[@RELOADING


	RELOAD HANDLING CODE 
	CODE KEY @RELOADINGCODE


]]

function handleReload(gun,dt)
	
	gun.reloadTime = gun.reloadTime - dt
	if(not gun.reloadPlayOnce)then
		PlayLoop(gun.reloadSound, GetShapeWorldTransform(gun.id).pos, 3)
	end
	local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	local base_reload = gun.reload					

	if(currentMagazine.magazineCapacity ==1) then
		base_reload =  gun.timeToFire
		eject_shell_casing(gun,base_reload,gun.reloadTime)
	end		
	
	if(gun.reloadTime < 0) then
		gun.reloading = false
		gun.timeToFire = 0
		gun.shell_ejected = false
		-- gun.magazines[gun.loadedMagazine].currentMagazine.AmmoCount =gun.magazines[gun.loadedMagazine].currentMagazine.magazineCapacity
		-- gun.magazines[gun.loadedMagazine].currentMagazine = gun.magazines[gun.loadedMagazine].nextMagazine
	
	end
end

function eject_shell_casing(gun,base_reload,reloadTime)
	if(debug_shell_casings) then 
				DebugWatch("base reload",base_reload)
				DebugWatch("relaodtime",reloadTime)
				DebugWatch("reload time actual",(base_reload*.5)-reloadTime)
				DebugWatch("time step",GetTimeStep())
				DebugWatch("test case 0 (ejector)",gun.shell_ejector~= nil )
				DebugWatch("test case 1 (shell ejected)",not gun.shell_ejected )
				DebugWatch("test case 2 (reload condition 1)",reloadTime<base_reload*.5 )
				DebugWatch("test case 3 (reload condition 2)",base_reload< GetTimeStep() )
	end

	if(gun.shell_ejector~= nil and not gun.shell_ejected and (reloadTime<base_reload*.55 or base_reload< GetTimeStep())) then 
		-- DebugPrint("test") 
		if(#gun.shell_ejector>1) then 
			gun.ejector_port = (gun.ejector_port % #gun.shell_ejector)+1 
		end
		local ejector_port = gun.ejector_port
		local xml = "<script open='true' pos='0.0 0.0 0.0'  file='MOD/scripts/shell_casing_lifespan.lua'> <body dynamic='true'> <vox file='MOD/vox/shell_casings.vox' "..gun.shell_casing_type.."'/></body></script>"
		local ejector_pos_base = Vec(gun.shell_ejector[ejector_port].x,gun.shell_ejector[ejector_port].y,gun.shell_ejector[ejector_port].z)
		local ejector_pos = TransformToParentPoint(GetShapeWorldTransform(gun.id),ejector_pos_base)

		local vel = Vec(rnd(-2, 2), rnd(4, 8), rnd(-2, 2))		
		if(gun.shell_ejector_dir) then 
			vel = Vec(rnd(-20, 20), rnd(-20, 20), rnd(-20, 20))
			-- vel = Vec(0,0,0)
			local shell_ejector_dir = Vec(gun.shell_ejector_dir[ejector_port].x,gun.shell_ejector_dir[ejector_port].y,gun.shell_ejector_dir[ejector_port].z)
			if(debug_shell_casings) then 
				DebugWatch("shell eject base",ejector_pos_base)
				DebugWatch("shell eject dir",shell_ejector_dir)
				DebugWatch("shell eject dir exists!",VecSub(ejector_pos_base,shell_ejector_dir))
			end
			local base_dir = Transform(ejector_pos_base,GetShapeWorldTransform(gun.id).rot)--,QuatLookAt(ejector_pos_base,shell_ejector_dir))
			-- base_dir.rot = QuatRotateQuat(base_dir.rot, QuatEuler(0, 0, 90))
			shell_ejector_dir = TransformToParentPoint(base_dir,VecScale(VecSub(shell_ejector_dir,ejector_pos_base),3))
			-- shell_ejector_dir.pos = Vec(shell_ejector_dir.pos[1],shell_ejector_dir.pos[2],shell_ejector_dir.pos[3]) 
			vel = VecAdd(VecScale(vel,0.1),shell_ejector_dir) --TransformToParentPoint(shell_ejector_dir,VecScale(vel,1))
			
			if(debug_shell_casings) then 
				DebugWatch("shell_ejector_dir CALCULATED!",shell_ejector_dir)
				DebugWatch("shell eject dir vel !",vel)
			end
		end
		vel = VecAdd(vel,
			VecScale(
				GetBodyVelocity(
					GetVehicleBody(vehicle.id)
					),
				0.8
				)
			)
		spawn_entity(ejector_pos,xml,vel)
		gun.shell_ejected = true

		if(gun.ejection_joint~=nil) then 

			local min, max = GetJointLimits(gun.ejection_joint)
			SetJointMotorTarget(gun.ejection_joint, max, 5)
		end
	end
end

function spawn_entity(pos,xml,vel)
	local entities = Spawn(xml, Transform(pos))

	--Set velocity on spawned bodies (only one in this case)


	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			SetBodyVelocity(entities[i], vel)
			SetBodyAngularVelocity(entities[i], Vec(rnd(-3,3), rnd(-3,3), rnd(-3,3)))
		end
	end
end

--[[@GUN_ANGLING

	HANDLE GUN ANGLING CODE

]]

function handlegunAngles()
	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	if(gunGroup~=nil and #gunGroup>0) then
		for key2,gun in ipairs(gunGroup) do
			if(not IsJointBroken(gun.gunJoint))then	
				if(gun.moved and not gun.locked) then
					storegunAngle(gun)
					gun.moved = false
				end
			end
		end
	end
end

function storegunAngle(gun)
	gun.currentGunjointAngle = GetJointMovement(gun.gunJoint)
end
--- i have no idea what this function was supposed to originally do, i guess compare last frame to this frame maybe?
function retainGunAngle(gun)
	if(gun.currentGunjointAngle < GetJointMovement(gun.gunJoint)) then
		return 1
	elseif(gun.currentGunjointAngle > GetJointMovement(gun.gunJoint)) then
		return -1
	else
		return 0 
	end
end

function reloadGun(gun)
	if unexpected_condition then error() end
	local loadedMagazine =  gun.magazines[gun.loadedMagazine]
	local currentMagazine =loadedMagazine.magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	if(gun.tailOffSound and gun.rapidFire)then
		local cannonLoc = GetShapeWorldTransform(gun.id)
		PlaySound(gun.tailOffSound, cannonLoc.pos, 5)
		gun.rapidFire = false
	end
	gun.reloading = true
	
	if(currentMagazine.magazineCapacity ==1) then
		gun.reloadTime =  gun.timeToFire
	else 
		gun.reloadTime = gun.reload
	end
	if(gun.ejection_joint~=nil) then 

		local min, max = GetJointLimits(gun.ejection_joint)
		SetJointMotorTarget(gun.ejection_joint, min, 5)
	end

	currentMagazine.AmmoCount = currentMagazine.magazineCapacity
	if(currentMagazine.expendedMagazines == gun.magazines[gun.loadedMagazine].magazineCount) then
		gun.magazines[gun.loadedMagazine].outOfAmmo = true
		
		return 0
	end
	if(not GetBool("savegame.mod.infiniteAmmo")) then
	currentMagazine.expendedMagazines = currentMagazine.expendedMagazines+1 
	end
		if(gun.reloadPlayOnce)then
			PlaySound(gun.reloadSound, GetShapeWorldTransform(gun.id).pos, 5)
		end

end


--[[@FIRECONTROL
	
	HANDLE WEAPON FIRE CONTROL



]]

function fireControl(dt,gun,barrelCoords)
	local body = GetShapeBody(gun.id)
	-- utils.printStr("firing "..gun.name.."with "..munitions[gun.default].name.."\n"..body.." "..gun.id.." "..vehicle.body)
	local barrelCoords = rectifyBarrelCoords(gun)
--	DebugWatch("barrel coords",barrelCoords)
	if( gun.weaponType ~= "special") then 
		for i=1, gun.smokeMulti do
			cannonSmoke(dt,gun,barrelCoords)

			
			if(gun.backBlast) then
				local backBlastLoc = barrelCoords
				backBlast(dt,gun,backBlastLoc)
			end
			if(gun.cannonBlast) then
				cannonBlast(gun,barrelCoords)
				
			end
			
		
		end
	end
	
	fire(gun,barrelCoords)
	processRecoil(gun)
	gun.timeToFire = gun.cycleTime
	gun.shell_ejected = false
	if(gun.ejection_joint~=nil) then 

		local min, max = GetJointLimits(gun.ejection_joint)
		SetJointMotorTarget(gun.ejection_joint, min, 5)
		gun.shell_ejected = false
	end
end

function cannonSmoke(dt,gun,barrelCoords)
		
		local cannonLoc = GetShapeWorldTransform(gun.id)
		-- local fwdPos = TransformToParentPoint(cannonLoc, Vec(0, 0, 100))
		local fwdPos = TransformToParentPoint(barrelCoords, Vec(math.random(-3*gun.smokeFactor,3*gun.smokeFactor), 
																math.random(-4*gun.smokeFactor,4*gun.smokeFactor),
																math.random(-3*gun.smokeFactor,2*gun.smokeFactor)))
		local direction = VecSub(fwdPos, cannonLoc.pos)
		-- direction = VecNormalize(direction) 
		smokePos = barrelCoords.pos
		local smokeX = clamp(((direction[1]*360)+math.random(1,10)*0.1),-gunSmokedissipation,gunSmokedissipation)
		local smokeY = clamp((direction[3]*10)+math.random(1,10),-gunSmokedissipation,gunSmokedissipation)
		
		ParticleReset()
		ParticleType("smoke")
		ParticleTile(0)
		local startColour = math.random(20,55)/100

		local endColour = math.random(1,10)/100
		ParticleColor(startColour ,startColour ,startColour ,endColour ,endColour ,endColour )
		ParticleRadius(math.random(0.5,1)*gun.smokeFactor, math.random(1,3)*gun.smokeFactor,"easeout")
		ParticleAlpha(1.0, 0.3,"easeout")
		ParticleGravity(1,-0.8,"easeout")
		ParticleDrag(1)
		ParticleEmissive(1, 0.1,"easeout")
		ParticleRotation(0.5, 0)
		ParticleStretch(0.8)
		ParticleCollide(0, 1, "constant", 0.05)

		SpawnParticle(smokePos,  VecScale(direction,0.25), math.random(3,16))


		-- ParticleReset()
		-- ParticleType("plain")
		-- ParticleTile(5)
		-- ParticleColor(1,1,0, 1,0,0)
		-- ParticleRadius((math.random(0.2,0.4)*gun.smokeFactor),(math.random(0.3,0.5)*gun.smokeFactor)*2)
		-- ParticleAlpha(1.0, 0.8,"easeout")
		-- ParticleGravity(2,1,"easeout")
		-- ParticleDrag(0.2)
		-- ParticleEmissive(1, 0.8,"easeout")
		-- ParticleRotation(0.5, 0)
		-- ParticleStretch(0.8)
		-- ParticleCollide(0, 1, "constant", 0.05)

		-- SpawnParticle(smokePos,  direction, math.random(0.1,1))


		-- SpawnParticle("smoke", smokePos, direction, (math.random(1,gunSmokeSize)*gun.smokeFactor), math.random(1,gunSmokeGravity)*gun.smokeFactor)
		SpawnParticle("fire", smokePos,direction, gun.smokeFactor, .2)

		PointLight(smokePos, 0.8, 0.8, 0.5, math.random(gun.smokeFactor,gun.smokeFactor*3))

		-- SpawnParticle("smoke", smokePos, Vec(-math.random(-1,1)*smokeX, 1.0+math.random(-3,1),math.random(1,1)*smokeY ), (math.random(1,gunSmokeSize)*gun.smokeFactor), math.random(1,gunSmokeGravity)*gun.smokeFactor)
	
end

function backBlast(dt,gun,barrelCoords)
		
		local backBlastLoc = rectifyBackBlastPoint(gun)
		local fwdPos = TransformToParentPoint(backBlastLoc, Vec(math.random(-3,3), math.random(2,6),math.random(-3,3)))
		local direction = VecSub(fwdPos, backBlastLoc.pos)
		local temp = direction[2]
		smokePos = backBlastLoc.pos
		local backBlast = nil
		if(gun.multiBarrel)then
			backBlast = gun.backBlast[gun.multiBarrel]
			
		else 
			backBlast = gun.backBlast[1]
		end
		local smokeX = clamp(((direction[1]*360)+math.random(1,10)*0.1),-gunSmokedissipation,gunSmokedissipation)
		local smokeY = clamp((direction[3]*10)+math.random(1,10),-gunSmokedissipation,gunSmokedissipation)
		
		--[[
			new particle stuff

		]]
		ParticleReset()
		ParticleType("smoke")
		ParticleTile(0)
		local startColour = math.random(20,55)/100

		local endColour = math.random(0,10)/100
		ParticleColor(startColour ,startColour ,startColour ,endColour ,endColour ,endColour )
		ParticleRadius(math.random(0.5,1)*gun.smokeFactor, math.random(2,6)*gun.smokeFactor,"easeout")
		ParticleAlpha(1.0, 0.2)
		ParticleGravity(1,-1,"easeout")
		ParticleDrag(0.8)
		ParticleEmissive(1, 0.1,"easeout")
		ParticleRotation(0.5, 0)
		ParticleStretch(1.0)
		ParticleCollide(1, 1, "constant", 0.05)

		SpawnParticle(smokePos,  direction, math.random(7,18))



		-- ParticleReset()
		-- ParticleType("plain")
		-- ParticleTile(5)
		-- ParticleColor(1,1,0, 1,0,0)
		-- ParticleRadius((math.random(gunSmokeSize,gunSmokeSize*gun.smokeFactor)),(math.random(gunSmokeSize,gunSmokeSize*gun.smokeFactor)*2))
		-- ParticleAlpha(1.0, 0.8,"easeout")
		-- ParticleGravity(2,-0.5,"easeout")
		-- ParticleDrag(0.7)
		-- ParticleEmissive(1, 0.8,"easeout")
		-- ParticleRotation(0.5, 0)
		-- ParticleStretch(0.8)
		-- ParticleCollide(0, 1, "constant", 0.05)

		-- SpawnParticle(smokePos,  direction, math.random(1,3))

		-- SpawnParticle("smoke", smokePos,direction, (math.random(1,gunSmokeSize)*gun.smokeFactor)/2, math.random(1,gunSmokeGravity)*gun.smokeFactor)
		SpawnParticle("fire", smokePos,direction, .6, .3)
		physicalBackblast(gun,backBlastLoc)
	

	-- DebugWatch("Direction: ["..direction[1]..","..direction[2]..","..direction[3].."]".."smokex: "..smokeX.." smoke y :"..smokeY)
end


function physicalBackblast(gun,backBlastLoc)
			local backBlast = nil
			if(gun.multiBarrel)then
				backBlast = gun.backBlast[gun.multiBarrel]
				
			else 
				backBlast = gun.backBlast[1]
			end
			local strength = backBlast.force/10	--Strength of blower
			local maxMass = 2400	--The maximum mass for a body to be affected
			local maxDist = 20	--The maximum distance for bodies to be affected
				--Get all physical and dynamic bodies in front of camera
				-- inVehicle, vehicleid = playerInVehicle()

			local t = backBlastLoc
			local c = TransformToParentPoint(t, Vec(0,  maxDist/2,0))
			local mi = VecAdd(c, Vec(-maxDist/5, -maxDist/5, -maxDist/5))
			local ma = VecAdd(c, Vec(maxDist/5, maxDist/5, maxDist/5))
			QueryRequire("physical dynamic")
			QueryRejectVehicle(vehicle.id)
			local bodies = QueryAabbBodies(mi, ma)


			--Loop through bodies and push them
			for i=1,#bodies do
				local b = bodies[i]


				local rand = (math.random())
				if(rand<.005) then 
					local t = GetBodyTransform(b)
					SpawnFire(t.pos)
				end
			end
			local mi = VecAdd(c, Vec(-maxDist/2, -maxDist/2, -maxDist/2))
			local ma = VecAdd(c, Vec(maxDist/2, maxDist/2, maxDist/2))
			QueryRequire("physical dynamic")
			QueryRejectVehicle(vehicle.id)
			local bodies = QueryAabbBodies(mi, ma)

			--Loop through bodies and push them
			for i=1,#bodies do
				local b = bodies[i]

				--Compute body center point and distance
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(bc, t.pos)
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)

				--Get body mass
				local mass = GetBodyMass(b)
				
				--Check if body is should be affected
				if dist < maxDist and mass < maxMass then
					--Make sure direction is always pointing slightly upwards
					dir[2] = 0.5
					dir = VecNormalize(dir)
			
					--Compute how much velocity to add
					local massScale = 1 - math.min(mass/maxMass, 1.0)
					local distScale = 1 - math.min(dist/maxDist, 1.0)
					local add = VecScale(dir, strength * massScale * distScale)
					
					--Add velocity to body
					local vel = GetBodyVelocity(b)
					vel = VecAdd(vel, add)
					SetBodyVelocity(b, vel)
				end
			end
end

function cannonBlast(gun,cannonLoc)

			local strength = gun.cannonBlast/10	--Strength of blower
			local maxMass = 2400	--The maximum mass for a body to be affected
			local maxDist = 10	--The maximum distance for bodies to be affected
				--Get all physical and dynamic bodies in front of camera
				-- inVehicle, vehicleid = playerInVehicle()
			local t = cannonLoc
			local c = TransformToParentPoint(t, Vec(0, .5,0))
			local mi = VecAdd(c, Vec(-maxDist, -maxDist/4, -maxDist/2))
			local ma = VecAdd(c, Vec(maxDist, 0, maxDist/2))
			QueryRequire("physical dynamic")
			QueryRejectVehicle(vehicle.id)
			-- for i=1,#ignored_bodies do 
			-- 	QueryRejectShape(ignored_bodies[i])
			-- end
			local bodies = QueryAabbBodies(mi, ma)

			--Loop through bodies and push them
			for i=1,#bodies do
				local b = bodies[i]


				--Compute body center point and distance
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(bc, t.pos)
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)

				--Get body mass
				local mass = GetBodyMass(b)


				--Check if body is should be affected
				
					--Make sure direction is always pointing slightly upwards
					dir[2] = 0.5
					dir = VecNormalize(dir)
			
					--Compute how much velocity to add
					local massScale = 1 - math.min(mass/maxMass, 1.0)
					local distScale = 1 - math.min(dist/maxDist, 1.0)
					local add = VecScale(dir, (strength*2) * massScale * distScale)
					
					--Add velocity to body
					local vel = GetBodyVelocity(b)
					vel = VecAdd(vel, add)
					if(not HasTag(GetBodyShapes(b)[1],"avf_id")or  tonumber(GetTagValue(GetBodyShapes(b)[1],"avf_id"))~=vehicle.id) then 
						add_blast_dust(gun,strength,mass,b,vel )
					end 
				if dist < maxDist and mass < maxMass then
					SetBodyVelocity(b, vel)
				end
			end
end



function add_blast_dust(gun,strength,mass,b,body_vel)
		local size = (strength*math.log(mass))* .2
		local pos = GetBodyTransform(b).pos
		local q = 1
		for i=1, 3*q do
			local w = 0.8-q*0.2
			local w2 = 1.0
			local r = size*(0.5 + 0.5*q)
			local v = VecAdd(Vec(0, q*0.5, 0), rndVec(1*q))
			local p = VecAdd(pos, rndVec(1*0.5))
			v = VecAdd(v,body_vel)
			ParticleReset()
			ParticleType("smoke")
			ParticleColor(w, w*0.95, w*0.9, w2, w2*0.95, w2*0.9)
			ParticleRadius(0.5*r, r)
			ParticleGravity(rnd(0,2))
			ParticleDrag(1.0)
			ParticleAlpha(q, q, "constant", 0, 0.5)
			SpawnParticle(p, v, rnd(3,9	))
		end


end



function rectifyBackBlastPoint(gun)

	local backBlastLoc = GetShapeWorldTransform(gun.id)
	local backBlast = nil
	if(gun.multiBarrel)then
		-- gun.multiBarrel, barrel = next(gun.barrels,gun.multiBarrel)
		backBlast = gun.backBlast[gun.multiBarrel]
		barrel = gun.barrels[gun.multiBarrel]
		
	else 
		backBlast = gun.backBlast[1]
		barrel = gun.barrels[1]
	end
	local backBlastLoc = backBlastLoc
	local y = barrel.y
	local x = barrel.x 
	local z = backBlast.z
	local fwdPos1 = TransformToParentPoint(backBlastLoc, Vec(x, z,y))
	local direction1 = VecSub(fwdPos1, backBlastLoc.pos)
	backBlastLoc.pos = VecAdd(backBlastLoc.pos, direction1)
	return backBlastLoc
	-- body
end

function smokeProjection(projector)
	-- testDistance(projector)
		-- utils.printStr(projector.reload)
		-- local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1),1)
  --   local direction = VecSub(fwdPos, cannonLoc.pos)
	 --    direction = VecNormalize(direction)
	 local maxDist = projector.maxDist
	 
	 
	 -- local launchers  	   = 6
	 
	 for i = 1,projector.smokeMulti do 
		 for j = 1, #projector.barrels do

		 	local barrel = projector.barrels[projector.multiBarrel]
		 	local cannonLoc=  rectifyBarrelCoords(projector)
		 	-- utils.printStr("tst")
		 	local projectionAngle =  -(math.sin(math.rad(barrel.y_angle)) * ((maxDist/4)))
		 	local projectionCone  =  (math.sin(math.rad(barrel.x_angle)) * maxDist)
		 	-- utils.printStr(projectionAngle.." | "..projectionCone)
		 	local z = math.abs(projectionCone)
			local fwdPos = TransformToParentPoint(cannonLoc,  Vec(projectionCone, -10+z,projectionAngle))
		    local direction = VecSub(fwdPos, cannonLoc.pos)
		    direction = VecNormalize(direction)
		    QueryRejectBody(vehicle.body)
		    QueryRequire("physical")
		    hit, dist = QueryRaycast(cannonLoc.pos, direction, maxDist)
		    if(hit)then
		    	hitPos = TransformToParentPoint(cannonLoc, Vec(projectionCone, -dist,projectionAngle))
		    else
		    	hitPos = TransformToParentPoint(cannonLoc, Vec(projectionCone, -maxDist+z,projectionAngle))
		    end

		    pushSmoke(projector,hitPos,cannonLoc.pos)
		     -- SpawnParticle("smoke",hitPos, Vec(0, 1, 0), 3, 8)
		    
		end


	 end

	 reloadSmoke(projector)

	
	--  for i =1,2 do
	-- 	 for i = -projectionCone,projectionCone,((projectionCone*2)/launchers) do
	-- 	 	local z = math.abs(i)
	-- 		local fwdPos = TransformToParentPoint(cannonLoc,  Vec(i, -10+z,projectionAngle))
	-- 	    local direction = VecSub(fwdPos, cannonLoc.pos)
	-- 	    direction = VecNormalize(direction)
	-- 	    QueryRejectBody(vehicle.body)
	-- 	    hit, dist = QueryRaycast(cannonLoc.pos, direction, maxDist)
	-- 	    if(hit)then
	-- 	    	hitPos = TransformToParentPoint(cannonLoc, Vec(i, -dist,projectionAngle))
	-- 	    else
	-- 	    	hitPos = TransformToParentPoint(cannonLoc, Vec(i, -maxDist+z,projectionAngle))
	-- 	    end

	-- 	    pushSmoke(projector,hitPos,cannonLoc.pos)
	-- 	     -- SpawnParticle("smoke",hitPos, Vec(0, 1, 0), 3, 8)
		    
	-- 	end
	-- end
	-- body
end

function pushSmoke(projector,hitPos,cannonPos)
	projectorHandler.shells[projectorHandler.shellNum] = deepcopy(projectorHandler.defaultShell)
	-- loadedShell 				= projectorHandler.shells[projectorHandler.shellNum] 
	-- loadedShell.active 			= true
	-- loadedShell.hitPos 			= hitPos
	-- loadedShell.maxDist 		= projector.maxDist
	-- loadedShell.velocity 		= projector.velocity
	-- loadedShell.speed   		= projector.velocity/projector.maxDist
	-- loadedShell.smokeFactor 	= projector.smokeFactor
	-- loadedShell.smokeMulti   	= projector.smokeMulti
	-- loadedShell.pos 			= cannonPos
	-- loadedShell.vel 			= Vec()
	loadedShell 				= projectorHandler.shells[projectorHandler.shellNum] 
	loadedShell.active 			= true
	loadedShell.hitPos 			= hitPos
	loadedShell.maxDist 		= projector.maxDist
	loadedShell.velocity 		= projector.velocity
	loadedShell.speed   		= loadedShell.velocity/loadedShell.maxDist
	loadedShell.smokeFactor 	= projector.smokeFactor
	loadedShell.smokeMulti   	= projector.smokeMulti
	loadedShell.pos 			= cannonPos
	loadedShell.vel 			= Vec()



	-- defaultShell = {active=false, hitPos=nil,timeToTarget =0}
	-- 			maxDist					= 10,
	-- 			magazineCapacity 		= 6,
	-- 			reload 					= 10,
	-- 			smokeFactor 			= .5,
	-- 			smokeMulti				= 1,



	projectorHandler.shellNum = (projectorHandler.shellNum%#projectorHandler.shells) +1
end


function reloadSmoke(projector)
	projector.currentReload = projector.reload
	projector.reloading = true
	-- utils.printStr("reloading smoke")
	-- body
end

function handleUtilityReloads(dt )
	for i=1,#vehicleFeatures.utility.smoke do
			if( vehicleFeatures.utility.smoke[i].reloading) then
				handleSmokeReload(vehicleFeatures.utility.smoke[i],dt)
			end
		end
	-- body
end

function handleSmokeReload(projector,dt)
	projector.currentReload = projector.currentReload -dt
	if(projector.currentReload < 0)then
		projector.reloading = false
	end 

end

function projectorTick(dt)
	local activeShells = 0
		for key,shell in ipairs( projectorHandler.shells  )do
			 if(shell.active==true)then
			 	if(type(shell.hitPos)~= "table")then
			 		shell.active = false
			 	else
				 	activeShells= activeShells+1
				 	if  VecLength(VecSub(shell.pos, shell.hitPos)) <0.3 then
				 		popSmoke(shell)
				 	else
				 		-- shell.timeToTarget = shell.timeToTarget-dt
						local acc = VecSub(shell.hitPos, shell.pos)
						shell.vel = VecAdd(shell.vel, VecScale(acc, shell.speed))
						shell.vel = VecScale(shell.vel, .98)
						shell.pos = VecAdd(shell.pos, VecScale(shell.vel, dt))
						SpawnParticle("smoke",shell.pos, Vec(0, 1, 0), .1, 2)
				 	end
			 	end
			 end
		end
	-- utils.printStr(activeShells)
	-- local acc = VecSub(chopperTargetPos, chopperTransform.pos)
	-- chopperVel = VecAdd(chopperVel, VecScale(acc, dt))
	-- chopperVel = VecScale(chopperVel, 0.98)
	-- chopperTransform.pos = VecAdd(chopperTransform.pos, VecScale(chopperVel, dt))


end

function popSmoke(shell)
	SpawnParticle("smoke",shell.hitPos, Vec(0, 1, 0), shell.smokeFactor, 8)
	shell.active = false
	shell = deepcopy(projectorHandler.defaultShell)
	-- body
end

function smokeGeneratorTick(projector,dt)
	local barrel = projector.barrels[1]
	local projectionX  =  (math.sin(math.rad(barrel.x_angle)) * maxDist)
	local projectionY  =  (math.sin(math.rad(barrel.x_angle)) * maxDist)
	local projectionZ  =  (math.sin(math.rad(barrel.x_angle)) * maxDist)
	if(projector.smokeTime > 0) then
		projector.smokeTime = projector.smokeTime - dt
		SpawnParticle("smoke",shell.pos, Vec(0, shell.y_angle, shell.z_angle), shell.smokeFactor, 2)
	end
	-- body
end

--[[
	simulate the projectiles motion from the weapon

]]
function simulate_projectile_motion(gun,cannonLoc) 
	local dt = GetTimeStep()

	cannonLoc.pos = TransformToParentPoint(cannonLoc,Vec(0,-1,0))
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,-1,0))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	direction = VecNormalize(direction)
	local point1 = cannonLoc.pos
	
	---
	local projectile 				= {} 
	projectile.active 			= true
	projectile.shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
	projectile.cannonLoc 			= cannonLoc
	projectile.point1			= point1
	projectile.lastPos 		= point1
	projectile.predictedBulletVelocity = VecScale(direction,projectile.shellType.velocity)
	projectile.originVehicle = vehicle.id
	projectile.originPos 	  = GetShapeWorldTransform(gun.id)
	projectile.originGun	  = gun.id
	projectile.originGun_data	 = deepcopy(gun)
	projectile.timeToLive	  = projectile.shellType.timeToLive
	

	local hit_target = false
	local closest_to_pos = nil
	for i =1,2000 do

		projectile.cannonLoc.pos = projectile.point1

		--projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		if(projectile.shellType.gravityCoef) then
			local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
		else
			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		end
		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))

		if(math.abs(projectile.point1[2]	 - projectile.originPos.pos[2]) < math.abs(VecSub(projectile.point1,point2)[2])) then 
			-- DebugWatch("comapre 1",projectile.point1[2]	 - projectile.originPos.pos[2])
			-- DebugWatch("compare 2",math.abs(VecSub(projectile.point1,point2)[2]))
			-- DebugWatch("pos",projectile.point1)
			closest_to_pos = VecCopy(projectile.point1)

		end


	--	DrawLine(projectile.point1,point2,0,1)
		local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))
		if(hit)then 
			hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
			hit_target = true
		-- end
			-- altloc.rot =  QuatLookAt(altloc.pos, GetCameraTransform().pos)
			-- altloc.pos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1*.99))
			projectile.point1 = hitPos
			break
		else

			projectile.point1 = point2
			if(projectile.hit_npc) then 
				projectile.hit_npc = false
			end
		end

	end
	-- Explosion(projectile.point1)
	local final_pos = Transform(projectile.point1,Quat())
	if(not hit_target and closest_to_pos ~=nil) then 
		final_pos.pos = VecCopy(closest_to_pos)
		-- DebugWatch("closest pos",closest_to_pos)
		-- DebugWatch("cannonloc pos",projectile.originPos.pos)
		hit_target = true
	end



	if(vehicle.sniperMode) then 
			vehicle.last_mouse_shift = {0,0}
			vehicle.arty_cam_pos = {TransformCopy(final_pos),hit_target}


		--set_artillery_cam(final_pos,hit_target)
	end

	return final_pos,hit_target 

end


function processRecoil(gun)
	local recoil = 0.01
	if gun.recoil then
		recoil = gun.recoil
	end
	local bodyLoc = GetBodyTransform(vehicle.body)
	local cannonLoc = GetShapeWorldTransform(gun.id)
	
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0, recoil,0))
    local direction = VecSub(fwdPos, cannonLoc.pos)

	local scaled = VecScale(VecNormalize(direction),recoil*.1)

	-- bodyLoc.pos = VecAdd(bodyLoc.pos,scaled)
	local bodyVelocity = GetBodyVelocity(vehicle.body)
	direction = VecAdd(bodyVelocity,direction)
	SetBodyVelocity(vehicle.body,direction)
	-- SetBodyTransform(vehicle.body,bodyLoc)
	
	processGunRecoil(gun)
	
end

function processGunRecoil(gun)
	local recoil = 0.005
	if gun.weapon_recoil then
		recoil = gun.weapon_recoil
	end
	
	
	local gunLoc = GetShapeWorldTransform(gun.id)
	local cannonLoc = getBarrelCoords(gun)

	local fwdPos = TransformToParentPoint(cannonLoc, 
		Vec(
			math.random()*math.random(-1,1)*.5, 
			-(math.random(15,35)/10)+math.random(),
			-(math.random(15,35)/10)+math.random()))
    local direction = VecSub(cannonLoc.pos,fwdPos)
    marker_1 = cannonLoc.pos
    marker_2 = fwdPos
	local scaled = VecScale(VecNormalize(direction),recoil)
	ApplyBodyImpulse(GetShapeBody(gun.id), cannonLoc.pos, scaled)

end



function testDistance(gun )
	local cannonLoc=  rectifyBarrelCoords(gun)
	QueryRejectBody(vehicle.body)
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1),0)
    local direction = VecSub(fwdPos, cannonLoc.pos)
    direction = VecNormalize(direction)
    QueryRequire("physical")
    hit, dist = QueryRaycast(cannonLoc.pos, direction, maxDist,.2)
    utils.printStr(dist.." | "..type(norma))
end

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


----- payload handlers


	--- @payload_tank_he

----


function payload_tank_he(shell,hitPos,hitTarget,test,custom_explosion_size,non_penetration)

	--Explosion(VecLerp(shell.last_flight_pos,hitPos,0.8),0.3)

	local explosion_size = shell.shellType.explosionSize
	if(custom_explosion_size~=nil ) then 
		explosion_size = custom_explosion_size
	end
	impact_size = explosion_size
	if(non_penetration ~= nil) then
		impact_size = impact_size
		explosion_size = impact_size*.25
	end
	local hard_damage = 0.2
	if(globalConfig.shrapnel_hard_damage_coef[shell.shellType.payload]~= nil ) then 
		hard_damage = hard_damage * globalConfig.shrapnel_hard_damage_coef[shell.shellType.payload] 
	end
	MakeHole(hitPos,explosion_size*1.5,explosion_size*1,explosion_size*hard_damage)

	-- DebugWatch("EXPLOSION SIZE",explosion_size)
	Paint(hitPos,explosion_size*(1+math.random()) , "explosion")
	if shell.shellType.explosionSize >0.5 then 
		local coef_explosion  = explosion_size--/clamp(math.log(shell.gun_RPM),1,100))
		-- DebugWatch("EXPLOSION COEF",coef_explosion)
		explosionController:pushExplosion(hitPos,coef_explosion)
	end
	-- if(shell.shellType.explosionSize>1) then 
		-- shell.shellType.explosionSize
		-- DebugPrint("test: ".. 130*shell.shellType.explosionSize)
		-- DebugWatch("test",IsHandleValid(explosion_sounds[math.random(1,#explosion_sounds)]))
		
		PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], hitPos, 15*(explosion_size*explosion_size), false)
			

	-- end 

	-- DebugWatch("EXPLOSION SIZE1",explosion_size)

	-- hurt player if needed
	local hurt_dist = explosion_size*2.1
	local toPlayer = VecSub(GetPlayerCameraTransform().pos, hitPos)
	local distToPlayer = VecLength(toPlayer)
	local distScale = clamp(1.0 - distToPlayer / hurt_dist, 0.0, 1.0)
	if distScale > 0 then
		local hit = QueryRaycast(hitPos, toPlayer, distToPlayer)
		if(not hit) then 
			local regular_damage = explosion_size*100
			local expected_damage = math.random((regular_damage*.75),regular_damage*1.25)/100
			local player_damage = 
				SetPlayerHealth(GetPlayerHealth() - expected_damage*distScale)
			end
	end

	--- create a series of firethreshold
	local firePos = Vec(0,0,0)
	local unitVec = Vec(0,0,0)
	local maxDist = explosion_size*1.5
	shell.shellType.caliber = shell.shellType.caliber
	pushshrapnel(shell.cannonLoc,shell,test,hitTarget)

	-- DebugWatch("EXPLOSION SIZE2",explosion_size)
	for i = 1,math.max(math.random(5,15)*explosion_size,1) do
		for xyz = 1,3 do 
			unitVec[xyz] = (math.random()*2)-1 
		end
		-- QueryRejectShape(hitTarget)
		local hit, dist = QueryRaycast(hitPos,VecNormalize(unitVec),maxDist)
		if hit and (math.random()>globalConfig.fire_chance_thres) then
			firePos = VecAdd(hitPos, VecScale(unitVec, dist))
			SpawnFire(firePos)
			-- DebugPrint(dist)

		end
	end

	-- DebugWatch("EXPLOSION SIZE3",explosion_size)

end


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

---- 

---- PROJECTILE HANDLING

---

function pushProjectile(cannonLoc,gun)
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,-1,0))

	local direction = VecSub(fwdPos, cannonLoc.pos)

	local point1 = cannonLoc.pos
	local point1 = VecAdd(point1,
						VecScale(
							GetBodyVelocity(
								GetVehicleBody(vehicle.id)),GetTimeStep()))	
	---
				-- local predictedBulletVelocity = VecScale(direction,velocity)

	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)

	loadedShell 				= projectileHandler.shells[projectileHandler.shellNum] 
	loadedShell.active 			= true
	loadedShell.shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
	loadedShell.cannonLoc 			= cannonLoc
	loadedShell.point1			= point1
	loadedShell.lastPos 		= point1
	loadedShell.predictedBulletVelocity = VecScale(direction,loadedShell.shellType.velocity)
	loadedShell.originVehicle = vehicle.id
	loadedShell.originPos 	  = GetShapeWorldTransform(gun.id)
	loadedShell.originGun	  = gun.id
	loadedShell.originGun_data	 = deepcopy(gun)
	loadedShell.timeToLive	  = loadedShell.shellType.timeToLive
	loadedShell.gun_RPM 	  = gun.RPM 
	if(gun.dispersion) then 
		loadedShell.dispersion 	  = gun.dispersion
	else
		loadedShell.dispersion 	  = 1
	end
	local loadedMagazine =  gun.magazines[gun.loadedMagazine]
	local currentMagazine =	loadedMagazine.magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	if (loadedShell.shellType.tracer and 
		 gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine].AmmoCount % loadedShell.shellType.tracer ==0)
	then
		loadedShell.tracer = true
	end
	--[[

		Distance values
		
	]]

	loadedShell.distance_travelled 	  = 0 
	loadedShell.optimum_distance 	  = 100
	if(loadedShell.shellType.optimum_distance~=nil) then 
		loadedShell.optimum_distance = loadedShell.shellType.optimum_distance
	end 


	loadedShell.pen_dist_coef= 1

	--[[
		Penetration values
	]]

	loadedShell.penDepth = loadedShell.shellType.maxPenDepth
	if(globalConfig.penCheck>=loadedShell.shellType.maxPenDepth)then
		loadedShell.maxChecks  =1
	else
		loadedShell.maxChecks = loadedShell.shellType.maxPenDepth/globalConfig.penCheck
	end
	projectileHandler.shellNum = (projectileHandler.shellNum%#projectileHandler.shells) +1

end

function initClusterBomblets(parentProjectile)

	for i=1,math.random(5,10) do
		pushClusterProjectile(parentProjectile.flightPos,parentProjectile)
		
	end
end


function pushClusterProjectile(bombletPos,parentProjectile)
	local fwdPos = TransformToParentPoint(bombletPos, Vec(0,-1,0))
	local direction = VecSub(fwdPos, bombletPos.pos)
	local point1 = bombletPos.pos
	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)

	local fwdPos = TransformToParentPoint(bombletPos, Vec(math.random(-10,10),-10,math.random(-10,10)))
	local direction = VecSub( fwdPos,bombletPos.pos)
	local point1 = bombletPos.pos
	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)
	local currentBomblet				= projectileHandler.shells[projectileHandler.shellNum] 
	currentBomblet.active 			= true 
	currentBomblet.shellType = deepcopy(parentProjectile.shellType)
	--- bomblet specific
	currentBomblet.shellType.payload = currentBomblet.shellType.bomblet.payload
	currentBomblet.shellType.explosionSize = currentBomblet.shellType.bomblet.explosionSize  
	currentBomblet.shellType.gravityCoef = currentBomblet.shellType.bomblet.gravityCoef
	---
	currentBomblet.cannonLoc 			= bombletPos
	currentBomblet.point1			= point1 
	currentBomblet.lastPos 			= point1

	local predictedBulletVelocity = VecScale(parentProjectile.predictedBulletVelocity,0.7)

	predictedBulletVelocity = VecAdd(
				predictedBulletVelocity,
				VecScale(rndVec(currentBomblet.shellType.bomblet.dispersion),
				math.log(parentProjectile.shellType.velocity)))
	currentBomblet.predictedBulletVelocity = predictedBulletVelocity
	currentBomblet.originVehicle = parentProjectile.originVehicle
	currentBomblet.originPos 	  = bombletPos 
	currentBomblet.originGun = parentProjectile.originGun
	currentBomblet.timeToLive	  = parentProjectile.timeToLive
	currentBomblet.dispersion 	  = 1
	currentBomblet.penDepth = parentProjectile.penDepth
	currentBomblet.maxChecks = parentProjectile.maxChecks
	currentBomblet.bomblet = true
	currentBomblet.shellType.airburst = false
	currentBomblet.shellType.shellWidth = math.max(math.random() * 
				(currentBomblet.shellType.shellWidth * 1),0.1 )
	currentBomblet.shellType.shellHeight = math.max(math.random() * 
				(currentBomblet.shellType.shellWidth * 1),0.1) 
		

	projectileHandler.shellNum = (projectileHandler.shellNum%#projectileHandler.shells) +1
end


--[[ @pop_projectile

		CODE TO RUN ON PROJECTILE IMPACT

		CONTROLS SHELL PENTRATION AND ALL SORTS

]]

function popProjectile(shell,hitTarget)


		if(shell.shellType.payload=="cluster") then
			if(VecLength(VecSub(shell.flightPos.pos,shell.originPos.pos))>10) then 
				Explosion(shell.flightPos.pos,shell.shellType.explosionSize)


			end
			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], shell.point1, 20*(shell.shellType.explosionSize*shell.shellType.explosionSize), false)

			initClusterBomblets(shell)
			shell.penDepth = 0
			
		end
		local penetration,passThrough,test,penDepth,dist,spallValue =  getProjectilePenetration(shell,hitTarget)
		local holeModifier = math.random(-15,15)/100
		impactEffect(shell,test.pos,hitTarget)
		if(debug_combat_stuff) then 
			DebugWatch("shell damage",shell.shellType.bulletdamage[1])

			DebugWatch("penDepth",shell.penDepth)
		end

		local pos = test.pos
		local impact_factor = 1
		if(shell.penDepth >0) then 
			impact_factor = 0.2
		end

		apply_impact_impulse(pos,shell,hitTarget,impact_factor)
		
		-- DebugPrint("hit target")
		if ((HasTag(hitTarget,"component") and 
			(GetTagValue(hitTarget,"component") == "ERA" or
			GetTagValue(hitTarget,"component") == "cage"  or
			GetTagValue(hitTarget,"component") == "spaced"))  or
			(shell.penDepth<=0 and  shell.shellType.payload == "HEAT")) then
			if(debug_special_armour) then 
				DebugPrint("hit armour with shell : "..shell.shellType.payload)
				DebugPrint("hit ERA_test")
			end
			if(shell.shellType.payload and (shell.shellType.payload == "HEAT" or 
												shell.shellType.payload == "HESH") and shell.shellType.chargeType==nil)  then
				local explosionPos = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.1,0))
				--Explosion(explosionPos,0.5)
				if(debug_special_armour) then 
					DebugPrint("hit armour with shell : "..shell.shellType.payload)
				end
				-- shell.shellType.payload = "HE"
				shell.penDepth = shell.penDepth *.5
				local explosive_payload = math.random(5,40)/10
				payload_tank_he(shell,explosionPos,hitTarget,test,explosive_payload,true)
				PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], explosionPos, 15*shell.shellType.explosionSize, false)
				if((HasTag(hitTarget,"component") and 
						(GetTagValue(hitTarget,"component") == "ERA" or
						GetTagValue(hitTarget,"component") == "cage"  or
						GetTagValue(hitTarget,"component") == "spaced"))) 
				then 
					if(debug_special_armour) then 
						DebugPrint("hit special armour, confirmed armour hit: "..GetTagValue(hitTarget,"component") )
					end
					explosionController:pushExplosion(shell.point1,.75)
				end
			-- 	DebugPrint("armor too thick")
				
				shell.active = false
				for key,val in ipairs( shell ) do 
					val = nil

				end
				shell = deepcopy(projectileHandler.defaultShell)
				return false
			elseif(shell.shellType.payload and (shell.shellType.payload == "HEAT" or 
												shell.shellType.payload == "HESH") and shell.shellType.chargeType=='tandem') then 
				 shell_passthrough_penetration(shell,test,spallValue,holeModifier)
				if(debug_special_armour) then 
						DebugPrint("hit special armour, confirmed armour hit: "..GetTagValue(hitTarget,"component").." and hit with Tandem warhead" )
				end
				shell.penDepth = shell.penDepth *.6
					explosionController:pushExplosion(shell.point1,1.75)
					shell.shellType.chargeType = nil
				return false
			elseif(shell.penDepth>0 and shell.shellType.payload and (shell.shellType.payload == "AP" or
												shell.shellType.payload == "APHE")) then
				shell.penDepth = shell.penDepth *.8
			elseif(shell.penDepth>0 and shell.shellType.payload and (shell.shellType.payload == "kinetic" or
												shell.shellType.payload == "APSDF")) then
				shell.penDepth = shell.penDepth *.9
			end
		

		elseif(shell.shellType.caliber>30) then 
			local coef_explosion = 200--/shell.gun_RPM
			explosionController:pushExplosion(pos,shell.shellType.caliber/coef_explosion )
		

		end


		SpawnParticle("smoke", shell.point1, Vec(0,1,0), (math.log(shell.shellType.caliber)/2)*(1+holeModifier), math.random(1,3))
		SpawnParticle("fire", shell.point1, Vec(0,1,0), (math.log(shell.shellType.caliber)/4)*(1+holeModifier) , .25)



		if(shell.shellType.payload and shell.penDepth>0 and 
			(shell.shellType.payload == "HEAT" or shell.shellType.payload == "HEAT-MP"))  then

			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],shell.point1, 15*shell.shellType.explosionSize, false)
		
			--	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1+holeModifier),shell.shellType.bulletdamage[2]*(1+holeModifier), shell.shellType.bulletdamage[3]*(1+holeModifier))
			--	MakeHole(test.pos,shell.shellType.bulletdamage[1]*(1+holeModifier),shell.shellType.bulletdamage[2]*(1+holeModifier), shell.shellType.bulletdamage[3]*(1+holeModifier))
			
			if(dist > globalConfig.HEATRange or dist == 0) then
				dist = ((shell.shellType.caliber/100)*2)*1.5
			elseif dist <1 then
				dist=(shell.shellType.caliber/100)*1.25
			end
			


			local explosionPos = VecCopy(test.pos)
			-- DebugPrint(dist)
			-- DebugPrint((shell.shellType.caliber/100)*2)
			local explosionPos_initial = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,1,0))
			payload_tank_he(shell,explosionPos_initial,hitTarget,test)
			-- create penetration explosions and spalling, starting just a little deeper inside.
			local start_dist = 1 
			local heat_pen_force = (dist*1.5)/0.75
			local pen_increment = 0.75
			for i=start_dist,(dist*1.0)+start_dist,pen_increment  do

				explosionPos = TransformToParentPoint(test, Vec(0,i-0.25,0))

	    		-- explosionPos = VecAdd(explosionPos, test.pos)
	    		-- if(i < (dist*1.5)/2) then 
					-- Explosion(explosionPos,0.5)
					payload_tank_he(shell,explosionPos,hitTarget,test,0.25*(start_dist/i))

				-- end

	    		-- projectileShrapnel(shell,Transform(explosionPos,test.rot),spallValue/(heat_pen_force) )

				explosive_penetrator_effect(shell,explosionPos)



			end
			-- DebugPrint("start  explostion pos  "..vec2str(test.pos))
			explosionPos = TransformToParentPoint(test, Vec(0,dist*.7+0.25,0))
			-- DebugPrint("end explostion pos  "..vec2str(explosionPos))

			for i=1,math.random(3,10) do 

	    		projectileShrapnel(shell,Transform(explosionPos,test.rot),spallValue/(heat_pen_force) )
	    	end

			-- if(shell.shellType.payload == "HEAT-MP") then
			-- 	local mp_blast = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.8,0))
			-- 	explosion(mp_blast0.7)
			-- end
		
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)

		elseif(shell.shellType.payload and shell.shellType.payload == "HESH") then
			local explosionPos = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.45,0))
			Explosion(explosionPos,0.5)

			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],explosionPos, 15*shell.shellType.explosionSize, false)
		
			explosionPos = TransformToParentPoint(test, Vec(0,.35,0))
			MakeHole(explosionPos,shell.shellType.bulletdamage[1]*((1.4+holeModifier)*.5),
						shell.shellType.bulletdamage[2]*((1.2+holeModifier)*.5), 
						shell.shellType.bulletdamage[3]*((1.2+holeModifier)*0.5))

			projectileShrapnel(shell,test,spallValue)
	
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)


		elseif(shell.penDepth>0) then		
			-- DebugPrint("2".." "..shell.penDepth)
					-- Explosion(shell.point1,0.5)
					-- MakeHole(shell.point1,1,.7,.5)
					-- gun.magazines[i].CfgAmmo
  				
					-- shellPenetration(shell,test,dist)
					shell.point1 = test.pos
					-- if shell.shellType.hit and shell.shellType.hit <3 then
					-- 	if(shell.shellType.hit ==1)then
					-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier))
					-- 	else
					-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier))
					-- 	end

					-- else
					-- 	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier), shell.shellType.bulletdamage[3]*(1.2+holeModifier))
					-- end
					MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier), shell.shellType.bulletdamage[3]*(1.2+holeModifier))
					projectileShrapnel(shell,test,spallValue)
					explosive_penetrator_effect(shell,test.pos)


					shell.predictedBulletVelocity = VecAdd(shell.predictedBulletVelocity,rndVec(shell.shellType.velocity/(shell.penDepth*10)))
					
					-- SpawnParticle("darksmoke",test.pos, Vec(0, -.1, 0), shell.shellType.bulletdamage[2], 2)
					-- SpawnParticle("darksmoke",test.pos, Vec(0, -.1, 0), shell.shellType.bulletdamage[2], 2)
		else
			-- DebugPrint("3 ".." "..shell.penDepth)
			local shell_hole = deepcopy(shell.shellType.bulletdamage)
			for i = 1,3 do 
				shell_hole[i] = shell_hole[i] +shell.penDepth 
			end

			holeModifier = holeModifier *(1-math.random(1,50)/100)
			if(not penetration) then 
				holeModifier = clamp(-1,0,(-(math.random(50,150)/100))+(shell.penDepth*100))
				--DebugWatch("non pen val hole modifier",holeModifier)
				-- DebugWatch("shell pen depth",shell.penDepth*100)
			end
			if(shell.shellType.payload) then

				if(shell.shellType.payload == "high-explosive") then
					Explosion(test.pos,shell.shellType.explosionSize)
				elseif(shell.shellType.payload == "explosive" or shell.shellType.payload == "HE" or shell.shellType.payload == "APHE") then 
					-- local explosion_pos = VecLerp(shell.last_flight_pos, test.pos,0.8)
					local explosion_pos = TransformToParentPoint(Transform(test.pos,test.rot), Vec(0,-0.25,0))
					payload_tank_he(shell,explosion_pos ,hitTarget,test)
				elseif(shell.shellType.payload == "incendiary") then
					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					end


					local fireChance = math.random()
					if(fireChance>globalConfig.fire_chance_thres)then
						SpawnFire(test.pos)
					end
				elseif(shell.shellType.payload == "incendiary") then
					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),
								shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier),
							shell_hole[3]*(1+holeModifier))
					end


					local fireChance = math.random()
					if(fireChance>globalConfig.fire_chance_thres)then
						SpawnFire(test.pos)
					end
					-- DebugWatch("fire change: ",fireChance)
				elseif(shell.shellType.payload == "HE-I") then

						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					
					SpawnFire(test.pos)
				elseif(shell.shellType.payload == "smoke") then
					-- MakeHole(shell.point1,1,.7,.5)
					local ShellSmoke = math.log(shell.shellType.caliber*2) 
					if( shell.smokeFactor) then
						ShellSmoke = shell.smokeFactor
					end
					for i =1,5 do 
					SpawnParticle("smoke",test.pos, Vec(math.random(-1,1), math.random(-2,1), math.random(-1,1)), ShellSmoke, 10)
					end
				elseif(shell.shellType.payload == "kinetic" or shell.shellType.payload == "AP") then
					if(shell.shellType.caliber>30) then 
						explosionController:pushExplosion(pos,shell.shellType.caliber/200)
					end

					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier),
								shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					end
				end
				
			end
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)
			-- utils.printStr("penetration  explosion")
		-- shellPenetration(shell)
		-- shell = deepcopy(artilleryHandler.defaultShell)
		end


end


function shell_passthrough_penetration(shell,test,spallValue,holeModifier)
	shell.point1 = test.pos
	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),
		shell.shellType.bulletdamage[2]*(1.2+holeModifier), 
		shell.shellType.bulletdamage[3]*(1.2+holeModifier))
	projectileShrapnel(shell,test,spallValue)
	explosive_penetrator_effect(shell,test.pos)
	shell.predictedBulletVelocity = VecAdd(shell.predictedBulletVelocity,rndVec(shell.shellType.velocity/(shell.penDepth*10)))
	
end

function vec2str(tvec)
    return "(x: "..tvec[1].."a y: "..tvec[2].." z: "..tvec[3]..")"
end

function impactEffect(projectile,hitPos,hitTarget)
	local impactSize = projectile.shellType.bulletdamage[1]
	impact_Debris(hitPos,impactSize*30,hitTarget)
	--fire 
	local q = 1.0 
	for i=1, 16 do
		local v = rndVec(impactSize*1)
		local p = hitPos
		local life = rnd(0.2, 0.7)
		life = 0.5 + life*life*life * 1.5
		ParticleReset()
		ParticleColor(1, 0.6, 0.4, 1, 0.3, 0.2)
		ParticleAlpha(1, 0)
		ParticleRadius((impactSize*0.5)*q, 0.5*(impactSize*0.5)*q)
		ParticleGravity(1, rnd(1, 10))
		ParticleDrag(0.6)
		ParticleEmissive(rnd(2, 5), 0, "easeout")
		ParticleTile(5)
		-- DebugWatch("p",p)
		-- DebugWatch("v",v)
		-- DebugWatch("life",life)
		SpawnParticle(p, v, life)
	end
		--- sparks
	local vel = 3
	for i=1, projectile.shellType.bulletdamage[1]*20 do
		local v = VecAdd(Vec(0, vel, 0 ), rndVec(rnd(vel*0.5, vel*1.5)))
		local life = rnd(0, 1)
		life = life*life * 5
		ParticleReset()
		ParticleEmissive(5, 0, "easeout")
		ParticleGravity(-10)
		ParticleRadius(0.03, 0.0, "easein")
		ParticleColor(1, 0.4, 0.3)
		ParticleTile(4)
		SpawnParticle(hitPos, v, life)
	end
end

function impact_Debris(hitPos, vel,hitTarget)
	for i=1, math.random(1,vel*3) do
		local r = rnd(0, 1)
		life = 0.5 + r*r*r*3
		r = (0.4 + 0.6*r*r*r)
		local v = VecAdd(Vec(0, r*vel*0.5, 0), VecScale(rndVec(1), r*vel))
		local radius = rnd(0.03, 0.05)
		local mat,r,g,b = GetShapeMaterialAtPosition(hitTarget, hitPos)
		local w = rnd(0.2, 0.6)
		if(r ==0 and g==0 and b == 0 ) then
			r,g,b = w,w,w

		end
		-- DebugPrint("r: "..r.." | g: "..g.." | b: "..b)
		ParticleReset()
		ParticleColor(r, g, b)
		ParticleAlpha(1)
		ParticleGravity(-10)
		ParticleRadius(radius, radius, "constant", 0, 0.2)
		ParticleSticky(0.2)
		ParticleStretch(0.0)
		ParticleTile(6)
		-- ParticleEmissive(1, 0)
		ParticleRotation(rnd(-20, 20), 0.0, "easeout")
		SpawnParticle(hitPos, v, life)
	
	end
end


function explosive_penetrator_effect(projectile,hitPos)
	local impactSize = projectile.shellType.bulletdamage[1]/3
	local blast_vel = 	VecScale(projectile.predictedBulletVelocity,0.3)
	--fire 
	-- DebugWatch("blast vel",blast_vel )
	-- DebugWatch("proj_pred",projectile.predictedBulletVelocity) 
	local q = 1.0 
	for i=1, 16 do
		local v = VecAdd(blast_vel,rndVec(impactSize*10))
		local p = hitPos
		local life = rnd(0.2, 0.7)
		life = 0.5 + life*life*life * 0.5
		ParticleReset()
		ParticleColor(1, 0.6, 0.4, 1, 0.3, 0.2)
		ParticleAlpha(1, 0)
		ParticleCollide(1, 1, "constant", 0.025)
		ParticleRadius((impactSize*0.5)*q, 0.5*(impactSize*0.5)*q)
		ParticleGravity(1, rnd(1, 10))
		ParticleDrag(1)
		ParticleEmissive(rnd(2, 5), 0, "easeout")
		ParticleTile(5)
		-- DebugWatch("p",p)
		-- DebugWatch("v",v)
		-- DebugWatch("life",life)
		SpawnParticle(p, v, life)
	end
		--- sparks
	local vel = 30
	for i=1, projectile.shellType.bulletdamage[1]*20 do
		local v = VecAdd(blast_vel,VecAdd(Vec(0, vel, 0 ), rndVec(rnd(vel*0.5, vel*1.5))))
		local life = rnd(0, 1)
		life = life*life * 3
		ParticleReset()
		ParticleCollide(1, 1, "constant", 0.025)
		ParticleEmissive(5, 0, "easeout")
		ParticleGravity(-20)
		ParticleRadius(0.03, 0.0, "easein")
		ParticleColor(1, 0.4, 0.3)
		ParticleTile(4)
		SpawnParticle(hitPos, v, life)
	end
end


--[[ @PROJECTILEOPERATIONS


	projectile operations code


]]

function projectileOperations(projectile,dt )
	    projectile.lastPos = projectile.point1
		projectile.cannonLoc.pos = projectile.point1
		local shellHeight = projectile.shellType.shellHeight
		local shellWidth = projectile.shellType.shellWidth
		local r = projectile.shellType.r
		local g = projectile.shellType.g
		local b = projectile.shellType.b
		if(projectile.tracer  ) then

			 shellHeight = shellHeight  * projectile.shellType.tracerL
			 shellWidth = shellWidth  * projectile.shellType.tracerW
			 r = projectile.shellType.tracerR
			 g = projectile.shellType.tracerG
			 b = projectile.shellType.tracerB
		end
		local altloc = TransformCopy(projectile.cannonLoc)
		--- sprite drawing
		-- altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 180,0))
		DrawSprite(projectile.shellType.sprite, altloc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
		
		altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
		DrawSprite(projectile.shellType.sprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
		altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
		DrawSprite(projectile.shellType.spriteRear, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)
		---
		--- adding sound
		if((projectile.shellType.flightLoopSound)) then
			PlayLoop(projectile.shellType.flightLoopSound, projectile.cannonLoc.pos, 20)
					
		end
		---
		---

			--- PROJECTILE MOTION

		---

		projectile.distance_travelled = projectile.distance_travelled + VecLength(VecScale(projectile.predictedBulletVelocity,dt))

		if(not(is_rocket(projectile) or is_chemical_warhead(projectile))) then
			-- DebugWatch("penetration distance travelled",projectile.distance_travelled)
			local max_upper_pen = 1.25
			local test_modifier =	max_upper_pen -  (clamp(projectile.distance_travelled-projectile.optimum_distance,0.1,2000)^0.25)*.1
			projectile.penetration_distance_modifier = clamp(1,0,1.25 )
			-- DebugWatch("penetration distance modifier",projectile.penetration_distance_modifier)

			-- DebugWatch("log dist",(test_modifier))
		end

		if(projectile.shellType.launcher and projectile.shellType.launcher == "guided") then
			local gunPos = retrieve_first_barrel_coord(projectile.originGun_data)
			--local gunPos = GetShapeWorldTransform(projectile.originGun)
			local projectlePos =  TransformCopy(projectile.cannonLoc)
			local length =  VecLength(VecSub(gunPos.pos,projectlePos.pos))
			local atgmfwdPos = VecSub(TransformToParentPoint(gunPos, Vec(0,-length,0)),projectlePos.pos)
			for key,value in pairs(atgmfwdPos) do 
				value = math.log(value)
			end
			-- atgmfwdPos = VecNormalize(atgmfwdPos)
			-- for key,value in pairs(atgmfwdPos) do 
			-- 	value = math.log(math.log(value))/2
			-- end

			-- if(debugMode)then
			-- 	DebugWatch("ATGMDir: ",VecStr(atgmfwdPos))
			-- end
			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,VecScale(atgmfwdPos,0.05))

		else 


			--- adding drag 

			-- projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.950)
			---  ADDING DISPERSION
			local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
			if(projectile.shellType.dispersionCoef) then
				dispersion=VecScale(dispersion,dispersionCoef)
			end
			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))


			--APPLYING WIND


			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(GetWindVelocity(),dt/
				math.log(projectile.shellType.velocity))))
			--- APPLYING GRAVITY
			if(projectile.shellType.gravityCoef) then
				local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
				projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
			else
				projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
			end
		end
		---

		--- EXAUST

		---
		local exaustPos = VecScale(projectile.predictedBulletVelocity,-1)
		-- utils.printStr(VecLength(VecSub(projectile.point1,projectile.originPos.pos)).." | "..VecStr(projectile.point1).." | "..VecStr(projectile.originPos.pos))
		if(VecLength(VecSub(projectile.point1,projectile.originPos.pos))>2)then
			if(projectile.shellType.launcher and (projectile.shellType.launcher == "rocket" or projectile.shellType.launcher == "guided")) then 
				if(VecLength(VecSub(projectile.point1,projectile.originPos.pos))<15)then
					 exaustPos = VecScale(projectile.predictedBulletVelocity,.4)
				elseif(VecLength(VecSub(projectile.point1,projectile.originPos.pos))<30)then

					 exaustPos = VecScale(projectile.predictedBulletVelocity,.7)
				end
				-- local exaustCoef = -math.log(projectile.shellType.caliber)/4
				 exaustPos = VecScale(projectile.predictedBulletVelocity,exaustCoef)
				 local calibreCoef = (math.log(projectile.shellType.caliber)/4) 

				if(projectile.shellType.launcher == "rocket") then
				SpawnParticle("fire",projectile.point1, exaustPos,  1.1*calibreCoef, .15)
				SpawnParticle("smoke",projectile.point1, exaustPos, 1.2*calibreCoef, .3)
				PointLight(projectile.point1, 0.8, 0.8, 0.5, math.random(1*calibreCoef,15*calibreCoef))
				else
					SpawnParticle("darksmoke",projectile.point1, exaustPos, 0.5*calibreCoef, .15)
				end
			else
				-- SpawnParticle("darksmoke",projectile.point1, exaustPos, .3, .15)
			end
		end
	
		--- test for impact

		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
		QueryRejectBody(projectile.originVehicle)
		QueryRejectShape(projectile.originGun)
		QueryRequire("physical")
		
		local rangeTestCoef = VecLength(VecSub(point2,projectile.point1))
		if(projectile.shellType.airburst ==true) then
			rangeTestCoef = math.max(25,rangeTestCoef*5)
		end
		local dir_vec = VecNormalize(VecSub(point2,projectile.point1))
		local hit, dist1,norm1,shape1 = QueryRaycast(
						projectile.point1, 
						dir_vec,
						rangeTestCoef
						)
		
		projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))
		
		local hit_player,player_pos =  inflict_player_damage(projectile,point2)

			if(hit)then 
				-- DebugPrint(rangeTestCoef.." "..projectile.shellType.payload)


				--[[


					TEMP FIX TO SUPPORT MORS LONGA



				]]




				if(projectile.hit_npc ==nil  or not projectile.hit_npc) then  
					mors_longa_damage(projectile,shape1, VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))) 
				end

					--[[


						TEMP FIX ENDS 




					]]

				local refDir = getRefDir(norm1,dir_vec)


				--[[



					acos(dotProduct(Va.normalize(), Vb.normalize()));
				cross = crossProduct(Va, Vb);
				if (dotProduct(Vn, cross) < 0) { // Or > 0
				  angle = -angle;
				}

				]]

				-- DebugWatch("vector impact: ",VecStr(norm1))
				-- DebugWatch("original vect",dir_vec)
				-- DebugWatch("ref dir",refDir)
				local angle_2_acos = math.deg(math.acos(VecDot(dir_vec,norm1)))
				local angle_2_dot = VecDot(dir_vec,norm1)
				local angle2 = angle_2_acos
				-- DebugWatch("angl3e 2", angle_2_acos)
				local angle = math.deg(math.atan2(norm1[3] - dir_vec[3], norm1[1] - dir_vec[1]))
				-- DebugWatch("angle of hit",angle)

				local ricochet_angle = math.random(50,90)	
				-- DebugPrint(projectile.shellType.penDepth)
				if(projectile.penDepth~=nil and projectile.penDepth>0) then 
					ricochet_angle = ricochet_angle + math.random(-30,15*projectile.penDepth)
				elseif(projectile.penDepth~=nil) then 
					ricochet_angle = ricochet_angle + math.random(-50,0)
				end
				-- DebugWatch("impact angle: ",180-angle_2_acos)
				-- DebugWatch("richochet angle: ",ricochet_angle)
				if(richochetModifiers[projectile.shellType.payload]~=nil) then 
					ricochet_angle = ricochet_angle * richochetModifiers[projectile.shellType.payload]
				end
				if((
						--angle_2_acos>	ricochet_angle  and 
						180-angle_2_acos >ricochet_angle)
				) then 
		
						--[[

							apply impulse to simulate being hit by something

						]]
						local pos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))

						local richochet_extreme = ricochet_angle/(180-angle_2_acos) 
						apply_impact_impulse(pos,projectile,shape1,0.8*richochet_extreme )
						-- DebugWatch("RECHOCHET AT ANGLE",180-angle_2_acos)

						hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),(dist1*.6)))
						projectile.flightPos = Transform(VecCopy(projectile.point1),QuatLookAt(point2,projectile.point1))
						projectile.point1 = VecLerp(projectile.point1 ,hitPos,0.95)
						impactEffect(projectile,hitPos,shape1)

						-- DebugPrint("deflect with angle of: "..angle_2_acos)
						local newVel =  VecScale(refDir,VecLength(projectile.predictedBulletVelocity))
						projectile.predictedBulletVelocity[1] = newVel[1]
						projectile.predictedBulletVelocity[3] = newVel[3]
						projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,math.random(25,75)/100)
						local holeModifier = math.random(-139,-10)/100

						local expected_damage = Vec(
										projectile.shellType.bulletdamage[1],
										projectile.shellType.bulletdamage[2],
										projectile.shellType.bulletdamage[2]
									)
						-- DebugWatch("expected_damage",expected_damage)
						-- DebugWatch("richochet_extreme",richochet_extreme)
						expected_damage = VecScale(expected_damage,richochet_extreme)

						-- DebugWatch("expected_damage_update",expected_damage)
						if projectile.shellType.hit and projectile.shellType.hit <3 then
							if(projectile.shellType.hit ==1)then
								MakeHole(projectile.point1,
									expected_damage[1]*(1.4+holeModifier))
							else
								MakeHole(projectile.point1,
									expected_damage[1]*(1.4+holeModifier),
									expected_damage[2]*(1.2+holeModifier))
							end

						else
							MakeHole(projectile.point1,
								expected_damage[1]*(1.4+holeModifier),
								expected_damage[2]*(1.2+holeModifier), 
								expected_damage[3]*(1.2+holeModifier))
						end
						if(projectile.penDepth>0) then 
							projectile.penDepth = projectile.penDepth/2
						end
						Paint(projectile.point1, projectile.shellType.bulletdamage[2]*(1.2+holeModifier), "explosion")

					else
						projectile.last_flight_pos = VecCopy(projectile.point1)
						hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
						projectile.flightPos = Transform(VecCopy(projectile.point1),QuatLookAt(point2,projectile.point1))
						projectile.point1 = hitPos

						popProjectile(projectile,shape1)
					
				end
			elseif(hit_player)then 
				projectile.last_flight_pos = VecCopy(projectile.point1)
				hitPos = player_pos--VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
				projectile.flightPos = Transform(VecCopy(projectile.point1),QuatLookAt(point2,projectile.point1))
				projectile.point1 = hitPos

				popProjectile(projectile,shape1)
			else
				projectile.point1 = point2
				if(projectile.hit_npc) then 
					projectile.hit_npc = false
				end
			end
		
end


function mors_longa_damage(projectile, hitshape,hitPos)

		local mors_longa_damage_mod = 7.5
        -- NPC DAMAGE START
        local gun_damage =  (projectile.shellType.bulletdamage[1] *projectile.shellType.caliber)*mors_longa_damage_mod
        local hitBody = GetShapeBody(hitshape) -- raycast hit shape
        if HasTag(hitBody, "gore_id") then

	        -- DebugPrint("hit target start")
            local path_damage = "level.goreai.body_damage_player." .. hitBody 
		    local damage = GetFloat(path_damage) + gun_damage
		    -- DebugPrint("damage done: "..damage)
		    SetFloat(path_damage, damage) -- Specific damage to each body by handle.

		    SetFloat("level.goreai.body_damage_player_x", hitPos[1])
		    SetFloat("level.goreai.body_damage_player_y", hitPos[2])
		    SetFloat("level.goreai.body_damage_player_z", hitPos[3])

		    SetFloat("level.goreai.body_damage_player_vel_x", projectile.predictedBulletVelocity[1])
		    SetFloat("level.goreai.body_damage_player_vel_y", projectile.predictedBulletVelocity[2])
		    SetFloat("level.goreai.body_damage_player_vel_z", projectile.predictedBulletVelocity[3])

		    projectile.hit_npc = true
            -- DebugPrint("gun damage hit for "..gun_damage)

	        -- DebugPrint("hit target complete")
            return true 

        end

        return false
        -- NPC DAMAGE END

end

function getRefDir(dir,hitNormal)
	local refDir = VecSub(dir, VecScale(hitNormal, VecDot(hitNormal, dir)*2))
	return refDir
end


function apply_impact_impulse(pos,projectile,shape1,factor)
	local pos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
	local imp = VecScale(
							projectile.predictedBulletVelocity,
							projectile.shellType.caliber * 
												(math.log(projectile.shellType.caliber)*.5))
	imp = VecScale(
							imp,
							factor)
	imp = VecScale(imp,globalConfig.impulse_coef)

	ApplyBodyImpulse(GetShapeBody(shape1), pos, imp)
	-- DebugWatch("hit shape ",GetShapeBody(shape1))
	-- DebugWatch("impulse applied",imp)
	-- DebugWatch("pos of impulse",pos)
end

function projectileTick(dt)
		if unexpected_condition then error() end
			local activeShells = 0
			for key,shell in ipairs( projectileHandler.shells  )do
			 	if(shell.active ~= nil and shell.active)then
			 		if(shell.timeToLive > 0) then 
			 			projectileOperations(shell,dt)
			 			shell.timeToLive = shell.timeToLive - dt
			 		else
			 			shell.active = false
			 		end
			 	end
		end
end


 -- check left right, if number then explode, if 0 then fly on.
 	-- pen coef typically 0.1 == 100mm
function getProjectilePenetration(shell,hitTarget)
	local cannonLoc = shell.cannonLoc
	cannonLoc.pos = shell.point1
	local penetration = false
	local passThrough = true  
	local test= cannonLoc	
	local outstring =""
	local penDepth =0
	local dist1 = 0
	local hit1=false
	local penDepth = 0
	local holeModifier = math.random(-15,15)/100

	local shell_pen_depth = shell.penDepth
	local shell_pen_coef = 1
	if(shell.pen_dist_coef~=nil) then 
		shell_pen_coef = shell.pen_dist_coef
	end

	local new_pendepth = shell.penDepth
	local weighted_pen_depth = shell.penDepth * shell_pen_coef
	local sum_pen_depth = 0

	local pen_coef = globalConfig.penCheck / globalConfig.base_pen
	if(globalConfig.pen_coefs[shell.shellType.payload]~= nil) then 
		pen_coef = pen_coef*globalConfig.pen_coefs[shell.shellType.payload]
	end
	pen_coef = pen_coef + ((math.random()-.5)*.15)
	local iteration_coef = globalConfig.base_pen / globalConfig.penCheck

	local spallValue = globalConfig.MaxSpall
	local spallCoef = 0
	local penValue =  calculate_pen_value(shell,hitTarget,test,pen_coef)
	spallCoef = spallCoef + penValue
	--shell.penDepth = shell.penDepth - (penValue * shell.shellType.penModifier)
	sum_pen_depth = sum_pen_depth + (penValue * shell.shellType.penModifier)
	Paint(test.pos, 0.1, "explosion")
	if(sum_pen_depth > weighted_pen_depth) then
		spallValue = spallValue * spallCoef
		Paint(test.pos, 0.1, "explosion")
		shell.penDepth = weighted_pen_depth - sum_pen_depth
		return false,false,test,0,0,spallValue
	end

	local damagePoints = {}

	local pen_check_iterations = globalConfig.pen_check_iterations

	for i =1,pen_check_iterations*iteration_coef do 



		if(debugMode) then 
			debugStuff.redCrosses[#debugStuff.redCrosses+1] = test.pos 

			debugStuff.redCrosses[#debugStuff.redCrosses+1] = fwdPos 
		end

		local fwdPos = TransformToParentPoint(test, Vec(0, globalConfig.penCheck * 1,0))
	    local direction = VecSub(fwdPos, test.pos)

	    direction = VecNormalize(direction)
	    QueryRequire("physical")
	    hit1, dist1,norm1,hitTarget  = QueryRaycast(test.pos, direction, globalConfig.penCheck*2)
		penValue = calculate_pen_value(shell,hitTarget,test,pen_coef)

		sum_pen_depth = sum_pen_depth + (penValue * shell.shellType.penModifier)
		spallCoef = spallCoef + penValue
		damagePoints[i] = VecCopy(test.pos)
		if(not hit1)then


			penDepth = globalConfig.penCheck*i
			penetration=true
			break
		elseif(sum_pen_depth > weighted_pen_depth) then  --shell.penDepth<0) then 
			penDepth = globalConfig.penCheck*i
			penetration=false
			shell.penDepth = weighted_pen_depth - sum_pen_depth
			break
		end
		test = rectifyPenetrationVal(test)
	end

	if(penetration) then 
		shell.penDepth = shell.penDepth  - sum_pen_depth
	end


	if(dist1 ==0) then

		passThrough = not hit1
		
	end
	local holeModifier_value_min = 15

	local holeModifier_value_max = 15
	local pen_true = "non-Penetration!"
	if(penetration) then 
		iteration_coef = 1
		pen_true = "Penetration!"
	else
		iteration_coef = math.max(1,iteration_coef*.75) 
	end
	-- isSpall= ""
	-- if(shell.isSpall) then
	-- 	isSpall = "Spalling "
	-- else
	-- 	DebugPrint(isSpall..pen_true.." | damage points: "..#damagePoints.." | Iteration coef: "..iteration_coef)
	-- end
	if(iteration_coef>#damagePoints) then 
		Paint(damagePoints[1], shell.shellType.bulletdamage[1]*(1.8+holeModifier), "explosion")
	end

	for i=1,#damagePoints,iteration_coef do 
		if( penetration) then 
			holeModifier =(-1 * (i/#damagePoints)) +   math.random(-holeModifier_value_min ,holeModifier_value_max)/100
		elseif(not penetration) then 
			holeModifier = -(math.random(20,50)/10) * (1-(i/(#damagePoints+3)))
		end
		if((shell.shellType.payload == "HEAT" or shell.shellType.payload == "HEAT-MP"))then 
			local hole_size = 0.15
			if(HasTag(hitTarget,"component") and 
			GetTagValue(hitTarget,"component") == "ERA" or
			GetTagValue(hitTarget,"component") == "cage"  or
			GetTagValue(hitTarget,"component") == "spaced") then 
				hole_size = 0.05
			end
			MakeHole(damagePoints[i],
				hole_size*(1.4+holeModifier),
				hole_size*(1.2+holeModifier), 
				hole_size*(1.2+holeModifier))
		else

			MakeHole(damagePoints[i],
				shell.shellType.bulletdamage[1]*(1.4+holeModifier),
				shell.shellType.bulletdamage[2]*(1.2+holeModifier), 
				shell.shellType.bulletdamage[3]*(1.2+holeModifier))
		end
		Paint(damagePoints[i], shell.shellType.bulletdamage[2]*(1.6+holeModifier), "explosion")
	end
	spallValue = spallValue * (spallCoef*.1)
	return penetration,passThrough,test,penDepth,dist1,spallValue
end


-- original pen value code
 --- (penValue + checkArmor(hitTarget))*pen_coef

 -- updated representative value below

 -- hardmetal = 0.45 
 -- rha = 0.03

function calculate_pen_value(shell,hitTarget,test,pen_coef)
	local mat,r,g,b = GetShapeMaterialAtPosition(hitTarget,test.pos)
	local penValue = get_penetration_table(shell)[mat]
	if(not penValue ) then
		penValue = 0.1
	end
	local armour_value = checkArmor(hitTarget,get_penetration_table(shell)['hardmetal'])
	if(armour_value ~= 0) then 
		penValue = armour_value * pen_coef
	else
		penValue = (penValue)*pen_coef
	end
	return penValue


end


-- returns pen table for shell based on payload type 
function get_penetration_table(shell) 
	if(shell.shellType.payload =="HEAT") then 
		-- DebugPrint("heat payload")
		return globalConfig.HEAT_pentable
	elseif(shell.shellType.payload=="kinetic") then
		return globalConfig.kinetic_pentable
	else
		-- DebugPrint("regular  payload")
		return globalConfig.materials
	end

end

-- returns pen table for shell based on payload type 
function get_penetration_table_by_payload(payload) 
	if(payload =="HEAT") then 
		-- DebugPrint("heat payload")
		return globalConfig.HEAT_pentable
	elseif(payload=="kinetic") then
		return globalConfig.kinetic_pentable
	else
		-- DebugPrint("regular  payload")
		return globalConfig.materials
	end

end
function checkArmor(target,RHAe)
	for armour_type,modifier in pairs(globalConfig.armour_types) do 
		if(HasTag(target,armour_type)) then 
			local tagValue = GetTagValue(target,armour_type)
			if tonumber(tagValue) ~= nil then
				-- DebugPrint("found "..armour_type.." | thickness: "..tagValue)
				return tagValue * (RHAe * 0.01)
			end
		end
	end
	return 0

end

function projectileShrapnel(projectile,test,spallValue)


			local projectile_vel = 80
			local projectile_caliber = 20
			
			if(projectile.shellType.velocity) then
				projectile_vel = projectile.shellType.velocity

			end
			if(projectile.shellType.caliber) then
				projectile_caliber =projectile.shellType.caliber

			end
			local strength = math.log(projectile_vel)*math.log(projectile_caliber )	--Strength of blower
			local maxMass = 2400	--The maximum mass for a body to be affected
			local maxDist = 1	--The maximum distance for bodies to be affected
				--Get all physical and dynamic bodies in front of camera
			
			local t = test
			
			local t1 = TransformToParentPoint(t, Vec(0,  maxDist/2,0))
			local c = TransformToParentPoint(t, Vec(0, -maxDist/2, 0))
			local mi = VecAdd(c, Vec(-maxDist/2, -maxDist/2, -maxDist/2))
			local ma = VecAdd(c, Vec(maxDist/2, maxDist/2, maxDist/2))
			QueryRequire("physical dynamic")
			
			local bodies = QueryAabbBodies(mi, ma)

			--Loop through bodies and push them
			for i=1,#bodies do
				local b = bodies[i]


				--Compute body center point and distance
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(t1, bc )
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)

				--Get body mass
				local mass = GetBodyMass(b)
				
				--Check if body is should be affected
				if dist < maxDist and mass < maxMass then
					--Make sure direction is always pointing slightly upwards
					dir[2] = 0.1
					dir = VecNormalize(dir)
			
					--Compute how much velocity to add
					local massScale = 1 - math.min(mass/maxMass, 1.0)
					local distScale = 1 - math.min(dist/maxDist, 1.0)
					local add = VecScale(dir, strength * massScale * distScale)
					
					--Add velocity to body
					local vel = GetBodyVelocity(b)
					vel = VecAdd(vel, add)
					SetBodyVelocity(b, vel)
				end
			end

			pushSpalling(projectile.cannonLoc,projectile,test,spallValue)
end



----

------ SPALLING and SHRAPNAL HANDLING

function pushSpalling(spallingLoc,spallShell,test,spallValue)

	---			kinetic = 0.8,
			-- AP 		= 0.3,
			-- APHE    = 0.3,
			-- HESH 	= 2,
			-- HEI 	= 1,

	local spallFactor = 0.25
	if(spallShell.shellType.payload) then
		local spallPayload = spallShell.shellType.payload
		if(spallShell.shellType.payload =="AP") then
			spallFactor = globalConfig.spallFactor.AP
		elseif(spallShell.shellType.payload =="APHE") then
			spallFactor = globalConfig.spallFactor.APHE
		elseif(spallShell.shellType.payload =="HESH") then
			spallFactor = globalConfig.spallFactor.HESH
		elseif(spallShell.shellType.payload =="HEAT") then
			spallFactor = globalConfig.spallFactor.HESH
		elseif(spallShell.shellType.payload =="HEI" or spallShell.shellType.payload =="HE-I") then
			spallFactor = globalConfig.spallFactor.HEI
		elseif(spallShell.shellType.payload =="kinetic") then
			spallFactor = globalConfig.spallFactor.kinetic	
		end


	end
	local spall_num = spallValue*spallFactor
	spall_num = math.max(spall_num,1)*math.random(3,9)--3
--	DebugWatch("spall num ",spall_num)
	-- DebugWatch("spall_num",spall_num)
	for i=1,math.random(spall_num*.5,spall_num*1.5) do 

		local spallingSizeCoef = math.random(1,4)/10

		if(spallShell.shellType.payload == "HESH")then
			spallingSizeCoef = spallingSizeCoef * globalConfig.spallFactor.HESH
		end

		-- test.rot = QuatLookAt(spallShell.lastPos,test)
		local spallPos = TransformCopy(test)
		-- spallPos.pos = TransformToParentPoint(spallPos, 0,-16,0)

		local fwdPos = TransformToParentPoint(spallPos, Vec(math.random(-10,10),-10,math.random(-10,10)))
		local direction = VecSub( fwdPos,spallPos.pos)
		local point1 = spallPos.pos
					
		spallHandler.shells[spallHandler.shellNum] = deepcopy(spallHandler.defaultShell)

		local currentSpall 				= spallHandler.shells[spallHandler.shellNum] 
		currentSpall.active 			= true 
		currentSpall.shellType = deepcopy(spallShell.shellType) 
		currentSpall.isSpall = true
		currentSpall.cannonLoc 			= spallPos
		currentSpall.point1			= point1 
		if(spallShell.shellType.payload =="HEAT") then 
			
			currentSpall.predictedBulletVelocity = get_heat_jet(spallPos)--= VecScale(spallShell.predictedBulletVelocity,0.9)
		else
			currentSpall.predictedBulletVelocity = VecScale(spallShell.predictedBulletVelocity,0.8)
		end
		currentSpall.initial_speed = VecCopy(currentSpall.predictedBulletVelocity)
		-- currentSpall.predictedBulletVelocity = VecScale(
		-- 												VecAdd(
		-- 													VecScale(spallShell.predictedBulletVelocity,0.8),fwdPos),0.5)
		--VecScale(direction,currentSpall.shellType.velocity*.2)
		currentSpall.originPos 	  = spallPos 
		currentSpall.timeToLive	  = math.random()*(spallingSizeCoef+0.2)--(currentSpall.shellType.timeToLive *(spallingSizeCoef+0.2))*(math.random(50,100)/100)
		--DebugWatch("spall coef ttl",math.random()*(spallingSizeCoef+0.2))
		if(spallShell.shellType.payload =="HEAT") then 
			currentSpall.timeToLive	 = math.random()/3
		end

		if(spallShell.dispersion) then 
			currentSpall.dispersion 	  = 300--spallShell.dispersion*(spallShell.dispersion*10)
		elseif(spallShell.shellType.payload =="HEAT") then 
			currentSpall.dispersion = 5--70
		else
			currentSpall.dispersion 	  = 200 
		end

		-- DebugPrint("velocity: "..VecStr(currentSpall.predictedBulletVelocity).."  | pos = "..VecStr(TransformToParentPoint(spallPos, 0,-16,0)).." | "..VecStr(test.pos))
		currentSpall.shellType.bulletdamage = VecScale(currentSpall.shellType.bulletdamage,0.25)
		currentSpall.shellType.bulletdamage[1] = currentSpall.shellType.bulletdamage[1] * spallingSizeCoef
		currentSpall.shellType.bulletdamage[2] = currentSpall.shellType.bulletdamage[2] * spallingSizeCoef
		currentSpall.shellType.bulletdamage[3] = currentSpall.shellType.bulletdamage[3] * spallingSizeCoef
		currentSpall.shellType.caliber = currentSpall.shellType.caliber * spallingSizeCoef
		currentSpall.shellType.shellWidth = currentSpall.shellType.shellHeight * (spallingSizeCoef*spallingSizeCoef) 
		currentSpall.shellType.shellHeight = currentSpall.shellType.shellHeight * (spallingSizeCoef*spallingSizeCoef)
		currentSpall.penDepth = (currentSpall.shellType.maxPenDepth/2)*spallingSizeCoef
		if(globalConfig.penCheck>=currentSpall.shellType.maxPenDepth)then
			currentSpall.maxChecks  =1
		else
			currentSpall.maxChecks = currentSpall.shellType.maxPenDepth/globalConfig.penCheck
		end
		-- currentSpall.maxChecks  =2

		currentSpall.shellType.r = 1 + (math.random(0,5)/10)
		currentSpall.shellType.g = 0.7 + (math.random(0,5)/10)
		currentSpall.shellType.b = 1


		spallHandler.shellNum = (spallHandler.shellNum%#spallHandler.shells) +1
	end
	-- DebugPrint("test")

end

function get_heat_jet(spallPos)
	local weapon_jet_vel = math.random(125,200)
  	local launch_dir = TransformCopy(spallPos)
  	local z = rnd(2,6)
  	local cone = (z*.9) * math.sin(90)
    local x = rnd(-cone,cone)
    local y = rnd(-cone,cone)
    --weapon.jet_vel*.7,weapon.jet_vel*1.3)
    local jet_vel = Vec(x,-z,y)
	-- DebugWatch("jet_vel",jet_vel)

	-- DebugWatch("cone",cone)
    jet_vel  =  VecNormalize(VecSub(launch_dir.pos,TransformToParentPoint(launch_dir, jet_vel)))
    local predictedBulletVelocity = VecScale(jet_vel,rnd(weapon_jet_vel *.7,weapon_jet_vel *1.3))

    return predictedBulletVelocity

end

function popSpalling(shell,hitTarget)


		local penetration,passThrough,test,penDepth,dist,spallValue =  getProjectilePenetration(shell,hitTarget)
		-- shell.penDepth = shell.penDepth - penDepth

		local holeModifier = math.random(-15,15)/100


		-- local daamge_coef = VecLength(shell.predictedBulletVelocity)/VecLength(shell.initial_speed)
		-- DebugWatch("shell damage",shell.shellType.bulletdamage[1])
		-- DebugWatch("prior damage",shell.shellType.bulletdamage)
		-- if(VecLength(shell.initial_speed)<VecLength(shell.predictedBulletVelocity)) then 
		-- 	DebugPrint("strange occurance of more speed occured")
		-- end
	if(VecLength(shell.initial_speed))>0 and
		VecLength(shell.initial_speed)>VecLength(shell.predictedBulletVelocity) then 
	    shell.shellType.bulletdamage = VecScale(shell.shellType.bulletdamage,
	                                		VecLength(shell.predictedBulletVelocity)/
	                                		VecLength(shell.initial_speed))
	else
		shell.shellType.bulletdamage = VecScale(shell.shellType.bulletdamage,0)
	end
    -- DebugWatch("post damage",shell.shellType.bulletdamage)
	local fireChance = math.random()
	local firethreshold = globalConfig.fire_chance_thres
	if(shell.shellType.payload) then
		if(shell.shellType.payload == "incendiary") then
			firethreshold = 0.8
		elseif(shell.shellType.payload == "HESH") then
				firethreshold = 0.11 * firethreshold
		elseif(shell.shellType.payload == "HEAT") then
				firethreshold = 0.34 * firethreshold
		elseif(shell.shellType.payload == "HE-I") then
				firethreshold = 0.55 * firethreshold
		elseif(shell.shellType.payload == "kinetic") then
				firethreshold = 0.08 * firethreshold
		elseif(shell.shellType.payload == "AP") then
				firethreshold = 0.04 * firethreshold
		end
		if(fireChance<firethreshold)then
			SpawnFire(shell.point1)
		end
		
	end

	if(shell.penDepth>0) then
		if shell.shellType.hit and shell.shellType.hit <3 then
			if(shell.shellType.hit ==1)then
				MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4)
			else
				MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2)
			end
		else
			MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2, shell.shellType.bulletdamage[3]*1.2)
		end
	
	else	
		local shell_hole = deepcopy(shell.shellType.bulletdamage)
		for i = 1,3 do 
			shell_hole[i] = shell_hole[i] +shell.penDepth 
		end

		if(not penetration) then 
			holeModifier = clamp(-1,0,(-(math.random(50,150)/100))+(shell.penDepth*100))
			--DebugWatch("non pen val hole modifier",holeModifier)
			-- DebugWatch("shell pen depth",shell.penDepth*100)
		end
		-- if shell.shellType.hit and shell.shellType.hit <3 then
		-- 	if(shell.shellType.hit ==1)then
		-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4)
		-- 	else
		-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2)
		-- 	end

		-- else
		-- 	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2, shell.shellType.bulletdamage[3]*1.2)
		-- end
		if shell.shellType.hit and shell.shellType.hit <3 then
			if(shell.shellType.hit ==1)then
				MakeHole(shell.point1,
					shell_hole[1]*(1+holeModifier))
			else

				MakeHole(shell.point1,
					shell_hole[1]*(1+holeModifier),
					shell_hole[2]*(1+holeModifier))
			end

		else
			MakeHole(shell.point1,
				shell_hole[1]*(1+holeModifier),
				shell_hole[2]*(1+holeModifier), 
				shell_hole[3]*(1+holeModifier))
		end
	-- 	Explosion(shell.point1)
		shell.active = false
		for key,val in ipairs( shell ) do 
			val = nil

		end
		shell = deepcopy(spallHandler.defaultShell)
	end

end

function spallingOperations(projectile,dt )
		projectile.cannonLoc.pos = projectile.point1
		local shellHeight = projectile.shellType.shellHeight
		local shellWidth = projectile.shellType.shellWidth
		local r = projectile.shellType.r
		local g = projectile.shellType.g
		local b = projectile.shellType.b


		--- sprite drawing
		DrawSprite(projectile.shellType.Spallingsprite, projectile.cannonLoc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
		local altloc = projectile.cannonLoc
		altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
		altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)
		

		projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.9)


		---
		---

			--- PROJECTILE MOTION

		---


		---  ADDING DISPERSION
		local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
		if(projectile.shellType.dispersionCoef) then
			dispersion=VecScale(dispersion,dispersionCoef)
		end
		projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))



		-- --- applying drag 
		-- local spallDrag = VecScale(
		-- 	VecSub(
		-- 		TransformToParentPoint(
		-- 			Transform(projectile.point1,projectile.cannonLoc.rot),
		-- 			Vec(0,0,50)),projectile.point1),
		-- 		dt)
		-- projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,spallDrag)
		--- APPLYING GRAVITY
		-- if(projectile.shellType.gravityCoef) then
		-- 	local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
		-- 	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
		-- else

			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		-- end

	
		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
		QueryRequire("physical")
		local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))
		
		projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))
		

		local hit_player =  inflict_player_damage(projectile,point2)

			if(hit or hit_player)then 
				hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
				projectile.point1 = hitPos
				-- if(projectile.hit_npc ==nil  or not projectile.hit_npc) then  
				-- 	mors_longa_damage(projectile, shape1,hitPos)
				-- end
				 popSpalling(projectile,shape1)
				-- Explosion(hitPos,2)
			else
				projectile.point1 = point2
				if(projectile.hit_npc) then 
					projectile.hit_npc = false
				end
			end
		
end


function pushshrapnel(spallingLoc,spallShell,test,hitTarget)

	local spallValue = math.random(5,10)
	local spall_calibre_coef = spallShell.shellType.caliber / globalConfig.optimum_spall_shell_calibre_size 
	spall_calibre_coef  = spall_calibre_coef  * spall_calibre_coef 
	if(spallShell.shellType.explosionSize) then 
		spallValue = spallShell.shellType.explosionSize*5
	end
	local spallQuant = math.random(1,spallValue*3)
---			kinetic = 0.8,
			-- AP 		= 0.3,
			-- APHE    = 0.3,
			-- HESH 	= 2,
			-- HEI 	= 1,
	-- DebugPrint(spallValue)
	if(globalConfig.shrapnel_coefs[spallShell.shellType.payload]~= nil ) then 
		spallQuant = spallQuant * globalConfig.shrapnel_coefs[spallShell.shellType.payload] * spall_calibre_coef
	end
	for i=1, spallQuant do 

		local spallingSizeCoef = math.random(10,40)/100
		if(spallShell.shellType.payload == "HESH")then
			spallingSizeCoef = spallingSizeCoef * globalConfig.spallFactor.HESH
		end

		-- test.rot = QuatLookAt(spallShell.lastPos,test)
		local spallPos = TransformCopy(test)
		-- spallPos.pos = TransformToParentPoint(spallPos, 0,-16,0)
		
		local direction = rndVec(math.random(1,spallValue))
		local point1 = spallPos.pos
					
		spallHandler.shells[spallHandler.shellNum] = deepcopy(spallHandler.defaultShell)
		local currentSpall 				= spallHandler.shells[spallHandler.shellNum] 
		currentSpall.active 			= true 
		currentSpall.shellType = deepcopy(spallShell.shellType) 
		currentSpall.cannonLoc 			= spallPos
		currentSpall.point1			= point1 
		currentSpall.predictedBulletVelocity = rndVec(math.random() * math.random(15,35))
		if(globalConfig.shrapnel_speed_coefs[spallShell.shellType.payload]~= nil ) then 
			currentSpall.predictedBulletVelocity = VecScale(currentSpall.predictedBulletVelocity,globalConfig.shrapnel_speed_coefs[spallShell.shellType.payload]*spall_calibre_coef)
		end		

		currentSpall.initial_speed= VecCopy(currentSpall.predictedBulletVelocity)
		currentSpall.shrapnel = true
		currentSpall.hitTarget = hitTarget
		-- currentSpall.predictedBulletVelocity = VecScale(
		-- 												VecAdd(
		-- 													VecScale(spallShell.predictedBulletVelocity,0.8),fwdPos),0.5)
		--VecScale(direction,currentSpall.shellType.velocity*.2)
		currentSpall.originPos 	  = spallPos 
		currentSpall.maxTimeToLive = (currentSpall.shellType.timeToLive *(spallingSizeCoef+0.2))*(math.random(50,100)/100)
		currentSpall.timeToLive	  = currentSpall.maxTimeToLive
		if(spallShell.dispersion) then 
			currentSpall.dispersion 	  = 20 
			else
			currentSpall.dispersion 	  = 10 
		end
		-- DebugPrint("velocity: "..VecStr(currentSpall.predictedBulletVelocity).."  | pos = "..VecStr(TransformToParentPoint(spallPos, 0,-16,0)).." | "..VecStr(test.pos))
		-- currentSpall.shellType.bulletdamage = VecScale(currentSpall.shellType.bulletdamage,0.9)
		
		spall_damage_coef = math.max(math.random(),0.1)
		currentSpall.shellType.bulletdamage[1] = (currentSpall.shellType.bulletdamage[1] * spallingSizeCoef)*spall_damage_coef
		currentSpall.shellType.bulletdamage[2] = (currentSpall.shellType.bulletdamage[2] * spallingSizeCoef)*spall_damage_coef
		currentSpall.shellType.bulletdamage[3] = (currentSpall.shellType.bulletdamage[3] * spallingSizeCoef)*spall_damage_coef
		if(globalConfig.shrapnel_hard_damage_coef[spallShell.shellType.payload]~= nil ) then 
			currentSpall.shellType.bulletdamage[3] = currentSpall.shellType.bulletdamage[3] * globalConfig.shrapnel_hard_damage_coef[spallShell.shellType.payload] 
		end
		local spall_caliber_size = math.max((currentSpall.shellType.caliber * spallingSizeCoef)*0.3,0.01)
		currentSpall.shellType.caliber =  math.random()*spall_caliber_size
		currentSpall.shellType.shellWidth = math.max(math.random() * (math.random() * (currentSpall.shellType.shellWidth * spallingSizeCoef)),0.1 )
		currentSpall.shellType.shellHeight = math.max(math.random() * (currentSpall.shellType.shellWidth * spallingSizeCoef),0.1) 
		currentSpall.penDepth = ((currentSpall.shellType.maxPenDepth/2)*spallingSizeCoef)*spall_damage_coef
		if(globalConfig.shrapnel_pen_coef[spallShell.shellType.payload]~= nil ) then 
			currentSpall.penDepth = currentSpall.penDepth * globalConfig.shrapnel_pen_coef[spallShell.shellType.payload] 
		end

		if(globalConfig.penCheck>=currentSpall.shellType.maxPenDepth)then
			currentSpall.maxChecks  =1
		else
			currentSpall.maxChecks = currentSpall.shellType.maxPenDepth/globalConfig.penCheck
		end
		-- currentSpall.maxChecks  =2

		currentSpall.shellType.r = math.max((2 + (math.random(0,5)/10)) *spall_damage_coef,0.3)
		currentSpall.shellType.g = math.max((1.7 + (math.random(0,5)/10))*spall_damage_coef,0.3)
		currentSpall.shellType.b = math.max((1 + (math.random(0,10)/10)) *spall_damage_coef,0.3)


		spallHandler.shellNum = (spallHandler.shellNum%#spallHandler.shells) +1

	end
	-- DebugPrint("test")

end


function shrapnelOperations(projectile,dt )
		projectile.cannonLoc.pos = projectile.point1
		local shellHeight = projectile.shellType.shellHeight
		local shellWidth = projectile.shellType.shellWidth
		-- local spallDecay =  math.random()* (currentSpall.maxTimeToLive / currentSpall.timeToLive	)
		local spallDecay = math.random()
		local r = projectile.shellType.r * spallDecay
		local g = projectile.shellType.g * spallDecay
		local b = projectile.shellType.b * spallDecay


		--- sprite drawing
		DrawSprite(projectile.shellType.Spallingsprite, projectile.cannonLoc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
		local altloc = projectile.cannonLoc
		altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
		altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)
		


		---
		---

			--- PROJECTILE MOTION

		---


		---  ADDING DISPERSION

		projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.98)

		local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
		if(projectile.shellType.dispersionCoef) then
			dispersion=VecScale(dispersion,dispersionCoef)
		end
		projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))



		-- --- applying drag 
		-- local spallDrag = VecScale(
		-- 	VecSub(
		-- 		TransformToParentPoint(
		-- 			Transform(projectile.point1,projectile.cannonLoc.rot),
		-- 			Vec(0,0,50)),projectile.point1),
		-- 		dt)
		-- projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,spallDrag)
		--- APPLYING GRAVITY
		-- if(projectile.shellType.gravityCoef) then
		-- 	local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
		-- 	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
		-- else

			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		-- end

	
		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
		QueryRequire("physical")
		local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))
		
		projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))
		
			if(hit)then 
				hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
				projectile.point1 = hitPos
				if(projectile.hit_npc ==nil  or not projectile.hit_npc) then  
					mors_longa_damage(projectile, shape1,hitPos)
				end
				 popSpalling(projectile,shape1)
				-- Explosion(hitPos,2)
			else

				projectile.point1 = point2
				if(projectile.hit_npc) then 
					projectile.hit_npc = false
				end
			end
		
end

function spallingTick(dt)
		if unexpected_condition then error() end
			local activeShells = 0
			for key,shell in ipairs( spallHandler.shells  )do
			 	if(shell.active)then
			 		if(shell.timeToLive > 0) then 
			 			if(shell.shrapnel) then 
			 				shrapnelOperations(shell,dt)
			 				
			 			else
				 			spallingOperations(shell,dt)
				 		end
			 			shell.timeToLive = shell.timeToLive - dt
			 		else
			 			shell.active = false
			 		end
			 	end
		end
end


-----



----

----- SHELL HANDLING

----


function pushShell(gun,t_hitPos,dist,t_distance,t_cannon,t_penDepth)
	-- utils.printStr("pushing shell")
	if(dist <=0)then
		dist = maxDist
	end

	artilleryHandler.shells[getShellNum()].active = true
	artilleryHandler.shells[getShellNum()].hitPos = t_hitPos
	artilleryHandler.shells[getShellNum()].timeToTarget = dist*shellSpeed
	artilleryHandler.shells[getShellNum()].shellType = gun.magazines[gun.loadedMagazine].CfgAmmo

	if(t_cannon) then
		
		artilleryHandler.shells[getShellNum()].distance = t_distance
		artilleryHandler.shells[getShellNum()].t_cannon = t_cannon
		if(not t_penDepth ) then
				artilleryHandler.shells[getShellNum()].penDepth = gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth
				if(globalConfig.penCheck>=gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth)then
					artilleryHandler.shells[getShellNum()].maxChecks  =1
				else
					artilleryHandler.shells[getShellNum()].maxChecks = gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth/globalConfig.penCheck
				end
				-- utils.printStr("1")
		end
		-- SetString("hud.notification",artilleryHandler.shells[getShellNum()].penetrations.."\n"..artilleryHandler.shells[getShellNum()].timeToTarget)
	-- utils.printStr("3")
	end

	if (t_penDepth) then
				
				artilleryHandler.shells[getShellNum()].penDepth = t_penDepth
				-- artilleryHandler.shells[getShellNum()].shellType.explosionSize =1.5

				-- utils.printStr(gun.explosionSize.." | "..t_penDepth.." | "..dist)
	end
	-- else
		artilleryHandler.shells[getShellNum()].explosionSize = artilleryHandler.shells[getShellNum()].shellType.explosionSize
	-- end

	incrementShellNum()
	-- utils.printStr(4)
end

function pushShell2(shell,t_hitPos,dist,t_distance,t_cannon)
	-- utils.printStr("pushing shell")
	if(dist <=0)then
		dist = maxDist
	end

	artilleryHandler.shells[getShellNum()].active = true
	artilleryHandler.shells[getShellNum()].hitPos = t_hitPos
	artilleryHandler.shells[getShellNum()].timeToTarget = dist*shellSpeed
	artilleryHandler.shells[getShellNum()].shellType = shell.shellType

	if(t_cannon) then
		
		artilleryHandler.shells[getShellNum()].distance = t_distance
		artilleryHandler.shells[getShellNum()].t_cannon = t_cannon
				artilleryHandler.shells[getShellNum()].penDepth = shell.penDepth

				artilleryHandler.shells[getShellNum()].maxChecks = shell.maxChecks
				artilleryHandler.shells[getShellNum()].explosionSize = artilleryHandler.shells[getShellNum()].shellType.explosionSize
				-- utils.printStr("1")
		-- SetString("hud.notification",artilleryHandler.shells[getShellNum()].penetrations.."\n"..artilleryHandler.shells[getShellNum()].timeToTarget)
	-- utils.printStr("3")
	end

	incrementShellNum()
	-- utils.printStr(4)
end

function popShell(shell)
	-- utils.printStr(1)
	if(shell.penDepth) then
		-- utils.printStr(2)
		-- utils.printStr(shell.penDepth)
		local penetration,passThrough,test,penDepth,dist =  getPenetration(shell) 
		-- utils.printStr(3)
		shell.penDepth = shell.penDepth - penDepth
		-- and shell.penetrations>0)
		-- utils.printStr(dist)
		if( passThrough and shell.penDepth>0) then
					
				if(shell.hitPos ~= nil)then
					-- utils.printStr(type(shell.hitPos))
					-- utils.printStr(utils.explodeTable(shell.hitPos).." "..shell.hitPos[1])
					-- utils.printLoc(shell.hitPos)

					Explosion(shell.hitPos,0.5)

					shellPenetration(shell,test,dist)
					-- utils.printStr(shell.penDepth)
					
				else
					utils.printStr("no shell hitPos")
				end


		else

			Explosion(test.pos,shell.explosionSize)
			-- utils.printStr("penetration  explosion")
		-- shellPenetration(shell)
		-- shell = deepcopy(artilleryHandler.defaultShell)
		end
	else
		-- utils.printStr("normal explosion")
		Explosion(shell.hitPos,shell.explosionSize)
	end
	shell.active = false
	shell = deepcopy(artilleryHandler.defaultShell)
end

function getShellNum()
	return artilleryHandler.shellNum
	
end

function incrementShellNum()
	artilleryHandler.shellNum = ((artilleryHandler.shellNum+1) % #artilleryHandler.shells)+1
end




function kill_shell(shell)

	shell.active = false
	for key,val in ipairs( shell ) do 
		val = nil

	end
	shell = deepcopy(projectileHandler.defaultShell)

		end


function artilleryTick(dt)
	local activeShells = 0
		for key,shell in ipairs( artilleryHandler.shells  )do
			 if(shell.active==true)then
			 	if(type(shell.hitPos)~= "table")then
			 		shell.active = false
			 	else
				 	activeShells= activeShells+1
				 	if shell.timeToTarget <0 then
				 		popShell(shell)
				 	else
				 		shell.timeToTarget = shell.timeToTarget-dt
				 	end
			 	end
			 end
		end
	-- utils.printStr(activeShells)
end





 -- check left right, if number then explode, if 0 then fly on.
function getPenetration(shell)
	local cannonLoc = shell.t_cannon
	local penetration = false
	local passThrough = true  
	local test= cannonLoc	
	local outstring =""
	local penDepth =0
	local dist1 = 0
	local hit1=false
	local penDepth = 0
	for i =1,shell.maxChecks do 
		local fwdPos = TransformToParentPoint(test, Vec(0, globalConfig.penCheck * -1,0))
	    local direction = VecSub(fwdPos, test.pos)
	     -- printloc(direction)
	    direction = VecNormalize(direction)
	    QueryRequire("physical")
    	hit1, dist1 = QueryRaycast(test.pos, direction, maxDist)
	    	local tstStrn = ""
	    	-- if(dist1 == 0 and hit1) then
	    	-- 	tstStrn = ("penetrated")
	    	-- elseif (dist1 == 0 ) then
	    	-- 	tstStrn = ("passThrough")
	    	-- else
	    	-- 	tstStrn = ("penetrated + possible next penetration")
	    	-- end
	    	outstring= outstring.."check: "..i.." : "..dist1.." "..tstStrn.."\n"--.."\n1: "..dist2.."\n1.5: "..dist3)	
	    	-- utils.printStr("2_3_5 "..outstring)
		
		if(dist1>0)then
			penDepth = globalConfig.penCheck*i
			penetration=true
			break
		end
		test = rectifyPenetrationVal(test)
	end
	-- utils.printStr("2_4")
	-- utils.printStr(outstring)
	if(dist1 ==0) then

		passThrough = not hit1

		-- passThrough,checks = didPassThrough(cannonLoc)
		-- checks=""
		-- if(not passThrough) then
		-- 	printStr("hitWall, stuck in object\nPrimaryChecks:\n"..outstring.."\nReversechecks:\n"..checks.."\nDidn't pass Through")
		-- else
		-- 	printStr("PrimaryChecks:\n"..outstring.."\nReversechecks:\n"..checks.."\nPassed Through")
		-- end
	end
	return penetration,passThrough,test,penDepth,dist1
end

function shellPenetration(shell,cannonLoc,dist)

	if(dist == 0) then
		dist = maxDist
	end

		hitPos = TransformToParentPoint(cannonLoc, Vec(0, dist * -1,0))

      	p = cannonLoc.pos

		d = VecNormalize(VecSub(hitPos, p))
		spread = 0.03
		d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d = VecNormalize(d)
		p = VecAdd(p, VecScale(d, 0.1))
		
			if (dist<maxDist) then
				cannonLoc.pos = hitPos
				pushShell2(shell,hitPos,dist,(maxDist-dist),cannonLoc)
				-- pushShell(shell,hitPos,dist,(maxDist-dist),cannonLoc,shell.penDepth)
				--pushShell(gun,t_hitPos,dist,t_distance,t_cannon,t_penDepth)
			end
		-- utils.printStr("test")
		Shoot(p, d,0)
	

	-- body
end

function rectifyPenetrationVal(t_cannonLoc)
		-- utils.printStr("fixingpen")
	local y = 0
	local x = 0 
	local z = globalConfig.penCheck


	local fwdPos = TransformToParentPoint(t_cannonLoc, Vec(x, z,y))

	local direction = VecSub(fwdPos, t_cannonLoc.pos)

	t_cannonLoc.pos = VecAdd(t_cannonLoc.pos, direction)
	return t_cannonLoc
end

function rectifyBarrelCoords(gun)
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
	local y = barrel.y
	local x = barrel.x 
	local z = barrel.z
	if(debugging_traversal) then 
		DebugWatch("x,y,z",x..","..y..","..z)
	end
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(x, z,y))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	cannonLoc.pos = VecAdd(cannonLoc.pos, direction)
	return cannonLoc
end



function retrieve_first_barrel_coord(gun)
	local barrel = nil

	barrel = gun.barrels[1]
	-- utils.printStr	(gun.multiBarrel)--.." | "..#gun.barrels	)
	local cannonLoc = GetShapeWorldTransform(gun.id)
	local y = barrel.y
	local x = barrel.x 
	local z = barrel.z
	if(debugging_traversal) then 
		DebugWatch("x,y,z",x..","..y..","..z)
	end
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(x, z,y))
	-- if(HasTag(gun.id "avf_barrel_coords_true")) then 
	-- 	 fwdPos = TransformToParentPoint(cannonLoc, Vec(x, z,y))
	-- end	
	local direction = VecSub(fwdPos, cannonLoc.pos)
	cannonLoc.pos = VecAdd(cannonLoc.pos, direction)
	return cannonLoc
end



function getBarrelCoords(gun)
	local barrel = nil
	if(gun.multiBarrel)then
		-- gun.multiBarrel, barrel = next(gun.barrels,gun.multiBarrel)
		barrel = gun.barrels[gun.multiBarrel]
	else 
		barrel = gun.barrels[1]
	end
	-- utils.printStr	(gun.multiBarrel)--.." | "..#gun.barrels	)
	local cannonLoc = GetShapeWorldTransform(gun.id)
	local y = barrel.y
	local x = barrel.x 
	local z = barrel.z
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(x, z,y))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	cannonLoc.pos = VecAdd(cannonLoc.pos, direction)
	return cannonLoc
end



function turretRotatation(turret,turretJoint,aim_gun,gun)
	if unexpected_condition then error() end
	if(turret)then 
		if( turret.locked) then
			local targetRotation = lockedTurretAngle(turret)
				SetJointMotor(turretJoint, targetRotation)
		else

			-- local turretTransform = GetShapeWorldTransform(turret.id)
			-- if(aim_gun~=nil) then 
			-- 	turretTransform.pos = aim_gun.pos
			-- end		
			-- if(gun ~= nil and HasTag(gun.id,"flip_angles")) then
			-- -- DebugWatch("rotating the angles",turretTransform) 
			-- 	turretTransform.rot = QuatRotateQuat(turretTransform.rot,QuatEuler(270, 90, 0))
			-- end
			-- --red = x axis
			-- draw_line_from_transform(turretTransform,-.1,0,0,	1,0,0)
			
			-- -- green = z axis
			-- draw_line_from_transform(turretTransform,0,0,-0.1,	0,1,0)

			-- -- blue = y axis 
			-- draw_line_from_transform(turretTransform,0,-.1,0,	0,0,1)

			local turret = turret.id
			local forward = turretAngle(0,1,0,turret,aim_gun,gun)
			local back 	  = turretAngle(0,-1,0,turret,aim_gun,gun) 
			local left 	  = turretAngle(-1,0,0,turret,aim_gun,gun)
			local right   = turretAngle(1,0,0,turret,aim_gun,gun)
			local up 	  = turretAngle(0,0,1,turret,aim_gun,gun)
			local down 	  = turretAngle(0,0,-1,turret,aim_gun,gun)

			-- DebugWatch("red = right",right)
			-- DebugWatch("green = down",down)
			-- DebugWatch("blue = forward",forward)

			-- SetString("hud.notification",
			-- 	"forward: "..
			-- 	forward..
			-- 	"\nback: "..
			-- 	back..
			-- 	"\nleft: "..
			-- 	left..
			-- 	"\nright: "..
			-- 	right..
			-- 	"\nup: "..
			-- 	up..
			-- 	"\ndown: "..
			-- 	down)

			-- DebugWatch("turret angle target",left-right)
			local target_move = left-right
			local bias = 0
			local min_move = 0.1
			if(forward<(1-bias)) then
				if(math.abs(target_move)>bias) then
					SetJointMotor(turretJoint, clamp(-1,1,(min_move*math.sign(target_move))+1.5*(target_move)))
				-- 
				-- if(left>right+bias) then
				-- 	SetJointMotor(turretJoint, clamp(0,1,1.5*(left-right)))
				-- elseif(right>left+bias) then
				-- 	SetJointMotor(turretJoint, clamp(-1,0,-1.5*(right-left)))
				else
					SetJointMotor(turretJoint, 0)
				end
			else
				SetJointMotor(turretJoint, 0)
			end

		end
	end
end

function turretAngle(x,y,z,turret,aim_gun,gun)

	local turretTransform = GetShapeWorldTransform(turret)
	if(aim_gun~=nil) then 
		turretTransform.pos = aim_gun.pos
	end
	if(gun ~= nil and 
		(HasTag(gun.id,"turret_flip_angle_x") or 
			HasTag(gun.id,"turret_flip_angle_y") or 
			HasTag(gun.id,"turret_flip_angle_z"))) then
		local x_tag = tonumber(GetTagValue(gun.id,"turret_flip_angle_x"))
		local y_tag = tonumber(GetTagValue(gun.id,"turret_flip_angle_y"))
		local z_tag = tonumber(GetTagValue(gun.id,"turret_flip_angle_z"))
		local x_rot = (x_tag~=nil and x_tag) or 0
		local y_rot = (y_tag~=nil and y_tag) or 0
		local z_rot = (z_tag~=nil and z_tag) or 0 
		-- DebugWatch("x_rot",x_rot)
		-- DebugWatch("y_rot",y_rot)
		-- DebugWatch("z_rot",z_rot)
		turretTransform.rot = QuatRotateQuat(turretTransform.rot,QuatEuler(x_rot,y_rot, z_rot))
	end
	if(gun~= nil and HasTag(gun.id,"turret_show_angles")) then 
		debug_draw_x_y_z(turretTransform)
	end
	local fwdPos = TransformToParentPoint(GetCameraTransform(), Vec(0, 0, 1000))
	local toPlayer = VecNormalize(VecSub(fwdPos, turretTransform.pos))
	local forward = TransformToParentVec(turretTransform, Vec(x,  y, z))
	local orientationFactor = clamp(VecDot(forward, toPlayer) * 0.7 + 0.3, 0.0, 1.0)
	return orientationFactor
end
function gunAngle(x,y,z,gun,gunJoint)

	local targetAngle, dist = getTargetAngle(gun)

	

	-- targetAngle = targetAngle*verted
    -- SetString("hud.notification","target Angle: "..targetAngle.."\nDist: "..dist.."\nJoint at: "..GetJointMovement(gunJoint).."\n min"..gun.elevationMin.." max:"..gun.elevationMax)
    local bias = 0
    if(-GetJointMovement(gunJoint) < (targetAngle-bias)) then
			SetJointMotor(gunJoint, 1*bias)
	elseif(-GetJointMovement(gunJoint) > (targetAngle+bias)) then
			SetJointMotor(gunJoint, -1*bias)
	else
		SetJointMotor(gunJoint	, 0)
	end 

end


function autoGunAim(gun,barrelCoords)
	local turretPos = GetShapeWorldTransform(gun.id).pos -- cheej
	-- turretPos[2] = turretPos[3]
	local targetPos = GetCameraTransform().pos
	local dir = VecSub(targetPos,turretPos)
	dir = VecNormalize(dir)
	local tilt = VecAdd(turretPos,dir)
	local heightDiff = tilt[2] - turretPos[2]
	heightDiff = 0.3 - heightDiff
	heightDiff = math.max(-0.25,heightDiff)
	-- targetPos[2] = 0
	-- turretPos[2] = 0
	if(reticleWorldPos) then 
		targetPos = reticleWorldPos
	end
	shootDir = VecSub(turretPos,targetPos)
	shootDir = VecNormalize(shootDir)
	-- shootDir[2] = heightDiff
	shootDir = VecNormalize(shootDir)

	local lookDir =  VecAdd(turretPos,VecScale(shootDir,100))
	local nt = Transform()
	-- if(reticleWorldPos)then 
	-- 	DebugWatch("reticle world",reticleWorldPos)
		
	-- else
	-- 	DebugWatch("lookdir",lookDir)
	-- end

	-- DebugLine(turretPos,lookDir,0,0,1,1)
	nt.rot = QuatLookAt(turretPos, lookDir) -- cheej
	nt.pos = VecCopy(turretPos)
	nt = TransformToParentPoint(nt,Vec(0,0,-50))
	gunLaying(gun,barrelCoords,nt)
end

function gunLaying(gun,barrelCoords,targetPos)
	-- DebugWatch("targetPos",targetPos)
	local up = gunAngle(0,0,-1,gun,targetPos)
	local down = gunAngle(0,0,1	,gun,targetPos)
	local bias = 0.05
	gun.aimed = false

	-- DebugWatch("gun up: ",
	-- 		up)
	-- DebugWatch("gun down: ",
	-- 		down)

	local dir = 0
	if(up < down-bias*0.25)then  -- and up-bias*.5>0) then 
		dir = 1
	elseif(up > down+bias*0.25 )then  --and down-bias*.5>0) then
		dir = -1

	end 
	-- DebugWatch("dir",dir)
	SetJointMotor(gun.gunJoint, dir*(bias*10))
end

function gunAngle(x,y,z,gun,targetPos)

	 	-- DebugWatch("avf ai turret test ",1)
	local gunTransform = GetShapeWorldTransform(gun.id)
	 
	local fwdPos = targetPos

	if(gun ~= nil and 
		(HasTag(gun.id,"flip_angle_x") or 
			HasTag(gun.id,"flip_angle_y") or 
			HasTag(gun.id,"flip_angle_z"))) then
		local x_tag = tonumber(GetTagValue(gun.id,"flip_angle_x"))
		local y_tag = tonumber(GetTagValue(gun.id,"flip_angle_y"))
		local z_tag = tonumber(GetTagValue(gun.id,"flip_angle_z"))
		local x_rot = (x_tag~=nil and x_tag) or 0
		local y_rot = (y_tag~=nil and y_tag) or 0
		local z_rot = (z_tag~=nil and z_tag) or 0 
		-- DebugWatch("x_rot",x_rot)
		-- DebugWatch("y_rot",y_rot)
		-- DebugWatch("z_rot",z_rot)
		gunTransform.rot = QuatRotateQuat(gunTransform.rot,QuatEuler(x_rot,y_rot, z_rot))
	end

    if(HasTag(gun.id,"show_angles")) then 
    	debug_draw_x_y_z(gunTransform)
    end
	-- DebugWatch("target",targetPos)

	-- DebugWatch("gunTransform.pos",gunTransform.pos)	
	---fwdPos = {fwdPos[1],fwdPos[3],fwdPos[2]}
	local toPlayer = VecNormalize(VecSub(gunTransform.pos,fwdPos))
	local forward = TransformToParentVec(gunTransform, Vec(x,  y, z))
	local orientationFactor = clamp(VecDot(forward, toPlayer) * 0.7 + 0.3, 0.0, 1.0)
	-- DebugLine(gunTransform.pos,fwdPos,1,0,0,1)

	return orientationFactor
end

function lockGun(gun)
	gun.lockedAngle =  GetJointMovement(gun.gunJoint)
end
function lockTurret(turret)
	turret.lockedAngle =  GetJointMovement(turret.turretJoint)
end

function lockedTurretAngle(turret)
	

	-- targetAngle = targetAngle*verted
    -- SetString("hud.notification","target Angle: "..targetAngle.."\nDist: "..dist.."\nJoint at: "..GetJointMovement(gunJoint).."\n min"..gun.elevationMin.." max:"..gun.elevationMax)
    local turretMovement = 0
    if(GetJointMovement(turret.turretJoint) > turret.lockedAngle) then
			turretMovement = 1
	elseif(GetJointMovement(turret.turretJoint) < turret.lockedAngle) then
			turretMovement = -1
	end 
	return turretMovement

end


function lockedGunAngle(gun)
	

	-- targetAngle = targetAngle*verted
    -- SetString("hud.notification","target Angle: "..targetAngle.."\nDist: "..dist.."\nJoint at: "..GetJointMovement(gunJoint).."\n min"..gun.elevationMin.." max:"..gun.elevationMax)
    local gunMovement = 0
    if(GetJointMovement(gun.gunJoint) > gun.lockedAngle) then
			gunMovement = 1
	elseif(GetJointMovement(gun.gunJoint) < gun.lockedAngle) then
			gunMovement = -1
	end 
	return gunMovement

end



function getTargetAngle(gun )
	 	local gunTransform =	GetShapeWorldTransform(GetJointOtherShape(gun.gunJoint,gun.id))
		gunTransform.pos = AabbGetShapeCenterPos(GetJointOtherShape(gun.gunJoint,gun.id))
		  -- GetCameraTransform()
		 -- gunTransform.pos[2] = 20- gunTransform.pos[2]
		-- gunTransform =  GetShapeWorldTransform(vehicle.turret)
		-- gunTransform.pos[2] = gunTransform.pos[2] 
		-- gunTransform.rot = camTransform.rot
		local verted	 = -1.2
		local fwdPos = TransformToParentPoint(gunTransform, Vec(0,maxDist *-1 ,0))
	    local direction = VecSub(fwdPos, gunTransform.pos)



	     -- printloc(direction)
	    direction = VecNormalize(direction)
    	QueryRejectBody(vehicle.body)
	-- QueryRejectBody(gun.id)
		QueryRequire("physical")
	    local hit, dist = QueryRaycast(gunTransform.pos, direction, maxDist)

		-- outerReticleScreenPos = 
		-- TransformToParentPoint(gunTransform, )



	    if(dist == 0)then
	    	dist = maxDist
	    end
    	targetAngle =  (dist*gun.rangeCalc)
    	if(gun.gunBias)then 
    		targetAngle = targetAngle+gun.gunBias
    	end
		-- targetAngle	=targetAngle	-5
		return targetAngle,dist
end


--Return a random vector of desired length
function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end


function rnd(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end


--[[



		PLAYER BEHAVIOURS 




]]

function inflict_player_damage(projectile,point2)
  local t= Transform(projectile.point1,QuatLookAt(projectile.point1,point2))
  local p = TransformToParentPoint(t, Vec(0, 0, -1))
  local p2 = TransformToParentPoint(t, Vec(0, 0, -2))
  p = VecCopy(t.pos)
  local d = VecNormalize(VecSub(point2,projectile.point1))

  hurt_dist = VecLength(VecSub(projectile.point1,point2))
  --Hurt player
  local player_cam_pos = GetPlayerCameraTransform().pos
  local player_pos = GetPlayerTransform().pos

  player_pos = VecLerp(player_pos,player_cam_pos,0.8)
  local toPlayer = VecSub(player_pos, t.pos)
  local distToPlayer = VecLength(toPlayer)
  local distScale = clamp(1.0 - distToPlayer / hurt_dist, 0.0, 1.0)
  -- DebugWatch("test",distScale)
  if distScale > 0 then
    -- DebugWatch("dist scale",distScale)
    toPlayer = VecNormalize(toPlayer)
    -- DebugWatch("dot to player",VecDot(d, toPlayer))
      -- DebugWatch("distToPlayer",distToPlayer)
    if VecDot(d, toPlayer) > 0.95  then
      -- DebugWatch("player dist scale",distScale)
      -- DebugWatch("distToPlayer",distToPlayer)
      local hit,hit_dist = QueryRaycast(p, toPlayer, distToPlayer)
      if not hit then



				if(debug_player_damage) then 
					DebugWatch("hit?",hit)
	      			DebugWatch("dist?",distToPlayer)
	      			DebugWatch("Vec dot",VecDot(d, toPlayer))
					debugStuff.redCrosses[#debugStuff.redCrosses+1] = p

					debugStuff.redCrosses[#debugStuff.redCrosses+1] =VecAdd(p,VecScale(toPlayer,distToPlayer)) 
				end
      			distScale = VecDot(d, toPlayer)
				-- DebugWatch("player would be hit",distToPlayer)
				-- DebugWatch("hit? ",VecDot(d, toPlayer))
				SetPlayerHealth(GetPlayerHealth() - 0.035 * projectile.shellType.bulletdamage[1] * (distScale*2)*projectile.shellType.caliber)
				return true, player_pos
			end
		end	
	end
	return false
end

function getPlayerShootInput()
	if InputPressed(armedVehicleControls.fire) or InputDown(armedVehicleControls.fire) then
	 
		return true,false,InputDown(armedVehicleControls.fire)
	elseif(InputReleased(armedVehicleControls.fire)) then
		
		return false,true 
	else
		return false
	end
	
end



function getPlayerInteactInput()
	if InputPressed("interact") or InputDown("interact") then
	 
		return true
	elseif(InputReleased("interact")) then
		
		return false,true 
	else
		return false
	end
	
end

function getPlayerGrabInput()
	if InputPressed("rmb") or InputDown("rmb") then
	 
		return true
	elseif(InputReleased("rmb")) then
		
		return false,true 
	else
		return false
	end
	
end

function getPlayerMouseDown()

	-- DebugWatch("mouse pressed",InputPressed(armedVehicleControls.fire))
 -- 	DebugWatch("Mouse down ",InputDown(armedVehicleControls.fire)) 


	if not InputPressed(armedVehicleControls.fire) and InputDown(armedVehicleControls.fire) then
		return true

	else
		return false
	end
end

function getInteractMouseDown()
	if not InputPressed("interact") and InputDown("interact") then
		return true

	else
		return false
	end
end

function input_active(inputKey) 
	if not InputPressed(inputKey) and InputDown(inputKey) then
		return true

	else
		return false
	end
end


--[[


	AMMO REFILL

]]


function ammoRefillTick(dt)
	
	local inVehicle,index = playerInVehicle()
	if(inVehicle) then
		for key,stockpile in pairs(ammoContainers.crates) do
			-- utils.printStr("vehicle not in region")
			if(IsVehicleInTrigger(stockpile,vehicles[index].vehicle.id))then
				ammoContainers.refillTimer = ammoContainers.refillTimer +dt
				if(ammoContainers.refillTimer>2) then
					local reloaded = refillAmmo(dt)
					if(reloaded > 0) then 
						PlaySound(ammoRefillSound, GetVehicleTransform(vehicle.id).pos, 5)
					end
					ammoContainers.refillTimer = 0
				end
			end

		end
	end
end


function refillAmmo(dt)
	local reloaded = 0
	local count = 0
	local teststr = ""
	for key,gunGroup in pairs(vehicleFeatures.weapons) do
		for key2,gun in ipairs(gunGroup) do
			for magazine,loadedMagazine in pairs(gun.magazines) do 
				count = count +1
				local currentMagazine =loadedMagazine.magazinesAmmo[loadedMagazine.currentMagazine]
				if(currentMagazine.expendedMagazines>0) then
					reloaded = reloaded +1
					currentMagazine.expendedMagazines = currentMagazine.expendedMagazines-1 
					if(loadedMagazine.outOfAmmo) then
						loadedMagazine.ammoCount = loadedMagazine.magazineCapacity
						loadedMagazine.outOfAmmo = false		
					end
				end
			end

		end
	end
	return reloaded
	-- utils.printStr("total mags: "..count.."\nReloaded: "..reloaded)
end

function handleInputs(dt)
	if unexpected_condition then error() end
	if(InputPressed(armedVehicleControls.deploySmoke))then
		for i=1,#vehicleFeatures.utility.smoke do
			if(not vehicleFeatures.utility.smoke[i].reloading) then
				smokeProjection(vehicleFeatures.utility.smoke[i])
			end
		end
	end 
	if(InputPressed(armedVehicleControls.changeWeapons))then 
		local tstStrn=""

		vehicleFeatures.currentGroup = (vehicleFeatures.currentGroup%#vehicleFeatures.validGroups)+1
		vehicleFeatures.equippedGroup = vehicleFeatures.validGroups[vehicleFeatures.currentGroup]
		-- utils.printStr(#vehicleFeatures.weapons.secondary.."\ntest string ="..tstStrn)
		-- utils.printStr(vehicleFeatures.equippedGroup.." equipped!")--.."\n"..tstStrn.." | "..vehicleFeatures.currentGroup..vehicleFeatures.validGroups[vehicleFeatures.currentGroup])
	end
	if(InputPressed(armedVehicleControls.changeAmmunition))then 
		for key2,gun in ipairs(vehicleFeatures.weapons[vehicleFeatures.equippedGroup]) do

				gun.loadedMagazine =  ((gun.loadedMagazine)%#gun.magazines)+1
				-- utils.printStr(gun.magazines[gun.loadedMagazine].name.." equipped!")
			end
		
	end
	if(InputPressed(armedVehicleControls.lockRotation))then 
		for key,turretGroup in pairs(vehicleFeatures.turrets) do
			for key2,turret in ipairs(turretGroup) do
				if(turret.locked) then
					utils.printStr("UNLOCKING TURRET")
					turret.locked = nil
				else
					utils.printStr("LOCKING TURRET")
					turret.locked = true
					lockTurret(turret)
				end

				
			end
		end 	
	end

	if InputPressed(armedVehicleControls.lockAngle) then
		local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
		for key2,gun in ipairs(gunGroup) do
			if(not IsJointBroken(gun.gunJoint))then	
				if(gun.locked) then
					utils.printStr("UNLOCKING GUN")
					gun.locked = nil
				else
					utils.printStr("LOCKING GUN")
					gun.locked = true
					lockGun(gun)
				end
			end
		end
	end

	if((InputPressed(armedVehicleControls.sniperMode))) then
		-- DebugPrint("changing sniper mode")
		vehicle.sniperMode = not vehicle.sniperMode
		vehicle.last_cam_pos = nil

		vehicle.last_mouse_shift = {0,0}
	end


	handleLightOperation()

		-- local k,v = next(vehicleFeatures.weapons,nil)
		-- utils.printStr(k)
end

function get_mouse_movement(t_modifier)
	modifier = 150 * t_modifier
	return InputValue("camerax") * modifier , InputValue("cameray") * modifier 
end


function playerInVehicle()

	local inVehicle = false
	local currentVehicle = 0
	local playerVehicle = GetPlayerVehicle()
	
	for key,vehicle in pairs(vehicles) do
		-- utils.printStr(vehicles[key].vehicleFeatures.weapons.primary[1].name)
		-- utils.printStr(vehicle.vehicle.id.." | "..playerVehicle) 
		if(vehicle.vehicle.id == playerVehicle) then 

			
			currentVehicle = key
			inVehicle = true
		end
	end
	return inVehicle,currentVehicle 
end

--Return a random vector of desired length
function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

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




UpdateQuickloadPatch() 