if ancient_apparition_ice_vortex_custom == nil then
  ancient_apparition_ice_vortex_custom = class ({})
end


function ancient_apparition_ice_vortex_custom:OnSpellStart()
  local caster = self:GetCaster()
  local point = self:GetCursorPosition()
  local team_id = caster:GetTeam()

  CreateModifierThinker(caster, self, "modifier_ancient_apparition_ice_vortex_custom_thinker", {}, point, team_id, false)
end


function ancient_apparition_ice_vortex_custom:GetCooldown(level)
  local caster = self:GetCaster()
  local cooldown = self.BaseClass.GetCooldown(self, level)

  local talent_value = caster:GetModifierStackCount("modifier_special_bonus_unique_ancient_apparition_3", caster)

  if talent_value then
    cooldown = cooldown - talent_value
  end

  return cooldown
end


function ancient_apparition_ice_vortex_custom:GetAOERadius()
  return self:GetLevelSpecialValueFor("radius", self:GetLevel() - 1)
end


if modifier_ancient_apparition_ice_vortex_custom_thinker == nil then
  modifier_ancient_apparition_ice_vortex_custom_thinker = class ({})
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:OnCreated()
  if IsServer() then
    local thinker = self:GetParent()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("ancient_apparition_ice_vortex_custom")

    thinker:EmitSound("Hero_Ancient_Apparition.IceVortexCast")
    thinker:EmitSound("Hero_Ancient_Apparition.IceVortex.lp")

    -- Get ability values
    local level = ability:GetLevel() - 1
    self.duration = ability:GetLevelSpecialValueFor("vortex_duration", level)
    self.expire = GameRules:GetGameTime() + self.duration
    self.effect_radius = ability:GetLevelSpecialValueFor("radius", level)
    self.vision_radius = ability:GetLevelSpecialValueFor("vision_aoe", level)

    -- Create particle
    local particle = ParticleManager:CreateParticle(
      "particles/units/heroes/hero_ancient_apparition/ancient_ice_vortex.vpcf",
      PATTACH_WORLDORIGIN,
      thinker
    )
    local thinker_pos = thinker:GetAbsOrigin()
    ParticleManager:SetParticleControl(particle, 0, thinker_pos + Vector(0, 0, 60))
    ParticleManager:SetParticleControl(particle, 5, Vector(self.effect_radius, 0, 0))
    self.particle = particle

    self:UpdateVision(1.0)

    self:StartIntervalThink(0.01)
  end
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:UpdateVision(duration)
  local thinker = self:GetParent()
  AddFOWViewer(thinker:GetTeam(), thinker:GetAbsOrigin(), self.vision_radius, 1.0, false)
  self.next_vision_update = GameRules:GetGameTime() + 1.0
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:OnIntervalThink()
  local game_time = GameRules:GetGameTime()
  local time_to_expire = self.expire - game_time

  if (not self.destroy_time) and (time_to_expire <= 0) then
    if IsServer() then
      self:GetParent():StopSound("Hero_Ancient_Apparition.IceVortex.lp")

      if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
      end
    end

    -- Destroy the thinker with a delay to let the end cap of the particle play
    self.destroy_time = game_time + 3.0
  end

  if self.destroy_time and game_time > self.destroy_time then
    self:Destroy()
  end

  -- Update vision once per second until the ability ends
  -- This way the effect lingers for at most one second when the thinker is destroyed
  if game_time >= self.next_vision_update then
    vision_duration = math.min(1.0, time_to_expire)

    if vision_duration > 0.0 then
      self:UpdateVision(vision_duration)
    end
  end
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:OnDestroy()
  self.destroy_time = nil
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:CheckState()
  return nil
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:IsAura()
  if self.destroy_time then
    return false
  else
    return true
  end
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:GetAuraRadius()
  return self.effect_radius
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:GetAuraSearchFlags()
  return DOTA_UNIT_TARGET_FLAG_NONE
end


function modifier_ancient_apparition_ice_vortex_custom_thinker:GetModifierAura()
  return "modifier_ice_vortex"
end
