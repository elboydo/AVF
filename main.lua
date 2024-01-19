
--[[]
#include "umf/umf_core.lua"
#include "AVF_VERSION.lua"

#include "common.lua"
#include "ammo.lua"
#include "weapons.lua"
#include "vehicle_setup.lua"
#include "AVF_UI.lua"
#include "commander/team_allocater.lua"
#include "commander/AVF_TAK.lua"
#include kinetic_effects.lua

#include "audio_effects.lua"
#include "visual_effects.lua"

#include "AIComponent.lua"


#include "explosionController.lua"


#include "guidance.lua"

#include "controls.lua"



#include databus.lua

#include debug_menu.lua

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

DEBUG_CODE = false

debugging_traversal =false

debug_combat_stuff = false

debug_weapon_pos = false


debug_special_armour = false

debug_shell_casings = false


debug_player_damage = false


debug_vehicle_locations_active = false

AVF_DEV_HUD_VISIBLE = false

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
	rpm_to_rad = 0.1047,
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


ai_scan_timestep = 0.3

last_ai_scan = 0


MISSILE_TRACK_TIME_MIN =1.3

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
				if(DEBUG_CODE) then 
					local status,retVal = pcall(initVehicle,vehicles[index])
					if status then 
							-- utils.printStr("no errors")
					else
						errorMessages = errorMessages..retVal.."\n"
					end
				else
					initVehicle(vehicles[index])
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



	team_allocator_init()
	AVF_TAK_INIT()

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
							if(DEBUG_CODE) then 
								local status,retVal = pcall(addGun,test[j], vehicle.shapes[i])
								if status then 
								-- utils.printStr("no errors")
								else
									errorMessages = errorMessages..retVal.."\n"
								end
							else
								addGun(test[j],vehicle.shapes[i])
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
	local group_name = ""
	for i =1,#vehicleFeatures.validGroups do 
		group_name = vehicleFeatures.validGroups[i]
		SetTag(vehicleFeatures.weapons[group_name][1].id,"avf_primary_weapon_group_"..i) 

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

	SetTag(vehicle.id,"avf_initialized")


	-- utils.printStr(tstStrn)
end


function initAI()

	if(HasTag(vehicle.id,"avf_ai")) then
		AVF_ai:initAi()
		-- DebugPrint("Vehicle: "..vehicle.id.." is ai ready")
	end
end

function tick(dt)


	-- Button will be placed in the bottom bar of the pause menu
	if PauseMenuButton("AVF Settings") then
		AVF_DEV_HUD_VISIBLE = not AVF_DEV_HUD_VISIBLE
	end
	if(AVF_DEV_HUD_VISIBLE) then 
		SetTimeScale(0.01)
	end

	frameErrorMessages = ""

	-- local player_pos = GetPlayerCameraTransform().pos
	-- local hit,d,n= QueryRaycast(player_pos, Vec(0,-1,0),10)
	-- DebugWatch("player height ",d)
	-- if(AVF_Vehicle_Used and (InputPressed("esc") or InputDown("esc") or InputReleased("esc"))) then
	-- 	SetInt("options.gfx.fov",originalFov)
	-- end

	
	

	if(DEBUG_CODE) then 
		-- local status,retVal = pcall(guidance_tick,dt)
		-- if status then 
		-- 	-- utils.printStr("no errors")
		-- else
		-- 	DebugWatch("[GUIDANCE TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		-- end

		local status,retVal = pcall(gameplayTicks,dt)
		if status then 
			-- utils.printStr("no errors")
		else
			DebugWatch("[GAMEPLAY TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end

		status,retVal = pcall(playerTicks,dt)
		if status then 
				
		else
			DebugWatch("[PLAYER TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end
	else
		gameplayTicks(dt)
		playerTicks(dt)

		--guidance_tick(dt)
	end

	pollNewVehicle(dt)
	new_ai_scan()

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


	if(DEBUG_CODE) then 
		-- local status,retVal = pcall(guidance_tick,dt)
		-- if status then 
		-- 	-- utils.printStr("no errors")
		-- else
		-- 	DebugWatch("[GUIDANCE TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		-- end

		local status,retVal = pcall(tool_ticks,dt)
		if status then 
			-- utils.printStr("no errors")
		else
			DebugWatch("[GAMEPLAY TICK ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end	
	else
		tool_ticks(dt)
	end


end

function tool_ticks(dt)
	if unexpected_condition then error() end
	AVF_TAK_TICK(dt)
	team_allocator_tick()
end

function gameplayTicks( dt )
	if unexpected_condition then error() end


	AVF_ai:aiTick(dt)

	

	reloadTicks(dt)




	ammoRefillTick(dt)

	explosionController:tick(dt)
end

function new_ai_scan(dt)



	local current_game_time = GetTime()
	if (current_game_time - last_ai_scan > ai_scan_timestep ) then 
		for key,vehicle_entry in pairs(vehicles) do
			vehicleFeatures = vehicle_entry.vehicleFeatures
			vehicle = vehicle_entry.vehicle
			if(HasTag(vehicle.id,"new_avf_ai") and HasTag(vehicle.id,"avf_ai")) then
				if(DEBUG_AI) then 
					DebugWatch("found new ai to add")

					local status,retVal = pcall(init_new_ai)
					if status then 
						
						DebugPrint("Vehicle: "..vehicle.id.." is ai ready")
					else
						DebugWatch("[AI ADD ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
					end
				else
					AVF_ai:initAi()
				end				
				
				RemoveTag(vehicle.id,"new_avf_ai")
			end
		end
		last_ai_scan = current_game_time
	end

end


function init_new_ai()
	AVF_ai:initAi()
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
					SetString("level.avf.weapon_group",vehicleFeatures.equippedGroup)
					handleInputs(dt)
					--DebugWatch("sniperMode", vehicle.sniperMode) 
					SetBool("level.avf.sniper_mode",false)
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
						 
						SetBool("level.avf.sniper_mode",true)
							set_sniper_cam(dt)
						--end
					end
					
					if(vehicle.sniperMode and vehicle.arty_cam_pos~=nil) then 
						set_artillery_cam()
					end
					handleUtilityReloads(dt)
					databus:update_vehicle_states()
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
			-- DebugWatch("vehicle disabled",HasTag(vehicle.id,"avf_vehicle_disabled"))
			if(HasTag(vehicle.id,"avf_vehicle_disabled")) then 
				return
			end
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
					if(IsHandleValid(GetVehicleBody(
										vehicle.vehicle.id
										))) 
					then
						DebugCross(
							VecAdd(
								retrieve_first_barrel_coord(gun).pos,
								
								VecScale(
									GetBodyVelocity(
										GetVehicleBody(
											vehicle.vehicle.id
											)
										),
									dt
									)
								),0,0,1)
					end

					 	
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
	if(DEBUG_CODE) then 	
		local status,retVal =pcall(physics_update_ticks,dt);
		if status then 
			-- utils.printStr("no errors")
		else
			DebugWatch("[ERROR]",retVal)
		end 
		local status,retVal = pcall(update_gameplay_ticks,dt)
		if status then 
				
		else
			DebugWatch("[update_gameplay_ticks ERROR]",retVal)--frameErrorMessages = frameErrorMessages..retVal.."\n"
		end
		if(debug_vehicle_locations_active) then 
			debug_vehicle_locations()
		end
	else
		physics_update_ticks(dt)
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

											local rotation_force = GetBodyMass(GetShapeBody(gun.parent_shape))
											SetJointMotor(gun.turretJoint, 0,rotation_force)
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

						local rotation_force = GetBodyMass(GetShapeBody(turret.id))
						SetJointMotor(turret.turretJoint, 0,rotation_force)
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

function set_commander_view_x_y()

	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]

	local focusGun = gunGroup[1]	
	local min, max = GetJointLimits(focusGun.gunJoint)
	focusGun.commander_view_y = ((GetJointMovement(focusGun.gunJoint) - min)/(max -min)) 
	focusGun.commander_view_x = ((GetJointMovement(focusGun.turretJoint) - focusGun.turret_min)/(focusGun.turret_max -focusGun.turret_min)) 

	
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
			commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(x_rot,y_rot, z_rot))
		end
	end
	focusGunPos = retrieve_first_barrel_coord(focusGun)
	local zero_range = 400
	if(focusGun.zeroing and focusGun.zeroing >=50) then
		zero_range = focusGun.zeroing 
	end	
	local cmddist = zero_range
	local deadzone = 0
	-- local commanderPos = GetShapeWorldTransform(vehicleFeatures.commanderPos) --vehicleFeatures.turrets.mainTurret[1].id)
	-- local commanderPos = GetVehicleTransform(vehicle.id)
	local posLoc  = TransformToParentPoint(commanderPos, Vec(x,  z, y ))
	local fwdLoc  = TransformToParentPoint(commanderPos, Vec(x,  z-2,y ))
	local direction = VecSub(posLoc, commanderPos.pos)
	commanderPos.rot = QuatLookAt(posLoc,fwdLoc)
	-- commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(0, 0, 0))
	commanderPos.pos = VecAdd(commanderPos.pos, direction)
	local bias = utils.sign(x)

	local primary = GetJointMovement(gunGroup[1].gunJoint)
	
	commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(-primary,0, 0))
	-- DebugWatch("avf zero range",zero_range)

	local testCommander =  TransformToParentPoint(commanderPos,Vec(0,000,-zero_range))
	local testGun =  TransformToParentPoint( retrieve_first_barrel_coord(focusGun),Vec(0,-zero_range,0))
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
	local rotateSpeed = (vehicle.sniperFOV*ZOOMVALUE) / vehicle.sniperFOV
	local mouseX, mouseY = get_mouse_movement(10)
	mouseX = -mouseX
	mouseY = -mouseY

	local min, max = GetJointLimits(focusGun.gunJoint)
	local current = GetJointMovement(focusGun.gunJoint)
	local gun_percentage = ((current - min)/(max -min))

	local gun_target_angle = (gun_percentage *(max -min))+min
	-- DebugWatch("gun movement gun_percentage ",gun_percentage)
	-- DebugWatch("gun turret rotation min ",min)
	-- DebugWatch("gun turret rotation max ",max)
	-- DebugWatch("gun turret rotation current ",current)
	-- DebugWatch("gun_target_angle",gun_target_angle)

	
	local zoom_modifier = 1 - clamp(0,1,(vehicle.ZOOMLEVEL / (vehicle.ZOOMMAX*1.5)))
	local view_y = (focusGun.commander_view_y + (focusGun.commander_y_rate*dt * utils.sign(-mouseY))*zoom_modifier)
	if(min == -180 and max == 180 ) then
		view_y = view_y %1
	end
	local view_x = (focusGun.commander_view_x + (focusGun.commander_x_rate*dt * utils.sign(-mouseX))*zoom_modifier)
	if(focusGun.turret_min == -180 and focusGun.turret_max  == 180 ) then
		view_x = view_x %1
	end
	focusGun.commander_view_x = clamp(0,1,view_x)
	focusGun.commander_view_y = clamp(0,1,view_y)
	local target_x = focusGun.commander_view_x * (focusGun.turret_max - focusGun.turret_min) + focusGun.turret_min
	local target_y = focusGun.commander_view_y * (max - min) + min
	
	local turret_rotation_force = GetBodyMass(GetShapeBody(focusGun.parent_shape))
	local rotation_force = GetBodyMass(GetShapeBody(focusGun.id))

	if(focusGun.turret_min == -180 and focusGun.turret_max  == 180 ) then
		local target_turret_rot = (GetJointMovement(focusGun.turretJoint)-target_x)
		if(math.abs(target_turret_rot) >90) then 
			target_turret_rot = 0.5*utils.sign(-target_turret_rot)
		end
		SetJointMotor(focusGun.turretJoint, focusGun.turret_rotation_rate*clamp(-1,1,target_turret_rot),turret_rotation_force)
		-- DebugWatch("target_turret_rot ",clamp(-1,1,target_turret_rot))
		-- DebugWatch("focusGun.turretJoint",focusGun.turretJoint)
		-- DebugWatch("focusGun.turret_rotation_rate*clamp(-1,1,target_turret_rot)",focusGun.turret_rotation_rate*clamp(-1,1,target_turret_rot))
		-- DebugWatch("turret rotation force",turret_rotation_force)
	else
		SetJointMotorTarget(focusGun.turretJoint, target_x, focusGun.turret_rotation_rate,turret_rotation_force)
	end
	-- DebugWatch("target_x ",target_x)
	-- DebugWatch("turret_rotateSpeed ",focusGun.turret_rotation_rate)
	if(min == -180 and max == 180 ) then
		SetJointMotor(focusGun.gunJoint, focusGun.elevationRate*(current-target_y),rotation_force)
		
	else

		SetJointMotorTarget(focusGun.gunJoint, target_y, focusGun.elevationRate,rotation_force)	
	end

	local focus_gun_aim_pos =  TransformToParentPoint( retrieve_first_barrel_coord(focusGun),Vec(0,zero_range,0))
	if(debugMode)then
		DebugWatch("MouseX",mouseX)
		DebugWatch("MouseY",mouseY)
	end
	for key,gun in pairs(gunGroup) do
			if(gun.id ~= focusGun.id) then 
				local turret_rotation_force = GetBodyMass(GetShapeBody(gun.parent_shape))
				if(gun.turretJoint~=nil and gun.turretJoint ~= focusGun.turretJoint) then 
					local min, max = GetJointLimits(gun.turretJoint)
					local current = GetJointMovement(gun.turretJoint)
					-- DebugWatch("gun turret rotation min ",min)
					-- DebugWatch("gun turret rotation max ",max)
					-- DebugWatch("gun turret rotation current ",current)
					-- DebugWatch("turret_rotateSpeed ",turret_rotateSpeed)
					if(math.abs(mouseX)>deadzone) then
							local turn_force = 1
							turret_rotateSpeed = rotateSpeed*.6
							SetJointMotor(gun.turretJoint, (turn_force*utils.sign(mouseX))*turret_rotateSpeed,turret_rotation_force)
					else
						SetJointMotor(gun.turretJoint, 0,turret_rotation_force)
					end
				end
					
				local rotation_force = GetBodyMass(GetShapeBody(gun.id))

				local barrelCoords = getBarrelCoords(gun)
				gunLaying(gun,barrelCoords,focus_gun_aim_pos)
			end
		end
end


function one_d_distance(num_1,num_2) 
if(num_1 > num_2) then
	return num_1
elseif (num_1<num_2) then 

else
	return 0
end

end


function set_sniper_cam(dt) 
	if unexpected_condition then error() end


	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	local testgunobj = gunGroup[1].id
	SetInt("level.avf.focus_weapon",testgunobj )

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
	
	local zero_range = 300
	if(focusGun.zeroing and focusGun.zeroing >=50) then
		zero_range = focusGun.zeroing 
	end	
	-- DebugWatch("zero range",zero_range)

	SetInt("level.avf.zeroing",zero_range)
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
	--[[ 

	brief test
	]]--
	local gun_vel = focusGun.magazines[focusGun.loadedMagazine].CfgAmmo.velocity
	local gravity_vector = VecLength(VecScale(globalConfig.gravity,focusGun.magazines[focusGun.loadedMagazine].CfgAmmo.gravityCoef))
	local expected_hit_point = Vec(0, (-gravity_vector * ((zero_range  / gun_vel ))*.1), -zero_range)

	--[[

	test end

	]]
	local testCommander =  TransformToParentPoint(commanderPos,Vec(0,000,-zero_range))
	-- local testGun =  TransformToParentPoint( focusGunPos,Vec(0,-zero_range,0))
	local testGun_x =  TransformToParentPoint( focusGunPos,Vec(0,expected_hit_point[3],0))
	local testGun_y =  TransformToParentPoint( focusGunPos,Vec(0,0,expected_hit_point[2]))
		
	local offSetAngle_x = (math.atan(VecLength(VecSub(testCommander,testGun_x))/cmddist)*10)*bias
	local offSetAngle_y = (math.atan(VecLength(VecSub(testCommander,testGun_y))/cmddist)*1.5)*bias

	-- local offSetAngle = (math.atan(VecLength(VecSub(testCommander,testGun))/cmddist)*10)*bias

	if(focusGun.aimForwards) then
		offSetAngle = 0
	end

	-- 	DebugWatch("test veclength: ",VecLength(VecSub(testCommander,testGun)))
	--DebugWatch("test angle: ",offSetAngle)


	-- simplified
	local testGun =  TransformToParentPoint( focusGunPos,Vec(0,expected_hit_point[3],expected_hit_point[2]))
	DebugCross(testGun,1,0,0	)
	commanderPos.rot  = QuatLookAt(commanderPos.pos, testGun)

	-- commanderPos.rot = QuatRotateQuat(commanderPos.rot,QuatEuler(-offSetAngle_y,-offSetAngle_x, 0))
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
		if(not vehicle.arty_cam_pos) then 
			vehicle.arty_cam_pos= Transform(Vec(),Quat())
		end
		local gun_movement = 0  
		local turret_movement = 0
		local mouseX, mouseY = 0,0
		local rotate_vec = Vec()
		if(vehicle.sniperMode) then 
			mouseX, mouseY = get_mouse_movement(0.25)
			gun_movement = mouseY
			turret_movement = mouseX
			rotate_vec = Vec(mouseX,0,mouseY)
		else
			if(input_active("w")) then
				gun_movement = -1
			elseif input_active("s") then
				gun_movement = 1
			end	
			if(input_active("a")) then
				turret_movement = 1
			elseif input_active("d") then
				turret_movement = -1
			end
		end	 

		local rotateSpeed = 1

		local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
		
		for key,gunGroup in pairs(vehicleFeatures.weapons) do
			
		-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do

				--[[ 	movement stuff ]]
				if(vehicle.sniperMode) then 
					  gun_movement, turret_movement = get_arty_aim_movement(rotate_vec,vehicle.arty_cam_pos[1],gun)
				end
				  -- get_arty_aim_movement(rotate_vec,vehicle.arty_cam_pos[1],gun)
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
									
					local rotation_force = GetBodyMass(GetShapeBody(gun.id))


					local min, max = GetJointLimits(gun.gunJoint)
					local current = GetJointMovement(gun.gunJoint)
					gun.commander_view_y = clamp(0,1,(gun.commander_view_y + (gun.commander_y_rate*GetTimeStep() * -gun_movement)))
					local target_y = gun.commander_view_y * (max - min) + min
					SetJointMotorTarget(gun.gunJoint, target_y, gun.elevationRate)


					-- if( gun.elevationSpeed) then
					-- 	SetJointMotor(gun.gunJoint, (gun.elevationSpeed*gun_movement)*rotateSpeed)
					-- else
					-- 	SetJointMotor(gun.gunJoint, gun_movement*rotateSpeed)
					-- end
					gun.last_gun_joint_pos = GetJointMovement(gun.gunJoint)
			
					--DebugWatch(" gun_movement*rotateSpeed", gun_movement*rotateSpeed)
				else
					local rotation_force = GetBodyMass(GetShapeBody(gun.id))
					local min, max = GetJointLimits(gun.gunJoint)
					local current = GetJointMovement(gun.gunJoint)
					gun.commander_view_y = clamp(0,1,(gun.commander_view_y + (gun.commander_y_rate*GetTimeStep() * -gun_movement)))
					local target_y = gun.commander_view_y * (max - min) + min
					SetJointMotorTarget(gun.gunJoint, target_y, gun.elevationRate)

					-- if(gun.last_gun_joint_pos and gun.last_gun_joint_pos < GetJointMovement(gun.gunJoint)) then 
					-- 	SetJointMotor(gun.gunJoint, 0.2)
					-- elseif(gun.last_gun_joint_pos and gun.last_gun_joint_pos > GetJointMovement(gun.gunJoint)) then 
					-- 	SetJointMotor(gun.gunJoint, -0.2)
					-- else
					-- 	SetJointMotor(gun.gunJoint, 0)
					-- end
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
	if(arty_pos) then 


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
	else
		return 0,0
	end
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
		
		if(gunGroup) then 
			-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do
				if(not gun.reloading and gun.tailOffSound and gun.rapidFire)then
					local cannonLoc = GetShapeWorldTransform(gun.id)
					play_gun_sound(gun.tailOffSound, cannonLoc.pos, 80, gun.custom_tail_off,gun,"tailOffSound")
					gun.rapidFire = false
				end
			end
		else
			DebugWatch("AVF Vehicle "..vehicle.id.." gungroup is ",gunGroup)
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

					  
					    if(gun.magazines[gun.loadedMagazine].CfgAmmo.guidance and 
					    	gun.magazines[gun.loadedMagazine].CfgAmmo.guidance == "homing") then 
					    	initiate_missile_guidance(dt,gun,firing)
					    else

						    if(getPlayerMouseDown() and gun.loopSoundFile)then
						    	if not gun.rapidFire then
						    		
						    		gun.rapidFire = true

						    	end
								local cannonLoc = GetShapeWorldTransform(gun.id)

								play_gun_loop_sound(gun.loopSoundFile, cannonLoc.pos, 5, gun.custom_loop_sound_file,gun,"loopSoundFile")
								
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
										if(DEBUG_CODE) then 
											local status,retVal = pcall(reloadGun,gun);
											if status then 
												-- utils.printStr("no errors")
											else
												errorMessages = errorMessages..retVal.."\n"
											end
										else
											reloadGun(gun)
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
					play_gun_sound(gun.tailOffSound, cannonLoc.pos, 5, gun.custom_tail_off,gun,"tailOffSound")
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

							play_gun_loop_sound(gun.loopSoundFile, cannonLoc.pos, 5, gun.custom_loop_sound_file,gun,"loopSoundFile")
							-- PlayLoop(gun.loopSoundFile, cannonLoc.pos, 5)
							
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
									if(DEBUG_CODE) then 
										local status,retVal = pcall(reloadGun,gun);
										if status then 
										else
											errorMessages = errorMessages..retVal.."\n"
										end
									else
										reloadGun(gun)
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
				if(DEBUG_CODE) then 
					local status,retVal = pcall(reloadGun,gun);
					if not status then 
						DebugWatch("weapon reload error: ",retVal)
					end
				else
					reloadGun(gun)
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
	local target_body = nil
	local max_dist = 400
	local playerShooting,released,held = getPlayerShootInput()
	if(playerShooting and firing)then
		local cannonLoc = retrieve_first_barrel_coord(gun)
		
		QueryRejectBody(vehicle.body)
		local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  max_dist * -1),0)
	    local direction = VecSub(fwdPos, cannonLoc.pos)
	
	    -- DebugWatch("test firing 2",firing)
	    direction = VecNormalize(direction)
	    QueryRequire("physical")
	    local hit, dist,n,shape = QueryRaycast(cannonLoc.pos, direction, max_dist)
	    -- DebugWatch("current track",gun.missile_guidance_current_track )
	    if(hit) then 
	    	
	    	local last_tracked,tracked_object = verify_tracked_target(gun,shape)
	    	target_body = tracked_object
	    	gun.target_body = tracked_object

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
	    -- DrawLine(cannonLoc.pos, pos, 1, 0, 0) 

	    -- DebugWatch("dist",dist)
	

	elseif(released) then 
		if(gun.missile_guidance_current_track and gun.missile_guidance_current_track>MISSILE_TRACK_TIME_MIN ) then 
	    	local min, max = GetBodyBounds(gun.missile_guidance_tracked_target )
			local boundsSize = VecSub(max, min)
			local center = VecLerp(min, max, 0.5)
			gun.missile_guidance_active_tracking_target = true
			gun.missile_guidance_target_lock = true
			gun.missile_guidance_target_pos = TransformToLocalPoint(GetBodyTransform(gun.missile_guidance_tracked_target),center)
			-- Explosion(TransformToParentPoint(GetBodyTransform(gun.missile_guidance_tracked_target),gun.missile_guidance_target_pos ),1.5)

			intel_payload = {
				payload_type 		= "target",
				target_body = gun.missile_guidance_tracked_target ,


			}	

			fireControl(dt,gun,Vec(),intel_payload)
		elseif (gun.missile_guidance_current_track and gun.missile_guidance_current_track>0.5) then       	
			local min, max = GetBodyBounds(gun.missile_guidance_tracked_target )
			local boundsSize = VecSub(max, min)
			local center = VecLerp(min, max, 0.5)
			gun.missile_guidance_target_pos = center
			-- Explosion(center,1.2)


			intel_payload = {
				payload_type 		= "target",
				target_body = gun.missile_guidance_tracked_target ,


			}
			fireControl(dt,gun,Vec(),intel_payload)

		end
		reset_missile_track(gun)
	elseif(gun.missile_guidance_tracking_target) then
		reset_missile_track(gun)
	end						    	
