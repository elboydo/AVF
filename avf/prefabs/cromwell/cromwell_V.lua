#include "../../scripts/avf_custom.lua"


--[[

	use this file to config the parameters for your tank

	Feel free to rename this to the name of your tank



]]

vehicleParts = {
	chassis = {

	},
	turrets = {

	},
	guns = {
		["mainCannon"] = {	
			name="Ordnance QF 75 mm",
			sight					= {
										[1] = {
										x=2.12,
										y=1.7,
										z=-0.05,
											},
										},

			scope_offset 			= {
										[1] = {
											x = 0.0,
											y = 0.01
											},
									},
			zoomSight 				= "MOD/gfx/TZF12.png",
			soundFile				= "MOD/sounds/tank/tank_fire_09",
			reloadSound				= "MOD/sounds/tank/reload_short_01",
			reloadPlayOnce			= true,
										-- aimForwards = true,
			zero_range 				= 400,

			elevationSpeed			= 1,
			barrels		= {
							[1] = {
								x = 0.9,
								y = 0.1,
								z = -0.1,
								}

							},
			
			magazines = {
						[1] = {name="APC M61",
						caliber 				= 75,
						velocity				= 200,
						maxPenDepth 			= 	1,
						shellWidth				= 0.25,
						shellHeight				= .75,
						r						= 0.4,
						g						= 1.4, 
						b						= 0.4,
						payload					= "AP",
					},
						[2] = {name="HE M46",
						caliber 				= 75,
						velocity				= 190,
						explosionSize			= 1.0,
						maxPenDepth 			= 0.3,
						shellWidth				= 0.25,
						shellHeight				= .75,
						r						= 1.0,
						g						= 0.4, 
						b						= 0.4, 
						payload = "HE",
					},
				},
				coax = 	{
					name="7.92mm Besa  Coax",
					sight					= {
												[1] = {
												x=2.12,
												y=1.7,
												z=-0.05,
													},
												},
					barrels		= {
									[1] = {
										x = 0.2,
										y = 0.1,
										z = 2.5,
										}
									},

					elevationSpeed			= .5,
					zoomSight 				= "MOD/gfx/tzf9b.png",
					canZoom					= true,

					-- 				},
					
					magazines = {
								[1] = {name="7.92×57mm Mauser",
							},
						},
				},
			
		},
		["hull_mg"] = 	{
			name="MG34 Coax",
			sight					= {
										[1] = {
										x=2.12,
										y=1.7,
										z=-0.05,
											},
										},
			barrels		= {
							[1] = {
								x = 0.2,
								y = 0.1,
								z = -0.5,
								}
							},

			-- 				},
			
			magazines = {
						[1] = {name="7.92×57mm Mauser",
					},
				},
			},
	},
}
	

	---- magazine num _ val
	---- barrels num value

vehicle = {

}

