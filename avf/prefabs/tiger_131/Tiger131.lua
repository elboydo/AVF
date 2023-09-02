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
			name="8.8 cm KwK Cannon",
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
											y = -0.05
											},
									},
			zoomSight 				= "MOD/gfx/tzf9b.png",
			soundFile				= "MOD/sounds/Relic700KwK37",
			reloadSound				= "MOD/sounds/Relic700KwKReload",
			reloadPlayOnce			= true,
										-- aimForwards = true,
			zero_range 				= 100,
			barrels		= {
							[1] = {
								x = 0.9,
								y = 0.1,
								z = -0.1,
								}

							},
			
			magazines = {
						[1] = {name="APCBC",
						caliber 				= 88,
						velocity				= 230,
						maxPenDepth = 0.85,
						payload					= "AP",
					},
						[2] = {name="Sprgr. L/45 (HE)",
						caliber 				= 88,
						velocity				= 220,
						explosionSize			= 1.2,
						maxPenDepth 			= 0.3,
						r						= 0.3,
						g						= 0.6, 
						b						= 0.3, 
						payload = "HE",
					},
				},
				coax = 	{
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

