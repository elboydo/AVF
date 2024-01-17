

-- Play a sound at a ocation and tag the source as playing the sound if necessary
function play_gun_sound(sound,pos,volume,tag_sound,source,sound_type)
	if(tag_sound) then 
		SetTag(source.id, "PlaySound", sound_type)
	else
		PlaySound(sound, pos, volume)
	end
end

-- Play a sound at a ocation and tag the source as playing the sound if necessary
function play_gun_loop_sound(sound,pos,volume,tag_sound,source,sound_type)
	if(tag_sound) then 
		DebugWatch("avf setting ".."PlayLoop",sound_type)
		SetTag(source.id, "PlayLoop", sound_type)
	else
		PlayLoop(sound, pos, volume)
	end
end
-- Play a sound at a ocation and tag the source as playing the sound if necessary
function play_reloading_sound(sound,pos,volume,tag_sound,reload_percentage,source,sound_type)
	-- DebugWatch("reloading",reload_percentage)
	if(tag_sound) then 
		SetTag(source.id, "reloading", reload_percentage)
	else
		PlayLoop(sound, pos, volume)
	end
end