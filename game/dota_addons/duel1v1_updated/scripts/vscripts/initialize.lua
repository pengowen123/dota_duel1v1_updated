-- Initialization of the game

require('neutrals')


-- Initializes the custom neutrals system
function InitNeutrals()
  local spawn_neutrals = function()
    SpawnAllNeutrals()
    return 60.0
  end

  Timers:CreateTimer(spawn_neutrals)
end


-- Levels all players to level 25
-- Also checks for players who didn't pick a hero and makes them lose
function LevelUpPlayers()
	for i, playerID in pairs(GetPlayerIDs()) do
    local player_entity = PlayerResource:GetSelectedHeroEntity(playerID)

    if player_entity then
      local levelup = function()
        player_entity:AddExperience(99999.0, 0, false, false)
      end

      local levelup_delay = 0.5

      Timers:CreateTimer(levelup_delay, levelup)
    else
      -- Make the player lose if they didn't pick a hero
      MakePlayerLose(playerID, "#duel_no_selected_hero")
    end
  end
end

-- Removes Town Portal Scrolls from players' inventories
-- One is added at the start of the game since 7.07, so this is called to delete it
function RemoveTPScroll()
  for i, playerID in pairs(GetPlayerIDs()) do
    local player_entity = PlayerResource:GetSelectedHeroEntity(playerID)

    if player_entity then
      for i=0,10 do
        local item = player_entity:GetItemInSlot(i)

        if item then
          local name = item:GetName()
          if name == "item_tpscroll" or name == "item_enchanted_mango" then
            item:Destroy()
          end
        end
      end
    else
      -- Make the player lose if they didn't pick a hero
      MakePlayerLose(playerID, "#duel_no_selected_hero")
    end
  end
end