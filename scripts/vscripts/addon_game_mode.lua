--[[
Dota RTS game mode

This file appears to be insane, variables here are default local, not global!
]]

print( "Dota RTS game mode loaded." )

if RTS == nil then
	_G.RTS = class({})
end

require( "abilities.ability_handler")
require( "abilities.commander_abilities")

-- Precache resources
function Precache( context )
	PrecacheUnitByNameSync( "npc_rts_building_hq", context )
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.RTS = RTS()
    GameRules.RTS:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function RTS:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetPreGameTime( 0.0 )

	GameMode:SetTowerBackdoorProtectionEnabled( false )

	-- Hook into game events
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( RTS, "OnEntKilled" ), self )

	-- Register Think
	-- GameMode:SetContextThink( "RTS:GameThink", function() return self:GameThink() end, 0.25 )
end

--------------------------------------------------------------------------------
function RTS:GameThink()
	return 0.25
end


function RTS:OnEntKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end

	for k,v in pairs( _G ) do
		Msg( tostring(k) .. "\n" )
		Msg( "    " .. tostring(v) .. "\n" )
	end

	if killedUnit:GetClassname() == "npc_dota_building" then
		for k,building in pairs( RTS.Buildings.List ) do
			if building.Entity:GetEntityIndex() == event.entindex_killed then
				table.remove( RTS.Buildings.List, k )
				break
			end
		end
	end
end