end

function verify_tracked_target(gun,shape) 
	local tracked_body = GetShapeBody(shape)
	tracked_body,mass = get_largest_body(tracked_body)
	-- DebugWatch("mass",mass)
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
	if(gun.missile_guidance_current_track>MISSILE_TRACK_TIME_MIN ) then 
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
	
	if(not gun.reloadPlayOnce)then
		local reload_percentage  = 1-(gun.reloadTime / gun.reload)
		play_reloading_sound(
			gun.reloadSound, 
			GetShapeWorldTransform(gun.id).pos, 
			5,
			gun.custom_reload,
			reload_percentage  ,
			gun,
			"reloadSound"
			)
		-- PlayLoop(gun.reloadSound, GetShapeWorldTransform(gun.id).pos, 3)
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

	gun.reloadTime = gun.reloadTime - dt
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
		play_gun_sound(gun.tailOffSound, cannonLoc.pos, 5, gun.custom_tail_off,gun,"tailOffSound")
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
			-- PlaySound(gun.reloadSound, GetShapeWorldTransform(gun.id).pos, 5)
			play_gun_sound(gun.reloadSound, GetShapeWorldTransform(gun.id).pos, 5, gun.custom_reload,gun,"reloadSound")
		end

end


--[[@FIRECONTROL
	
	HANDLE WEAPON FIRE CONTROL



]]

