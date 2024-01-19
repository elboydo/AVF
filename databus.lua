databus ={
	TAK_COMMANDS = {
		[1] = 'AVF_TAK_MOVE',
		[2] = 'AVF_TAK_ATTACK'
	}
}

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

	local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	SetTag(gun.id,"avf.databus.loaded_magazine",gun.loadedMagazine)

	SetTag(gun.id,"avf.databus.ammo_count",currentMagazine.AmmoCount)

end

function databus:retrieve_tak_commands(ai)
	local command_name = nil
	local new_command = HasTag(ai.id,'AVF_TAK_NEW_COMMAND')
	if(new_command) then 
		RemoveTag(ai.id,'AVF_TAK_NEW_COMMAND')
	end
	local move_target = nil 
	local attack_target = nil
	if(HasTag(ai.id,'AVF_TAK_MOVE')) then 
		-- DebugWatch("AI HAS TAK COMMAND")
		local string_as_pos = GetTagValue(ai.id,'AVF_TAK_MOVE')
		string_as_pos = string.split(string_as_pos, ',')
		move_target = Vec(string_as_pos[1],string_as_pos[2],string_as_pos[3])
		-- DebugPrint("hit distance: " .. dist)
		-- DebugWatch("attempting to split",Transform(move_target))

	elseif(HasTag(ai.id,'AVF_TAK_ATTACK')) then 

	end
	return new_command,move_target,attack_target
		-- BELOWS IS PRIMING FOR WHENEVER THIS NEEDS AUTOMATION 
	-- for i=1, ipairs(databus['TAK_COMMANDS']) do 
	-- 	command_name=databus['TAK_COMMANDS'][i]
	-- 	if(HasTag(ai.id,command_name)) then 

	-- 	end
	-- end

end



function string:split(sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if self:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = self:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = self:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = self:sub(nStart)
   end

   return aRecord
end