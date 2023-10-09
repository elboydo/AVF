databus ={}
function databus:update_vehicle_states()

	for i =1,#vehicleFeatures.validGroups do 
		group_name = vehicleFeatures.validGroups[i]
		self:update_weapons_data(vehicleFeatures.weapons[group_name])

	end 

end


function databus:update_weapons_data(gunGroup)

	local gunGroup = vehicleFeatures.weapons[vehicleFeatures.equippedGroup]
	for key2,gun in ipairs(gunGroup) do
		if( not IsJointBroken(gun.gunJoint) and  not (gun.turretJoint and IsJointBroken(gun.turretJoint)))then	---not IsShapeBroken(gun.id) and
			self:update_weapon_information(gun)
		end
	end

end



function databus:update_weapon_information(gun)
	SetTag(gun.id,"avf.databus.loaded_magazine",gun.loadedMagazine)

end