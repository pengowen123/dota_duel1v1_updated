-- Controls the rematch system to let players play against each other again

require('utils')
require('rematch_timer')
require('kills')
require('hero_select_timer')
require('round_timer')

-- Constants

-- Stores whether each player has voted to rematch
vote_rematch_data = {}


-- A listener for when a player votes to rematch
function OnVoteRematch(event_source_index, args)
	local id = args["id"]
	vote_rematch_data[id] = true

	local data = {}
	data.id = id

	CustomGameEventManager:Send_ServerToAllClients("player_vote_rematch_lua", data)

	if AllVotedRematch() then
		CustomGameEventManager:Send_ServerToAllClients("all_voted_rematch", nil)
		-- Hide the victory notification
    Notifications:ClearBottomFromAll()
    -- Prevent the game from ending because a rematch will happen
		rematch_timer = 0
		-- Prevent new rounds from starting
		round_start_timer = 0
		-- Start a timer for the hero select phase
		local game_start_delay = 30
		SetHeroSelectTimer(game_start_delay)
	end
end


-- Initializes the vote rematch data
function InitVoteRematchData()
	vote_rematch_data = {}

	for i, id in pairs(GetPlayerIDs()) do
		vote_rematch_data[id] = false

		-- Make bots always vote to rematch (the UI update happens in rounds.lua)
		if IsBot(id) then
			vote_rematch_data[id] = true
		end
	end
end


-- Returns whether all players have voted to rematch
function AllVotedRematch()
	for i, vote in pairs(vote_rematch_data) do
		if not vote then
			return false
		end
	end

	return true
end