function fireControl(dt,gun,barrelCoords,--[[optional]]intel_payload)
	-- if(intel_payload and intel_payload.payload_type ) then 
	-- 	DebugPrint("firecontrol intel payload: "..intel_payload.payload_type)
	-- else 
	-- 	DebugPrint("firecontrol no intel payload detected")
	-- end

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
	
	fire(gun,barrelCoords,intel_payload)
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

    local gun_com = GetBodyCenterOfMass(GetShapeBody(gun.id))
    local gun_com_offset = 
    	VecSub(
			cannonLocpos,
			TransformToParentPoint(cannonLoc,gun_com)
    		)[2]
    	
   	-- DebugWatch("com_offset",gun_com_offset)

	local gun_mass = GetBodyMass(GetShapeBody(gun.id))
	local gun_parent_mass = GetBodyMass(GetShapeBody(gun.parent_shape))
	local bullet_grain = 64
	-- DebugWatch("gun_mass",gun_mass)
	-- DebugWatch("gun_parent_mass",gun_parent_mass)
	-- DebugWatch("modulo",-3%30)

	local mass = gun.magazines[gun.loadedMagazine].CfgAmmo.caliber * .01
	local gun_vel = gun.magazines[gun.loadedMagazine].CfgAmmo.velocity
	gun_vel = gun_vel 
	-- recoil = (((.5 * mass * gun_vel)*0.01)*recoil)
	recoil = (mass /(gun_mass+gun_parent_mass))*gun_vel*recoil
	local original_recoil = (mass /gun_mass)*gun_vel*recoil
	-- DebugWatch("recoil",recoil)
	-- DebugWatch("original_recoil",original_recoil)
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
	cannonLoc.pos = add_vehicle_vel(cannonLoc.pos,gun.parent_vehicle)
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
	cannonLoc.pos = add_vehicle_vel(cannonLoc.pos,gun.parent_vehicle)
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
	cannonLoc.pos = add_vehicle_vel(cannonLoc.pos,gun.parent_vehicle)
	return cannonLoc
