armedVehicleControls = {
	fire 				= "usetool",
	sniperMode 			= "vehiclelower",
	changeWeapons		= "r",
	changeTurretGroup	= "t",
	changeAmmunition	= "f",
	deploySmoke			= "g",
	toggle_Searchlight =  "l",
}

armedVehicleControlsOrder = {
	[1] 			="fire",
	[2] 			= "sniperMode",
	[3] 			= "changeWeapons",
	[4]				= "changeAmmunition",
	[5]				= "deploySmoke",
	[6]			="toggle_Searchlight",
}

armedVehicleControls_arty = {
	fire 				= "usetool",
	Arty_cam 			= "vehiclelower",
	left	= "left",
	right	= "right",
	up			= "up",
	down  =  "down",
}

armedVehicleControlsOrder_arty = {
	[1] 			="fire",
	[2] 			= "Arty_cam",
	[3] 			= "left",
	[4]				= "right",
	[5]				= "up",
	[6]			="down",
}

-- 	camerax = "camerax",	--Camera x movement, scaled by sensitivity. Only valid in InputValue.
-- cameray = "cameray",



function loadCustomControls()
	for key, value in pairs(armedVehicleControls) do 
		
		if GetString("savegame.mod.controls."..key)~="" then
			armedVehicleControls[key] =  GetString("savegame.mod.controls."..key)
		end
	end

end