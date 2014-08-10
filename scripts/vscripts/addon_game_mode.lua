--[[
Dota RTS game mode

This file appears to be insane, variables here are default local, not global!
]]

print( "Dota RTS game mode loaded." )

if RTS == nil then
	_G.RTS = class({})
end

-- Precache resources
function Precache( context )
	PrecacheUnitByNameSync( "npc_rts_building_hq", context )
	PrecacheUnitByNameSync( "npc_rts_unit_commander", context )
	PrecacheUnitByNameSync( "npc_rts_unit_worker", context )
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
	GameRules:SetPreGameTime( 0.0 )
	GameRules:SetTreeRegrowTime( 9999999.9 )

	GameMode:SetTowerBackdoorProtectionEnabled( false )
	GameMode:SetRecommendedItemsDisabled( true )
	GameMode:SetTopBarTeamValuesVisible( false )

	-- Hook into game events
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( RTS, "OnEntityKilled" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RTS, "OnNPCSpawned" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( RTS, "OnGameRulesStateChange" ), self )

	RTS.Abilities.InterruptChannelInit()

	-- Register Think
	-- GameMode:SetContextThink( "RTS.GameThink", function() return RTS.GameThink() end, 0.1 )
end

--------------------------------------------------------------------------------
function RTS:GameThink()
	return 0.1
end

function RTS:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end

	if killedUnit:GetClassname() == "npc_dota_building" then
		for k, building in pairs( RTS.Buildings.List ) do
			if building.Entity ~= nil then
				if building.Entity:GetEntityIndex() == event.entindex_killed then
					table.remove( RTS.Buildings.List, k )
					break
				end
			end
		end
	elseif killedUnit:GetClassname() == "npc_dota_creature" then
		for k, unit in pairs( RTS.Units.List ) do
			if unit.Entity ~= nil then
				if unit.Entity:GetEntityIndex() == event.entindex_killed then
					table.remove( RTS.Units.List, k )
					break
				end
			end
		end
	end
end

function RTS:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- TODO: Replace this with our own UI
		SendToConsole( "dota_sf_hud_channelbar 0" )
	end
end

require( "units.rts_unit_commander" )

function RTS:OnNPCSpawned( event )
	local npc = EntIndexToHScript( event.entindex )
	if not npc or npc:GetClassname() ~= "npc_dota_hero_abaddon" then
		return
	end

	npc:AddNewModifier( npc, nil, "modifier_invulnerable", {} )
	npc:AddNoDraw()
	npc:SetMoveCapability( 0 ) -- DOTA_UNIT_MOVE_CAP_NONE

	local commander = RTS.Units.Commander( npc:GetOrigin(), npc:GetOwner(), npc:GetTeam() )
	commander:DoComplete()
end

require( "abilities.ability_handler" )
require( "abilities.abilities" )