end


function add_vehicle_vel(pos,vehicle_id)
	return VecAdd(
			pos,
			VecScale(
				GetBodyVelocity(
					GetVehicleBody(
						vehicle_id
						)
					),
				GetTimeStep()
				)
			)	
end


function turretRotatation(turret,turretJoint,aim_gun,gun)
	if unexpected_condition then error() end
	if(turret)then 
		local core_turret = turret 
		local rotation_force = GetBodyMass(GetShapeBody(turret.id))*1.3
		-- DebugWatch("turret weight",rotation_force)
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

			-- local turret = turret.id
			local forward = turretAngle(0,1,0,turret.id,aim_gun,gun)
			local back 	  = turretAngle(0,-1,0,turret.id,aim_gun,gun) 
			local left 	  = turretAngle(-1,0,0,turret.id,aim_gun,gun)
			local right   = turretAngle(1,0,0,turret.id,aim_gun,gun)
			local up 	  = turretAngle(0,0,1,turret.id,aim_gun,gun)
			local down 	  = turretAngle(0,0,-1,turret.id,aim_gun,gun)

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
					SetJointMotor(
						turretJoint, 
						gun.turret_rotation_rate* clamp(-1,1,target_move+ 0.1 * utils.sign(target_move)),
						rotation_force)
					
 

					-- SetJointMotor(
					-- 	turretJoint, 
					-- 	clamp(
					-- 		-1,
					-- 		1,
					-- 		(min_move*math.sign(target_move))+1.5*(target_move)),
					-- 	rotation_force)
				-- 
				-- if(left>right+bias) then
				-- 	SetJointMotor(turretJoint, clamp(0,1,1.5*(left-right)))
				-- elseif(right>left+bias) then
				-- 	SetJointMotor(turretJoint, clamp(-1,0,-1.5*(right-left)))
				else
					SetJointMotor(turretJoint, 0,rotation_force)
				end
			else
				SetJointMotor(turretJoint, 0,rotation_force)
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
	local turretPos = retrieve_first_barrel_coord(gun).pos--GetShapeWorldTransform(gun.id).pos -- cheej
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
	if(false and reticleWorldPos) then 
		targetPos = reticleWorldPos
		DebugWatch("reticle pos exists",reticleWorldPos)
	else
			local crosshairDir = UiPixelToWorld(UiCenter(), UiMiddle()-50)
		local crosshairQuat = QuatDir(crosshairDir)
	    local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)
		targetPos = TransformToParentPoint(crosshairTr,Vec(0,0,-gun.zeroing))--TransformToParentPoint(GetCameraTransform(),Vec(0,0,-gun.zeroing)) 
	end
	shootDir = VecSub(turretPos,targetPos)
	shootDir = VecNormalize(shootDir)
	-- shootDir[2] = heightDiff
	shootDir = VecNormalize(shootDir)

	local lookDir =  VecAdd(turretPos,VecScale(shootDir,gun.zeroing))
	local nt = Transform()


	nt.rot = QuatLookAt(turretPos, lookDir) -- cheej
	nt.pos = VecCopy(turretPos)
	nt = TransformToParentPoint(nt,Vec(0,0,-gun.zeroing))
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
	local dir_impulse = 0 
	if(up < down-bias*0.25)then  -- and up-bias*.5>0) then 
		dir = 1
		dir_impulse = down
	elseif(up > down+bias*0.25 )then  --and down-bias*.5>0) then
		dir = -1
		dir_impulse = up

	end 
	-- DebugWatch("dir",dir)

	local rotation_force = GetBodyMass(GetShapeBody(gun.id))


	local min, max = GetJointLimits(gun.gunJoint)
	local current = GetJointMovement(gun.gunJoint)
	gun.commander_view_y = clamp(0,1,(gun.commander_view_y + (gun.commander_y_rate*GetTimeStep() * -dir)))
	local target_y = gun.commander_view_y * (max - min) + min
	SetJointMotorTarget(gun.gunJoint, target_y, gun.elevationRate)

end

function gunAngle(x,y,z,gun,targetPos)

	 	-- DebugWatch("avf ai turret test ",1)
	local gunTransform =  retrieve_first_barrel_coord(gun)
	 
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

		if (vehicle.sniperMode	) then
			set_commander_view_x_y()
		end
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

		set_commander_view_x_y()
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





UpdateQuickloadPatch() 