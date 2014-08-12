--[[
Dota RTS game mode

This file appears to be insane, variables here are default local, not global!
]]

print( "Dota RTS game mode loaded." )

if RTS == nil then
	_G.RTS = class({})
end

require( "utils.abilities" )
require( "utils.timer" )
require( "rts_resource_manager" )

-- Precache resources
function Precache( context )
	PrecacheUnitByNameSync( "npc_rts_building_hq", context )
	PrecacheUnitByNameSync( "npc_rts_building_barracks", context )
	PrecacheUnitByNameSync( "npc_rts_unit_commander", context )
	PrecacheUnitByNameSync( "npc_rts_unit_worker", context )
	PrecacheUnitByNameSync( "npc_rts_unit_lumberjack", context )
	PrecacheUnitByNameSync( "npc_rts_unit_soldier", context )
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
	GameRules:SetTreeRegrowTime( 1000000000 )

	GameMode:SetTowerBackdoorProtectionEnabled( false )
	GameMode:SetRecommendedItemsDisabled( true )
	GameMode:SetTopBarTeamValuesVisible( false )
	-- GameMode:SetCameraDistanceOverride( 2000 )

	-- Hook into game events
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( RTS, "OnEntityKilled" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RTS, "OnNPCSpawned" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( RTS, "OnGameRulesStateChange" ), self )

	RTS.Utils.Abilities.Init()
	RTS.Utils.Timer.Init()
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
		RTS.Resources.Init()
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
	npc:SetOrigin( Vector( 1000, 0, 0 ) )

	-- TODO: Get spawn point for player from info_player_start_goodguys/badguys
	local commander = RTS.Units.Commander( npc:GetOrigin(), npc:GetOwner(), npc:GetTeam() )
	commander:DoComplete()

	RTS.Utils.Timer.Register( function()
		commander.Entity:SetOrigin( npc:GetOrigin() )
		npc:SetOrigin( Vector( 0, 0, 10000 ) )
		end, 0.25 )
end

require( "abilities.ability_handler" )
require( "abilities.abilities" )