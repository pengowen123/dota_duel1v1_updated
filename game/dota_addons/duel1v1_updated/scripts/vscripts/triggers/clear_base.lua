function OnStartTouch(keys)
	local activator = keys.activator
	local name = activator:GetName()
	local classname = activator:GetClassname()

	if classname == "npc_dota_thinker" then
		for i, modifier in pairs(activator:FindAllModifiers()) do
			local modifier_name = modifier:GetName()

			if modifier_name == "modifier_arc_warden_scepter" then
				modifier:StartIntervalThink(1.0)
				return
			end

			if modifier_name == "modifier_slardar_puddle_thinker" then
				modifier:Destroy()
				return
			end
		end
	end

	if name == "npc_dota_hero_monkey_king" then
		for i, modifier in pairs(activator:FindAllModifiers()) do
			local modifier_name = modifier:GetName()
			if modifier_name == "modifier_monkey_king_fur_army_soldier" or modifier_name == "modifier_monkey_king_fur_army_soldier_active" then
				modifier:Destroy()
				return
			end
		end
	end

	if classname == "dota_death_prophet_exorcism_spirit" or classname == "npc_dota_wisp_spirit" then
		return
	end

	if name == "ent_dota_shop" then
		return
	end

	if name == "npc_dota_hero_arc_warden" then
		local is_tempest_double = false

		local modifiers = activator:FindAllModifiers()

	  for i, modifier in pairs(modifiers) do
	    if modifier:GetName() == "modifier_arc_warden_tempest_double" then
	    	is_tempest_double = true
	    end
    end

    if not is_tempest_double then
    	return
    end
	end

	if string.find(name, "npc_dota_hero") and name ~= "npc_dota_hero_arc_warden" and not activator:IsIllusion() then
		return
	elseif classname == "dota_item_drop" then
		activator:Kill()
	elseif name == "npc_dota_creep_neutral" then
		-- Neutral creeps must be removed instead of killed, or new neutrals will not spawn
		-- because the camps still count as populated
		UTIL_Remove(activator)
	else
		-- Make the entity commit suicide
		activator:Kill(nil, activator)
	end
end

function OnEndTouch(keys)
end