#include "avf_custom.lua"





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
		["yourTankCannonName"] = {	
			name="tank shooty",
			magazines = {},
			
			sight					= {
										[1] = {
										x=1.1,
										y=1.0,
										z=2.0,
											},
										},
										-- aimForwards = true,
			barrels		= {
							[1] = {
								x = 0.2,
								y = 0.1,
								z = -1.5,
								}

							},
			},
	},
	}
	

	---- magazine num _ val
	---- barrels num value

vehicle = {

}

