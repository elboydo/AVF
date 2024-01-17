DEBUG_AI_PRIORITIES = false	





function SHOW_AVF_DEV_HUD()
	UiMakeInteractive()


	UiPush()
	UiTranslate(UiCenter(), 50)
	UiAlign("center top")

	--Title
	UiImageBox("MOD/gfx/AVF_logo.png",400,400,1,1)
	UiTranslate(0, 300)
	UiFont("bold.ttf", 48)
	UiText("Armed Vehicles Framework (AVF) Options")
	UiTranslate(0, 50)
	UiText("AVF Version: "..VERSION)
	UiPop()
	---AVF_logo

--[[




debugMode = false

DEBUG_AI = false

DEBUG_CODE = true

debugging_traversal =false

debug_combat_stuff = false

debug_weapon_pos = false


debug_special_armour = false

debug_shell_casings = false


debug_player_damage = false


debug_vehicle_locations_active = false


]]
	UiTranslate(UiCenter()/2, 150)
	UiFont("regular.ttf", 26)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
		UiTranslate(-110, 0)
		UiAlign("center left")
		UiColor(0,0,0,0.5)

		UiTranslate(-10, 0)
		UiImageBox("ui/common/box-solid-6.png", 270, 800, 6, 6)
		
		UiTranslate(5, 0)
		UiTranslate(0, 40)
		UiText("Debug options")
		UiTranslate(0, 50)
		set_button_colour(DEBUG_CODE)
		UiTextButton("Debug code", 250, 40)
		if UiTextButton("Debug code", 250, 40) then
			DEBUG_CODE = not DEBUG_CODE
		end
			UiTranslate(0, 40)
		set_button_colour(DEBUG_AI)
		UiTextButton("DEBUG_AI", 250, 40)
		if UiTextButton("DEBUG_AI", 250, 40) then
			DEBUG_AI = not DEBUG_AI
		end
		UiTranslate(0, 40)
		set_button_colour(DEBUG_AI_PRIORITIES)
		UiTextButton("DEBUG_AI_PRIORITIES", 250, 40)
		if UiTextButton("DEBUG_AI_PRIORITIES", 250, 40) then
			DEBUG_AI_PRIORITIES = not DEBUG_AI_PRIORITIES
		end
		UiTranslate(0, 40)
		set_button_colour(_AI_DEBUG_PATHING)
		UiTextButton("_AI_DEBUG_PATHING", 250, 40)
		if UiTextButton("_AI_DEBUG_PATHING", 250, 40) then
			_AI_DEBUG_PATHING = not _AI_DEBUG_PATHING
		end


		
			UiTranslate(0, 40)

		set_button_colour(debugging_traversal)
		UiTextButton("debugging_traversal", 250, 40)
		if UiTextButton("debugging_traversal", 250, 40) then
			debugging_traversal = not debugging_traversal
		end
			UiTranslate(0, 40)
		set_button_colour(debug_combat_stuff)
		UiTextButton("debug_combat_stuff", 250, 40)
		if UiTextButton("debug_combat_stuff", 250, 40) then
			debug_combat_stuff = not debug_combat_stuff
		end
			UiTranslate(0, 40)




		UiTranslate(0, 100)
		if UiTextButton("Close", 200, 40) then
			AVF_DEV_HUD_VISIBLE=false
		end	
	UiPop()


	
	UiTranslate(UiCenter(), 250)
	--Draw buttons
	UiTranslate(0, 200)
	UiFont("regular.ttf", 26)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
		local w = 300
		local h = 50
		UiTranslate(-110, -100)
		UiAlign("left")
		local debugText = "Enable"
		if(GetBool("savegame.mod.debug")) then
			debugText = "Disable"
		end
		if UiTextButton(debugText.." Debug Mode", w, h) then
			SetBool("savegame.mod.debug", not GetBool("savegame.mod.debug"))
		end	
		UiTranslate(0, 50)
		local infiniteAmmoText = "Enable"
		if(GetBool("savegame.mod.infiniteAmmo")) then
			infiniteAmmoText = "Disable"
		end
		if UiTextButton(infiniteAmmoText.." Infinite Ammo", w, h) then
			SetBool("savegame.mod.infiniteAmmo", not GetBool("savegame.mod.infiniteAmmo"))
		end	
		UiTranslate(0, 50)
		local controlsHudText = "Hide"
		if(GetBool("savegame.mod.hideControls")) then
			controlsHudText = "Show"
		end
		if UiTextButton(controlsHudText.." Controls HUD", w, h) then
			SetBool("savegame.mod.hideControls", not GetBool("savegame.mod.hideControls"))
		end


		-- UiTranslate(270, 0)
		-- if GetBool("savegame.mod.mph") then
		-- 	UiPush()
		-- 		UiColor(0.5, 1, 0.5, 0.2)
		-- 		UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
		-- 	UiPop()
		-- end
		-- if UiTextButton("Imperial MPH", 200, 40) then
		-- 	SetBool("savegame.mod.mph", true)
		-- end
	UiPop()
	
	UiTranslate(0, 100)
	if UiTextButton("Close", 200, 40) then
		AVF_DEV_HUD_VISIBLE=false
	end	
end

function set_button_colour(condition)
	if(condition) then 
		UiColor(0,1,0,1)
	else
		UiColor(0.8,0.8,0.8,0.5)
	end
end